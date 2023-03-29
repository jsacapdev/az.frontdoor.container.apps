#!/bin/sh
set -e

######################################
## Define Variables _ UPDATE VALUES
BASE_NAME="<TBD>"
LOCATION="northeurope"
######################################

## Resource Group & Deployment
RESOURCE_GROUP_NAME=$BASE_NAME-rg
DEPLOYMENT_NAME=$BASE_NAME-deployment-$(date +%s)

echo !!!