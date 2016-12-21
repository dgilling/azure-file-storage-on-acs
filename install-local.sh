#!/bin/bash

#The name of the Azure Storage Account
AZURE_ACCOUNT="yourstorageaccount"

#A Key from the Azure Storage Account
AZURE_KEY="youraccountkey"


#Install depenancies
apt-get1 install -y cifs-utils

#Copy and create config files to the folders on the agent
cp azurefile.conf /etc/init/azurefile.conf
touch /etc/default/azurefile
echo "AZURE_STORAGE_BASE=core.windows.net" >> /etc/default/azurefile
echo "AF_ACCOUNT_NAME=$AZURE_ACCOUNT" >> /etc/default/azurefile
echo " AF_ACCOUNT_KEY=$AZURE_KEY" >> /etc/default/azurefile

#Load the driver
initctl reload-configuration
initctl start azurefile