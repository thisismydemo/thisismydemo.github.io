---
title: Dell APEX - Create Service Principle and Assign Roles via Azure CLI
description: ""
date: 2024-08-05T11:38:44.425Z
preview: ""
draft: false
tags:
    - Azure Stack HCI
    - Dell APEX
categories:
    - Azure Stack HCI
lastmod: 2024-08-05T15:14:29.873Z
thumbnail: ""
lead: Automating the Deployment of Azure Stack HCI Series
slug: dell-apex-create-service-principle-assign-roles-azure-cli
---


There are several key differences when deploying an Azure Stack HCI Cluster using a premier solution like Dell's APEX Cloud Platform for Microsoft Azure versus using an integrated system. For detailed information about Azure Stack HCI solution categories, please visit [Azure Stack HCI Solutions](https://azurestackhcisolutions.azure.microsoft.com/#/Learn).

One notable difference is the use of a service principal in the cluster deployment for APEX and the necessary Azure roles that need to be assigned. In contrast, integrated systems require deployment through Microsoft Cloud, either via the portal or ARM Templates. When using the portal method, the deploying account must have the appropriate Azure roles assigned. With the ARM Template method, a service principal is required, but the deployment process will assign the necessary roles to that service principal. While access to run the ARM template is still required, the template will handle the rest of the role assignments.

- [Install Azure CLI for Windows](#install-azure-cli-for-windows)
- [Create The Service Principal](#create-the-service-principal)
- [Assign The Azure Roles](#assign-the-azure-roles)

## Install Azure CLI for Windows

If you don't have the Azure CLI for Windows installed, you can use the following Azure CLI command to install it:

[Install Azure CLI for Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=powershell)

```powershell
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/ installazurecliwindowsx64 -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
```

## Create The Service Principal

The following steps will create the Azure Entra ID Application and create the Service Principal for the Application.

Logon to the correct tenant and subscription:

```powershell
az login --use-device-code
```

![](/img/apex-sp/Screenshot%202024-08-05%20090325.png)

Set and Verify that the correct subscription has been selected:

```powershell
az account set --subscription [subscriptionID]
az account show
```

![](/img/apex-sp/Screenshot%202024-08-05%20091657.png)


Create the Entra ID Application:

```powershell
az ad app create --display-name “Azure Stack HCI Deployment”
```

![](/img/apex-sp/Screenshot%202024-08-05%20092609.png)

Create the Service Principal for the Application:

```powershell
az ad sp create-for-rbac --name “Azure Stack HCI Deployment”
```

![](/img/apex-sp/Screenshot%202024-08-05%20092818.png)

## Assign The Azure Roles

Based off the requirements that Dell provided, the following Azure roles need to be assign to the newly created service principal. These roles are similar to what you would set for a user that will be deploying a cluster using the Microsoft Cloud Deployment method via the Azure Portal.

Role Name | Scope
---------|----------
 Azure Stack HCI Administrator | Subscription
 Reader | Subscription
 Azure Resource Bridge Deployment Role | Subscription
 Key Vault Administrator | Resource Group
 Key Vault Contributor | Resource Group
 Storage Account Contributor | Resource Group

First verify the Display Name of the newly created Service Principal:

```powershell
az ad sp list --display-name "Azure Stack HCI Deployment" --query "[].{name:displayName}"
```

![](/img/apex-sp/Screenshot%202024-08-05%20104956.png)

Next, get the service principals Object ID:

```powershell
az ad sp list --display-name "Azure Stack HCI Deployment" --query "[].{id:id}" --output tsv
```

![](/img/apex-sp/Screenshot%202024-08-05%20105134.png)

Now assign the roles:

Below is an example of the script that needs to be run for each Azure Role assignment:
az role assignment create --assignee-object-id <ObjectID> --role "<RoleName>" --scope "<Scope>"
- Replace <ObjectID> with the Object ID from the previous step.
- Replace <RoleName> with one of the above roles mentioned previously.
- Replace <Scope> with either the resource group ID or the Subscription.
To target a scope at the subscription level, replace <SubscriptionID> with the Subscription ID that the Azure Stack HCI resources exist:
--scope "/subscriptions/<SubscriptionID>"

```powershell
az role assignment create --assignee-object-id aa8d5302-9b4e-4cd3-8061-89771753907a --role "Azure Stack HCI Administrator" --scope "/subscriptions/[subscriptionid]"
az role assignment create --assignee-object-id aa8d5302-9b4e-4cd3-8061-89771753907a --role "Reader" --scope "/subscriptions/[subscriptionid]"
az role assignment create --assignee-object-id aa8d5302-9b4e-4cd3-8061-89771753907a --role "Azure Resource Bridge Deployment Role" --scope "/subscriptions/[subscriptionid]"
az role assignment create --assignee-object-id aa8d5302-9b4e-4cd3-8061-89771753907a --role "Key Vault Administrator" --scope "/subscriptions/[subscriptionid]/resourceGroups/[resourcegroup]"
az role assignment create --assignee-object-id aa8d5302-9b4e-4cd3-8061-89771753907a --role "Key Vault Contributor" --scope "/subscriptions/[subscriptionid]/resourceGroups/[resourcegroup]"
az role assignment create --assignee-object-id aa8d5302-9b4e-4cd3-8061-89771753907a --role "Storage Account Contributor" --scope "/subscriptions/[subscriptionid]/resourceGroups/[resourcegroup]"
```

![](/img/apex-sp/Screenshot%202024-08-05%20105947.png)

The service principal has now been created and assigned the correct Azure roles. Dell does mention that this service principle also needs to either be owner or have Contributor and User Access Administrator as well.
