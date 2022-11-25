# Join Shared Network
## Shared configuration repo fork
1. Fork PharmaLedger-IMI/epi-shared-configuration repository with your account  (https://github.com/PharmaLedger-IMI/epi-shared-configuration)
2. Create a directory under the appropriate network/environment and perform an initial commit 

## Clone Automation Repo
1. Clone pl-automation repo (https://github.com/PharmaLedger-IMI/pl-automation)
2. Change directory to pl-automation
```shell
cd path_to_pl_automation_clone
```
3 Initialise company directory for appropriate network by executing:
```shell
./deployments/bin/init.sh <company-directory-name> <network-name> 
```
## GitHub & Quorum Configuration
1. Configure ../bin/<company>/<network>/private/github.info.yaml for forked repo access
2. Populate ../bin/<company>/<network>/private/qn-0.info.yaml with desired quorum node helm chart values to be overwritten (values omitted will be defaulted) 

## Generate enode information
1. Execute:
```shell
./deployments/bin/join-network.sh <company-name> 
```
which will create join-network.plugin.json & join-network.plugin.secrets.json

## Shared Repo Update & Pull Request
When everything is complete, a Pull Request to Pharmaledger-IMI/epi-shared-configuration should be created for review by the repo admin

## Specify peers & propose as validators
1. Populate the nodes to be recognised as static peers and validators (peer naming as in github networks/<network>/editable repo directory) in ./deployments/bin/<company>/<network>/private/update-partners.info.yaml

2. Execute:
```shell
./deployments/bin/update-partners.sh <company-name>
```
3. For each new node addition, peers and validators can be updated by simply updating update-partners.info.yaml file and executing this script again
