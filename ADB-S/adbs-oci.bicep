param location string
param uamiId string
param keyVaultName string
param kvSecretName_ociConfig string
param kvSecretName_ociPrivateKey string
param ociRegion string
param adbsA_Ocid string
param adbsB_Ocid string
param subnetResourceId string

var useVnet = !empty(subnetResourceId)

@description('Promote adbs-a as elastic pool leader (OCI CLI update)')
resource scriptMakeLeader 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'oci-make-leader'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  properties: {
    azCliVersion: '2.63.0'
    retentionInterval: 'P1D'
    timeout: 'PT60M'
    cleanupPreference: 'OnSuccess'
    vnetSetting: useVnet ? {
      subnetResourceId: subnetResourceId
    } : null
    environmentVariables: [
      { name: 'KV_NAME', value: keyVaultName }
      { name: 'KV_SECRET_OCI_CONFIG', value: kvSecretName_ociConfig }
      { name: 'KV_SECRET_OCI_KEY', value: kvSecretName_ociPrivateKey }
      { name: 'OCI_REGION', value: ociRegion }
      { name: 'LEADER_ADB_OCID', value: adbsA_Ocid }
      { name: 'POOL_ECPU', value: '1024' } // adjust to your pool size
    ]
    scriptContent: '''
set -euo pipefail

# Pull OCI creds from Key Vault using the UAMI
OCI_CONFIG_TEXT=$(az keyvault secret show --vault-name "$KV_NAME" --name "$KV_SECRET_OCI_CONFIG" --query value -o tsv)
OCI_KEY_PEM=$(az keyvault secret show --vault-name "$KV_NAME" --name "$KV_SECRET_OCI_KEY" --query value -o tsv)

python3 -m pip install --upgrade oci-cli

mkdir -p ~/.oci
printf "%s" "$OCI_KEY_PEM" > ~/.oci/oci_api_key.pem
chmod 600 ~/.oci/oci_api_key.pem
printf "%s" "$OCI_CONFIG_TEXT" > ~/.oci/config
chmod 600 ~/.oci/config

# Enable/Configure elastic pool on the leader ADB.
# NOTE: Exact payload fields for elastic pools may vary by OCI CLI version. Two common patterns are shown:
#  (A) Explicit pool creation via elasticPool details
#  (B) Flagging the ADB as pool leader

set +e
RESP=$(oci db autonomous-database update \
  --autonomous-database-id "$LEADER_ADB_OCID" \
  --from-json "{\"elasticPool\":{\"ecpuCount\":$POOL_ECPU}}" \
  --wait-for-state AVAILABLE \
  --region "$OCI_REGION" 2>/dev/null)
RC=$?
set -e

if [ $RC -ne 0 ]; then
  # Fallback pattern
  RESP=$(oci db autonomous-database update \
    --autonomous-database-id "$LEADER_ADB_OCID" \
    --from-json '{"isElasticPoolLeader": true}' \
    --wait-for-state AVAILABLE \
    --region "$OCI_REGION")
fi

POOL_ID=$(echo "$RESP" | jq -r '.data["elastic-pool-id"] // empty')

jq -n --arg poolId "$POOL_ID" '{elasticPoolId: $poolId}' > "$AZ_SCRIPTS_OUTPUT_PATH"
'''
  }
}

@description('Join adbs-b to the elastic pool led by adbs-a (OCI CLI update)')
resource scriptJoin 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'oci-join-pool'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  properties: {
    azCliVersion: '2.63.0'
    retentionInterval: 'P1D'
    timeout: 'PT60M'
    cleanupPreference: 'OnSuccess'
    vnetSetting: useVnet ? {
      subnetResourceId: subnetResourceId
    } : null
    environmentVariables: [
      { name: 'KV_NAME', value: keyVaultName }
      { name: 'KV_SECRET_OCI_CONFIG', value: kvSecretName_ociConfig }
      { name: 'KV_SECRET_OCI_KEY', value: kvSecretName_ociPrivateKey }
      { name: 'OCI_REGION', value: ociRegion }
      { name: 'LEADER_ADB_OCID', value: adbsA_Ocid }
      { name: 'MEMBER_ADB_OCID', value: adbsB_Ocid }
      { name: 'ELASTIC_POOL_ID', value: scriptMakeLeader.properties.outputs.elasticPoolId }
    ]
    scriptContent: '''
set -euo pipefail

OCI_CONFIG_TEXT=$(az keyvault secret show --vault-name "$KV_NAME" --name "$KV_SECRET_OCI_CONFIG" --query value -o tsv)
OCI_KEY_PEM=$(az keyvault secret show --vault-name "$KV_NAME" --name "$KV_SECRET_OCI_KEY" --query value -o tsv)

python3 -m pip install --upgrade oci-cli

mkdir -p ~/.oci
printf "%s" "$OCI_KEY_PEM" > ~/.oci/oci_api_key.pem
chmod 600 ~/.oci/oci_api_key.pem
printf "%s" "$OCI_CONFIG_TEXT" > ~/.oci/config
chmod 600 ~/.oci/config

# Join member to pool - try with explicit pool id first, fallback to leader id
set +e
if [ -n "$ELASTIC_POOL_ID" ]; then
  oci db autonomous-database update \
    --autonomous-database-id "$MEMBER_ADB_OCID" \
    --from-json "{\"elasticPoolId\": \"$ELASTIC_POOL_ID\"}" \
    --wait-for-state AVAILABLE \
    --region "$OCI_REGION"
  RC=$?
else
  RC=1
fi

if [ $RC -ne 0 ]; then
  oci db autonomous-database update \
    --autonomous-database-id "$MEMBER_ADB_OCID" \
    --from-json "{\"joinElasticPoolLeaderId\": \"$LEADER_ADB_OCID\"}" \
    --wait-for-state AVAILABLE \
    --region "$OCI_REGION" || true
fi
set -e

jq -n --arg memberId "$MEMBER_ADB_OCID" '{joinedMemberId: $memberId}' > "$AZ_SCRIPTS_OUTPUT_PATH"
'''
    dependsOn: [ scriptMakeLeader ]
  }
}

output elasticPoolId string = scriptMakeLeader.properties.outputs.elasticPoolId
