---
title: My MicroK8s Cluster Is Now Manged by Azure. What is next?
description: ""
date: 2023-09-28T17:20:35.988Z
preview: /img/microsk8s_mgmt_arc/1_ZGA9YPjXDWukHAXhO2QDUQ.png
draft: true
tags:
  - Azure Arc
  - MicrosK8S
  - Kubernetes
categories:
  - Azure Arc-Enabled Kubernetes
  - MicroK8S
lastmod: 2023-09-28T17:53:52.441Z
thumbnail: /img/microsk8s_mgmt_arc/1_ZGA9YPjXDWukHAXhO2QDUQ.png
lead: Using Azure Arc-enabled Kubernetes to Monitor, Secure, Regulate, Deploy and more
keywords:
  - Azure Arc
  - Azure Monitor
  - MicroK8s
  - Container Insights
slug: microk8s-cluster-manged-azure
---
In a previous blog series [MicroK8S and WSL Managed by Azure Arc - A blog series about my experiences with MicroK8S, WSL, and Azure Arc](https://www.thisismydemo.cloud/post/microk8s-wsl-managed-azure-arc/) I had a curiosity to see if I could deploy MicroK8s on my WIndows 10 WSL instance and then manage the WSL instance with Azure Arc and then manage the MicroK8s cluster using Arc-enabled Kubernetes.

So let's refresh here a little. I was able to get a MicroK8s cluster deployed on WSL running on my Windows 10 laptop. I was able to get the Azure Arc Agent (Azure Connected Machine Agent) connected and now my WSL instance is a managed Azure resource using Azure Arc-enabled Servers. Last but not least, I was able to get the MicroK8s cluster connected using Azure Arc-enabled Kubernetes as well. So now, I want to discuss some of the things we can do with that Kubernetes cluster now that it is being manged by Azure.

----------

To start, let me share the Microsoft Learn Document [What is Azure Arc-enabled Kubernetes](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/overview) so we are all on the same page when it comes to what it is and what it can do.

At a high level we can do some of the following to our Kubernetes clusters running anyway as long as we can manage them using Azure Arc.  Here is a short list of things I will try to blog about here:

* Deploying Configurations using GitOps
* Azure Resource Graph Queries
* Identity and Access Management
* Installing Cluster Extensions
* Monitor our Cluster using Azure Monitor Container Insights
* Access Secrets from an Azure Key Vault
* Policy Enforcements using Azure Policy
* Threat Protection using Microsoft Defender for Cloud
* Deploy Azure Arc-enabled Open Service Mesh
* Azure Machine Learning for Kubernetes
* Event Grid on Kubernetes
* Azure Arc-enabled Data Services

These are some but not all of the things I would love to dig in and blog about here.  It may be multiple blogs. I do want to cover Monitoring our cluster using Azure Monitor Container Insights, Azure Policy, and Microsoft Defender for Cloud for sure in this series.  Some of the solutions I would not be able to deploy on my little single node cluster running on WSL.

-------

