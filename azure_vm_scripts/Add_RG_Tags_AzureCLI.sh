
# For resource tags, double-quotes on the variables is the right way.
RES_TAGS="ServiceClass:Critical EnvID:PROD BillingID:TBD OrgID:ERP OwnerID:peter.piela@kodakalaris.com"
az group create --name 'pzrgtest' --location 'eastus' --tags $RES_TAGS

az group create --name 'pzrgtest' --location 'eastus' --tags ServiceClass:Critical EnvID:PROD BillingID:TBD OrgID:ERP OwnerID:peter.pie


./deploy-stand-alone-linux-vm.sh -i AZURE_SUBSCRIPTION_ID -u MGMT_SP_USERNAME -p MGMT_SP_PASSWORD -f VM_NAME -g VM_IMAGE -h RESOURCE_GROUP_NAME -j LINUX_USERNAME -k LINUX_USERNAME_HOME_DIR -c VM_SSH_PUBLIC_KEY -v VM_OS_DISK_SIZE_GB -b VM_SIZE -l LOCATION -r RES_TAGS

./deploy-stand-alone-linux-vm.sh -i 0b62f50c-c15a-40e2-b1ab-7ac2596a1d74 -t cf5b57b5-3bce-46f1-82b0-396341247817 -u aif-cluster-mgmt-k8s -p '}-&(/[@&!a&+d+_]!8>#^|D$d' -f pzlinux01 -g UbuntuLTS  -h pzrglintest -j linuxadmin -k /home/linuxadmin -c "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqywmlyS+w6LBkOEIUOfGRHjmm8Sdvz1uouAJYWwjTQuYZ/+7px9cukLhPZFnM82ESH6d76O0Rmmb6+HBxU7+4oL1KZwJsHjVzjPVb8fh3jPt2u23Rr7O9AmubpLsfZfZIX1+Vz6iZh3/QDGHCjGcVQIaGJWL4BFRoozWvkEqtxA4Izn86O/U/sqTljP7g0UoE8Cn0yM6/lLufJJa1pNjr+ZnCt4HkJk3/reWy/WWEf1Hken5ZCgjH2k+3rel7j+PKoHwJN8tkWe0ZNLVd5t8P9V7PUy/v6OcKt0tz9h9nV3oTP7gGmHroUDKsSebVbWmZfs9vMIKM8g2tytJl7QfbQ== rsa-key-20181206" -v 128 -b Standard_DS2_v2 -l southcentralus -x "ServiceClass:Critical EnvID:PROD BillingID:TBD OrgID:ERP OwnerID:peter.piela@kodakalaris.com"

-y ""/subscriptions/0b62f50c-c15a-40e2-b1ab-7ac2596a1d74/resourceGroups/AlarisARM-VNETs/providers/Microsoft.Network/virtualNetworks/AlarisARM-VNET5/subnets/default""

            echo -e "-i AZURE_SUBSCRIPTION_ID            - The Azure Subscription ID."
            echo -e "-t AZURE_SUBSCRIPTION_TENANT_ID     - The Azure Subscription Tenant ID."
            echo -e "-u MGMT_SP_USERNAME                 - Management Service Principal Username. This is used for managing Infrastructure as Code in an Azure Subscription."
            echo -e "-p MGMT_SP_PASSWORD                 - Management Service Principal Password."
            echo -e "-f VM_NAME                          - The Name of the VM being deployed as a Self-Hosted Azure DevOps Agent."
            echo -e "-g VM_IMAGE                         - The VM Image to use to create the VM."
            echo -e "-h RESOURCE_GROUP_NAME              - The Name of the Resource Group where the VM is being deployed to."
            echo -e "-j LINUX_USERNAME                   - The admin Linux Username of the VM."
            echo -e "-k LINUX_USERNAME_HOME_DIR          - The '/home' directory path of the admin Linux Username."
            echo -e "-c VM_SSH_PUBLIC_KEY                - The VM SSH Public Key to use to login to the VM."
            echo -e "-v VM_OS_DISK_SIZE_GB               - The VM OS Disk Size (GB)."
            echo -e "-b VM_SIZE                          - The VM Size to Deploy."
            echo -e "-l LOCATION                          - The Azure region target for deployment."
            echo -e "-r RES_TAGS                          - The resource tags to apply to the Resource Group."