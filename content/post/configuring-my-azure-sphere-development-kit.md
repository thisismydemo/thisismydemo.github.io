---
title: Configuring My Azure Sphere Development Kit - But is it a brick now?
description: ""
date: 2023-03-23T23:17:39.100Z
preview: /img/azsphereregister/register_004.png
draft: true
tags: ""
categories: ""
lastmod: 2023-03-24T01:20:20.742Z
thumbnail: /img/azsphereregister/register_004.png
lead: Is my Azure Sphere Development Kit a brick now?
---

In a previous blog I wrote about having to recover my Azure Sphere Development Kit. So I decided to right one on what to do with it once I have recovered it. So this blog continues from [My Azure Sphere Needs Reset?](https://www.thisismydemo.cloud/post/my-azure-sphere-needs-reset/)

Let's start over...  

The first step was to get all the needed tools installed. There are a few ways to manage an Azure Sphere.

1. Via Windows CLI
2. Via Visual Studio Code
3. Via VIsual Studio
4. Via Linux CLI

I went the route of the Windows CLi

## Windows CLI Installation

For the installation for Windows CLI you will need to install the Azure SPhere SDK.  You can download this at [Azure Sphere SDK Download](https://aka.ms/AzureSphereSDKDownload/Windows).  Once downloaded just run the installation.

## CMake and Ninja for Windows

The WIndows CLi will need to install CMake and Ninja for Windows.  I did this using the Chocolaty installation.

1. choco install ninja
2. choco install cmake

## Claim the Device

We need to claim the device now. Each device will be associated with an Azure Sphere Tenant.

First we sign on to our device.  I have mine plugged into my computer.  This is where we will need to use either VS Code or the Windows CLI.  But first we need to register user since we never have signed on to this device before.

```Powershell
azsphere register-user --new-user <email-address>
```
![](/img/azsphereregister/register_001.png)

Next we want to login to Azure Sphere using a Microsoft Account.

![](/img/azsphereregister/register_002.png)

![](/img/azsphereregister/register_003.png)

Once we have logged on and accept the Permissions Request we need to then change or create the tenant that we will be using.

An Azure Sphere tenant is a concept in the Azure Sphere platform that represents an organization or entity that manages one or more Azure Sphere deployments. A tenant is a logical container that provides a way to group and organize Azure Sphere resources, such as devices, applications, and policies.

In Azure Sphere, a tenant is associated with an Azure Active Directory (Azure AD) tenant, which provides a way to manage user access and permissions for the Azure Sphere resources. Azure Sphere tenants can be created and managed through the Azure portal or using Azure Sphere APIs and command-line tools.

Each Azure Sphere tenant has a unique ID and a set of configuration settings that define the policies, security baselines, and connectivity settings for the devices in the tenant's deployment. Multiple tenants can be created and managed within a single Azure subscription, allowing organizations to manage multiple Azure Sphere deployments with different configurations and security policies.

Once logged in, you can pull up a list of available tenants using the following command:

```PowerShell
azsphere tenant list
```
I don't currently have a tenant to assign so I am going to create a new tenant for this device.  So we would use the following command to do this.

```PowerShell
azsphere tenant create --name <tenant-name or tenant-ID>
```

Note:


