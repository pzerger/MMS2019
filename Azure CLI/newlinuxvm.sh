
# SAMPLE with parameters
# ./newlinuxvm.sh "Visual Studio Enterprise" "pzubunturg" "southcentralus" "pzubuntu" "UbuntuLTS" "pzerger" "Lumagate2019!" "/subscriptions/5a359609-61ff-4446-98bf-b47117867ed8/resourceGroups/AlarisARM-VNET4/providers/Microsoft.Network/virtualNetworks/AlarisARM-VNET4/subnets/default"

# BEFORE YOU BEGIN: 
# Login from Azure CLI by typing 'az login'

# PARAMETERS: 
# AZURE_SUB="$1"
# RES_GRP="$2"
# LOC="$3" 
# SVR_NAME="$4"
# SKU="$5"
# ADMIN_USER="$6"
# ADMIN_PW="$7"
# SUBNET="$8"

AZURE_SUB="aaa8a52e-e487-4c7c-a73f-bb72d9ac65d2"
RES_GRP="swarmdev"
LOC="eastus" 
SVR_NAME="worker0"
SIZE="Standard_D4s_v3"
SKU="UbuntuLTS"
ADMIN_USER="pzerger"
ADMIN_PW="LumagateFTW!"
SUBNET="/subscriptions/aaa8a52e-e487-4c7c-a73f-bb72d9ac65d2/resourceGroups/swarmdev/providers/Microsoft.Network/virtualNetworks/swarmdev-vnet/subnets/default"

# Change current Azure subscription to desired
# Using ID (Guid) or Name is accepted
az account set --subscription "$AZURE_SUB"

# Create a resource group
az group create \
--name "$RES_GRP" \
--location "$LOC"

  # #########################################
  # Create an Ubuntu VM on EXISTING subnet
  # #########################################

# Create an Ubuntu VM 
# Creates VM with 2 x 10 GB data disks, attaches to existing subnet.
# Full list of az vm create parameters @ https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
# For a full list of Linux SKUs, see https://docs.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest#az-vm-image-list-skus
az vm create \
  --resource-group "$RES_GRP" \
  --name "$SVR_NAME" \
  --image "$SKU" \
  --size "$SIZE" \
  --subnet "/subscriptions/aaa8a52e-e487-4c7c-a73f-bb72d9ac65d2/resourceGroups/swarmdev/providers/Microsoft.Network/virtualNetworks/swarmdev-vnet/subnets/default" \
  --data-disk-sizes-gb 10 10 \
  --public-ip-address-dns-name "$SVR_NAME" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PW"
  
  # If you want SSH keys instead of pw, comment this line and uncomment the next
  #--generate-ssh-keys
 
  
  # #########################################
  # Instal software (run shell inside the VM)
  # #########################################
  
  # install nginx web server  
  # az vm run-command invoke -g "$RES_GRP"  -n "$SVR_NAME" --command-id RunShellScript --scripts "sudo apt-get update && sudo apt-get install -y nginx"
  
  # run other shell commands here 
  
  # NOTES
  
  # When connecting a VM to an existing subnet, you must specify the subnet ID as demonstrated above.
  # To get that value, use this query to get that value, replacing the VNETs resource group (-g) and --vnet-name with the name of the existing
  # az network vnet subnet show -g swarmdev --vnet-name swarmdev-vnet -n default -o tsv --query id

  # /subscriptions/0b62f50c-c15a-40e2-b1ab-7ac2596a1d74/resourceGroups/AlarisARM-VNETs/providers/Microsoft.Network/virtualNetworks/AlarisARM-VNET5/subnets/default
  # /subscriptions/aaa8a52e-e487-4c7c-a73f-bb72d9ac65d2/resourceGroups/swarmdev/providers/Microsoft.Network/virtualNetworks/swarmdev-vnet/subnets/default

#############################
# Open ports on NSG on VM NIC
#############################

# Allow PostGreSQL connections
# NOTE: This is OPTIONAL! pgAdmin can connect over SSH! 
# az network nsg rule create --resource-group $RESOURCE_GROUP_NAME \
# --nsg-name "${VM_NAME}nsg" \
# --name 'PostgreSQLInboundAllow' \
# --protocol both \
# --priority 1001 \
# --destination-port-range 5432 \