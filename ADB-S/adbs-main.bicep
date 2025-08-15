param keyVaultName string = 'akv-uk-01'
param owner string = 'Steven Chan'


// Prepare to get secret from existing AKV
resource akv 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

// Create the ADBS as the leader of the elastic pool
module adbsEpLeader 'adbs-az.bicep' = {
  name: 'adbs01'
  params: {
    location: resourceGroup().location
    owner: owner
    purpose: 'Elastic Pool Leader for ADB-S via Bicep and OCI CLI'
    env: 'POC'
    adbsName: 'adbs01'
    dbapw: akv.getSecret('oci-adbs-adminpw')
  }
}

// Set the elastic pool leader via OCI CLI
@description('Promote the ADB-S as elastic pool leader (OCI CLI update)')
module becomeEpLeader 'adbs-oci.bicep' = {
  name: 'asdb01-AsEpLeader'
  params: {
    deploymentScriptsName: 'becomeEpLeader'
    ociFingerprint: akv.getSecret('oci-fingerprint')
    ociUser: akv.getSecret('oci-user-ocid')
    ociTenancy: akv.getSecret('oci-tenancy-ocid')
    ociKeyContent: akv.getSecret('oci-api-key')
    adbsName: adbsEpLeader.name
    elasticPoolIsDisabled: 'null'
    elasticPoolEcpuCount : '128'
  }
}

// Create the ADBS as member of the elastic pool
module adbsEpMember 'adbs-az.bicep' = {
  name: 'adbs02'
  params: {
    location: resourceGroup().location
    owner: owner
    purpose: 'Elastic Pool Member for ADB-S via Bicep and OCI CLI'
    env: 'POC'
    adbsName: 'adbs02'
    dbapw: akv.getSecret('oci-adbs-adminpw')
  }
}

// Set the ADBS to join the elastic pool leader via OCI CLI
module becomeEpMember 'adbs-oci.bicep' = {
  name: 'adbs02-AsEpMember'
  params: {
    deploymentScriptsName: 'becomeEpMember'
    ociFingerprint: akv.getSecret('oci-fingerprint')
    ociUser: akv.getSecret('oci-user-ocid')
    ociTenancy: akv.getSecret('oci-tenancy-ocid')
    ociKeyContent: akv.getSecret('oci-api-key')
    adbsName: adbsEpMember.outputs.adbs_name
    elasticPoolResourcePoolLeaderId : adbsEpLeader.outputs.adbs_Ocid
  }
}
