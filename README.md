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


## How to trigger a workflow

https://stackoverflow.com/questions/77354529/how-can-i-trigger-a-github-actions-workflow-from-another-github-actions-workflow


https://stackoverflow.com/questions/62736315/invoke-github-actions-workflow-manually-and-pass-parameters


An example is given in trigger.yml which uses curl to post a request.

Another method is to use previous workflow complete:
```code
on:
  workflow_run:
    workflows: ["CI build"]
    types:
      - completed
```

## Access Opinionated Cluster 
After add configuration with AKS name and Resource group local AZ Cli can stop/start the AKS but can't run kubectl commands such as 'kubectl get <nodes|pods>'

Even kubelogin with token successful still can run kubectl. Need investigate
 
It is resolved after adding following:
```code
export KUBECONFIG=~/.kube/config
kubelogin convert-kubeconfig -l spn --client-id ${{ secrets.AAD_CLIENT_ID }} --client-secret ${{ secrets.AAD_CLIENT_SECRET }}
```
Also at AKS side add "<user>=<Service Principal Object ID>"
Currently two users added: 1) Github App name 2) Github Action runner user: "runner". I think 2) make effect but need to confirm 


## To Do 

### Organize the Github Action repo
It is currently under Github account xwang2713 (ming)
We should move it to hpcc-systems

How should we trigger Github Action Test after build? What is Github user used to run HPCC Build.
Trigger a GitHub Action Workflow in another Github Account need that account's token



### How do we want to log the test results
1. Saved in release
2. Saved in Github Action Archive


### More type of tests
BVT list

### All test should be run through local command-line environment 
It will help to debug and investigate, etc
Only ECLWatch IP is needed for most case

### Cost export
Can't see all cost from the resource group for opinionated cluster


### Refactor the Github Action Code
Need add more input parameters such AKS name and resource group name

Break down the code to several Github Action YAML files for easy re-use and complete the each steps even some failed in the middle 

### Error Handling
#### Download HPCC-Platform Docker image failure
I experience one time of this failure for "Simple ECL Test". 

#### Node not available
 Warning  FailedScheduling  106s  default-scheduler   0/2 nodes are available: 2 node(s) had untolerated taint {CriticalAddonsOnly: true}. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
  Normal   TriggeredScaleUp  99s   cluster-autoscaler  pod triggered scale-up: [{aks-thorpool2-13421744-vmss 0->1 (max: 1)}]


Do we use spot instances?

