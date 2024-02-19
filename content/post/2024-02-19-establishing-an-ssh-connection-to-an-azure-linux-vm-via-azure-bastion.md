---
title: Establishing an SSH Connection to an Azure Linux VM via Azure Bastion
description: ""
date: 2024-02-19T18:14:07.000Z
preview: /img/ssh-linux-bastion/Screenshot 2024-02-19 121756.png
draft: false
tags:
  - Azure Bastion
  - Linux
categories:
  - Azure
lastmod: 2024-02-19T19:11:57.137Z
thumbnail: /img/ssh-linux-bastion/Screenshot 2024-02-19 121756.png
lead: Playing with the penguin again
slug: establishing-ssh-connection-azure-linux-vm-azure-bastion
---
With most my blogs, they all start with me trying to do something I have done in the past and have forgotten or with something I have never had to do and now need to do it. So, is the case with this blog. I have never had to worry about establishing an ssh connection to a Linux VM in Azure via Azure Bastion until today.

-------------------------------------------

I want to start this blog by showing how to connect via Bastion using the Azure Portal first. Then move on to how to establish the connection using a native client on our local machine via Azure Bastion.

- [Connecting via the Portal](#connecting-via-the-portal)
- [Connecting via Native Clients](#connecting-via-native-clients)
- [Final Thoughts](#final-thoughts)


## Connecting via the Portal
Connecting via the Azure Portal is one day to establish an ssh connection to my Azure Linux VM. This is a quick and easy way to get connected to my VM. As you can see here, I have my TestVM configured to use a user and password. In production, this should be using an ssh key and that key should be stored in a Keyvault of some kind. Don't do as I do, just do as I say kind of thing?

![](/img/ssh-linux-bastion/Screenshot%202024-02-19%20121933.png)

Here I am not connected and have access to my Linux VM. However, this isn't really an optimal way of managing anything. It is a quick and easy way to get connected and has it's place.

![](/img/ssh-linux-bastion/Screenshot%202024-02-19%20122045.png)

## Connecting via Native Clients

Here is where we can connect via Azure Bastion using our native client on our local computer, this can be a WSL sessions, Putty, or even PowerShell. There are various ways of signing in to our Linux VM via Bastion. We could use an SSH Key par, enable our VM to authenticate via Microsoft Entra ID, or the way I will be doing it for now, a simple username and password. We will be using Azure CLI for this process as well. So we need to make sure we have Azure CLI installed, which I already do have it installed on my Ubuntu WSL distro I am using.

First we will want to make sure we authenticate correctly with Azure CLI. To do this we first need to login and then set the right subscription we weill be using.

```Powershell
az login
az account set --subscription "SubscriptionID"
```

Next we will SSH to the VM using a password.  Here is the example Azure CLi code:

```PowerShell
az network bastion ssh --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --auth-type password --username xyz
```

Just remember to change the following:

- Name:  Bastion Host Name
- Resource Group:  Resource Group Name Where Bastion is deployed.
- Target Resource: This is the complete target resource path for the VM we are connecting to.
- User Name:  The user name we are going to connect with

We could add a parameter for password but I left that blank so it will prompt us before connecting.

Now I run the command but wait..... I get an error that my Bastion isn't configured with the proper SKU and I don't have Native Client enabled.

![](/img/ssh-linux-bastion/Screenshot%202024-02-19%20121654.png)

We need to come to the properties of the Azure Bastion instance. As we can see here I am running the Basic SKU which Native Client is not supported in. I will need to configure this Bastion instance as a Standard SKU and enable Native Client.

![](/img/ssh-linux-bastion/Screenshot%202024-02-19%20122241.png)

Here I have made those changes from within the Bastion Configuration blade. I have also enabled copy and paste. So go get some coffee and wait. This takes a while.

![](/img/ssh-linux-bastion/Screenshot%202024-02-19%20122451.png)

So now we will try connecting again. Bingo, we now have established an ssh connection to an Azure VM via Azure Bastion.

![](/img/ssh-linux-bastion/Screenshot%202024-02-19%20123451.png)

---------------------------------

## Final Thoughts

Between Microsoft CoPilot and Microsoft Learn, I was able to easily find these commands and everything I needed to do.  I knew about the Bastion SKU before I started but wanted to put that in here as an example for myself and others that read this later. The following documentation from Microsoft was very useful, [Connect to a VM using Bastion and a Linux native client](https://learn.microsoft.com/en-us/azure/bastion/connect-vm-native-client-linux)