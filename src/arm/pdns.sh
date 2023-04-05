#!/bin/bash
set -e

echo "Parameters..."
echo "Container Environment Resource Group -> $1";
echo "Container Environment Name -> $2";
echo "Location -> $3";
echo "Shared Resource Group -> $4";
echo "Container Apps Vnet -> $5";
echo "Shared Vnet -> $6";

CONTAINER_RESOURCE_GROUP_NAME=$1
CONTAINER_ENV_NAME=$2
LOCATION=$3
SHARED_RESOURCE_GROUP_NAME=$4
CONTAINER_APPS_VNET_NAME=$5
SHARED_VNET_NAME=$6

# workaround to get bicep to work with azure cli github action
az config set bicep.use_binary_from_path=false
az config set extension.use_dynamic_install=yes_without_prompt
az bicep install
az extension add --name containerapp

# get the default domain for the azure container app envioronment 
DEFAULT_DOMAIN=$(az containerapp env show \
                -n $CONTAINER_ENV_NAME \
                -g $CONTAINER_RESOURCE_GROUP_NAME \
                -output none \
                -o tsv \
                --query properties.defaultDomain)

# get all the private dns zones configured in the central 'hub' vnet
DNS_ZONES=$(az network private-dns zone list \
                  -g $SHARED_RESOURCE_GROUP_NAME \
                  -output none \
                  -o tsv \
                  --query [*].name)

# check if the dns zone for the container app env has already been configured. if so, exit.
for zone in $DNS_ZONES; do
    if [ "$zone" = "$DEFAULT_DOMAIN" ]; then
        echo "DNS Zone already configured. Exiting."
        exit 0
    fi
done     

# parse the container app default domain 
arrIN=(${DEFAULT_DOMAIN//./ })

# construct the name of the managed resource group for the azure container app
MANAGED_CONTAINER_RESOURCE_GROUP_NAME="mc_${arrIN[0]}-rg_${arrIN[0]}_$LOCATION"

# get the (private) IP addresses for the internal load balancer that sits in front of the container apps envioronment
PRIVATE_IP_ADDRESSES=$(az network lb show \
                       -g $MANAGED_CONTAINER_RESOURCE_GROUP_NAME \
                       -n kubernetes-internal \
                       -output none \
                       -o tsv \
                       --query frontendIPConfigurations[].privateIPAddress)

# create a private dns zone for container apps default domain
az network private-dns zone create -g $SHARED_RESOURCE_GROUP_NAME -n $DEFAULT_DOMAIN -output none

# join the shared vnet to the new private dns zone
SHARED_VNET_ID=$(az network vnet show -g $SHARED_RESOURCE_GROUP_NAME -n $SHARED_VNET_NAME --query id --out tsv -output none)

az network private-dns link vnet create -g $SHARED_RESOURCE_GROUP_NAME -n $SHARED_VNET_NAME -z $DEFAULT_DOMAIN -v $SHARED_VNET_ID -e False

# join the container apps vnet to the new private dns zone
APPS_VNET_ID=$(az network vnet show -g $CONTAINER_RESOURCE_GROUP_NAME -n $CONTAINER_APPS_VNET_NAME --query id --out tsv -output none)

az network private-dns link vnet create -g $SHARED_RESOURCE_GROUP_NAME -n $CONTAINER_APPS_VNET_NAME -z $DEFAULT_DOMAIN -v $APPS_VNET_ID -e False -output none

# add the private IP's to newly created default domain to ensure clients on the internal network can resolve to the IP using DNS
for ip in $PRIVATE_IP_ADDRESSES; do
    az network private-dns record-set a add-record -g $SHARED_RESOURCE_GROUP_NAME -z $DEFAULT_DOMAIN -n "*" -a $ip -output none
done                       

echo "Finished."
