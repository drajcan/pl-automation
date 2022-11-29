# Restore Network

## Clone deployments repo 
Execute: 
```shell
https://github.com/Axiologic/deployments.git
```
## Clone Automation Repo
1. Clone pl-automation repo (https://github.com/PharmaLedger-IMI/pl-automation)
```shell
git clone https://github.com/PharmaLedger-IMI/pl-automation
```

## Deploy ethereum adapter
Execute:
```shell
./deployments/bin/ethadapter.sh "my-company-name" 
```

## Deploy epi
Execute:
```shell
./deployments/bin/apihub.sh "my-company-name"

