---
title: "Odin for Azure Local: A Community Tool Deep Dive"
description: An in-depth review of Microsoft's community-built Azure Local configuration wizard—what works, what's coming, and the gaps you need to know about.
date: 2026-02-09T16:56:18.598Z
draft: false
preview: /img/azurelocal_odin/odin-logo.png
fmContentType: post
slug: odin-azure-local-community-tool-deep-dive
lead: The Optimal Deployment and Infrastructure Navigator
thumbnail: /img/azurelocal_odin/odin-logo.png
categories:
  - Azure Local
  - Community Tools
tags:
  - ARM Templates
  - Azure Local
  - Community Tools
  - Deployment Planning
  - Infrastructure as Code
  - ODIN
lastmod: 2026-02-09T17:08:42.404Z
---

I'm in the middle of writing [The Hyper-V Renaissance](/post/hyper-v-renaissance)—an 18-part series making the case for traditional Hyper-V with Windows Server 2025 as a serious virtualization platform. It's been consuming most of my writing time, and I've been heads-down on TCO comparisons, cluster builds, and PowerShell automation.

But sometimes you stumble across something that deserves its own post, and you have to step away from the main project for a minute.

There's a new community tool for Azure Local that's worth your attention. It's called **Odin**—the "**O**ptimal **D**eployment and **I**nfrastructure **N**avigator"—and it's hosted right on Microsoft's GitHub. Before you get too excited, let me set expectations: this tool comes with a clear disclaimer that it's provided "as-is, without Microsoft support." It's experimental.

But it's also genuinely useful, and it reveals some interesting things about where Azure Local is headed.

I've spent some time clicking through every option, and I want to share what I found—the good, the gaps, and the "coming soon" features that hint at Microsoft's roadmap. Then it's back to the Hyper-V series.

**Tool URL**: [azure.github.io/odinforazurelocal](https://azure.github.io/odinforazurelocal/)

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [What Is Odin for Azure Local?](#what-is-odin-for-azure-local)
- [The Three Pillars of Odin](#the-three-pillars-of-odin)
- [Odin Sizer Tool](#odin-sizer-tool)
  - [First Impressions \& Inputs](#first-impressions--inputs)
  - [Workload Scenario Section](#workload-scenario-section)
  - [Sizing Notes \& Observations](#sizing-notes--observations)
  - [Room for Growth \& Community Momentum](#room-for-growth--community-momentum)
- [Odin Knowledge](#odin-knowledge)
  - [What You'll Learn](#what-youll-learn)
  - [Sidebar Navigation](#sidebar-navigation)
  - [Public Path vs. Private Path: The Core Decision](#public-path-vs-private-path-the-core-decision)
  - [Arc Gateway Benefits](#arc-gateway-benefits)
  - [Private Endpoints Deep Dive](#private-endpoints-deep-dive)
  - [Configuration Scripts](#configuration-scripts)
  - [My Take](#my-take)
- [Odin Designer (Main Configuration Wizard)](#odin-designer-main-configuration-wizard)
  - [Section 01: Deployment Type](#section-01-deployment-type)
  - [Section 02: Azure Cloud](#section-02-azure-cloud)
  - [Section 03: Region](#section-03-region)
  - [Section 04: Cluster Configuration](#section-04-cluster-configuration)
  - [Section 05: Cluster Size](#section-05-cluster-size)
  - [Section 05.5: Cloud Witness](#section-055-cloud-witness)
  - [Section 06: Storage Connectivity](#section-06-storage-connectivity)
  - [Section 07: Network Adapter Ports](#section-07-network-adapter-ports)
  - [Section 08: Network Traffic Intents](#section-08-network-traffic-intents)
  - [Section 09: Outbound Connectivity](#section-09-outbound-connectivity)
  - [Section 10: Arc Gateway](#section-10-arc-gateway)
  - [Section 11: Proxy Configuration](#section-11-proxy-configuration)
  - [Section 12: Private Endpoints](#section-12-private-endpoints)
  - [Section 13: Management Connectivity](#section-13-management-connectivity)
  - [Section 14: Management VLAN](#section-14-management-vlan)
  - [Section 15: Infrastructure Network](#section-15-infrastructure-network)
  - [Section 16: Storage Pool Configuration](#section-16-storage-pool-configuration)
  - [Section 17: Active Directory](#section-17-active-directory)
  - [Section 18: Security Configuration](#section-18-security-configuration)
  - [Section 19: Software Defined Networking](#section-19-software-defined-networking)
  - [Generating Reports and ARM Templates](#generating-reports-and-arm-templates)
  - [Designer: Final Thoughts](#designer-final-thoughts)
- [Summary: Strengths, Gaps \& Wishlist](#summary-strengths-gaps--wishlist)
- [Who Should Use Odin?](#who-should-use-odin)
- [Conclusion](#conclusion)
- [Resources](#resources)
  - [Odin Links:](#odin-links)
  - [Microsoft Documentation:](#microsoft-documentation)


---
![](/img/azurelocal_odin/Screenshot%202026-02-04%20205904.png)

## What Is Odin for Azure Local?

Odin is a browser-based wizard that walks you through the decisions required to configure an Azure Local deployment. It's a decision tree—you make selections, and it guides you through the implications of those choices.

The tool covers:

- Deployment type (Hyperconverged, Multi-Rack, Disconnected, M365 Local)
- Azure cloud and region selection
- Cluster configuration and sizing
- Storage connectivity options
- Network adapter and traffic intent configuration
- Outbound connectivity and proxy settings
- Identity (Active Directory or Local Identity with Key Vault)
- Security configuration
- Software Defined Networking options

At the end, you can preview your cluster configuration, generate a detailed design document explaining the decision logic behind your selections, and export ARM deployment parameters (with placeholders for uncollected values). 

The current version is **0.14.52**, but when when i first started to write this blog it was written for version 0.12.5.  Since then the group that maintains this tool has acatually been very responsive to feed back and even from my oringaial blog to what I will be publishing the Designer part of Odin for Azure Local has changed greatly.

Odin also includes:
- A **Sizer tool** for estimating cluster capacity based on workloads (Azure Local VMs, AKS Arc clusters, Azure Virtual Desktop)
- A **Knowledge base** with in-depth guidance on outbound connectivity, Arc Gateway, and private endpoints

As an open-source, community-built tool hosted on GitHub (`https://github.com/azure/odinforazurelocal`), Odin comes with a clear disclaimer: it's provided "as-is, without Microsoft support" and is experimental. However, it's actively maintained and helps IT architects validate cluster designs and accelerate Azure Local learning.

---

## The Three Pillars of Odin

Odin is built around three interconnected tools that address different phases of Azure Local planning:

1. **Designer** — The main configuration wizard that generates deployment parameters and documentation
2. **Knowledge Base** — Deep-dive documentation on connectivity, networking, and architecture decisions
3. **Sizer Tool** — Capacity planning and workload estimation before you buy hardware

Each tool can be used independently, but they work best together: use the Sizer to understand your capacity needs, reference the Knowledge Base when you hit complex networking decisions, and run through the Designer to generate your baseline configuration. Let's look at each one.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20210010.png)

---

## Odin Sizer Tool

**Preview Release:** This tool helps you estimate Azure Local cluster requirements based on workload scenarios. Results are estimates and should be validated with your hardware vendor.

I'm genuinely excited to see a community-driven sizing tool for Azure Local! Odin's Sizer is a fresh step in the right direction—making it easier for architects and engineers to get a quick sense of what their clusters might need, even if it's still a work in progress.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20210102.png)

### First Impressions & Inputs

The Sizer starts with the basics, just like any good sizing tool:

- Number of nodes
- Cluster type (Standard Cluster or Rack Aware Cluster—just hit GA in January!)
- Storage resiliency (Two-way or Three-way mirror)

One thing I immediately noticed: there's no way to specify the number of disks per node, disk type (NVMe, SSD, etc.), or disk size. Maybe those options appear later, but as of now, storage input is pretty limited. This isn't a full Storage Spaces Direct sizing tool—it's focused on workload sizing, not hardware detail.

### Workload Scenario Section

Next up is the workload scenario section, where you add the workloads you want to run. This is where Odin Sizer really shines for quick planning:

- **Azure Local VMs**: Inputs for workload name, vCPUs per VM, memory per VM (GB), storage per VM (GB), and number of VMs.
- **Azure Virtual Desktop (AVD)**: Choose a user profile (Light, Medium, Power), number of users, and see the per-profile specs (vCPUs, memory, storage).
- **AKS Arc Clusters**: Name your workload, set the number of clusters, control plane node count/vCPUs/memory, and work node count/vCPUs/memory/storage.

Here's how I tested it:

**Scenario 1: 2-node Standard Cluster, Two-way Mirror**

- Nodes: 2
- Cluster type: Standard
- Storage resiliency: Two-way mirror

**Azure Local VMs**
- 4 vCPUs per VM
- 16 GB memory per VM
- 100 GB storage per VM
- 10 VMs

![](/img/azurelocal_odin/Screenshot%202026-02-04%20223647.png)

**Azure Virtual Desktop**
- Workload: Azure Virtual Desktop
- User profile: Power Users
- Number of users: 50
- (Profile specs: 2 vCPUs/user, 8 GB RAM/user, 80 GB storage/user)

![](/img/azurelocal_odin/Screenshot%202026-02-04%20223706.png)

**AKS Arc Clusters**
- Workload: AKS Arc Cluster
- Number of clusters: 5
- Control plane: 3 nodes, 4 vCPUs, 8 GB RAM per node
- Work nodes: 3 per cluster, 8 vCPUs, 16 GB RAM, 200 GB storage per node

![](/img/azurelocal_odin/Screenshot%202026-02-04%20223512.png)

As you add each scenario, the requirements summary and graphs update in real time—very handy for visualizing the impact of your choices.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20223534.png)

### Sizing Notes & Observations

The tool provides some helpful notes at the bottom:

> N+1 capacity: Requirements calculated assuming 1 node is available during maintenance
> Storage resiliency: Two-way mirror (2x raw storage)
> vCPU calculations assume 4:1 overcommit ratio
> Minimum per node: 32 GB RAM, 4 cores (Azure Local requirements)

I do wonder if the tool fully accounts for nodes being taken offline for updates, and whether it shows what workloads can run on a single node in a two-node cluster. There's definitely room for more detail and flexibility here, especially for those of us who do a lot of small, 2-node deployments.

### Room for Growth & Community Momentum

Overall, Odin Sizer is a fantastic start! It's not as deep as some vendor tools (like [Peter Teeling's Sizing Tool](https://thankful-coast-075a8e20f.1.azurestaticapps.net/)), but it's open, community-driven, and improving fast. I'd love to see more storage input options and maybe even some of the features from those more mature tools in the future.

If you're reading this and want to help, jump in! Community feedback and contributions will make Odin Sizer even better for everyone planning Azure Local deployments.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20225040.png)

---

## Odin Knowledge

The Knowledge section is Odin's comprehensive documentation hub but here's the key insight: it's currently laser-focused on a single, critical topic. The sidebar is titled **"Odin for Azure Local | Outbound Connectivity Guide v1.0"**, which tells me this is a deep dive into one of the most complex aspects of Azure Local deployments rather than a broad knowledge base.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20210041.png)

### What You'll Learn

The guide opens with a clear summary of what's covered:

- **Architecture Components**: Understanding core components including Azure Local machines, Arc Gateway, proxies, and networking infrastructure
- **Traffic Categorization**: Distinguishing between different types of network traffic and their routing paths
- **Configuration Steps**: Setting up proxies, firewall rules, and Arc Gateway registration
- **Best Practices**: When to use each architecture based on your requirements

### Sidebar Navigation

The sidebar breaks down into focused sections:

- Overview
- Architecture Comparison
- When to Use
- Private Endpoints Scenarios
- Reserved Subnets (ARB/AKS)
- Traffic Flows Comparison
- Traffic Categories
- AKS Subnet Requirements
- Configuration

### Public Path vs. Private Path: The Core Decision

The heart of this guide is helping you choose between two connectivity architectures:

**Public Path** (4 options available now):
- Traffic routes to Azure via public internet
- Uses on-premises proxy and firewall infrastructure
- Arc Gateway recommended to reduce firewall rules from hundreds to fewer than 30 endpoints
- Options range from no proxy/no Arc Gateway (simplest) to proxy + Arc Gateway (best security)

**Private Path** (coming soon):
- Traffic routes through ExpressRoute or Site-to-Site VPN—no public internet exposure
- Requires Azure Firewall Explicit Proxy hosted in Azure
- Arc Gateway required for HTTPS traffic
- Single validated configuration (no mix-and-match options)

The guide includes detailed comparison tables, traffic flow diagrams for each step (bypass, HTTP, HTTPS, ARB, AKS, VMs), and clear guidance on when to choose each architecture.

### Arc Gateway Benefits

One of the standout sections covers why Arc Gateway matters:

- **Better Security**: Fewer open connections reduce attack surface; firewall rules drop from hundreds to fewer than 30 endpoints
- **Easier Setup**: Leverage existing network infrastructure while Arc Gateway manages Azure connectivity
- **Simpler Management**: Fewer endpoints means easier tracking and troubleshooting

### Private Endpoints Deep Dive

The guide goes into excellent detail on Private Endpoints configuration for:

- Azure Key Vault (keep public during deployment, restrict after)
- Azure Storage/Blob (required for 2-node cloud witness)
- Azure Container Registry (no wildcards supported—specific FQDNs required)
- Azure Site Recovery (two routing options with SSL inspection considerations)

It also warns about reserved IP ranges for Arc Resource Bridge (10.244.0.0/16, 10.96.0.0/12)—if your private endpoints overlap these ranges, traffic will fail.

### Configuration Scripts

The guide includes ready-to-use PowerShell scripts for all four Public Path registration options, complete with proxy bypass examples and verification commands.

### My Take

Scanning through this Knowledge section, I'm impressed by the depth. It's not trying to cover everything—it's doing one topic extremely well. For anyone wrestling with Azure Local networking decisions, especially around Arc Gateway, private connectivity, and firewall rules, this is genuinely useful documentation.

I'd love to see Odin expand this approach to other complex topics (storage architecture, SDN configuration, identity options), but as a focused v1.0 on outbound connectivity, it delivers.

---

## Odin Designer (Main Configuration Wizard)

Last but not least—and what I think is the most important part of Odin—is the **Designer**!

> ***The following section I have tried to keep up to date since I frist started to use Odin.  However the team updating this tool is fixing and updating recommenations very fast and things that we had recommened to change have already been changed.***



The tool opens with a statement about what Odin is:

> Odin, the Norse god embodying strategic thinking and architecture, is your guide for Azure Local deployments. This Optimal Deployment and Infrastructure Navigator provides a decision tree interface to select an Azure Local deployment type, and instance design using validated architecture and network configuration.

From my viewpoint—someone who already has a lot of the deployment automated and pretty decent documentation built around design and implementation—I was very impressed with the Designer out of the box. I ran into some UI issues, but those can be fixed. Since this is not fully released and not an official Microsoft product, it's something that can be of use for those just starting their journey with Azure Local.

That said, whoever uses this tool needs a good understanding and core knowledge of Hyper-V, Storage Spaces Direct, and the basics of what Azure Local is, what Software Defined Networking is, Active Directory, and so on.

**There's also a big disclaimer at the top of the page—please read it!**

> Disclaimer: This tool is provided as-is, without Microsoft support. Odin is an experimental project that accelerates skills and knowledge ramp up for Azure Local, and helps IT architects validate cluster design configurations.

The Designer is split into sections. On the right side of the page is a progress and configuration summary section that updates as you make your selections. In some ways, this is an Azure Local Planning "Choose Your Own Adventure" being led by the Norwegian God Odin!

Let's walk through each section.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20230614.png)

### Section 01: Deployment Type

Each option enables other options with various different choices. The deployment types are:

- **Hyperconverged**: What we're all used to with Azure Stack HCI, Windows Storage Spaces Direct, vSAN, and now Azure Local. Hyperconverged means compute, storage, and network together.
- **Multi-Rack Clusters**: Just went GA in the 2601 release of Azure Local.
- **Disconnected**: Air-gapped operation with local management.
- **M365 Local**: Microsoft's new sovereign cloud solution.

For this blog, I'm picking **Hyperconverged** as my deployment type.

*Note: With each section there are help and information links that are very useful.*

![](/img/azurelocal_odin/Screenshot%202026-02-04%20230631.png)

### Section 02: Azure Cloud

Options include:
- Azure Commercial (Public Cloud)
- Azure Government
- Azure China

I don't know if Azure Local is even supported in Azure China yet—it may be in Private Preview. Azure Government was announced not long ago but is only in one region at this time. Azure Public only has two US regions available for Azure Local currently.

I'll pick **Azure Commercial** for Step 2.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20230757.png)

### Section 03: Region

As soon as I select Azure Commercial, step three becomes active. This is where I pick what region I'm placing my Azure Local resources in. I'll choose **South Central US**—the only other US region is East US at this time.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20230832.png)

### Section 04: Cluster Configuration

Options include:
- **Hyperconverged Low Capacity** — [Still in preview](https://learn.microsoft.com/azure/azure-local/concepts/system-requirements-small-23h2)
- **Hyperconverged** — Standard configuration
- **Hyperconverged Rack Aware** — [Just went GA in build 2601](https://learn.microsoft.com/azure/azure-local/concepts/rack-aware-cluster-overview)

I'm selecting **Hyperconverged**.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20231147.png)

### Section 05: Cluster Size

For this blog, I'm picking **3 nodes**. Most of my clusters have been 2-node deployments, but I wanted to pick 3 nodes because it gives us more options in upcoming steps like witness configuration, mirroring options, and so on.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20231215.png)

### Section 05.5: Cloud Witness

For two nodes, a witness is a must. However, with 3 or more nodes you don't technically have to have a witness. I don't understand why not—in my mind, even a 3-node cluster should have a witness. In fact, my 4-node clusters still use a witness.

More info on [cluster witnesses](https://learn.microsoft.com/windows-server/failover-clustering/deploy-quorum-witness).

![](/img/azurelocal_odin/Screenshot%202026-02-04%20231324.png)

### Section 06: Storage Connectivity

Here we have a big decision that should have already been made before you even start. Did you buy expensive top-of-rack switches that may be overkill in price just for 2 or 3 node solutions?

For some people, the cost of 2 top-of-rack switches that meet Microsoft's networking requirements can lead to a big price tag for this project. Hence why you can do **switchless**.

Switchless doesn't mean you don't need switches—you still need switches for management and compute traffic, but those requirements are not as rigid. Switchless just means the storage is connected on network adapters that are connected directly between nodes and not going through a switch. This is great for 2 or 3 node solutions. Some do it with 4, but more nodes means more network adapters, which means higher cost.

Something to keep in mind is growth. If you're going to scale out these clusters past 3 nodes, I would stay with storage switched. If you don't and have to grow later, this means a redeployment of your cluster.

I'm going to do **Storage Switched**. Once selected, the step expands to allow ToR Switch Config. The options are single ToR switch or dual ToR switches. **Never go single. Never, never, never.** I'll choose **Dual ToR Switches** for redundancy.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20231941.png)

### Section 07: Network Adapter Ports

There's a lot to this decision that one should make before even ordering the hardware.

Normally, people order either Intel or Nvidia network adapters. For Dell, as an example, all my nodes come with two Nvidia ConnectX-6 network adapters (the ones that support 100 Gb). Each network adapter has 2 ports. My Dells also come with a Broadcom network adapter with two ports at 1 Gb.

In most cases, we just use the Nvidia ConnectX adapters giving me 4 ports. For this demo, because I can, I'm selecting **6 ports**.

Once I select 6 ports, section 7 expands giving us our port configuration. Here is where we can declare the port speeds and if they are RDMA capable—highly important for storage intents.

I did some custom edits on Port 1 and Port 2. Those two ports represent the two ports on my Broadcom 1 Gb network adapters. The rest I leave as 25 GbE even though my switch and cards can handle 100 GbE. 

This is one of the areas that the ODIN team quickly updated after some recommendatoins.  Last week, there was no way to name your network adapters the way they would show in the OS, so when you would export to ARM or other formats the naming was not correct.  However since last week this has changeed.
This is one of the areas that the ODIN team quickly updated after some recommendations. Last week, there was no way to name your network adapters the way they would show in the OS, so when you would export to ARM or other formats the naming was not correct. However, since last week this has changed.
![](/img/azurelocal_odin/Screenshot%202026-02-04%20233013.png)

Now we can actually name the nework adapters which is going to be a big help when we create our diagrams and ARM templates later. Now, I can see my 6 network adapters and ports, the names that will show up in the OS and also the same name that we will use for ARM template deployments or Portal Deployments.  This is a very helpful update.
Now we can actually name the network adapters, which is going to be a big help when we create our diagrams and ARM templates later. Now, I can see my 6 network adapters and ports, the names that will show up in the OS, and also the same name that we will use for ARM template deployments or Portal Deployments. This is a very helpful update.
![](/img/azurelocal_odin/Screenshot%202026-02-08%20214555.png)


### Section 08: Network Traffic Intents

I'm picking **Custom** for my network traffic intents. [More information on network intents](https://learn.microsoft.com/azure/azure-local/plan/cloud-deployment-network-considerations#step-3-determine-network-traffic-intents).

Immediately I see a **NOT SUPPORTED** message pop up:

![](/img/azurelocal_odin/Screenshot%202026-02-04%20232945.png)

> At least 2 RDMA-enabled port(s) must be assigned to Storage traffic (SMB). Update Step 07 Port Configuration so RDMA is enabled on the ports used for Storage traffic.

This is expected since I marked my Embedded NIC 1 and Embedded NIC 2 as not being RDMA compatible. This is fine—those two ports are going to be for management traffic anyway.

Next I play the match game of ports with intents:

- **Embedded NIC 1 and Embedded NIC 2** → Management intent
- **Slot 3 Port 1 and Slot 6 Port 2** → Compute intent (on different adapters for HA)
- **Slot 3 Port 2 and Port 6 Port 1** → Storage intent (on different adapters for HA)

For HA and resiliency, I'll have cabled Slot 3 Port 1 and Slot 6 Port 2 to Switch 00, and Slot 3 Port 2 and Slot 6 Port 1 to Switch 01. That way if a card goes out or a switch goes down, I still have physical connectivity between my nodes and my top-of-rack switch. Also, with our Dell AX-760 the Network Adapter in Slot 6 is upside down. For physically cabling this is important to know.
For HA and resiliency, I'll have cabled Slot 3 Port 1 and Slot 6 Port 2 to Switch 00, and Slot 3 Port 2 and Slot 6 Port 1 to Switch 01. That way if a card goes out or a switch goes down, I still have physical connectivity between my nodes and my top-of-rack switch. Also, with our Dell AX-760 the Network Adapter in Slot 6 is upside down. For physical cabling, this is important to know.
![](/img/azurelocal_odin/Screenshot%202026-02-08%20215416.png)

**Why do I use three intents?** In most cases I normally just do 2 (compute/management + storage) and sometimes just 1 fully converged intent. But in some cases—like where I work—my company manages the management network, but the customer manages everything on top of the hypervisors. We've also deployed 3 intents where we had management/compute, storage, and then another separate compute intent.

Other examples: you may have requirements to physically separate your networks for various reasons—legacy backup networks, different switches, and so on.

The last part of Section 08 covers **overrides** on those intents. Management and compute intents don't really need RoCEv2 or iWARP. Jumbo frames may come into play with compute. I always bump my jumbo frames to 9014—I'm not sure why Microsoft defaults to 1514.
The last part of Section 08 covers **overrides** on those intents. Management and compute intents don't really need RoCEv2 or iWARP. Jumbo frames may come into play with compute. I always set my jumbo frames to 9014—I'm not sure why Microsoft defaults to 1514.
![](/img/azurelocal_odin/Screenshot%202026-02-04%20234244.png)

For the storage intent, note the VLAN section. Since we're using only two ports for the storage intent, we only need 2 storage VLANs. These VLANs are not routable past the top-of-rack switch—basically just east/west on those switches. Microsoft defaults to VLAN 711 and 712. In a fully converged solution with 4 ports for storage/compute/management, you'd see 4 storage VLANs: 711, 712, 713, and 714.

Last for Section 08 is **Storage Auto IP**. In most cases, leave this default to enabled. There isn't really a need to statically assign the storage port IPs. Microsoft uses 10.71.1.x for port 1 and 10.71.2.x for port 2. [More on custom storage IPs](https://learn.microsoft.com/azure/azure-local/plan/cloud-deployment-network-considerations#custom-ips-for-storage).

![](/img/azurelocal_odin/Screenshot%202026-02-04%20234546.png)

*Before we move to Section 09, check the sidebar on the right—our progress is now 40% (8/20 decisions made) and we can see some of the configuration populated.*

![](/img/azurelocal_odin/Screenshot%202026-02-04%20234638.png)

### Section 09: Outbound Connectivity

This is a section that in the near future will be important to have made major decisions around. This also is a section where the Knowledge section will help with decision making. [More on firewall requirements](https://learn.microsoft.com/azure/azure-local/concepts/firewall-requirements).

There's a **Compare** button that compares Public Path vs. Private Path:

**Public Path**

**Pros:**
- Simpler initial setup
- Lower cost (no ExpressRoute/VPN required)
- Uses existing on-premises proxy/firewall infrastructure
- Multiple configuration options (4 scenarios)

**Cons:**
- Requires public internet egress
- Traffic routes through public endpoints
- More firewall rules if not using Arc Gateway

**Use Cases:**
- Standard deployments with reliable internet
- Existing on-premises proxy/firewall infrastructure
- Cost-sensitive environments
- Public internet egress acceptable per security policy

**Recommended:** For most deployments with internet connectivity

---

**Private Path (ExpressRoute)**

**Pros:**
- Zero public internet exposure
- Traffic stays on private network
- Azure Firewall provides centralized security
- Highest security posture
- Compliance-friendly for regulated industries

**Cons:**
- Higher cost (ExpressRoute + Azure Firewall)
- More complex initial setup
- Requires Arc Gateway + Azure Firewall Explicit Proxy
- ExpressRoute or Site-to-Site VPN required

**Use Cases:**
- Zero public internet exposure required
- Government, healthcare, financial industries
- Existing ExpressRoute or Site-to-Site VPN
- Regulatory/compliance requirements mandate private connectivity

---

For this blog I'm selecting **Public Internet**. The Private Connection (ExpressRoute/VPN) option shows "Coming Soon—Feature not available yet."

![](/img/azurelocal_odin/Screenshot%202026-02-04%20235159.png)

### Section 10: Arc Gateway

All my deployments moving forward will use Arc Gateway. At the top of this section is a link to the [connectivity guide](https://azure.github.io/odinforazurelocal/docs/outbound-connectivity/index.html) which is in the Knowledge section. There's also a Compare button:

**Arc Gateway Enabled**

**Pros:**
- Reduces firewall rules from hundreds to fewer than 30 endpoints
- Enhanced security posture
- Simpler firewall management
- Required for Private Path (ExpressRoute)

**Cons:**
- Additional Arc Gateway resource required
- Slightly more complex initial setup

**Use Cases:**
- Security-focused deployments
- Limited internet egress policies
- Private Path (ExpressRoute) deployments
- Simplified firewall rule management

**Recommended:** Recommended for all deployments

---

**Arc Gateway Disabled**

**Pros:**
- Simpler initial configuration
- One less Azure resource to manage

**Cons:**
- Hundreds of firewall rules required
- More endpoints to manage and troubleshoot
- Not supported for Private Path (ExpressRoute)

**Use Cases:**
- Simple deployments with unrestricted internet
- Testing and development environments

**Recommended:** For simple deployments only

---

I use Arc Gateway for all my deployments now. I'll select **Enable**. [More on Arc Gateway](https://learn.microsoft.com/azure/azure-local/deploy/deployment-azure-arc-gateway-overview).

![](/img/azurelocal_odin/Screenshot%202026-02-04%20235540.png)

### Section 11: Proxy Configuration

I'll click **Disable**. This will come into play more once the private connection in Section 09 is released.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20235554.png)

### Section 12: Private Endpoints

[More information on private endpoints](https://azure.github.io/odinforazurelocal/docs/outbound-connectivity/index.html#private-endpoints) is in the Knowledge section.

I'll choose **Disabled** for now. Some private endpoints are not yet supported with Azure Local, and the design and configuration for private endpoints needs more thought.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20235752.png)

### Section 13: Management Connectivity

Here we pick static or DHCP-assigned IP addresses for our management network. I use **Static**—always have and won't change. If you choose DHCP, make sure you have a reservation set. You do not want your node IP addresses changing. That is bad!

When you click Static, it will need the node names and the node IP (CIDR) addresses.

![](/img/azurelocal_odin/Screenshot%202026-02-04%20235956.png)

### Section 14: Management VLAN

If you have to assign your network adapters a VLAN, this is where you specify it. In most cases the management VLAN is using 0 and handled by the ports on the switch.

![](/img/azurelocal_odin/Screenshot%202026-02-05%20000253.png)

### Section 15: Infrastructure Network

This is a range of IPs needed for cluster infrastructure. One IP is used for the cluster IP, then 2 are used by the ARB VM, and the rest are used by the SDN network controller and other infrastructure services.

*Note: The first IP in this range will be the cluster IP.*

![](/img/azurelocal_odin/Screenshot%202026-02-05%20000604.png)

### Section 16: Storage Pool Configuration

This is where you tell the deployment to create the infrastructure volume and then a user storage volume for each physical machine. Basically, it creates a Cluster Shared Volume named "Infrastructure" (about 250 GB), and if you select **Express**, in my 3-node case it will create 3 CSVs with generic names (UserStorage01, 02, 03) across the available storage in your storage pool.

For some this is good. I don't like this—I prefer to create my own storage after the cluster is deployed, so I'll select **InfraOnly**.

You also have a choice to keep existing storage, which means if these nodes had been a cluster and you're redeploying for some reason, that data will be preserved.

![](/img/azurelocal_odin/Screenshot%202026-02-05%20000938.png)

### Section 17: Active Directory

Options:
- **Active Directory Domain Services (AD)** — Traditional identity
- **Azure Key Vault for Identity (AD-less)** — Local identity provider, still in preview

I have deployed the Key Vault option and it seems to work. This helps if you have remote sites without AD infrastructure—you still need DNS but no AD.

For this blog, I'll pick **Active Directory**. Once selected, the section expands asking for:
- Active Directory name (not your Entra ID tenant)
- OU path for cluster resources (LCM account, cluster nodes, cluster object)
- Domain controller IP addresses

[More on AD preparation](https://learn.microsoft.com/azure/azure-local/deploy/deployment-prep-active-directory#active-directory-preparation-module).

> **Important:** DNS servers cannot be changed after deployment. Ensure the configuration is correct before proceeding.

![](/img/azurelocal_odin/Screenshot%202026-02-05%20001545.png)

### Section 18: Security Configuration

In most cases, select **Recommended**. I do not—I customize mine.

Why? Because I don't like WDAC!

[More on security for Azure Local](https://learn.microsoft.com/azure/azure-local/concepts/security-features).

![](/img/azurelocal_odin/Screenshot%202026-02-05%20001703.png)

### Section 19: Software Defined Networking

Most people will select **No SDN** at this point and move on. For this blog, I'll select **Enable SDN**.

Once enabled, it shows SDN feature options. [Read about Azure Arc-managed SDN on Azure Local](https://learn.microsoft.com/azure/azure-local/concepts/sdn-overview).

The only two options supported by SDN managed by Azure Arc right now are:
- **Logical Networks (LNET)**
- **Network Security Groups (NSG)**

Once those are selected, click **SDN Managed by Arc**. At this time, do not select "SDN managed by on-premises tools."

![](/img/azurelocal_odin/Screenshot%202026-02-05%20001928.png)

### Generating Reports and ARM Templates

Now we're ready to preview our cluster configuration! This pops up an overview of the config. If "Configuration Complete" is green at the bottom, click **Generate Report**.

![](/img/azurelocal_odin/Screenshot%202026-02-05%20002252.png)

The report is broken into sections:
- **R1**: Report metadata
- **R2**: Configuration Summary
- **R3**: Validation Summary
- **R4**: Decision and Rationale

The report comes with nice detailed diagrams and is very thorough with many links to supporting documentation. The diagrams can be exported as SVG in light or dark mode. For example, the diagram for storage is nice.  You can see how the swtiches are mapped to each network intent and which ports below to each network intent.

![](/img/azurelocal_odin/azure-local-diagram-dark-20260208-2159.svg)

The outbound connectivity diagram is very nice as well.

![](/img/azurelocal_odin/outbound-connectivity-dark-20260208-2202.svg)


This is another section that the ODIN team took some suggestions and updated the tool.  Last week all we could do with these reports where being able print it, download as Word, or download/print as PDF. As of the current release, we can now export to Mark Down as well, which rocks for those of use who do nothing but Mark Down for documenation these days.
This is another section that the ODIN team took some suggestions and updated the tool. Last week, all we could do with these reports was print them, download as Word, or download/print as PDF. As of the current release, we can now export to Markdown as well, which rocks for those of us who do nothing but Markdown for documentation these days.
![](/img/azurelocal_odin/Screenshot%202026-02-08%20220508.png)

Over on the side menu to the right, there's a way to export the configuration to .json files.

![](/img/azurelocal_odin/Screenshot%202026-02-05%20002856.png)

Finally, the ability to **Generate Cluster ARM Deployment Files**.

![](/img/azurelocal_odin/Screenshot%202026-02-05%20002907.png)

When you click the button, another window opens: "Odin for Azure Local - ARM Parameters JSON."

- **Section A1**: Metadata
- **Section A2**: Enter your Tenant ID, Subscription ID, Resource Group, and deployment name

Section A2 will ask for the following placeholder values:

- Cluster Name
- Key Vault name
- Diagnostic storage account name
- Local admin credentials
- Deployment (LCM) credentials
- HCI resource provider object ID
- Arc node resource IDs
- OU path (optional)
- Custom location name (optional)

Once entered, click **Update Parameters JSON** and it will update the JSON file that can be seen in Section A5.

- **Section A3**: Deploy to Azure button and links to sample ARM templates
- **Section A4**: Deployment Script Generation—export PowerShell scripts, Azure CLI scripts, and links to Bicep and Terraform examples
- **Section A5**: The Parameter file JSON—copy and paste into VS Code and replace values as needed
- **Section A6**: Integration Features—export Azure DevOps Pipeline template, GitHub Actions workflow, and a section about REST API for Automation (coming soon)

### Designer: Final Thoughts

The Designer is the heart of Odin. It walks you through 20 decision points, validates your choices against Microsoft's requirements, and generates documentation and deployment artifacts. For anyone learning Azure Local or validating a design, this is genuinely valuable.

The generic port naming is frustrating (I really want to see adapters and their ports grouped together), and some features are still "coming soon." But the structured approach, the helpful comparison buttons, and the quality of the generated documentation make this a tool worth using.

**Things I'd like to see changed or added:**

1. **Export as Markdown** -  **Implemented In Recent Release** — Right now you can only export as Word or PDF. Markdown export would be much more useful for those of us who work in code-based documentation systems.

2. **Diagram export as Draw.io or Visio** — The diagrams are nice, but SVG-only export is limiting. Draw.io or Visio formats would allow for easier editing and integration into existing documentation. (**Coming Soon!**)
3. **Network Adapters with port mapping** — **Implemented In Recent Release** -  Show which port is on which network adapter. This is important for the ARM template and for anyone cabling a cluster.
4. **Network Adapter names** — **Implemented In Recent Release**  - Let us name the adapters, not just Port 1, Port 2, etc. This is also important for deployment and makes the generated documentation much more useful.
5. **ARM template needs more work** — The ARM template export is nice, but there's still a lot of manual work to do after export. More complete templates or better placeholders would help.

---

## Summary: Strengths, Gaps & Wishlist

| Feature | Status | Notes |
|---------|--------|-------|
| **Core Tools** |  |  |
| Sizer Tool | Good | Capacity planning for workloads |
| Knowledge Base | Excellent | Comprehensive connectivity guidance |
| Designer Wizard | Good | 19-step configuration process |
| **Strengths** |  |  |
| Network Intents | Excellent | Drag-and-drop, maps to Network ATC |
| Deployment Types | Good | Full scenario coverage |
| Identity Options | Good | AD or Key Vault |
| Security Config | Good | Secure defaults + customization |
| Reporting | Good | Design docs with decision logic |
| **Limitations** |  |  |
| Low Capacity Clusters | Caution | [Not GA](https://learn.microsoft.com/azure/azure-local/concepts/system-requirements-small-23h2)—verify before production |
| Network Adapter ID | Gap | Generic ports only—maintain your own mapping |
| ExpressRoute/VPN | Coming Soon | Private connectivity not yet available |
| Private Endpoints | Limited | Arc Resource Bridge not supported |
| SDN Features | Limited | Only 2 of 5 with Arc-managed SDN |
| **Wishlist** |  |  |
| Markdown Export | Completed | HTML only | 
| Draw.io Export | Missing | SVG only |
| Full ARM Templates | Missing | Parameters only, no CI/CD pipelines |
| REST API | Missing | Not publicly documented |

---

## Who Should Use Odin?

**Valuable for:**
- IT architects validating Azure Local design decisions
- Pre-sales engineers building configuration proposals
- Training and enablement teams learning Azure Local
- Documentation efforts requiring baseline architecture

**Not a replacement for:**
- Azure Portal deployment workflow
- Hardware compatibility validation
- Production deployment automation

**Tips for success:**
- Use Odin early in planning to understand decision points
- Don't rely on non-GA features for production
- Maintain your own hardware mapping documentation
- Verify SDN requirements before selecting features
- Export and supplement generated documentation with your own details

---

## Conclusion

Odin for Azure Local is a valuable community tool for planning and learning, but remember its experimental status. The Sizer, Knowledge Base, and Designer work together to provide a comprehensive planning experience—from capacity estimation to connectivity architecture to configuration generation.

It's not perfect. Generic adapter naming is frustrating, SDN guidance needs clarity, and export capabilities are limited. But it's free, actively maintained (version 0.12.5), and provides a structured approach to Azure Local deployment planning.

Use it as one tool in your planning toolkit—not as sole source of truth, but as a way to organize thinking and generate baseline documentation. The Network Intent visualization and Knowledge Base alone make it worth exploring.
Use it as one tool in your planning toolkit—not as the sole source of truth, but as a way to organize thinking and generate baseline documentation. The Network Intent visualization and Knowledge Base alone make it worth exploring.
**Tool URL**: [azure.github.io/odinforazurelocal](https://azure.github.io/odinforazurelocal/)

---

## Resources

### Odin Links:
- [Odin for Azure Local](https://azure.github.io/odinforazurelocal/)
- [Odin Knowledge Base](https://azure.github.io/odinforazurelocal/docs/outbound-connectivity/index.html)
- [Odin Sizer](https://azure.github.io/odinforazurelocal/sizer/index.html)

### Microsoft Documentation:
- [Azure Local Overview](https://learn.microsoft.com/azure/azure-local)
- [Azure Local Scalability Deployments](https://learn.microsoft.com/azure/azure-local/scalability-deployments)
- [Low Capacity System Requirements](https://learn.microsoft.com/azure/azure-local/concepts/system-requirements-small-23h2)
- [Rack Aware Cluster Overview](https://learn.microsoft.com/azure/azure-local/concepts/rack-aware-cluster-overview)
- [Network Traffic Intents](https://learn.microsoft.com/azure/azure-local/plan/cloud-deployment-network-considerations)
- [Local Identity with Key Vault](https://learn.microsoft.com/azure/azure-local/deploy/deployment-local-identity-with-key-vault)
- [Firewall Requirements](https://learn.microsoft.com/azure/azure-local/concepts/firewall-requirements)
- [Security Features](https://learn.microsoft.com/azure/azure-local/concepts/security-features)

---

*This review is based on Odin for Azure Local version 0.12.5. The tool is experimental and not officially supported by Microsoft. Features and capabilities may change in future versions.*
*This review is based on Odin for Azure Local version 0.14.52. The tool is experimental and not officially supported by Microsoft. Features and capabilities may change in future versions.*
<!-- 
SCREENSHOT CHECKLIST - Capture these from the tool:

[ ] Main landing page showing disclaimer
[ ] Network Adapter Ports showing generic Port 1, Port 2 naming
[ ] Network Traffic Intents drag-and-drop interface
[ ] Outbound Connectivity showing ExpressRoute/VPN "Coming Soon"
[ ] Private Endpoints showing Arc Resource Bridge "Not supported"
[ ] SDN Enable showing the 5 feature options
[ ] SDN Management selection (Arc vs On-Premises)
[ ] Identity selection (AD vs Key Vault)
[ ] Security configuration options
[ ] Generated design document example
[ ] Generated diagram (SVG output)

-->
