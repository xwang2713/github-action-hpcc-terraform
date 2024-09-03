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

In /.github/workflows/az-study.yml replace AZ_RESOURCE_GROUP and AKS_NAME environment variable

commit and push your code. You can manually run the workflow

## To Do 
Uninstall/Install HPCC Cluster
Run test
