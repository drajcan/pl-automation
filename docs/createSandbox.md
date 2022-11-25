# Create sandbox network

## Create sandbox configuration repo
Create a repository in your account and add the folder "networks" inside it.

## Clone Automation Repo
1. Clone pl-automation repo (https://github.com/PharmaLedger-IMI/pl-automation)
```shell
git clone https://github.com/PharmaLedger-IMI/pl-automation
```
2. Change directory to pl-automation
```shell
cd pl-automation
```
3. Initialise company directory for appropriate network by executing:
```shell
./deployments/bin/init.sh "my-company-name" "sandbox-network-name" 
```
## GitHub Configuration
Configure ./"my-company-name"/"sandbox-network-name"/private/github.info.yaml for the created repo access
![image](https://user-images.githubusercontent.com/35995331/203970385-a49da4e1-b9d6-41ec-8d5d-4922db99df11.png)

## Deploy standalone quorum network
Execute:
```shell
./deployments/bin/standalone-quorum.sh "my-company-name" 
```
which will create a standalone quorum network with 4 nodes and will deploy the smart contract.
## Deploy ethereum adapter
Execute:
```shell
./deployments/bin/ethadapter.sh "my-company-name" 
```
## Deploy epi
1. Configure ./"my-company-name"/"sandbox-network-name"/private/epi.info.yaml which are the values for epi helm chart
2. Execute:
```shell
./deployments/bin/apihub.sh "my-company-name" 
```
