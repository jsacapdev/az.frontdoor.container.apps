# Azure Container Apps and FrontDoor

A proof of concept to learn more about the capability offered using Azure Container Apps. Deploying the Azure Container App so it is not available publicly, but present it out using Azure Front Door.

|Description|Status|
|-|-|
|Infrastructure|[![Deploy Infrastructure](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/deploy-iac.yaml/badge.svg)](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/deploy-iac.yaml)|
|Application|[![Build Node Container App](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/build-app.yaml/badge.svg)](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/build-app.yaml)|

## Application Architecture

The following application architecture has been modelled within this repository.

Azure Front Door provides the front door to the application architecture from the internet. From that point onwards, traffic flows on the Microsoft backbone network.

The Azure Container Application service runs behind a Standard Azure Load Balancer. The Azure Container App is enabled for the Private Link Service. That Private Link Service ensures that traffic flows privately from from Azure Front Door.

![ACA](https://github.com/jsacapdev/az.frontdoor.container.apps/blob/main/assets/architecture.png?)

## Scratch space notes

Notes on running the application docker container locally.

``` pwsh
export CR_PAT=<PAT>

echo $CR_PAT | docker login ghcr.io -u jsacapdev --password-stdin

docker pull ghcr.io/NAMESPACE/IMAGE_NAME

docker pull ghcr.io/jsacapdev/nodeapp:latest

docker run -p 49160:3000 -d ghcr.io/jsacapdev/nodeapp:latest

curl -i localhost:49160/health

docker exec -it <container id> /bin/bash
```