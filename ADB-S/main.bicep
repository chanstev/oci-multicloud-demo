@description('Azure location for deployment resources (deploymentScripts, identities, etc.)')
param location string = resourceGroup().location

@description('Resource ID of an existing Azure Key Vault that holds OCI credentials (and optionally the ADB admin password).')
param keyVaultId string

@description('Name of the Key Vault (for az keyvault commands inside deploymentScripts)')
param keyVaultName string

@description('Secret name in Key Vault that contains the OCI CLI config text (INI)')
param kvSecretName_ociConfig string = 'oci-config'

@description('Secret name in Key Vault that contains the OCI API private key (PEM)')
param kvSecretName_ociPrivateKey string = 'oci-privatekey'

@description('ADB ADMIN password (pass via parameter file as a Key Vault reference)')
@secure()
param adbAdminPassword string

@description('OCI region identifier for Oracle Database@Azure (e.g., "uk-london-1-azr"). Must match your tenancy setup.')
param ociRegion string

@description('Display name / DB name for the first ADB (future pool leader)')
param adbsAName string = 'adbs-a'

@description('Display name / DB name for the second ADB (pool member)')
param adbsBName string = 'adbs-b'

@description('ECPU count to allocate to adbs-a at creation')
param adbsAEcpu int = 64

@description('ECPU count to allocate to adbs-b at creation (initial)')
param adbsBEcpu int = 1

@description('Autonomous Database workload: OLTP | DW | AJD | APEX')
param dbWorkload string = 'OLTP'

@description('A valid Autonomous DB version (see Oracle.Database/locations/autonomousDbVersions)')
param dbVersion string

@description('User-Assigned Managed Identity name to create for deployment scripts')
param uamiName string = 'adb-oci-uami'

@description('(Optional) Subnet to attach deploymentScripts container to (for egress control). Leave empty to skip.')
param subnetResourceId string = ''

module createAz 'adbs-az.bicep' = {
  name: 'create-az-adbs'
  params: {
    location: location
    keyVaultId: keyVaultId
    keyVaultName: keyVaultName
    uamiName: uamiName
    adbAdminPassword: adbAdminPassword
    dbVersion: dbVersion
    dbWorkload: dbWorkload
    adbsAName: adbsAName
    adbsBName: adbsBName
    adbsAEcpu: adbsAEcpu
    adbsBEcpu: adbsBEcpu
  }
}

module ociOps 'adbs-oci.bicep' = {
  name: 'oci-elastic-pool-ops'
  params: {
    location: location
    uamiId: createAz.outputs.uamiId
    keyVaultName: keyVaultName
    kvSecretName_ociConfig: kvSecretName_ociConfig
    kvSecretName_ociPrivateKey: kvSecretName_ociPrivateKey
    ociRegion: ociRegion
    adbsA_Ocid: createAz.outputs.adbsA_Ocid
    adbsB_Ocid: createAz.outputs.adbsB_Ocid
    subnetResourceId: subnetResourceId
  }
}

output adbsAResourceId string = createAz.outputs.adbsA_ResourceId
output adbsBResourceId string = createAz.outputs.adbsB_ResourceId
output adbsA_Ocid string = createAz.outputs.adbsA_Ocid
output adbsB_Ocid string = createAz.outputs.adbsB_Ocid
output elasticPoolId string = ociOps.outputs.elasticPoolId