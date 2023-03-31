# Azure Container Apps and FrontDoor

A proof of concept to learn more about the capability offered using Azure Container Apps. Deploying the Azure Container App so it is not available publicly, but present it out using Azure Front Door.

|Description|Status|
|-|-|
|Infrastructure|[![Deploy Infrastructure](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/deploy-iac.yaml/badge.svg)](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/deploy-iac.yaml)|
|Application|[![Build Node Container App](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/build-app.yaml/badge.svg)](https://github.com/jsacapdev/az.frontdoor.container.apps/actions/workflows/build-app.yaml)|

## Scratch space notes

To pull down the docker image from the GitHub container registry, and then run it locally:

``` pwsh
export CR_PAT=<PAT>

echo $CR_PAT | docker login ghcr.io -u jsacapdev --password-stdin

docker pull ghcr.io/NAMESPACE/IMAGE_NAME

docker pull ghcr.io/jsacapdev/nodeapp:latest

docker run -p 49160:3000 -d ghcr.io/jsacapdev/nodeapp:latest

curl -i localhost:49160/health

docker exec -it <container id> /bin/bash
```