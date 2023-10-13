---
title: Azure Stack HCI - Everything I know Series
description: ""
date: 2023-10-13T16:15:49.341Z
preview: /img/azshci-series/azure-stack-hci.png
draft: false
tags:
    - Azure Stack HCI
categories:
    - Azure Stack HCI
lastmod: 2023-10-13T17:20:01.075Z
thumbnail: /img/azshci-series/azure-stack-hci.png
lead: This is a series of blogs about my experiences with Azure Stack HCI
slug: azure-stack-hci-series
keywords:
    - Azure Stack Edge
    - Azure Stack HCI
    - Azure Stack Hub
    - Azure Stack
---
In this blog series I plan to blog about everything I know about Azure Stack HCI. So, it should be a very short blog series. Just kidding.  Again, I tend to blog about subjects that I am currently working on or will be currently working on. So, Azure Stack HCI is fresh on my mind again these days.

In this series I plan to touch on the following topics:

* My Azure Stack HCI Infrastructure
* Deploying a Single Node HCI Cluster
* Single server scale-out of my Azure Stack HCI cluster to a two node cluster then on to a three node cluster and beyond.
* Monitoring and Managing Azure Stack HCI
  * Backups
  * Site Recovery
  * Monitoring with Azure Monitor
  * Managing with Azure Arc-enabled VMs for Azure Stack HCI
* Azure Kubernetes Service (AKS) on Azure Stack HCI
* Azure Virtual Desktop on Azure Stack HCI
* Application Services on Azure Stack HCI
* Use cases and more...

To start this series I will give you a bit of history about my experience with this product, what Azure Stack HCI is and is not, when you should or need to use Azure Stack HCI, and more.

## My History with Azure Stack HCI

My history with Azure Stack HCI is farley short and uneventful. In 2017 time period I was working for Dell Services which was then purchased by NTT Data and we became NTT Data Services. Just like my current role at TierPoint, I was hired to help build Microsoft solutions for customers primary around Microsoft's Private cloud offerings. For more information about what Azure Stack HCI is now, please see the next section below.  But what was Azure Stack HCI then? Well, Server 2016 was being well adopted in a lot of corporations. Hyper-V Server had by this point proven itself to those that would listen to be a direct competitor for VMWare's ESXi. (Prove me wrong) A new technology was introduced in Server 2016 called Storage Spaces Direct or better referred to as S2D. Software defined network (SDN) was introduced within Windows server 2012 but still needed maturing. I will be honest, it still needed maturing in Server 2016 as well. So, with Server 2016, Microsoft entered into the HyperConverged world of server compute. (Is that a word?)

I started to build Hyperconverged solutions for customers using Windows 2016 at this time. We had decided to use System Center Virtual Machine Manager to be our management plane for our solutions. I am pretty sure Windows Admin Center (WAC) was not around yet. If it had been, it would have been referred to as Project Honolulu and it was no where the product it is now. We as in I built a lot of PowerShell scripts to do a lot of these deployments manually and to get S2D and SDN working correctly. Which was very difficult at times.

I think by early 2019 or late 2018 I was now digging deep into another new technology that Microsoft was releasing called Azure Stack. Long story short my focus went from S2D to Azure Stack, which then lead to renaming of S2D to Azure Stack HCI which renamed Azure Stack to Azure Stack Hub, and then a third member of the family was introduced as Azure Stack Edge, which previously was called Azure Data Box Edge.

Since then, while working at Microsoft Federal I worked a lot with all three products in the Azure Stack family. I took a short break when I left Microsoft to be a consultant but now my focus is yet again Azure Stack HCI.

## What is Azure Stack HCI?
Instead of re-inventing the wheel I am going to copy and paste from the following Microsoft Learn Document,[ Azure Stack HCI solution overview](https://learn.microsoft.com/en-us/azure-stack/hci/overview) but use AI to mix it up a little.

Azure Stack HCI is a hyperconverged infrastructure (HCI) to support virtualized Windows and Linux workloads. It seamlessly integrates on-premises systems with Azure cloud services, allowing for both storage and computing in a unified environment.

Azure Stack HCI is designed primarily for virtualization purposes. As such, the majority of applications and server roles should operate within virtual machines (VMs). However, there are certain exceptions like Hyper-V, Network Controller, and various elements essential for Software Defined Networking (SDN) or for overseeing and maintaining the well-being of the hosted VMs.

Azure Stack HCI is a top-tier virtualization platform constructed from trusted technologies such as Hyper-V, Storage Spaces Direct, and SDN inspired by Azure. It belongs to the Azure Stack lineage, utilizing the same software-defined resources for computing, storage, and networking as seen in Azure Stack Hub.

Every Azure Stack HCI cluster is made up of 1 to 16 certified physical servers. Regardless of whether it's a single server or multiple, all servers within the cluster share resources and configurations using the Windows Server Failover Clustering capability.

Azure Stack HCI combines the following:

* Azure Stack HCI operating system
* Validated hardware from an OEM partner
* Azure hybrid services
* Windows Admin Center
* Hyper-V-based compute resources
* Storage Spaces Direct-based virtualized storage
* SDN-based virtualized networking using Network Controller (optional)

### When to use it over Azure Stack Hub or Azure Stack Edge?

[Azure Stack Hub](https://learn.microsoft.com/en-us/azure-stack/operator/azure-stack-overview?view=azs-2306), [Azure Stack HCI](https://learn.microsoft.com/en-us/azure-stack/hci/), and [Azure Stack Edge](https://learn.microsoft.com/en-us/azure/databox-online/)are all part of the [Azure Stack family](https://learn.microsoft.com/en-us/azure-stack/) but each serve distinct purposes within the Azure ecosystem. Let's understand each product's purpose and ideal use cases:

**Azure Stack Hub:**

- **Purpose**: Azure Stack Hub is an extension of Azure that brings the innovation of cloud computing to build and deploy hybrid applications anywhere. It offers a consistent cloud environment for application development, deployment, and management.
- **When to Use**:
  - When you need to run applications in on-premises datacenters with a consistent Azure experience.
  - If you operate in regions with connectivity or regulatory constraints that prevent the use of the global Azure cloud.
  - When you wish to develop once and deploy in Azure or on-premises without modifying the code.

**Azure Stack HCI:**

- **Purpose**: Azure Stack HCI is a hyperconverged solution that integrates compute, storage, and networking on existing hardware, letting you run virtualized Windows and Linux workloads. It's a part of the Azure Stack family but specifically targets virtualization use cases.
- **When to Use**: 
  - When you're looking for a hyperconverged infrastructure (HCI) solution for virtualized workloads.
  - If you aim to modernize and consolidate your on-premises infrastructure while still integrating with Azure services.
  - When you want to scale compute and storage resources separately.

**Azure Stack Edge:**

- **Purpose**: Azure Stack Edge is a cloud-managed appliance that brings Azure's compute, storage, and machine learning capabilities to the edge.
- **When to Use**:
  -For scenarios where you need to process data locally due to latency, connectivity, or regulatory requirements.
  If you need to analyze, transform, and filter data at the edge before sending it to Azure.
  When you want to deploy and run containerized applications at the edge.
  If you require built-in AI capabilities at the edge, such as models for anomaly detection, image recognition, etc.

In summary, the choice between these three options boils down to your specific needs:

**Azure Stack Hub** is suitable for a full hybrid cloud experience with app consistency.

**Azure Stack HCI** is ideal for hyperconverged infrastructure needs with virtualization.

**Azure Stack Edge** is the go-to for edge computing and AI scenarios where local data processing is essential.

## What are some use cases?

There are many use cases that I can think of when it comes to why Azure Stack HCI. For me and the work I do a lot of our customers need the performance on premises to host applications that they can't yet move to the cloud.  They don't want to pay the cost for a solution like VMWare, which is a very trusted solution in itself, but over they need a cheaper alternative that also provides scalability and performance that matches.

Microsoft Learn has some great documentation about other use cases for Azure Stack HCI.  Please read the following documentation [Common use cases for Azure Stack HCI](https://learn.microsoft.com/en-us/azure-stack/hci/overview#common-use-cases-for-azure-stack-hci). I included some below:

Customers often choose Azure Stack HCI in the following scenarios.

| Use case                                          | Description                             |
| :------------------------------------------------ | :-------------------------------------- |
| Branch office and edge                            | For branch office and edge workloads, you can minimize infrastructure costs by deploying two-node clusters with inexpensive witness options, such as Cloud Witness or a USB drive–based file share witness. Another factor that contributes to the lower cost of two-node clusters is support for switchless networking, which relies on crossover cable between cluster nodes instead of more expensive high-speed switches. Customers can also centrally view remote Azure Stack HCI deployments in the Azure portal. To learn more about this workload, see [Deploy branch office and edge on Azure Stack HCI](deploy/branch-office-edge.md).|
| Virtual desktop infrastructure (VDI)              | Azure Stack HCI clusters are well suited for large-scale VDI deployments with RDS or equivalent third-party offerings as the virtual desktop broker. Azure Stack HCI provides additional benefits by including centralized storage and enhanced security, which simplifies protecting user data and minimizes the risk of accidental or intentional data leaks. To learn more about this workload, see [Deploy virtual desktop infrastructure (VDI) on Azure Stack HCI](deploy/virtual-desktop-infrastructure.md).|
| Highly performant SQL Server                      | Azure Stack HCI provides an additional layer of resiliency to highly available, mission-critical Always On availability groups-based deployments of SQL Server. This approach also offers extra benefits associated with the single-vendor approach, including simplified support and performance optimizations built into the underlying platform. To learn more about this workload, see [Deploy SQL Server on Azure Stack HCI](deploy/sql-server.md).|
| Trusted enterprise virtualization                 | Azure Stack HCI satisfies the trusted enterprise virtualization requirements through its built-in support for Virtualization-based Security (VBS). VBS relies on Hyper-V to implement the mechanism referred to as virtual secure mode, which forms a dedicated, isolated memory region within its guest VMs. By using programming techniques, it's possible to perform designated, security-sensitive operations in this dedicated memory region while blocking access to it from the host OS. This considerably limits potential vulnerability to kernel-based exploits. To learn more about this workload, see [Deploy Trusted Enterprise Virtualization on Azure Stack HCI](deploy/trusted-enterprise-virtualization.md).|
| Azure Kubernetes Service (AKS)                    | You can leverage Azure Stack HCI to host container-based deployments, which increases workload density and resource usage efficiency. Azure Stack HCI also further enhances the agility and resiliency inherent to Azure Kubernetes deployments. Azure Stack HCI manages automatic failover of VMs serving as Kubernetes cluster nodes in case of a localized failure of the underlying physical components. This supplements the high availability built into Kubernetes, which automatically restarts failed containers on either the same or another VM. To learn more about this workload, see [What is Azure Kubernetes Service on Azure Stack HCI and Windows Server ?](/azure/aks/hybrid/overview).|
| Scale-out storage                                 | Storage Spaces Direct is a core technology of Azure Stack HCI that uses industry-standard servers with locally attached drives to offer high availability, performance, and scalability. Using Storage Spaces Direct results in significant cost reductions compared with competing offers based on storage area network (SAN) or network-attached storage (NAS) technologies. These benefits result from an innovative design and a wide range of enhancements, such as persistent read/write cache drives, mirror-accelerated parity, nested resiliency, and deduplication.|
| Disaster recovery for virtualized workloads       | An Azure Stack HCI stretched cluster provides automatic failover of virtualized workloads to a secondary site following a primary site failure. Synchronous replication ensures crash consistency of VM disks.|
| Data center consolidation and modernization       | Refreshing and consolidating aging virtualization hosts with Azure Stack HCI can improve scalability and make your environment easier to manage and secure. It's also an opportunity to retire legacy SAN storage to reduce footprint and total cost of ownership. Operations and systems administration are simplified with unified tools and interfaces and a single point of support.|
| Run Azure services on-premises                    | Azure Arc allows you to run Azure services anywhere. This allows you to build consistent hybrid and multicloud application architectures by using Azure services that can run in Azure, on-premises, at the edge, or at other cloud providers. Azure Arc enabled services allow you to run Azure data services and Azure application services such as Azure App Service, Functions, Logic Apps, Event Grid, and API Management anywhere to support hybrid workloads. To learn more, see [Azure Arc overview](/azure/azure-arc/overview).|

So now I am doing copying and pasting from Microsoft Learn, I will start working on my fist blog of this series, **Azure Stack HCI - Part II - Deploying a single node HCI cluster**.
