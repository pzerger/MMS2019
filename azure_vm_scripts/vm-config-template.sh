#!/bin/bash
#
#
# Name:             self-hosted-agent-ubuntu-16.04-lts-template.sh
#
# Author:           Ryan Irujo 
# 
# Synopsis:         This script adds the required configurations, tools, and features to a Linux VM in Azure.
#
# Description:      This script adds the required configurations, tools, and features to a Linux VM in Azure.
#
#                   Syntax for running this script is detailed below or can be displayed by running:
#                   
#                   ./self-hosted-agent-ubuntu-16.04-lts-template.sh --help
#
#
#                   Once this script is executed, the following actions will occur:
#
#                   - Setting up the Hostname variable.
#                   - Configuring Log Files.
#                   - Updating the local apt database.
#                   - Installing standard packages via apt-get.
#                   - Checking to see if Azure CLI is installed.
#                       - Installing the Azure CLI.
#                   - Checking to see if Kubectl is installed.
#                       - Installing Kubectl.
#                   - Checking to see if Helm is installed.
#                       - Checking to see if the latest version of Helm is installed.
#                           - Installing the Latest Version of Helm.
#                       - Installing the Latest Version of Helm.
#                   - Installing .NET Core 2.0 SDK and Runtime.
#                   - Configuring 'vim' editor.
#
# Additional Notes: This script was designed to run on a Self-Hosted Linux Agent in Azure DevOps (VSTS) from within a Build or Release.
#
#

# Parameters that are passed in via 'sed' from the 'deploy-self-hosted-agent-ubuntu-16.04-lts.sh' Bash Script.
LINUX_USERNAME="{LINUX_USERNAME}"
LINUX_USERNAME_HOME_DIR="{LINUX_USERNAME_HOME_DIR}"
AZURE_DEVOPS_URL="{AZURE_DEVOPS_URL}"
AZURE_DEVOPS_AGENT_POOL="{AZURE_DEVOPS_AGENT_POOL}"
AZURE_DEVOPS_PAT_TOKEN="{AZURE_DEVOPS_PAT_TOKEN}"

# Setting up the Hostname variable.
HOSTNAME=$(cat /etc/hostname)

# Configuring Log Files.
UPDATE_PACKAGES_STATUS_LOG="$LINUX_USERNAME_HOME_DIR/update-packages.log"
CONFIG_AGENT_STATUS_LOG="$LINUX_USERNAME_HOME_DIR/setup-agent-status.log"
AGENT_INSTALLATION_LOG="$LINUX_USERNAME_HOME_DIR/agent-install.log"

# Updating the local apt database.
sudo apt-get update -y > $UPDATE_PACKAGES_STATUS_LOG

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Apt database updated." >> $CONFIG_AGENT_STATUS_LOG
else
    echo "[$(date -u)][---fail---] Failed to updated Apt database." >> $CONFIG_AGENT_STATUS_LOG
fi

# Installing standard packages via apt-get.
sudo apt-get install -y \
apt-transport-https \
build-essential \
cmake \
curl \
docker \
docker.io \
expect \
dos2unix \
git \
jq \
nodejs \
vim \
unzip >> $UPDATE_PACKAGES_STATUS_LOG

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Packages installed via apt-get." >> $CONFIG_AGENT_STATUS_LOG
else
    echo "[$(date -u)][---fail---] Failed to install packages via apt-get." >> $CONFIG_AGENT_STATUS_LOG
fi

# Checking to see if Azure CLI is installed.
/usr/bin/az --version | grep azure-cli > /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---info---] Azure CLI is already installed." >> $CONFIG_AGENT_STATUS_LOG
else
    echo "[$(date -u)][---info---] Azure CLI is not installed." >> $CONFIG_AGENT_STATUS_LOG

    # Installing the Azure CLI.
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -s -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    sudo apt-get install -y apt-transport-https && \
    sudo apt-get update && \
    sudo apt-get install -y azure-cli > /dev/null 2>&0

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed Azure CLI." >> $CONFIG_AGENT_STATUS_LOG
    else
        echo "[$(date -u)][---fail---] Failed to install Azure CLI." >> $CONFIG_AGENT_STATUS_LOG
        exit 2
    fi
fi

# Checking to see if Kubectl is installed.
/usr/local/bin/kubectl version > /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---info---] kubectl is already installed." >> $CONFIG_AGENT_STATUS_LOG
else
    echo "[$(date -u)][---info---] kubectl is not installed." >> $CONFIG_AGENT_STATUS_LOG

    # Installing Kubectl.
    curl -s -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl > /dev/null 2>&0

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed Kubectl." >> $CONFIG_AGENT_STATUS_LOG
    else
        echo "[$(date -u)][---fail---] Failed to install Kubectl." >> $CONFIG_AGENT_STATUS_LOG
        exit 2
    fi
fi

# Retrieving the latest version of Helm.
HELM_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/helm/helm/releases/latest" | grep tag_name | awk '{print $2}' | tr -d '"' | tr -d ',')

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---info---] Retrieved the latest version of Helm [$HELM_LATEST_VERSION]."
else
    echo "[$(date -u)][---info---] Failed to retrieve the latest version of Helm [$HELM_LATEST_VERSION]."
    exit 2
fi

# Checking to see if Helm is installed.
if [ -e "/usr/local/bin/helm" ]; then
    echo "[$(date -u)][---info---] Helm is already installed."

    # Checking to see if the latest version of Helm is installed.
    HELM_VERSION_INSTALLED=$(/usr/local/bin/helm version -c --short)

    if [[ "$HELM_VERSION_INSTALLED" =~ "$HELM_LATEST_VERSION" ]]; then
        echo "[$(date -u)][---info---] Latest version of Helm [$HELM_LATEST_VERSION] is already installed."
    else
        echo "[$(date -u)][---info---] Currently using Helm [$HELM_VERSION_INSTALLED]. Installing the latest version of Helm [$HELM_LATEST_VERSION]."

        # Installing the Latest Version of Helm.
        wget -q https://storage.googleapis.com/kubernetes-helm/helm-$HELM_LATEST_VERSION-linux-amd64.tar.gz &&
        tar -xzf helm-$HELM_LATEST_VERSION-linux-amd64.tar.gz &&
        sudo mv linux-amd64/helm /usr/local/bin/helm &&
        sudo chmod 775 /usr/local/bin/helm > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---success---] Installed Helm [$HELM_LATEST_VERSION]."
        else
            echo "[$(date -u)][---fail---] Failed to install Helm [$HELM_LATEST_VERSION]."
            exit 2
        fi
    fi
else
    echo "[$(date -u)][---info---] Helm is not installed."
    echo "[$(date -u)][---info---] Installing the latest version of Helm [$HELM_LATEST_VERSION]."

    # Installing the Latest Version of Helm.
    wget -q https://storage.googleapis.com/kubernetes-helm/helm-$HELM_LATEST_VERSION-linux-amd64.tar.gz &&
    tar -xzf helm-$HELM_LATEST_VERSION-linux-amd64.tar.gz &&
    sudo mv linux-amd64/helm /usr/local/bin/helm &&
    sudo chmod 775 /usr/local/bin/helm > /dev/null 2>&1


    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed Helm [$HELM_LATEST_VERSION]."
    else
        echo "[$(date -u)][---fail---] Failed to install Helm [$HELM_LATEST_VERSION]."
        exit 2
    fi
fi

# Installing .NET Core 2.0 SDK and Runtime.
wget -nv https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb && \
sudo dpkg -i packages-microsoft-prod.deb && \
sudo apt-get install -y apt-transport-https && \
sudo apt-get update -y && \
sudo apt-get install -y dotnet-sdk-2.1 && \
sudo apt-get install -y aspnetcore-runtime-2.1> /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---info---] Installed .NET Core 2.0 SDK and Runtime." >> $CONFIG_AGENT_STATUS_LOG
else
    echo "[$(date -u)][---info---] Failed to install .NET Core 2.0 SDK and Runtime" >> $CONFIG_AGENT_STATUS_LOG
fi

# Configuring 'vim' editor.
sed -i -e '$ a :color elflord' /etc/vim/vimrc && \
sed -i -e '$ a set pastetoggle=<F2>' /etc/vim/vimrc

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---info---] added custom vim settings." >> $CONFIG_AGENT_STATUS_LOG
else
    echo "[$(date -u)][---info---] failed to add custom vim settings." >> $CONFIG_AGENT_STATUS_LOG
fi

# Process Complete.
echo "[$(date -u)][---info---] Setup of the Self-Hosted Linux Agent is Complete."