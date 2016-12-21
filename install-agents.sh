#!/bin/bash

#Detects the user
user=$(whoami)

#Loops over each of the swarm nodes and installs the driver on each node
docker -H 127.0.0.1:2375 info | grep -oP '(?:[0-9]{1,3}\.){3}[0-9]{1,3}' | while read -r ip ; do
    echo "Processing $ip"
    scp -o "StrictHostKeyChecking no" install-local.sh azurefile azurefile.conf $user@$ip:~/
    ssh -o "StrictHostKeyChecking no" -n $user@$ip sudo sh ~/install-local.sh
    echo "Done $ip"
done
