#!/bin/bash

#The name of the Azure Storage Account
AZURE_ACCOUNT="yourstorageaccount"

#A Key from the Azure Storage Account
AZURE_KEY="youraccountkey"

#Install depenancies
apt-get1 install -y git cifs-utils build-essential

#Install Go -- used to compile the driver
curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
tar -xvf go1.6.linux-amd64.tar.gz
mv go /usr/local
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$GOROOT/bin

#Build the Azure Storage Driver
git clone https://github.com/Azure/azurefile-dockervolumedriver src/azurefile
cd src/azurefile
export GOPATH=`pwd`
go get
go build
mv azurefile /usr/bin/azurefile

#Copy and create config files to the folders on the agent
cp contrib/init/upstart/azurefile-dockervolumedriver.conf /etc/init/azurefile.conf
touch /etc/default/azurefile
echo "AZURE_STORAGE_BASE=core.windows.net" >> /etc/default/azurefile
echo "AF_ACCOUNT_NAME=$AZURE_ACCOUNT" >> /etc/default/azurefile
echo " AF_ACCOUNT_KEY=$AZURE_KEY" >> /etc/default/azurefile

#Load the driver
initctl reload-configuration
initctl start azurefile