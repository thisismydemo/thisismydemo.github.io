---
title: Setting Up Entra Permissions Management
description: "This is a short blog on how to configure Entra Permissions Management for the
  first time. "
date: 2023-01-18T17:59:11.946Z
preview: /img/entra/entra-01.jpg
draft: false
tags:
  - Entra Permissions Management
  - Microsoft Entra
  - Permissions Management
categories:
  - Entra Permissions Management
thumbnail: /img/entra/entra-01.jpg
lead: Get your hands dirty with Entra Permissions Management
lastmod: 2023-01-20T20:13:58.855Z
---
This post will be a walk through on how to quickly setup Entra Permissions Management for the first time. One of the best ways to try our Entra Permissions Management is to start a trial and just jump in.  The Identity product group has a nice little user guide out there on [Microsoft Learn Trial user guide: Microsoft Entra Permissions Management](https://learn.microsoft.com/en-us/azure/active-directory/cloud-infrastructure-entitlement-management/permissions-management-trial-user-guide).  There are also other ways to get your hands dirty with Entra, you can always reach out to my company and have us do an [Entra PM multi-cloud risk assessment analyzes Azure and multi-cloud permissions risk](https://www.invokellc.com/offers/microsoft-entra-permissions-management-multi-cloud-risk-assessment).

For now, I will just walk you through how to start your Entra Permissions Management journey.

### What is Microsoft Entra Permissions Management?

Microsoft Entra Permissions Management is a cloud infrastructure entitlement management (CIEM) product that provides comprehensive visibility and control over permissions for any identity and any resource in Microsoft Azure, Amazon Web Services (AWS) and Google Cloud Platform (GCP). Microsoft Entra Permissions Management is one solution among many multiclouid identitiy and access products 

The entire product family includes:

* Azure Active Directory
* Microsoft Entra Permissions Management
* Microsoft Entra Verified ID
* Microsoft Entra Workload Identities
* Microsoft Entra Identity Governance

## Setting Up Permissions Management

Before we being there are a few things that are needed in order to setup a trail for Permissions Management.
* An Azure AD Tenant
* Be a Global Administrator or have access to a user that is a Global Administrator
* Have not already had a trail of Permissions Management enabled and expired.

### Starting the 90-day trial
There are a few different ways to start the trial.  I will talk about three of them.
1. From the Entra Permissions Management Website
2. From the M365 Admin Portal
3. From Azure Active Directory Portal.

#### From THe Entra Permissoins Management Website
The first way is to go to the Entra Permissions Management web site and click on the Try For Free button.

![Image](/img/entra/entra-01.jpg)

It will then prompt you for to enter an email address.  Enter your work account that belongs to the tenant that you will be using to try out Entra.

![Image](/img/entra/entra-02.jpg)

If you tenant already has had a trial, or a trial is currently going then you will see the next screen.

![Image](/img/entra/entra-03.jpg)

#### From the M365 Portal
You can also sign up through the M365 admin portal by going to Purchase Services.

Select Entra Permissions Management under Security and Identity

![Image](/img/entra/entra-04.jpg)

At this point you should have an option to start the trail.  On my tenant, I already have the trail activated so all I can do is hit manage.

![Image](/img/entra/entra-05.jpg)5

Once the trail has been started you can come back here to manage it.

![Image](/img/entra/entra-06.jpg)

#### From Azure AD Portal

In the Azure AD portal, select Permissions Management, and then select the link to purchase a license or begin a trial.

1. Go to Entra services and use your credentials to sign in to Azure Active Directory.
2. If you aren't already authenticated, sign in as a global administrator user.
3. If needed, activate the global administrator role in your Azure AD tenant.
4. In the Azure AD portal, select Permissions Management, and then select the link to purchase a license or begin a trial.

### Configure Data Collection Settings
Once you have signed up for the trial.  The first screen that launches is the Data Collectors dashboard.

![Image](/img/entra/entra-config-01.jpg)

We will be onboarding an Azure Subscription. Select Azure under the Data Collectors tab.  There are three options that we can choose from.
1. Automaticlly manage
2. Enter Authorization Systems
3. Select Authorization Systems

Option 1 allows subscriptions to be automaticlly detect and monitored.
Option 2 we will have the ability to specify certain subscriptions to manage and monitor.
Option 3 will  allow us to specify the authorization system where we will later select  subscriptions to monitor.

![Image](/img/entra/entra-config-02.jpg)

Since this is just collecting data at this point I will always go with Option 1.

First thing is to create the role assignments.  This can be done three ways:

* Via Console
* Via PowerShell
* Via Azure Command Line

I am going to do this via PowerShell and target the Root Management Group.  In order to target the root management group the user configuring this needs to have the correct roles assigned.

```
New-AzRoleAssignment -ApplicationId b46c3ac5-9da6-418f-a849-0a07a10b3c6c  -RoleDefinitionName "Reader" -Scope "/providers/Microsoft.Management/managementGroups/<managementgroup>"
```
![Image](/img/entra/entra-config-03.jpg)

Once the role assignment has been grated access to the authorization system we can continue by click Verify Now & Save.
From the Dashboard you can now check the progress of the collector that was just created.
![Image](/img/entra/entra-config-04.jpg)

![Image](/img/entra/entra-config-05.jpg)

![Image](/img/entra/entra-config-06.jpg)

After a few minutes all the discovered subscriptions should be in a status of "Onboarded". Now that our data collector has been setup, we can go back to the Entra Permissons Management dashboard.

![Image](/img/entra/entra-config-07.jpg)

***
So now we have successfully signed up for Entra Permissions Management and we have successfully onboarded our Microsoft Azure Subscriptions. There is so much more to do at this point. 
* Onboard GCP projects
* Onboard AWS accounts
* Discover and Assess
* Remediate & manage
* Monitor & alert

All these will come as I blog more about Microsoft Entra Permissions Management. For now this blog was just focusing on how to setup Entra Permissions Management. I am excited to share more about what Entra Permissions Management can do for you and your origination.  Not even just Entra Permissions Management but the entire Entra family of products.

I think my next blog will be showing how to configure a data collector for a Google Cloud project.

