param location string = 'uksouth'
param owner string = 'Steven Chan'
param purpose string = 'POC of Provisioning ADB-S with Elastic Pool via Bicep'
param env string = 'POC'

param adbsName string 
@secure()
param dbapw string

resource adbs 'Oracle.Database/autonomousDatabases@2025-03-01' = {
  name: adbsName
  location: location
  tags: {
    Owner: owner
    Environment: env
    Purpose: purpose
  }
  properties: {
    dataBaseType: 'Regular'
    displayName: adbsName
    adminPassword: dbapw
    dbWorkload: 'OLTP' 
    dbVersion: '23ai'
    computeModel: 'ECPU'
    computeCount: json('2')
    isAutoScalingEnabled: false
    isMtlsConnectionRequired: true
    dataStorageSizeInTbs: 1
    licenseModel: 'BringYourOwnLicense'

  }
}

output adbs_Ocid string = adbs.properties.ocid
output adbs_ociUrl string = adbs.properties.ociUrl
output adbs_name string = adbs.name
