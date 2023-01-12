# Create Shared Network
## Shared configuration repo fork
1. Fork PharmaLedger-IMI/epi-shared-configuration repository with your account  (https://github.com/PharmaLedger-IMI/epi-shared-configuration)
2. Create a directory under the appropriate network/environment and perform an initial commit 

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
./deployments/bin/init.sh "my-company-name" "shared-network-name" 

Note!!!
For macOS if this above command throw an error execute folowing steps:
 a. brew install gnu-sed
 b. brew info gnu-sed
 this will give a result like : 
     brew info gnu-sed (snippet)
    ==> Caveats
    GNU "sed" has been installed as "gsed".
    If you need to use it as "sed", you can add a "gnubin" directory
    to your PATH from your bashrc like:

        PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
 c. update the PATH (a restart is required to take the changes)
 d. try again 
 
```
## GitHub & Quorum Configuration
1. Configure ./"my-company-name"/"shared-network-name"/private/github.info.yaml for forked repo access
![image](https://user-images.githubusercontent.com/35995331/203970385-a49da4e1-b9d6-41ec-8d5d-4922db99df11.png)

3. Populate ./"my-company-name"/"shared-network-name"/private/qn-0.info.yaml with desired quorum node helm chart values to be overwritten (values omitted will be defaulted) 
![image](https://user-images.githubusercontent.com/35995331/203970728-cdc91c2d-ad93-4b60-adc9-af458d883fda.png)


## Deploy quorum node
1. Execute:
```shell
./deployments/bin/new-network.sh "my-company-name" 
```
which will deploy the quorum node and will deploy the smart contract

## Shared Repo Update & Pull Request
When everything is complete, a Pull Request to Pharmaledger-IMI/epi-shared-configuration should be created for review by the repo admin

## Specify peers & propose as validators
1. Populate the nodes to be recognised as static peers and validators (peer naming as in github networks/"my-company-name"/editable repo directory) in ./deployments/bin/"my-company-name"/"shared-network-name"/private/update-partners.info.yaml
![image](https://user-images.githubusercontent.com/35995331/203969712-75f7562b-9703-4c57-b072-1d636d9cc940.png)

2. Execute:
```shell
./deployments/bin/update-partners.sh "my-company-name"
```
3. For each new node addition, peers and validators can be updated by simply updating update-partners.info.yaml file and executing this script again

## Deploy ethereum adapter
Execute:
```shell
./deployments/bin/ethadapter.sh "my-company-name" 
```
## Deploy epi
1. Configure ./"my-company-name"/"shared-network-name"/private/epi.info.yaml which are the values for epi helm chart
2. Execute:
```shell
./deployments/bin/apihub.sh "my-company-name"
