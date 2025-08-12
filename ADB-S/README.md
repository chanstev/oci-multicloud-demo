# Azure Bicep – ADB@Azure Creation + OCI CLI Elastic Pool Ops

## Overview
This solution uses **Azure-native** resource type `Oracle.Database/autonomousDatabases` to create two Autonomous Databases in Oracle Database@Azure, then uses **OCI CLI** (triggered via Azure `deploymentScripts`) to:
1. Promote the first DB (`adbs-a`) to be an **elastic pool leader**.
2. Join the second DB (`adbs-b`) to that elastic pool.

## Prerequisites
- An existing Azure Key Vault with:
  - `oci-config` – OCI CLI INI config content.
  - `oci-privatekey` – OCI API private key PEM.
  - `adb-admin-password` – ADMIN user password for both DBs.
- Azure subscription with [Oracle Database@Azure](https://learn.microsoft.com/azure/oracle-database/) enabled.
- Appropriate OCI tenancy/region mapping for Database@Azure.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed.

## Deploy
```bash
# Log in to Azure
az login

# Set subscription
az account set --subscription <subId>

# Deploy using the provided parameters.json
az deployment group create \
  --resource-group <rgName> \
  --template-file main.bicep \
  --parameters @parameters.json
```

## Outputs
- `adbsAResourceId` – Azure resource ID for `adbs-a`.
- `adbsBResourceId` – Azure resource ID for `adbs-b`.
- `adbsA_Ocid` – OCI OCID for `adbs-a`.
- `adbsB_Ocid` – OCI OCID for `adbs-b`.
- `elasticPoolId` – Elastic pool OCID (if returned by OCI CLI update).

## Notes
- The OCI CLI update payloads for enabling elastic pools can differ by OCI version and tenancy setup. Adjust the JSON in `adbs-oci.bicep` if required.
- `subnetResourceId` is optional—set if your environment requires deployment scripts to run inside a VNet.
