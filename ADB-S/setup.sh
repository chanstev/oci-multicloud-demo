# Login Azure CLI
az login 
# Uncomment the following lines to set up Azure CLI with your service principal credentials
# export ARM_CLIENT_ID="your_client_id"
# export ARM_CLIENT_SECRET="your_client_secret"
# export ARM_TENANT_ID="your_tenant_id"
# export ARM_SUBSCRIPTION_ID="your_subscription_id"
# az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID
# az account set -s $ARM_SUBSCRIPTION_ID

# create resource group and Key Vault
export resourceGroupName='your-resource-group-name'
export location='uksouth'
export keyvaultName='your-keyvault-name'
az group create --name ${resourceGroupName} --location ${location}
az keyvault create --name ${keyvaultName} --resource-group ${resourceGroupName} --location ${location} --enabled-for-template-deployment true --sku standard

# Set up secrets in Key Vault
# OCI CLI environment variables
export OCI_CLI_TENANCY="ocid1.tenancy.oc1..xxxxx"
export OCI_CLI_USER="ocid1.user.oc1..xxxxx"
export OCI_CLI_FINGERPRINT="your_fingerprint"
export OCI_CLI_KEY_FILE="your_key_file_path.pem"
export ADBS_PW='your_db_password'

# uncomment the following line to check OCI access
# oci iam tenancy get --tenancy-id $OCI_CLI_TENANCY --output table --query "data.{Name:name, OCID:id}" --auth api_key
az keyvault secret set --vault-name ${keyvaultName} --name "oci-tenancy-ocid" --value "${OCI_CLI_TENANCY}" 
az keyvault secret set --vault-name ${keyvaultName} --name "oci-user-ocid" --value "{$OCI_CLI_USER}" 
az keyvault secret set --vault-name ${keyvaultName} --name "oci-fingerprint" --value "{$OCI_CLI_FINGERPRINT}" 
az keyvault secret set --vault-name ${keyvaultName} --name "oci-api-key" --file $OCI_CLI_KEY_FILE 
az keyvault secret set --vault-name ${keyvaultName} --name "oci-adbs-adminpw" --value $ADBS_PW 