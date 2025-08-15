param deploymentScriptsName string = 'ociCli-adbs-update'
param location string = resourceGroup().location
param adbsName string
param timeoutInMinutes string = '15' // how long to wait for ADB-S to be available before failing the script

@description('OCID of elastic pool leader, for elastic pool member only')
param elasticPoolResourcePoolLeaderId string = 'null'

@description('Elastic Pool is disabled or not, for elastic pool leader only')
@allowed([
  'null'
  'true'
])
param elasticPoolIsDisabled string = 'true'

@description('Elastic Pool ECPU count, for elastic pool leader only')
@allowed([
  'null'
  '128'
  '256'
  '512'
  '1024'
  '2048'
  '4096'
])
param elasticPoolEcpuCount string = 'null'

@secure()
param ociFingerprint string
@secure()
param ociUser string
@secure()
param ociTenancy string
@secure()
param ociKeyContent string

resource adbsAzRes 'Oracle.Database/autonomousDatabases@2025-03-01' existing = {
  name: adbsName
  scope: resourceGroup()
}

var scriptContentParam = {
  adbsOcid: adbsAzRes.properties.ocid
  adbsOciRegion: split(adbsAzRes.properties.ocid, '.')[3]
  timeoutInMinutes: timeoutInMinutes
  elasticPoolResourcePoolLeaderId: elasticPoolResourcePoolLeaderId
  elasticPoolIsDisabled: elasticPoolIsDisabled
  elasticPoolEcpuCount: elasticPoolEcpuCount
  // JSON configuration for the ADB-S update (elasticPoolResourcePoolLeaderId is only used for member, resource-pool-summary is only used for leader)
  json_config: elasticPoolResourcePoolLeaderId != 'null' ? '{"resource-pool-leader-id":"${elasticPoolResourcePoolLeaderId}"}' : '{"resource-pool-summary":{"is-disabled":${elasticPoolIsDisabled}, "pool-size":${elasticPoolEcpuCount}}}'
}

var scriptContentTemplate = '''
set -euo pipefail

# Install OCI CLI
apk add --no-cache coreutils
curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh -o install.sh
chmod +x install.sh
bash install.sh --accept-all-defaults
export PATH="$PATH:/root/bin"

# Wait for ADB-S to be available
echo "Waiting for ADB-S to be available..."
timeout ${timeoutInMinutes}m bash -lc "until (($(oci db autonomous-database get --region uk-london-1 --autonomous-database-id ${adbsOcid} --query 'data."lifecycle-state"' | grep -c 'AVAILABLE') > 0)); do printf . ;sleep 5; done"

# Wait for elastic pool leader to be available
[[ $(echo ${elasticPoolResourcePoolLeaderId} | wc -m) -gt 26 ]] && timeout ${timeoutInMinutes}m bash -lc "until (($(oci db autonomous-database get --region uk-london-1 --autonomous-database-id ${elasticPoolResourcePoolLeaderId} --query 'data."lifecycle-state"' | grep -c 'AVAILABLE') > 0)); do printf . ;sleep 5; done"

# Set the ADB-S as elastic pool leader or member
oci db autonomous-database update \
  --autonomous-database-id ${adbsOcid} \
  --region ${adbsOciRegion} --wait-for-state AVAILABLE \
  --from-json '${json_config}' \
  --force --query data --output json | jq > $AZ_SCRIPTS_OUTPUT_PATH
'''

resource ociCli 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptsName
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    retentionInterval: 'PT1H'
    environmentVariables: [
      { name: 'OCI_CLI_TENANCY', secureValue: ociTenancy}
      { name: 'OCI_CLI_USER', secureValue: ociUser }
      { name: 'OCI_CLI_FINGERPRINT', secureValue: ociFingerprint}
      { name: 'OCI_CLI_KEY_CONTENT', secureValue: ociKeyContent }
    ]
    scriptContent: reduce(
        items(scriptContentParam),
        {value: scriptContentTemplate},
        (curr, next) => {value: replace(curr.value, '\${${next.key}}', next.value)}
      ).value
  }
}
