---
title: Azure Stack HCI - Series Ended
description: This is a series of blogs about my experiences with Azure Stack HCI
date: 2023-11-28T21:01:59.683Z
preview: /img/azshci-series/azure-stack-hci.png
draft: false
tags:
    - Azure Stack HCI
categories:
    - Azure Stack HCI
lastmod: 2023-11-29T14:39:28.339Z
thumbnail: /img/azshci-series/azure-stack-hci.png
lead: This is a series of blogs about my experiences with Azure Stack HCI
slug: azure-stack-hci-series-ended
---

In this blog series I plan to blog about everything I know about Azure Stack HCI. So, it should be a very short blog series. Just kidding. Again, I tend to blog about subjects that I am currently working on or will be currently working on. So, Azure Stack HCI is fresh on my mind again these days.

I have decided to end this blog series but not end blogging about Azure Stack HCI. For those that don't know, Azure Stack HCI 23H2 Preview has been released. The GA date isn't officially published yet.  However, I feel blogging about release 22H2 will be a mute point now with some of the major changes coming in release 23H2.

I do have a blog coming soon about my experiences using the cloud deployment method of deploying Azure Stack HCI 23H2 Preview.  All my future AzSHCI blogs will be based off of 23H2 as well. As for now, here are some of the new features and improvements that are coming with release 23H2.

* **Cloud-based deployment:** You can now deploy an Azure Stack HCI cluster via the Azure portal or an Azure Resource Manager deployment template.
* **Cloud-based updates**: The new release has the infrastructure to consolidate all the relevant updates for the OS, software agents, Azure Arc infrastructure, and OEM drivers and firmware into a unified monthly update package. You can apply the updates using the PowerShell or the Azure Update Manager tool.
* **Cloud-based monitoring:** The release integrates Azure Monitor alerts with Azure Stack HCI so that any health alerts generated within your on-premises Azure Stack HCI system are automatically forwarded to Azure Monitor alerts. You can link these alerts with your automated incident management systems, ensuring timely and efficient response. You can also monitor the health of your Azure Stack HCI system via the metrics collected for compute, storage, and network resources.
* **Azure Arc VM management** Beginning this release, the following Azure Arc VM management capabilities are available:

  * Simplified Arc Resource Bridge deployment. The Arc Resource Bridge is now deployed as part of the Azure Stack HCI deployment. For more information, see Deploy Azure Stack HCI cluster using the Azure portal.
  * New RBAC roles for Arc VMs. This release introduces new RBAC roles for Arc VMs. For more information, see Manage RBAC roles for Arc VMs.
  * New Azure consistent CLI. Beginning this preview release, a new consistent command line experience is available to create VM and VM resources such as VM images, storage paths, logical networks, and network interfaces. For more information, see Create Arc VMs on Azure Stack HCI.
  * Support for static IPs. This release has the support for static IPs. For more information, see Create static logical networks on Azure Stack HCI.
  * Support for storage paths. While default storage paths are created during the deployment, you can also specify custom storage paths for your Arc VMs. For more information, see Create storage paths on Azure Stack HCI.
  * Support for Azure VM extensions on Arc VMs on Azure Stack HCI. Starting with this preview release, you can also enable and manage the Azure VM extensions that are supported on Azure Arc, on Azure Stack HCI Arc VMs created via the Azure CLI. You can manage these VM extensions using the Azure CLI or the Azure portal. For more information, see Manage VM extensions for Azure Stack HCI VMs.
  * Trusted launch for Azure Arc VMs. Azure Trusted Launch protects VMs against boot kits, rootkits, and kernel-level malware. Starting this preview release, some of those Trusted Launch capabilities are available for Arc VMs on Azure Stack HCI. For more information, see Trusted launch for Arc VMs.

* **Security capabilities:** The new installations with this release of Azure Stack HCI start with a secure-by-default strategy. The new version has a tailored security baseline coupled with a security drift control mechanism and a set of well-known security features enabled by default. This release provides:

  * A tailored security baseline with over 300 security settings configured and enforced with a security drift control mechanism. For more information, see Security baseline settings for Azure Stack HCI.
  * Out-of-box protection for data and network with SMB signing and BitLocker encryption for OS and Cluster Shared Volumes. For more information, see BitLocker encryption for Azure Stack HCI.
  * Reduced attack surface as Windows Defender Application Control is enabled by default and limits the applications and the code that you can run on the core platform. For more information, see Windows Defender Application Control for Azure Stack HCI.