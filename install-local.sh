#!/bin/bash

#The name of the Azure Storage Account
AZURE_ACCOUNT="youraccountname"

#A Key from the Azure Storage Account
AZURE_KEY="yourkey"


#Install depenancies
apt-get install -y cifs-utils

#Copy and create config files to the folders on the agent
mv azurefile /usr/bin/azurefile
cp azurefile.conf /etc/init/azurefile.conf
touch /etc/default/azurefile
echo "AZURE_STORAGE_BASE=core.windows.net" >> /etc/default/azurefile
echo "AF_ACCOUNT_NAME=$AZURE_ACCOUNT" >> /etc/default/azurefile
echo " AF_ACCOUNT_KEY=$AZURE_KEY" >> /etc/default/azurefile

#Load the driver
initctl reload-configuration
initctl start azurefile
