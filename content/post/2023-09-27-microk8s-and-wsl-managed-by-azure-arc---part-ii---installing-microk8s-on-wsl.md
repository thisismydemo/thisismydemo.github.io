---
title: MicroK8S and WSL Managed by Azure Arc - Part II - Installing MicroK8S on WSL
description: A blog series about my experiences with MicroK8S, WSL, and Azure Arc
date: 2023-09-27T19:00:00.472Z
preview: /img/microk8s_arc/OIP.png
draft: false
tags:
  - Azure Arc
  - Kubernetes
  - MicrosK8S
categories:
  - Azure Arc-Enabled Kubernetes
  - Azure Arc-Enabled Servers
  - MicroK8S
lastmod: 2023-09-28T16:56:40.032Z
thumbnail: /img/microk8s_arc/OIP.png
lead: A blog series about my experiences with MicroK8S, WSL, and Azure Arc
slug: microk8s-wsl-managed-azure-arc-part-ii-installing-microk8s-wsl
keywords:
  - Azure CLI
  - MicroK8s
  - WSL
---
In this blog series I am going to discuss my experiences with MicroK8S, installing it on Windows Subsystem for Linux, and how to connect the cluster to Azure using Azure Arc-Enabled Kubernetes.

This is the first blog in a series of blogs.

1. [Installing MicroK8s on Windows Subsystem for Linux (WSL)](https://www.thisismydemo.cloud/post/microk8s-wsl-managed-azure-arc-part-ii-installing-microk8s-wsl/)
2. [Azure Arc-enabled servers:  Installing Azure Connected Machine Agent](https://www.thisismydemo.cloud/post/microk8s-wsl-managed-azure-arc-part-iii-azure-arc/)
3. Azure Arc-enabled Kubernetes:  Connecting my MicroK8S cluster to Azure

-------------------------------

# Installing MicroK8s on WSL

In this blog I will discuss my experience with installing Microk8s on [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/). I will add a short section on how to get WSL 2 installed on Windows 10 which should also work for Windows 11.  Then I will go into how to install MicroK8s on WSL.  So let the demo begin?

## Install Windows Subsystem for Linux (WSL)
There isn't much to installing WSL2 these days.  In the past it was a pain to get it installed on Windows 10.  Windows 11 made it easier to install.  Most of the headaches came from all the prerequisites that were needed.  However, installing WSL on Windows 10 is simple, a one liner and a reboot. For more detailed information on how to install WSL on Windows 10 or Windows 11 please check out the following Microsoft Learn Document at [How to install Linux on Windows with WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

So, we just need open a command prompt or PowerShell in administrator mode and then enter the following command:

```
wsl --install
```

There are other things we may need to check. Make sure that we are using WSL 2.  Make sure we have defined our distribution of Linux.  By default it will be Ubuntu which is what I will be using in this blog.

We can check what distributions are available by running the following command:

```
wsl -l -o
```

To verify that we are running Ubuntu and it is running under WSL 2 the following command will work:

```
wsl -l -v
```

Once WSL has been installed we can move forward to install MicroK8s on WSL.

## Install MicroK8s on WSL

So now I have WSL installed and configured.  I am ready to install MicroK8s.  This installation was straight forward and surprisingly simple. I read a few different blogs and some had you do something with multipass and others snap and so on.  I picked the easiest route for my little brain.

First thing is to enable systemd which will enable running snap and MicroK8s natively.

```
echo -e "[boot]\nsystemd=true" | sudo tee /etc/wsl.conf
```

Next we will install MicrosK8s

```
sudo snap install microk8s --classic
```

At this point we can monitor and wait for the installation.

```
sudo microk8s status --wait-ready
```

Once the installation is completed we need to make sure that our node is running and using the WSL2 kernel:

```
sudo microk8s kubectl get node -o wide
```

Once installed we need to make sure the user is allowed to use MicroK8s commands:

```
sudo usermod -aG microk8s $USER
sudo chown -f -R $USER ~/.kube
```

To get the cluster ready for our next blog series I also installed DNS, Storage, and the Dashboard functionality.

```
sudo microk8s enable dns
sudo microk8s enable storage
sudo microk8s enable dashboard
```

At this point we now have a single node MicroK8s cluster running in WSL. In my next blog I will explain how to install the Azure Arc Agent, also known as the Azure Connected Machine Agent in order to manage my WSL instance via Azure Arc-enabled servers.  The blog following, will go into details on how to connect this Kubernetes cluster to Azure using Azure Arc-enabled Kubernetes.