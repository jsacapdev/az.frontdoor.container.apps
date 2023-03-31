#!/bin/sh
set -e

echo "Parameters..."
echo "Resource Group -> $1";
echo "Deployment Name -> $2";
echo "Base Name -> $3";
echo "Workspace -> $4";

RESOURCE_GROUP_NAME=$1
DEPLOYMENT_NAME=$2
BASE_NAME=$3

# workaround to get bicep to work with azure cli github action
az config set bicep.use_binary_from_path=false
az bicep install

result=$(az deployment group create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $DEPLOYMENT_NAME \
    --template-file $WORKSPACE/main.bicep \
    --parameters \
    baseName=$BASE_NAME \
    -o json \
    --query properties.outputs.result.value | jq -r . >$WORKSPACE/outputs.json)

echo "Finshed."
