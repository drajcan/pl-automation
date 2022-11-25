# pl-automation
pharmaledger use cases automation and conventions for build of use cases and deployment

# Prerequisites
Following components should be pre-installed:
1. Helm pl-plugin ( https://github.com/PharmaLedger-IMI/helm-pl-plugin )
```shell
helm plugin install https://github.com/PharmaLedger-IMI/helm-pl-plugin
```
2. Pharmaledger-imi/helm-charts ( https://github.com/PharmaLedger-IMI/helm-charts )
```bash
helm repo add pharmaledger-imi https://pharmaledger-imi.github.io/helm-charts
```
# Join blockchain network 
https://github.com/PharmaLedger-IMI/pl-automation/blob/master/docs/joinShared.md

# Usage to build images
## clone this repo
## edit your company_configs/install.cfg 
   install.cfg shoudl contain: use case workspace repo link, docker repo authentication, 

## run ./install.sh
## run ./buildImages.sh


# Usage for deployment
## install helm-plugin 
## install helm-charts
## clone the shared use case congifs in  shared_configs
## clone the company specific configs in company_confg folder 
## customise those configs (manual editing)
## install each use cases as descipbe din the helm-chart repo using the predefined scripts

 

