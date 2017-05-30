#!/bin/bash

#Detects the user
user=$(whoami)

kubectl get nodes | grep -o 'k8s-agent-.*-[0-9]*' | while read -r agent; do
    echo "Processing $agent"
    scp -o "StrictHostKeyChecking no" install-local-kubernetes.sh $user@$agent:~/
    ssh -o "StrictHostKeyChecking no" -n $user@$agent sudo sh ~/install-local-kubernetes.sh
    echo "Done $agent"
done
