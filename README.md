# github-action-hpcc-terraform
This repositoary is for host github action code for deploy both Community and Opinionated HPCC Systems Terraform in Azure.
It doesn't include the two HPCC Systems Terraform repos


## Pre-requisites
### Create Github secretes:
```code
ADD_CLIENT_ID: ${{ secrets.ADD_CLIENT_ID }}
ADD_CLIENT_SECRET: ${{ secrets.AAD_CLIENT_SECRET }}
ADD_TENANT_ID: ${{ secrets.ADD_TENANT_ID }}
ADD_SUBSCRIPTION_ID: ${{ secrets.ADD_SUBSCRIPTION_ID }}
```
You also can create a credentials secret to include everything:
```code
ADD_AZURE_CREDENTIALS:
{
    "clientId":  "<client id value>"
    "clientSecret":  "<client secret value>",
    "subscriptionId":  "<subscription value>",
    "tenantId":  "<tennat id value>",
}
```

### Create an AKS in Azure
For example use our opinionated terraform modules
Write down the resourece group and AKS name


## How to run 
Currently you need at least set AZ_RESOURCE_GROUP and AKS_NAME environment variables in the yaml file you want to run
Currently set as workflow_dispatch. So you need manually trigger it from github repo -> Actions. Select the workflow from "All workflows" in left panel. Click "Run workflow" from "Run workflow" list at the right

### Azure Login only
Workflow: "Azure Login with Github Action". File: .github/workflows/az-login.yml

### A sample Github actions
Workflow: "Explore Azure with Github Action". File: .github/workflows/az-study.yml
User need set additional environment variables such as:
```code
HPCC Platform version
HPCC Platform source branch 
```

The current steps include:
1. Azure login
2. Start AKS
3. Clean previous HPCC Systems storage and cluster
4. Deploy HPCC Systems storage
5. Deploy HPCC Systems cluster
6. Run a simple ECL test with HPCC Platform container
7. Run ECL Watch Playground test for target "hthor" and "thor". "roxie" is disabled since it doesn't work as HPCC 9.8.18-1
8. Delete HPCC Systems storage and cluster
9. Stop AKS


## To Do 

1. Test through opinionated HPCC Terraform Cluster. Current test is based on manual created AKS from Azure Portal
2. More type of tests
3. Cost export
