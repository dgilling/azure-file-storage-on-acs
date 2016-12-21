#!/bin/bash

#Install depenancies
apt-get install -y git cifs-utils build-essential

#Install Go -- used to compile the driver
wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
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
mv azurefile ../../azurefile

#Copy config up
cp contrib/init/upstart/azurefile-dockervolumedriver.conf ../../azurefile.conf

