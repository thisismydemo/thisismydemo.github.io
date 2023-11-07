---
title: Azure Stack HCI - Part IX - Azure Kubernetes Service Deployment
description: This is a series of blogs about my experiences with Azure Stack HCI
date: 2023-11-07T19:23:51.708Z
preview: /img/azshci-series/part-ix/aks-hci-architecture-focused.png
draft: false
tags:
    - Azure Arc
    - Azure Kubernetes Service
    - Azure Stack HCI
    - WIndows Admin Center
categories:
    - Azure Stack HCI
lastmod: 2023-11-07T19:27:45.369Z
thumbnail: /img/azshci-series/part-ix/aks-hci-architecture-focused.png
lead: This is a series of blogs about my experiences with Azure Stack HCI
slug: azure-stack-hci-part-ix-azure-kubernetes-service-deployment
---
In this blog series I plan to blog about everything I know about Azure Stack HCI. So, it should be a very short blog series. Just kidding. Again, I tend to blog about subjects that I am currently working on or will be currently working on. So, Azure Stack HCI is fresh on my mind again these days.

I now have Azure Stack HCI cluster deployed. We can manage it using Windows Admin Center or PowerShell. In later blogs I will go into how to us Azure Arc services to manage our workloads that we will deploy on our cluster. This blog I want to focus on deploying Azure Kubernetes Service and deploying an AKS host on my HCI cluster. This will enable my me to deploy Kubernetes clusters for various workloads later.

The following will be covered in this blog:

- [Requirements](#requirements)
  - [Active Directory Requirements](#active-directory-requirements)
  - [Hardware Requirements](#hardware-requirements)
    - [Maximum Support Hardware](#maximum-support-hardware)
  - [Compute Requirements](#compute-requirements)
    - [Minimum memory requirements](#minimum-memory-requirements)
    - [Recommend Compute](#recommend-compute)
  - [Storage Requirements](#storage-requirements)
  - [Network Requirements](#network-requirements)
    - [IP Address Assignment](#ip-address-assignment)
    - [Minimum IP Address Reservation](#minimum-ip-address-reservation)
    - [Network port and URL Requirements](#network-port-and-url-requirements)
    - [Azure Arc Requirements](#azure-arc-requirements)
  - [Windows Admin Center Requirements](#windows-admin-center-requirements)
  - [Azure Requirements](#azure-requirements)
    - [Azure account and Subscription](#azure-account-and-subscription)
    - [Microsoft Entra Permissions](#microsoft-entra-permissions)
    - [Azure subscription role and access level](#azure-subscription-role-and-access-level)
    - [Azure resource group](#azure-resource-group)
- [Deploying Azure Kubernetes Hosts](#deploying-azure-kubernetes-hosts)
- [Final Thought](#final-thought)

-----

## Requirements

Just like with anything there are some requirements that we will need to met in order to deploy and configure AKS on our Azure Stack HCI cluster. The following requirements can be found also on the Microsoft Learn documentation, https://learn.microsoft.com/en-us/azure/aks/hybrid/system-requirements?tabs=allow-table

### Active Directory Requirements

For effective operation of AKS on Azure Stack HCI and Windows Server or Windows Server Datacenter failover clusters with two or more physical nodes in an Active Directory setup, follow these recommendations:

 - Active Directory is not required for single-node deployments of Azure Stack HCI or Windows Server.
 - Time Synchronization: Ensure all cluster nodes and the domain controller have a time difference of no more than 2 minutes. Use the Windows Time Service for guidance on configuring time sync.
 - User Account Permissions: Accounts used for managing AKS on Azure Stack HCI and Windows Server or Windows Server Datacenter clusters must have adequate Active Directory permissions. This includes necessary permissions within Organizational Units (OUs) if they are utilized for group policies.
 - Organizational Unit (OU): Dedicate an OU for the servers and services in your clusters to better manage access and permissions.
 - GPO Templates: Exclude AKS deployments on Azure Stack HCI and Windows Server from GPO templates to avoid conflicts, with server hardening policies to be addressed in a future update.

### Hardware Requirements

To get the best performance and compatibility for Azure Stack HCI, I suggest buying a hardware/software solution that has been tested and approved by Microsoft partners. These solutions follow their design guidelines and ensure that everything works well together. We also need to make sure that the systems, components, devices, and drivers we will use have the Windows Server Certified label from the Windows Server Catalog. For more information, please visit the website for Azure Stack HCI solutions.

#### Maximum Support Hardware

Resource | Maximum
------- | -------
Physical servers per cluster | 8
Total number of VMs | 200

### Compute Requirements

#### Minimum memory requirements

Cluster type | Control plane VM size | Worker node | For update operations | Load balancer
-------------|-----------------------|-------------|-----------------------|--------------
AKS Host | Standard_A4_v2 VM size = 8GB | NA - AKS host doesn't have worker nodes | 8GB | NA - AKS host uses kubevip for load balancing
Workload cluster | Standard_A4_v2 VM size = 8GB | Standard_K8S3_v1 for 1 worker node = 6GB | Can re-use the 8GB reserved above for workload cluster upgrade | NA if kubevip is used for load balancing (instead of the default HAProxy load balancer)
Total minimum requirement | 30GB RAM

#### Recommend Compute

Environment | CPU cores per server | RAM
------------|----------------------|----
Azure Stack HCI or Windows Server cluster | 32 | 256 GB
Windows Server failover cluster | 32 | 256 GB
Single node Windows Server | 16 | 128 GB

### Storage Requirements

Name | Storage type | Required capacity
-----|--------------|------------------
Azure Stack HCI Cluster | Cluster Shared Volumes | 1 TB
Windows Server Datacenter failover cluster | Cluster Shared Volumes | 1 TB
Single-node Windows Server Datacenter | Direct Attached Storage | 500 GB

### Network Requirements

When setting up an Azure Stack HCI cluster or a Windows Server Datacenter cluster, several critical networking requirements must be met. You must have a uniform external virtual switch pre-configured across all cluster nodes, which is essential if using Windows Admin Center. Disabling IPv6 on all network adapters is necessary. All cluster nodes, along with the Kubernetes cluster VMs, need external internet access to deploy successfully. It’s crucial to ensure that all subnets designated for the cluster are capable of intercommunication and have internet access, and there must be network connectivity between the Azure Stack HCI hosts and tenant VMs. DNS name resolution must be functional for intra-node communication. Additionally, it is advisable to enable dynamic DNS updates to facilitate the automatic registration of AKS on Azure Stack HCI and Windows Server components in the DNS for easier discovery.

#### IP Address Assignment

In deploying AKS on Azure Stack HCI and Windows Server, virtual networks distribute IP addresses to necessary Kubernetes resources, with two networking models available to match your architectural preferences. These models are separate from your data center's physical network structure. In the Static IP networking model, fixed IP addresses are designated to components like the Kubernetes cluster API server, nodes, VMs, load balancers, and services. Alternatively, the DHCP networking model uses a DHCP server to assign dynamic IPs to the nodes, VMs, and load balancers, while the Kubernetes cluster API server and services maintain static IPs.

#### Minimum IP Address Reservation

Cluster type | Control plane node | Worker node | For update operations | Load balancer
-------------|--------------------|-------------|-----------------------|--------------
AKS Host | 1 IP | NA | 2 IP | NA
Workload cluster | 1 IP per node | 1 IP per node | 5 IP | 1 IP

Resource type | Number of IP addresses
--------------|-----------------------
Cluster API server | 1 per cluster
Kubernetes Services | 1 per service

#### Network port and URL Requirements

Port | Source | Description | Firewall Notes
-----|--------|-------------|---------------
22 | AKS VMs | Required to collect logs when using Get-AksHciLogs | If using separate VLANs, the physical Hyper-V Hosts need to access the AKS VMs on this port.
6443 | AKS VMs | Required to communicate with Kubernetes APIs | If using separate VLANs, the physical Hyper-V Hosts need to access the AKS VMs on this port.
45000 | Physical Hyper-V Hosts | wssdAgent gRPC Server | No cross-VLAN rules are needed.
45001 | Physical Hyper-V Hosts | wssdAgent gRPC Authentication | No cross-VLAN rules are needed.
46000 | AKS VMs | wssdCloudAgent to lbagent | If using separate VLANs, the physical Hyper-V Hosts need to access the AKS VMs on this port.
55000 | Cluster Resource (-CloudServiceCIDR) | Cloud Agent gRPC Server | If using separate VLANs, the AKS VMs need to access the Cluster Resource's IP on this port.
65000 | Cluster Resource (-CloudServiceCIDR) | Cloud Agent gRPC Authentication | If using separate VLANs, the AKS VMs need to access the Cluster Resource's IP on this port.

URL | Port | Notes
----|------|------
msk8s.api.cdp.microsoft.com | 443 | Used when downloading the AKS on Azure Stack HCI product catalog, product bits, and OS images from SFS. Occurs when running Set-AksHciConfig and any time you download from SFS.
msk8s.b.tlu.dl.delivery.mp.microsoft.com
msk8s.f.tlu.dl.delivery.mp.microsoft.com | 80 | Used when downloading the AKS on Azure Stack HCI product catalog, product bits, and OS images from SFS. Occurs when running Set-AksHciConfig and any time you download from SFS.
login.microsoftonline.com
login.windows.net
management.azure.com
msft.sts.microsoft.com
graph.windows.net | 443 | Used for logging into Azure when running Set-AksHciRegistration.
ecpacr.azurecr.io
mcr.microsoft.com
*.mcr.microsoft.com
*.data.mcr.microsoft.com
*.blob.core.windows.net
US endpoint: wus2replica*.blob.core.windows.net | 443 | Required to pull container images when running Install-AksHci.
<region>.dp.kubernetesconfiguration.azure.com | 443 | Required to onboard AKS hybrid clusters to Azure Arc.
gbl.his.arc.azure.com | 443 | Required to get the regional endpoint for pulling system-assigned Managed Identity certificates.
*.his.arc.azure.com | 443 | Required to pull system-assigned Managed Identity certificates.
k8connecthelm.azureedge.net | 443 | Arc-enabled Kubernetes uses Helm 3 to deploy Azure Arc agents on the AKS-HCI management cluster. This endpoint is needed for the Helm client download to facilitate deployment of the agent helm chart.
*.arc.azure.net | 443 | Required to manage AKS hybrid clusters in Azure portal.
dl.k8s.io | 443 | Required to download and update Kubernetes binaries for Azure Arc.
akshci.azurefd.net | 443 | Required for AKS on Azure Stack HCI billing when running Install-AksHci.
v20.events.data.microsoft.com
gcs.prod.monitoring.core.windows.net | 443 | Used periodically to send Microsoft required diagnostic data from the Azure Stack HCI or Windows Server host.

#### Azure Arc Requirements

The provided list of URLs is the essential set for linking your AKS service on Azure Stack HCI with Azure for billing purposes. Should you wish to utilize additional features such as cluster connect, custom locations, Azure RBAC, Azure Monitor, or other Azure services within your AKS workload cluster, further URLs will need to be permitted. For an exhaustive inventory of necessary URLs, please refer to the network requirements for Azure Arc enabled Kubernetes. Additionally, it is advisable to check the Azure Stack HCI URLs, especially considering that, starting with Azure Stack HCI version 21H2, Arc for server agents come pre-installed on nodes, and thus, their specific URLs should also be examined.

### Windows Admin Center Requirements

Windows Admin Center serves as the interface for setting up and managing AKS on Azure Stack HCI and Windows Server. To effectively utilize Windows Admin Center for these services, the gateway machine must fulfill several prerequisites: it must be a Windows 10 or Windows Server machine, registered with Azure, part of the same domain as the Azure Stack HCI or Windows Server Datacenter cluster, and connected to an Azure subscription where you have Owner-level access. You can verify your level of access through the "Access control (IAM)" section within the Azure portal by selecting "View my access."

### Azure Requirements

#### Azure account and Subscription

To integrate AKS on Azure Stack HCI and Windows Server with your Azure account, you must have an existing Azure account and subscription. If you don't have one, you can create a new Azure account and choose from various subscription types, including free accounts with credits for students or Visual Studio subscribers, pay-as-you-go, Enterprise Agreement (EA), or through the Cloud Solution Provider (CSP) program.

#### Microsoft Entra Permissions

Regarding permissions, you need the appropriate authority in Microsoft Entra to register an application with your Azure tenant. Verify your permissions by checking your role in the "Roles and administrators" section under Microsoft Entra ID in the Azure portal. If you're a 'User,' confirm that non-administrators are allowed to register applications in the "User settings" under Microsoft Entra. If app registration is restricted, you'll need an administrator role or approval from an administrator who can modify these settings.

#### Azure subscription role and access level

For your Azure subscription access level, confirm your status by selecting "Access control (IAM)" and then "View my access" within the Azure portal. When deploying an AKS Host or workload cluster via Windows Admin Center, you must be an Owner of the subscription. Alternatively, if using PowerShell for deployment, you must possess the Owner role or use a service principal with at least a Contributor or Owner role.

If you're under an EA or CSP subscription and lack sufficient permissions, the recommended approach is to have your Azure administrator create a service principal with the necessary permissions. Admins should refer to the guidance on creating a service principal for detailed instructions.

#### Azure resource group

We need resource groups that are in the supported regions:

* Australia East
* East US
* Southeast Asia
* West Europe

-----

## Deploying Azure Kubernetes Hosts

When setting up AKS on Azure Stack HCI, you deploy a management host which is a virtual machine that acts as the gateway between the on-premises environment and Azure services. This host is where you install Windows Admin Center and the AKS extension. The management host is responsible for a range of functions including:

- Cluster Creation and Management: Through the Windows Admin Center, the management host allows administrators to deploy, view, and manage Kubernetes clusters.
- Integration with Azure: The management host connects to Azure to provide hybrid capabilities. This includes accessing Azure services like Azure Monitor, Azure Security Center, and implementing Azure RBAC for Kubernetes authorization.
- Lifecycle Operations: The management host facilitates various lifecycle operations such as updating and scaling the Kubernetes clusters, applying patches, and performing upgrades.
- Networking: It helps configure the networking for the Kubernetes clusters, ensuring that the containers can communicate with each other and the host environment properly.
- Resource Management: It manages the allocation of resources to the Kubernetes clusters, ensuring that they have the necessary compute, storage, and networking resources.
- Security: The management host helps enforce security policies and integrates with Azure Arc for governance and compliance across hybrid Kubernetes deployments.

The deployment process typically involves setting up the Windows Admin Center on a Windows Server VM, registering it with Azure, and then using the AKS extension to create and manage Kubernetes clusters on Azure Stack HCI. The VM must have access to the necessary Azure URLs for billing and other Azure services, and it must have appropriate permissions set up in Azure to register applications and perform required operations.

This management infrastructure ensures that the Kubernetes clusters on Azure Stack HCI can be managed as seamlessly as if they were running in Azure itself, providing a consistent management experience across both environments.

![](/img/azshci-series/part-ix/aks-hci-architecture-focused.png)

There are two ways we can deploy the Azure Kubernetes Service on HCI. We can use the Windows Admin Center or deploy via PowerShell. In this blog I choose to do it via the Windows Admin Center but I will also provide a blog later on how to deploy the management cluster using PowerShell.

The first step is to logon to our Windows Admin Center,then go to our Cluster Manager and select our cluster we will be deploying AKS.  From there we will click on the Azure Kubernetes Service under Cluster Resource section. Here we will click Setup to continue.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20083341.png)

On the next page, Setup Azure Kubernetes Service Hybrid, we will click on Next: System Checks. Here there is a link to review the completed requirements. Those requirements I also post at the beginning of this document.  It will have a short summary of requirements needed on this page as well.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20083608.png)

On the first page for the System CHecks, we will need to put in our Active Directory password for our account that has admin rights to all servers in this cluster. It will verify that password and then continue.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20083751.png)

This will then kick off a system check. This can take some time. So go get some coffee.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20083822.png)

The system check should be done and we can review any changes that will take place if any are needed. An Install button should now be available toward the top of the window. Here we will click install and it will install all the necessary changes listed on this screen.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20085138.png)

Once the required changes are done and installed, we should be able to continue by clicking the Next: Credential delegation button.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20090038.png)

On the Credential delegation we will click the Enable button to enable credential delegation. This will allow CredSSP to be enabled so that hte Windows Admin Center can pass credentials to servers in this cluster.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20090114.png)

After we have enabled credential delegation we will then be prompted to click Next: Host Configuration. On the Host Configuration screen we will have more decisions to make. Many more. Here we will decide the following:

- Management Cluster Name
- Folder to Store VM Images
- VM Networking
  - Virtual Switch
  - If we use Vlans
  - Our Cloudagent IP
  - The big one, do we go static or dhcp?

For my environment, this is a lab, so I will keep it simple and go DHCP.  The first image blow is all the fields you would need to populate if you went with the static choice.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20092821.png)

This next image is the direction I went, I picked DHCP. The only few important items here is the Cloudagent IP and the Kubernetes node IP pool start and stop.  For my blog and lab I kept the default Management Cluster Name. I selected the only vSwithch I have configured. If you remember in previous blogs I used the single Network ATC intent for all, storage, compute, and management. In theory, you could create another compute intent just for Kubernetes.

I am not using any VLANS in this lab and I choose DHCP.  I picked an IP out of a range I will be using, 10.0.0.100 then for the load balancer settings my pool was from 10.0.0.100 - 10.0.0.200.  (cough cough)

I don't need to configure a proxy. So now, we can click Next: Azure Registration.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20093047.png)

On the Azure Registration section, I selected the right Subscription, and created a new Resource Group for these resources to be stored in Azure. _Also, a very big important thing, I couldn't select South Central US because that region doesn't currently support AKS hybrid registration. AKS hybrid registration is currently only supported in the following regions: West Europe, East US, Southeast Asia, Australia East, Central India._

We can now click Next: Review and Validation

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20093404.png)

Here we can validate all our settings are correct. Then we can click the Validate Configuration button.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20093531.png)

Then we wait while the system is validated.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20093602.png)

Oh My!!  (I hinted toward this in a previous step, did you catch my cough cough moment?) My CloudServiceIP I picked was in the same range as my IP pool. So, we click back and back to fix it.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20094235.png)

After a few minutes. More like an hour and plenty of coffee trips, we now have all success statuses except for our Validate KVA, this is the Kubernetes Virtual Appliance, a VM that will run, our management VM in fact.  We do now have the option to click Next: New Cluster

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20110017.png)

Now we will wait for a while. We can see that in our notification window that we are now Installing AKS Hybrid.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20110047.png)

And we wait and wait while we watch this screen do nothing for a good time. THen again, we can get more coffee? You ever have a bulletproof coffee? If you have been on the Keto diet, more than likely you have. Oh, very good fatty coffee!! Check it out.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20110103.png)

Finally, after a long 18 minutes my AKS Hybrid solution is installed!

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20112107.png)

Now if we go to our Azure Kubernetes Service window in Windows Admin Center we can see the status of our Hybrid service, and any status of any clusters running now.

![](/img/azshci-series/part-ix/Screenshot%202023-11-07%20112308.png)

-----

## Final Thought

Well, I now have the capabilities to deploy Azure Kubernetes cluster to my Azure Stack HCI. That will be another blog post much later. I have a lot more to write first. It wasn't too hard, then again, I did it in a lab, I was my own security guy, my own networking guy, my own compute and storage guy, so it made things a lot easier. I am looking forward to more blogs about this experience.