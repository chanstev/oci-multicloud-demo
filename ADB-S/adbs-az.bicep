param location string
param keyVaultId string
param keyVaultName string
param uamiName string
@secure()
param adbAdminPassword string
param dbVersion string
param dbWorkload string
param adbsAName string
param adbsBName string
param adbsAEcpu int
param adbsBEcpu int

// --- Managed Identity + KV RBAC ---
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uamiName
  location: location
}

// Built-in role: Key Vault Secrets User
var kvSecretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource kvSecretsUserRA 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultId, uami.id, 'kv-secrets-user')
  scope: keyVaultId
  properties: {
    roleDefinitionId: kvSecretsUserRoleId
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// --- ADB-S: adbs-a (leader-to-be) ---
resource adbsA 'Oracle.Database/autonomousDatabases@2025-03-01' = {
  name: adbsAName
  location: location
  properties: {
    dataBaseType: 'Regular'
    displayName: adbsAName
    adminPassword: adbAdminPassword
    dbWorkload: dbWorkload // OLTP | DW | AJD | APEX
    dbVersion: dbVersion
    computeModel: 'ECPU'
    computeCount: adbsAEcpu
    isAutoScalingEnabled: false
  }
}

// --- ADB-S: adbs-b (member-to-be) ---
resource adbsB 'Oracle.Database/autonomousDatabases@2025-03-01' = {
  name: adbsBName
  location: location
  properties: {
    dataBaseType: 'Regular'
    displayName: adbsBName
    adminPassword: adbAdminPassword
    dbWorkload: dbWorkload
    dbVersion: dbVersion
    computeModel: 'ECPU'
    computeCount: adbsBEcpu
    isAutoScalingEnabled: false
  }
  dependsOn: [ adbsA ]
}

// OCIDs exposed by the Azure-native resource (used by OCI CLI)
var adbsA_Ocid = adbsA.properties.autonomousDatabaseId
var adbsB_Ocid = adbsB.properties.autonomousDatabaseId

output uamiId string = uami.id
output adbsA_ResourceId string = adbsA.id
output adbsB_ResourceId string = adbsB.id
output adbsA_Ocid string = adbsA_Ocid
output adbsB_Ocid string = adbsB_Ocid
