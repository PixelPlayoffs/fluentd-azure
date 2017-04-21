#!/bin/bash

export AZ_HOSTNAME='ipdockervm'
export AZ_RGROUP='fluentd-azure'
export AZ_DNSNAME=$AZ_HOSTNAME
export AZ_DNSPATH='eastus.cloudapp.azure.com'
export AZ_DNSFQDN="$AZ_DNSNAME.$AZ_DNSPATH"

log () {
  echo "$1"
}

# Create a resource group
# az group create -n $AZ_RGROUP -l eastus

# Create a VM
log "Creating vm: $AZ_HOSTNAME"
az vm create -n $AZ_HOSTNAME \
  -g $AZ_RGROUP \
  --image UbuntuLTS \
  --admin-username tdr \
  --authentication-type ssh \
  --public-ip-address-dns-name $AZ_DNSNAME
log "$AZ_HOSTNAME created..."

# Open Port Docker TLS Port
log "$AZ_HOSTNAME: opening port..."
az vm open-port --resource-group $AZ_RGROUP --name $AZ_HOSTNAME --port 2376
log "$AZ_HOSTNAME port created..."

# Create TLS Certs
log "Creating Certs"
sh tls-certs.sh
log "Certs created..."

# Create Public Docker config file
sh create-pub.sh

# Create protected Docker config file
sh create-prot.sh

# Add the Docker extension to the VM (with TLS)
log "Adding Docker VM extension to $AZ_HOSTNAME"
az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --name DockerExtension \
  --version 1.2.2 \
  --vm-name $AZ_HOSTNAME \
  --resource-group $AZ_RGROUP \
  --settings pub.json \
  --protected-settings prot.json
log "VM extension added to $AZ_HOSTNAME"

# Test TLS
# docker --tlsverify --tlscacert=keys/ca.pem --tlscert=keys/cert.pem --tlskey=keys/key.pem -H=$AZ_DNSFQDN:2376 version

# run Fluentd container

# < old > Add a custom script extension to install fluentd

# Start elastic Search

# Test fluentd

# Configure Docker damemon