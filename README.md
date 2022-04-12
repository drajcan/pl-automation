# pl-automation
pharma ledger use cases automation and conventions for build of use cases and deployment


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

 

