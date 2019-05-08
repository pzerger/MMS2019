#!/bin/bash
#
#
# Name:             deploy-stand-alone-linux-vm.sh 
#
# Author:           Ryan Irujo
# 
# Synopsis:         This script is used to deploy a Stand-Alone VM in Azure to a new subnet.
#
# Description:      This script is used to deploy a Stand-Alone VM in Azure.
#
#                   Syntax for running this script is detailed below or can be displayed by running:
#                   
#                   ./deploy-stand-alone-linux-vm.sh --help
#
#
#                   Once this script is executed, the following actions will occur:
#
#                   - Logging in to Azure as the Management Service Principal.
#                   - Setting the Azure Subscription to work with.
#                   - Making a copy of the 'vm-config-template.sh' script to work with.
#                   - Adding the Linux Username to the 'vm-config.sh' script.
#                   - Adding the Linux User Home Dir to the 'vm-config.sh' script.
#                   - Deploying the Self-Hosted Linux Agent in Azure.
#                   - Process Complete.
#
# Additional Notes: This script was designed to run on a Hosted Linux Agent in Azure DevOps (VSTS) from within a Build or Release. 
#                   Since a Build or Release provides a brand new Hosted Linux Agent for each iteration, this script has been made 
#                   to be as idempotent as possible.
#
#
# Parse Script Parameters.
while getopts "i:t:u:p:f:g:h:j:k:l:z:x:c:v:b:" opt; do
    case "${opt}" in
        i) # Azure Subscription ID.
             AZURE_SUBSCRIPTION_ID=${OPTARG}
             ;;
        t) # Azure Subscription Tenant ID.
             AZURE_SUBSCRIPTION_TENANT_ID=${OPTARG}
             ;;
        u) # Management Service Principal Username. This is used for managing Infrastructure as Code in an Azure Subscription.
             MGMT_SP_USERNAME=${OPTARG}
             ;;
        p) # Management Service Principal Password.
             MGMT_SP_PASSWORD=${OPTARG}
             ;;
        f) # The Name of the VM being deployed as a Self-Hosted Azure DevOps Agent.
             VM_NAME=${OPTARG}
             ;;
        g) # The VM Image to use to create the VM.
             VM_IMAGE=${OPTARG}
             ;;
        h) # The Name of the Resource Group where the VM is being deployed to.
             RESOURCE_GROUP_NAME=${OPTARG}
             ;;
        j) # The admin Linux Username of the VM.
             LINUX_USERNAME=${OPTARG}
             ;;
        k) # The '/home' directory path of the admin Linux Username.
             LINUX_USERNAME_HOME_DIR=${OPTARG}
             ;;
        c) # The VM SSH Public Key to use to login to the VM.
             VM_SSH_PUBLIC_KEY=${OPTARG}
             ;;
        v) # The VM OS Disk Size (GB).
             VM_OS_DISK_SIZE_GB=${OPTARG}
             ;;
        b) # The VM Size to Deploy.
             VM_SIZE=${OPTARG}
             ;;
        \?) # Unrecognised option - show help.
            echo -e \\n"Option [-${BOLD}$OPTARG${NORM}] is not allowed. All Valid Options are listed below:"
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
            exit 2
            ;;
    esac
done
shift $((OPTIND-1))

# Verifying the Script Parameters Values exist.
if [ -z "${AZURE_SUBSCRIPTION_ID}" ]; then
    echo "[$(date -u)][---fail---] The Azure Subscription ID must be provided."
    exit 2
fi

if [ -z "${AZURE_SUBSCRIPTION_TENANT_ID}" ]; then
    echo "[$(date -u)][---fail---] The Azure Subscription Tenant ID must be provided."
    exit 2
fi

if [ -z "${MGMT_SP_USERNAME}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Username must be provided."
    exit 2
fi

if [ -z "${MGMT_SP_PASSWORD}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Password must be provided."
    exit 2
fi

if [ -z "${VM_NAME}" ]; then
    echo "[$(date -u)][---fail---] The Name of the VM being deployed as a Self-Hosted Azure DevOps Agent must be provided."
    exit 2
fi

if [ -z "${VM_IMAGE}" ]; then
    echo "[$(date -u)][---fail---] The The VM Image to use to create the VM must be provided."
    exit 2
fi

if [ -z "${RESOURCE_GROUP_NAME}" ]; then
    echo "[$(date -u)][---fail---] The Name of the Resource Group where the VM is being deployed to must be provided."
    exit 2
fi

if [ -z "${LINUX_USERNAME}" ]; then
    echo "[$(date -u)][---fail---] The admin Linux Username of the VM must be provided."
    exit 2
fi

if [ -z "${LINUX_USERNAME_HOME_DIR}" ]; then
    echo "[$(date -u)][---fail---] The '/home' directory path of the admin Linux Username."
    exit 2
fi

if [ -z "${VM_SSH_PUBLIC_KEY}" ]; then
    echo "[$(date -u)][---fail---] The VM SSH Public Key to use to login to the VM must be provided."
    exit 2
fi

if [ -z "${VM_OS_DISK_SIZE_GB}" ]; then
    echo "[$(date -u)][---fail---] The VM OS Disk Size (GB) must be provided."
    exit 2
fi

if [ -z "${VM_SIZE}" ]; then
    echo "[$(date -u)][---fail---] The VM Size to Deploy must be provided."
    exit 2
fi

# Logging in to Azure as the Management Service Principal.
/usr/bin/az login \
--service-principal \
-u "http://$MGMT_SP_USERNAME" \
-p $MGMT_SP_PASSWORD \
--tenant $AZURE_SUBSCRIPTION_TENANT_ID > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Logged into Azure as the Management Service Principal [$MGMT_SP_USERNAME]."
else
    echo "[$(date -u)][---fail---] Failed to login to Azure as the Management Service Principal [$MGMT_SP_USERNAME]."
    exit 2
fi

# Setting the Azure Subscription to work with.
/usr/bin/az account set -s $AZURE_SUBSCRIPTION_ID

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Azure CLI set to Azure Subscription [$AZURE_SUBSCRIPTION_ID]."
else
    echo "[$(date -u)][---fail---] Failed to set Azure CLI to Azure Subscription [$AZURE_SUBSCRIPTION_ID]."
    exit 2
fi

# Making a copy of the 'vm-config-template.sh' script to work with.
cp $SYSTEM_DEFAULTWORKINGDIRECTORY/$RELEASE_PRIMARYARTIFACTSOURCEALIAS/azure_vm_scripts/vm-config-template.sh \
vm-config.sh

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Made a copy of the 'vm-config-template.sh' script called 'vm-config.sh'."
else
    echo "[$(date -u)][---fail---] Failed to make a copy of the 'vm-config-template.sh' script called 'vm-config.sh'."
    exit 2
fi

# Adding the Linux Username to the 'vm-config.sh' script.
sed -i -e "s/{LINUX_USERNAME}/$LINUX_USERNAME/" vm-config.sh

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Added the Linux Username [$LINUX_USERNAME] to 'vm-config.sh'."
else
    echo "[$(date -u)][---fail---] Failed to add the Linux Username [$LINUX_USERNAME] to 'vm-config.sh'."
    exit 2
fi

# Adding the Linux User Home Dir to the 'vm-config.sh' script.
sed -i -e "s~{LINUX_USERNAME_HOME_DIR}~$LINUX_USERNAME_HOME_DIR~" vm-config.sh

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Added the Linux User Home Dir [$LINUX_USERNAME_HOME_DIR] to 'vm-config.sh'."
else
    echo "[$(date -u)][---fail---] Failed to add the Linux User Home Dir [$LINUX_USERNAME_HOME_DIR] to 'vm-config.sh'."
    exit 2
fi

# Deploying the Self-Hosted Linux Agent in Azure.
/usr/bin/az vm create \
--name "$VM_NAME" \
--resource-group "$RESOURCE_GROUP_NAME" \
--image "$VM_IMAGE" \
--admin-username "$LINUX_USERNAME" \
--custom-data "vm-config.sh" \
--public-ip-address "$VM_NAME" \
--public-ip-address-dns-name "$VM_NAME" \
--nsg-rule ssh \
--os-disk-size-gb "$VM_OS_DISK_SIZE_GB" \
--size "$VM_SIZE" \
--ssh-key-value "$VM_SSH_PUBLIC_KEY" \
--vnet-name "$VM_NAME-vnet"

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Deployed the Azure VM [$VM_NAME] to Resource Group [$RESOURCE_GROUP_NAME]."
else
    echo "[$(date -u)][---fail---] Failed to deploy the Azure VM [$VM_NAME] to Resource Group [$RESOURCE_GROUP_NAME]."
    exit 2
fi

# Process Complete.
echo "[$(date -u)][---info---] Deployment of the Self-Hosted Linux Agent [$VM_NAME] is Complete."

