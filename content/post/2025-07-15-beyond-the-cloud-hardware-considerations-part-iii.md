---
title: "Beyond the Cloud: Hardware Considerations - Part III"
description: Hardware decisions make or break VMware exits. Reuse existing SANs with Windows Server or invest $200K+ in Azure Local nodes? Real costs & VMware VCF 9.0 impact.
date: 2025-06-26T12:52:40.687Z
preview: /img/rethinkvmware/hardware-part3-banner.png
draft: false
tags:
  - Hardware
  - Storage
  - SAN
  - Validated Nodes
  - Infrastructure
  - Hyper-V
  - Azure Local
categories:
  - Infrastructure
  - Hardware
  - Virtualization
thumbnail: /img/rethinkvmware/hardware-part3-banner.png
lead: Your VMware exit hardware strategy determines both timeline and budget. Windows Server offers maximum flexibility with existing infrastructure, Azure Local requires validated nodes costing $200K-500K+, and VMware VCF 9.0 deprecates older hardware anyway. This analysis provides a framework for making hardware decisions that fit your organization's timeline and budget constraints.
slug: cloud-hardware-considerations-part-iii
lastmod: 2025-06-27T15:24:43.925Z
---

*(Note: AVS – Azure VMware Solution – is not covered in detail here since it's essentially outsourcing VMware onto Azure's hardware. That involves a different calculus: you avoid buying hardware entirely, but you pay cloud rental fees and must fit into Azure's instance constraints. In this post, we focus on on-premises alternatives where you control the hardware.)*

# Hardware Considerations: Build Your Cloud on Your Terms

**Series Recap:** In **Part 1** of this series, we examined the total cost of ownership (TCO) implications of different post-VMware paths, comparing capital expenditure vs. subscription models across on-premises Hyper-V, Azure Local (formerly Azure Stack HCI), and Azure VMware Solution (AVS). In **Part 2**, we dove into licensing – analyzing how VMware vSphere licensing stacks up against Microsoft's offerings (Windows Server and Azure Local) in 2025, and what those licensing differences mean for choosing a virtualization platform. These earlier posts highlighted that organizations leaving VMware have viable Microsoft-based alternatives that can reduce costs and simplify licensing. Now, in **Part 3**, we turn to the **infrastructure** question: **What are your hardware options when "rethinking virtualization" away from VMware?** Can you reuse your **existing servers and storage**, or are you forced into buying **new, validated hardware nodes**? How do Microsoft's two on-premises solutions – **Windows Server Hyper-V with Failover Clustering (WSFC)** and **Azure Local** – compare in terms of hardware requirements? We'll explore scenarios for customers looking to leave VMware, whether they're **not ready for a hardware refresh** or **planning a refresh alongside the migration**, and we'll also briefly touch on upcoming **VMware Cloud Foundation 9.0** hardware needs.

## Series Navigation

- **Introduction**: [Beyond the Cloud: Rethinking Virtualization Post-VMware](https://thisismydemo.cloud/post/rethinking-virtualization-post-vmware/)
- **Part I**: [Beyond the Cloud: CapEx vs Subscription TCO Analysis](https://thisismydemo.cloud/post/capex-subscription-tco-modeling-hyper-azure-local-avs/)
- **Part II**: [Beyond the Cloud: 2025 Virtualization Licensing Guide](https://thisismydemo.cloud/post/choosing-your-virtualization-platform-2025-licensing-analysis/)
- **Part III**: Hardware Considerations - Build Your Cloud on Your Terms *(This Post)*

---

## Table of Contents

- [Hardware Considerations: Build Your Cloud on Your Terms](#hardware-considerations-build-your-cloud-on-your-terms)
  - [Series Navigation](#series-navigation)
  - [Table of Contents](#table-of-contents)
  - [Reuse vs. Refresh: The Hardware Dilemma](#reuse-vs-refresh-the-hardware-dilemma)
    - [Path 1: Reuse Existing Hardware](#path-1-reuse-existing-hardware)
    - [Path 2: Refresh with New Hardware](#path-2-refresh-with-new-hardware)
    - [Making the Decision: Framework and Considerations](#making-the-decision-framework-and-considerations)
      - [Hardware Investment Comparison](#hardware-investment-comparison)
  - [Windows Server on Existing Infrastructure: SAN or S2D?](#windows-server-on-existing-infrastructure-san-or-s2d)
    - [Traditional SAN-based Cluster (Reuse Your SAN)](#traditional-san-based-cluster-reuse-your-san)
    - [Storage Spaces Direct (Hyper-Converged) Cluster](#storage-spaces-direct-hyper-converged-cluster)
    - [SAN vs S2D: Technical Comparison](#san-vs-s2d-technical-comparison)
    - [Mixed Server Environments: Windows Server's Flexibility Advantage](#mixed-server-environments-windows-servers-flexibility-advantage)
  - [Azure Local: New Hardware and Validated Nodes](#azure-local-new-hardware-and-validated-nodes)
    - [Azure Local Pricing: What It Really Costs](#azure-local-pricing-what-it-really-costs)
    - [Current Azure Local Catalog: Vendor Solutions](#current-azure-local-catalog-vendor-solutions)
    - [Hardware and Infrastructure Requirements](#hardware-and-infrastructure-requirements)
    - [Network Infrastructure: Beyond Basic Connectivity](#network-infrastructure-beyond-basic-connectivity)
      - [Mandatory Network Standards Compliance](#mandatory-network-standards-compliance)
      - [Realistic Network Investment](#realistic-network-investment)
    - [Azure Local vs. Windows Server: Decision Matrix](#azure-local-vs-windows-server-decision-matrix)
    - [When Azure Local Makes Sense: Real Scenarios](#when-azure-local-makes-sense-real-scenarios)
  - [VMware Cloud Foundation 9.0](#vmware-cloud-foundation-90)
    - [New Hardware Requirements for ESXi 9.0](#new-hardware-requirements-for-esxi-90)
    - [Device Deprecation Impact](#device-deprecation-impact)
    - [Cost and Planning Implications](#cost-and-planning-implications)
  - [Side-by-Side Comparison](#side-by-side-comparison)
  - [Conclusion: Choose the Path that Fits Your Needs](#conclusion-choose-the-path-that-fits-your-needs)
    - [Quick Decision Framework](#quick-decision-framework)
  - [My Personal Recommendations: The Windows Server Advantage](#my-personal-recommendations-the-windows-server-advantage)
    - [For the Budget-Conscious (Most Organizations)](#for-the-budget-conscious-most-organizations)
    - [For the Pragmatic IT Professional](#for-the-pragmatic-it-professional)
    - [For Organizations Seeking True Independence](#for-organizations-seeking-true-independence)
    - [The Arc-Enabled Middle Ground](#the-arc-enabled-middle-ground)
    - [Cost Reality Check](#cost-reality-check)
    - [When Azure Local Actually Makes Sense](#when-azure-local-actually-makes-sense)
    - [Bottom Line Recommendation](#bottom-line-recommendation)
    - [Microsoft Official Documentation](#microsoft-official-documentation)
    - [Industry Analysis \& Comparisons](#industry-analysis--comparisons)
    - [Hardware Vendor Documentation](#hardware-vendor-documentation)
    - [VMware/Broadcom Resources](#vmwarebroadcom-resources)
    - [Cost Analysis \& Technical Comparisons](#cost-analysis--technical-comparisons)

---

## Reuse vs. Refresh: The Hardware Dilemma

When considering your post-VMware virtualization strategy, one of the first questions organizations face is whether to reuse existing hardware or invest in new equipment. This decision significantly impacts both initial costs and long-term operational success.

**The VMware Hardware Timeline Factor:** What makes this decision particularly urgent for many organizations is VMware's accelerating hardware obsolescence timeline. With VMware Cloud Foundation 9.0 and ESXi 9.0, VMware is deprecating significant numbers of older server components (storage controllers, network adapters, etc.) that were supported in vSphere 7 and 8. Organizations staying with VMware face their own hardware refresh timeline pressure – you can't simply renew VMware licenses and keep running on the same hardware indefinitely. VMware's compatibility guides now warn that upgrading to ESXi 9.0 with unsupported devices can result in **loss of storage or network access**, forcing hardware replacement before the upgrade. This creates a unique situation: **both staying with VMware and moving to Azure Local may require new hardware**, but for different reasons and on different timelines.

### Path 1: Reuse Existing Hardware

If your current servers and storage ran VMware vSphere reliably, you might prefer to repurpose them for the new solution. This path favors a platform that is flexible with hardware compatibility. Microsoft's traditional Windows Server + Hyper-V is very accommodating here – it can run on a wide range of commodity servers and supports classic external SAN storage for clusters.

In fact, Windows Server 2025 (with Hyper-V and Failover Clustering) offers much greater flexibility to leverage existing gear than Azure Local does. If your goal is to maximize use of existing hardware, the Windows Server route is often the best choice. It allows clustering with either shared storage (e.g., an iSCSI or FC SAN or NAS) or with internal disks via Storage Spaces Direct – giving you options to integrate with whatever infrastructure you already have.

**The Hidden Advantage:** What many organizations don't realize is that choosing Windows Server Hyper-V doesn't just give you immediate VMware exit options – it gives you **timeline control**. You can migrate away from VMware immediately using existing hardware, then gradually modernize your infrastructure over months or years rather than being forced into a forklift upgrade to meet someone else's deadline.

### Path 2: Refresh with New Hardware

Some organizations align their hardware refresh cycle with moving off VMware. Microsoft's Azure Local is positioned as a modern hyper-converged solution, but it almost always requires new hardware to meet its certified solution requirements.

Azure Local runs on specific validated node configurations – typically turnkey integrated systems from OEM partners (Dell, HPE, Lenovo, etc.) – rather than just any random server. In fact, Microsoft notes that you can only repurpose existing servers for Azure Local if they exactly match a current validated node profile in the Azure Local Catalog.

> **💡 Key Insight**
>
> In approximately **99.9% of cases**, existing hardware will not meet the stringent requirements for Azure Local deployment. This statistic, while seemingly harsh, reflects the reality of modern hyperconverged infrastructure demands.

In practice, unless your older servers were originally purchased as a supported HCI solution, this is rarely the case. The Azure Local program emphasizes using approved hardware to ensure stability – following the validated hardware path helps avoid "ghost chasing" of obscure firmware issues under load. OEMs provide jointly supported solutions, and Microsoft "highly recommends" integrated systems that come pre-built and pre-tested for Azure Local.

**Current Azure Local Catalog State:** As of late 2024, the catalog includes:

- **100+ validated hardware configurations** from leading vendors
- **New low-specification options** for smaller deployments
- **Expanded processor support** including Intel and AMD latest generations
- **Flexible storage configurations** accommodating various workload types

However, the catalog's expansion doesn't change the fundamental reality: existing enterprise hardware rarely meets the precise specifications required for certification. The result is a rock-solid platform, but at the cost of being locked into new hardware purchases in the near term.

### Making the Decision: Framework and Considerations

When evaluating your hardware refresh strategy, consider this decision flow:

1. **Audit Current Hardware** - CPU generation and features, memory type and capacity, storage configuration and performance, network capabilities

2. **Compare Against Requirements** - Check Azure Local hardware catalog, identify gaps and compatibility issues, calculate upgrade costs vs. replacement

3. **Evaluate Business Impact** - Deployment timeline requirements, performance expectations, support and maintenance needs, budget constraints

4. **Consider External Pressures** - VMware upgrade deadlines and deprecated hardware, budget approval timelines, vendor delivery schedules for new hardware

#### Hardware Investment Comparison

| Approach | Initial Cost | Long-term TCO | Risk Level | Timeline Control |
|----------|-------------|---------------|------------|------------------|
| **Reuse Existing (Windows Server)** | Low | Medium | Low-Medium | High |
| **Refresh with Certified (Azure Local)** | High | Low | Low | Low |
| **VMware VCF 9.0 Upgrade** | Medium | High | Medium | Low |

**Key Considerations:**

- **Reuse Existing**: Immediate VMware exit capability, gradual modernization on your timeline
- **Refresh with Certified**: Modern infrastructure but forced timeline and significant upfront investment
- **VMware Upgrade**: Hardware refresh required anyway, but ongoing licensing costs and vendor lock-in

In short, Windows Server Hyper-V (WSFC) offers a "build your cloud on your terms" approach – you can likely reuse your existing mix of servers and storage – whereas Azure Local usually mandates a clean slate with new, homogenized hardware. Next, we'll compare these options in detail: using Windows Server on your current infrastructure (either with your SAN or with Storage Spaces Direct) versus rolling out Azure Local on vendor-validated nodes.

---

## Windows Server on Existing Infrastructure: SAN or S2D?

One of the strengths of the Windows Server Failover Clustering approach is its **hardware flexibility**. You have two architecture choices for storage when using WSFC + Hyper-V:

### Traditional SAN-based Cluster (Reuse Your SAN)

If you have an existing Fibre Channel or iSCSI SAN that's still performant and supported, you can continue to leverage it with a Windows Server Hyper-V cluster. Microsoft fully supports "traditional infrastructure" setups where VMs on a Windows cluster use an external shared SAN/NAS for storage.

**How the Architecture Works:** In this model, each Hyper-V host connects to the SAN LUNs (or shares) and those LUNs are configured as Cluster Shared Volumes (CSVs) accessible by all nodes. This essentially replicates the VMware + SAN design with a different hypervisor. The benefit is obvious: you **protect your prior investments** in storage.

**Real-World Example:** For example, if you recently bought an all-flash SAN that has years of life left, moving to WSFC/Hyper-V lets you **swap the hypervisor but keep the storage** – an incremental migration that minimizes new spend. Administrators who are comfortable with their SAN vendor's tools and best practices can stick with what they know, just integrating it with Windows instead of ESXi.

**The Azure Local Contrast:** Microsoft explicitly acknowledges that Windows Server remains ideal for these scenarios (multiple hosts clustered with a shared disk array), whereas Azure Local **does not support external SAN storage** at all. In fact, Azure Local's reliance on Storage Spaces Direct means it **cannot use** a fibre channel or iSCSI SAN for VM storage – there's no option for multi-path shared LUNs in Azure Local's design.

**Technical Implementation:** Windows Server, on the other hand, can certainly use SAN/NAS storage for clustering, including using multi-path IO (MPIO) with identical HBAs across nodes for robust SAN connectivity. If you have a reliable SAN and processes built around it, **WSFC lets you keep that architecture** while moving away from VMware.

**Perfect Timing Scenario:** This path is especially attractive for organizations facing a VMware license deadline but whose hardware (servers *and* SAN) is not due for refresh – you can transition to Hyper-V on your existing hosts, connect them to the existing SAN, and avoid a costly all-at-once hardware purchase.

### Storage Spaces Direct (Hyper-Converged) Cluster

For organizations that don't have an external SAN, or who want to move toward a hyper-converged model using **local disks**, Windows Server Datacenter edition offers **Storage Spaces Direct (S2D)** as an option. S2D allows a WSFC cluster to pool internal drives on each host into a distributed, highly-available storage array – conceptually similar to VMware vSAN.

**The Core Appeal:** The appeal of S2D is that you can eliminate the external SAN and use commodity disks (SSD/NVMe) inside the Hyper-V hosts to get SAN-like performance. If your existing VMware hosts have ample drive bays (or you're willing to add some storage to them), you could repurpose those servers into an S2D cluster.

**Hardware Considerations:** This route might require some updates – e.g., adding SSDs or NVMe disks, and ensuring you have a high-bandwidth network between nodes (10 GbE or higher is recommended, with RDMA for best results). It's also ideal to use identical or very similar servers for S2D clusters, although it's not a strict requirement; Microsoft recommends matching hardware for consistency, and cluster validation will flag major discrepancies, but it doesn't require the nodes to be identical models. In practice, successful S2D deployments typically use the same make/model servers with consistent drives and NICs for predictable performance.

**Cost & Management Advantages:** Assuming your hardware meets the requirements, S2D can be a cost-effective way to get an all-software-defined infrastructure. Because S2D is built into Windows Server, you avoid the expense of an external SAN array. In fact, a Hyper-V cluster with S2D is often **much cheaper than buying a new high-end SAN** from a vendor. You're using industry-standard drives and controllers, and the "SAN intelligence" is provided by Windows Server itself.

**Administrative Benefits:** Administration can also be simpler: storage management is unified with the OS (PowerShell, Windows Admin Center, etc.) instead of dealing with separate SAN management GUIs.

**Resiliency Considerations:** On the flip side, be mindful of the cluster size and resiliency: a **2-node S2D cluster** is possible (with witness) but uses simple two-way mirroring (50% capacity efficiency), whereas 3+ nodes enable more efficient resiliency (like three-way mirror or parity) and higher uptime during maintenance.

**Hardware Requirements for Existing Infrastructure:** If reusing existing hardware for S2D, ensure the controllers are in HBA mode (pass-through) and not RAID, and that any older NICs are capable of the throughput needed – a 1 Gbps network is technically supported but will be a bottleneck; 10 Gbps+ and RDMA is strongly recommended for HCI scenarios.

**The Gradual Modernization Path:** In summary, **Windows Server S2D** gives you a path to hyper-converged infrastructure without forcing new hardware purchases – you can *gradually* modernize by, say, adding some SSDs and 10/25 Gb NICs to your existing servers rather than replacing everything outright. Many organizations find that attractive when budgets are tight. And if you *do* decide to buy new servers for a Hyper-V cluster, you can do so on your own terms (any hardware on the Windows Server HCL that passes cluster validation is supported) rather than being limited to HCI-certified nodes.

### SAN vs S2D: Technical Comparison

| Factor | **Traditional SAN** | **Storage Spaces Direct (S2D)** |
|--------|-------------------|--------------------------------|
| **Hardware Investment** | Preserve existing SAN | Add local drives, upgrade networking |
| **Network Requirements** | Lower (SAN fabric handles storage traffic) | Higher (10+ GbE, RDMA recommended) |
| **Management Interface** | Separate SAN vendor tools | Unified with Windows (PowerShell, WAC) |
| **Hardware Flexibility** | Any certified servers | Identical/similar servers preferred |
| **Storage Controllers** | Any supported configuration | Must be HBA mode (no RAID) |
| **Capacity Efficiency** | SAN-dependent | 50% (2-node) to better (3+ nodes) |
| **Cost Model** | Existing investment + server refresh | Gradual modernization possible |

### Mixed Server Environments: Windows Server's Flexibility Advantage

It's worth noting that Windows Server clusters can tolerate a degree of hardware heterogeneity. It's generally best practice to use homogeneous nodes in a cluster, but Microsoft support's stance is simply that all components must be certified for Windows Server and the cluster must pass validation.

**What This Means in Practice:** That means you could have, for example, two slightly different server models or memory sizes in one cluster, and as long as they function well together (and you might enable CPU compatibility mode for live migrations across different CPU generations), it's a supported config. Many Hyper-V deployments over the years have mixed hardware during transitions (adding newer nodes to an old cluster during upgrades, etc.).

**Real-World CPU Compatibility Scenarios:** Here are common mixed-hardware scenarios where Windows Server's flexibility shines:

- **Generational Upgrades:** Mixing Intel Xeon E5-2600 v3 (Haswell) with E5-2600 v4 (Broadwell) processors in the same cluster by enabling CPU compatibility mode to mask newer instruction sets
- **Vendor Transitions:** Running Dell PowerEdge R730 servers alongside HPE ProLiant DL380 Gen9 servers, as long as both pass cluster validation
- **Memory Configurations:** Having some nodes with 128GB RAM and others with 256GB RAM, allowing workload placement based on memory requirements
- **Phased Refreshes:** Adding newer servers with NVMe storage to an existing cluster with SATA SSDs, gradually migrating workloads to higher-performance nodes
- **CPU Socket Differences:** Mixing dual-socket and quad-socket servers in the same cluster (though VM sizing must be planned accordingly)

**Azure Local's Strict Requirements:** **Azure Local, by contrast, requires uniformity** – the official requirement is that *"all servers must be the same manufacturer and model"* in an HCI cluster. The HCI operating system expects symmetric hardware for storage pooling and uses an image-based lifecycle approach, so mixing server types is not part of its design.

**Bottom Line:** In short, WSFC gives you more wiggle room to **mix and match hardware to a degree** (helpful when repurposing existing gear), whereas Azure Local expects essentially identical nodes (typically delivered as a batch from an OEM) for each cluster.

---

## Azure Local: New Hardware and Validated Nodes

Azure Local (formerly Azure Stack HCI) is Microsoft's premier hybrid cloud-integrated HCI platform – but it comes with strict hardware prescriptions and significant cost implications. If you're considering this route as your VMware replacement, here are the key hardware considerations:

### Azure Local Pricing: What It Really Costs

Azure Local operates on a **dual subscription model** that organizations must understand before committing:

> **💰 Azure Local Total Cost Breakdown**
>
> - **Azure Local Service**: $10/core/month (mandatory for all physical cores)
> - **Windows Server Licensing**: $23.30/core/month (unless using existing licenses with Software Assurance)
> - **Hardware Investment**: New validated nodes required in most cases

**Real-World Cost Example**: A typical 4-node cluster with dual 16-core processors (128 total cores):
- Azure Local service: $1,280/month
- Windows Server licensing: $2,982/month (if new licenses needed)
- **Total monthly cost**: $4,262 before hardware amortization

Compare this to Windows Server perpetual licensing, where you pay once and own the license indefinitely (with optional Software Assurance for updates).

### Current Azure Local Catalog: Vendor Solutions

The Azure Local catalog has expanded significantly in 2024-2025:

| **Vendor** | **Solution Lines** | **Deployment Types** | **Key Advantages** |
|------------|-------------------|---------------------|-------------------|
| **Dell** | PowerEdge (AX, VX series) | 2-16 nodes, ROBO to datacenter | Integrated APEX support, lifecycle management |
| **HPE** | ProLiant DL145 Gen11, Apollo | Edge-optimized, full rack solutions | HPE GreenLake integration, hybrid management |
| **Lenovo** | ThinkAgile MX1020/MX1021 | 2-node edge, branch office focus | Pre-configured appliances, simplified deployment |
| **DataON** | AZS series | Storage-optimized configurations | High-density storage, cost-effective options |

**Key Reality Check**: While the catalog offers variety, **delivery timelines** for validated nodes can be 8-16 weeks, potentially impacting your VMware exit timeline.

### Hardware and Infrastructure Requirements

* **Validated Hardware Only:** Azure Local is **sold as a solution**, not just software. Microsoft works with hardware partners to provide a catalog of validated node configurations and integrated systems. In fact, you cannot simply install Azure Local on any random server and call it a supported production deployment – it needs to align with a supported combination of components (CPU, drives, NICs, firmware, etc.). As noted earlier, existing servers can only be used if they **exactly match a current validated node profile** in the Azure Local Catalog. For the vast majority of environments, this means **buying new nodes** that are listed in the Azure Local Catalog. These are often sold in pre-configured clusters of 2, 4, or more nodes, with all identical hardware. This ensures that the cluster will pass Microsoft's HCI validation and that you have a single throat to choke for support (often the OEM will handle first-line support for the hardware, with Microsoft covering the software). The emphasis on validated hardware is to ensure reliability – Microsoft and OEMs run extensive stress tests on these configurations. Deploying on something off-list risks hitting firmware or driver issues under load, which is why *"following the validated hardware path"* is strongly urged. In the HCI world, an misbehaving component can bring big headaches, so Microsoft's stance (echoed by partners like Dell) is to stick to known-good builds to **avoid playing whack-a-mole with obscure hardware issues**.

**Current Azure Local Catalog State:** As of late 2024, the catalog includes:

- **100+ validated hardware configurations** from leading vendors
- **New low-specification options** for smaller deployments
- **Expanded processor support** including Intel and AMD latest generations
- **Flexible storage configurations** accommodating various workload types

However, the catalog's expansion doesn't change the fundamental reality: existing enterprise hardware rarely meets the precise specifications required for certification. The result is a rock-solid platform, but at the cost of being locked into new hardware purchases in the near term.

> **🚫 Critical Limitation: No External SAN Support**
>
> Azure Local **cannot integrate with existing SAN infrastructure**. Unlike Windows Server Failover Clustering, which supports both SAN and hyper-converged storage, Azure Local is **Storage Spaces Direct only**.
>
> **Impact**: If you have a recently purchased SAN with years of useful life remaining, Azure Local provides no migration path to preserve that investment. Your storage investment becomes a sunk cost.

* **Hyper-Converged Storage (No SAN):** Azure Local's architecture is inherently hyper-converged – it **requires Storage Spaces Direct** using local disks in each node. Unlike a Windows Server cluster, **you cannot use an external SAN** with Azure Local for your VM storage. The system will not even allow adding a shared LUN to the cluster; all storage must be direct-attached to the hosts (or in a single-node scenario, attached JBOD, but not shared between nodes). This means that if you have an existing SAN, Azure Local provides no way to incorporate it – that storage would become effectively sidelined (perhaps used for backups or secondary storage, but not for the HCI cluster's primary workloads). Azure Local's philosophy is to instead use internal NVMe, SSD, and possibly HDDs to create a software-defined pool. This delivers excellent performance (especially with all-flash NVMe configurations) and simplifies management to one layer. But it reinforces that moving to Azure Local is a **full infrastructure replacement**: new servers *with their own internal storage* handle everything. It's an all-in-one approach.

### Network Infrastructure: Beyond Basic Connectivity

Azure Local's hyper-converged architecture places significant demands on your network infrastructure:

#### Mandatory Network Standards Compliance
- **IEEE 802.1Q**: VLAN support (required in all scenarios)
- **IEEE 802.1Qbb**: Priority Flow Control for lossless storage traffic
- **IEEE 802.1Qaz**: Enhanced Transmission Selection for QoS
- **IEEE 802.1AB**: Link Layer Discovery Protocol for troubleshooting

#### Realistic Network Investment
Many VMware environments running on 1GbE will require **complete network refresh** for Azure Local:

| **Current Network** | **Required Upgrade** | **Estimated Investment** |
|-------------------|---------------------|------------------------|
| 1GbE switches | 10/25GbE with DCB support | $15,000-50,000+ |
| Basic 10GbE | RDMA-capable 25/100GbE | $25,000-75,000+ |
| Legacy switching | Complete ToR refresh | $50,000-150,000+ |

**Critical Point**: Unlike Windows Server clusters that can work with existing network infrastructure, Azure Local **mandates** specific network capabilities that older environments typically lack.

* **Network Requirements:** Given the heavy reliance on east-west traffic for S2D replication, Azure Local has higher network demands. Realistically, 10 GbE is the minimum, and 25–100 Gb networks with RDMA are recommended for all-flash scenarios. Many older VMware deployments on 1 GbE won't meet Azure Local's performance needs. Thus, adopting HCI might involve upgrading network switches and NICs along with the servers. (Windows Server clusters with a SAN can sometimes get by with lower network throughput since the heavy lifting is offloaded to the SAN fabric; HCI pushes that onto the cluster network.)

* **Lifecycle and Updates:** Azure Local is delivered as an OS with frequent feature updates (semi-annual releases). OEM integrated systems often include streamlined update tools (e.g., firmware + driver + OS updates in one workflow). This is a benefit of buying into the validated model: you get a cohesive experience for patching. However, it also underscores that **older hardware may not be able to catch up** – each new HCI release might drop support for out-of-date devices. (For instance, if an older RAID controller or NIC isn't re-certified by the OEM for the latest HCI version, you might not be able to upgrade that cluster without hardware changes. This is similar to what VMware is doing with vSphere – more on that shortly.)

### Azure Local vs. Windows Server: Decision Matrix

| **Factor** | **Azure Local** | **Windows Server 2025** | **Decision Criteria** |
|------------|----------------|-------------------------|---------------------|
| **Upfront Hardware Cost** | $200,000-500,000+ (new validated nodes) | $0-50,000 (minor upgrades) | Budget availability for major refresh |
| **Monthly Operating Cost** | $4,000-15,000+ (subscription fees) | $0-2,000 (maintenance only) | Preference for CapEx vs OpEx |
| **Timeline to Production** | 12-20 weeks (hardware + deployment) | 2-8 weeks (migration planning) | VMware deadline pressure |
| **Storage Investment Protection** | Cannot reuse existing SAN | Full SAN compatibility | Value of existing storage infrastructure |
| **Network Infrastructure** | Requires modern DCB-capable switching | Works with existing network gear | Network refresh budget availability |

### When Azure Local Makes Sense: Real Scenarios

**Scenario 1: Greenfield Deployment**
- New datacenter or major refresh already planned
- Budget allocated for modern infrastructure
- Strong Azure integration requirements
- **Verdict**: Azure Local is ideal

**Scenario 2: VMware Refugee with Recent Hardware**
- Servers purchased within last 3-4 years
- Existing SAN with remaining lifespan
- Tight budget constraints
- **Verdict**: Windows Server is the pragmatic choice

**Scenario 3: Distributed Branch Offices**
- Multiple small sites needing HCI
- Limited local IT expertise
- Cloud management requirements
- **Verdict**: Azure Local's validated appliances shine here

**Scenario 4: Mixed Environment Transition**
- Gradual VMware migration over 12-24 months
- Varying hardware ages across environment
- Need to maintain operations during transition
- **Verdict**: Windows Server provides necessary flexibility

In summary, Azure Local is a powerful solution if you're aiming for a **modern, cloud-connected datacenter** and are willing (and able) to invest in **new infrastructure that meets the spec**. It shines in scenarios like distributed branch office deployments, edge locations, or a fresh private cloud build that needs Azure integration. But for customers coming from VMware who have a lot of sunk cost in their current hardware, HCI's hardware requirements can be a tough pill – it's essentially a **forklift upgrade** in many cases. This is exactly why we've been highlighting the Windows Server alternative in this series: it lets you incrementally adopt new technology on your timeline. Microsoft's marketing might paint Azure Local as the only forward path, but as we see, **WSFC/Hyper-V offers a more hardware-agnostic approach** that can be just as viable, especially during transition periods.

---

## VMware Cloud Foundation 9.0

VMware Cloud Foundation 9.0 was announced and became generally available on **June 17, 2025**. When I hear about a new version, my first instinct is to go and check the compatibility guides to see what impact this might have on hardware.

VCF 9.0 requires ESXi 9.0 to be installed, which introduces several significant hardware requirement changes that could impact your infrastructure planning and budget.

### New Hardware Requirements for ESXi 9.0

| Component | ESXi 8.0 | ESXi 9.0 | Impact |
|-----------|----------|----------|---------|
| **Boot Media** | 32 GB minimum | **128 GB minimum** | 4x increase - likely for container runtime support |
| **Boot Method** | BIOS or UEFI | **UEFI only** | Legacy BIOS no longer supported |
| **Memory** | 4 GB minimum | **8 GB minimum** | 2x increase for base functionality |
| **CPU Architecture** | x86-64 | x86-64 with enhanced features | Some older CPUs deprecated |

> **💡 Key Insight**: The 128 GB boot media requirement represents the most significant change. This likely supports the new container runtime included in ESXi 9.0, but it means your existing 32-64 GB boot drives won't be sufficient.

### Device Deprecation Impact

VMware has deprecated a significant number of devices and adapters for ESXi 9.0, documented in [KB 391170](https://knowledge.broadcom.com/external/article/391170/esxi-9-list-of-deprecated-and-removed-de.html). The deprecation affects:

- **Network Cards**: Several Intel and Broadcom NICs
- **Storage Controllers**: Legacy RAID controllers and HBAs  
- **Server Platforms**: Older generation servers from major vendors

**Understanding Deprecation Levels**:

- **Restricted**: Device functions but with limited support
- **End of Life (EOL)**: Device completely unsupported

### Cost and Planning Implications

**Immediate Costs**:

- Boot media upgrades: ~$50-200 per server for enterprise SSDs
- Memory upgrades: ~$100-500 per server (if below 8GB)
- Network/storage adapters: $200-2,000 per server for replacements

**Planning Timeline**:

- **Q3 2025**: Audit current hardware against KB 391170
- **Q4 2025**: Budget for necessary upgrades
- **Q1 2026**: Begin staged hardware updates
- **Q2-Q3 2026**: VCF 9.0 deployment window

> **⚠️ Critical Decision Point**: If you're running older hardware, you might find that multiple devices are no longer supported. This could force an unplanned hardware refresh cycle that significantly impacts your infrastructure budget and timeline.

The key question is: what does this mean for your existing infrastructure? Run the compatibility assessment now to avoid deployment surprises later.

---

## Side-by-Side Comparison

To crystallize the differences, here's a side-by-side look at hardware considerations for **Windows Server (WSFC) vs. Azure Local**, along with a note on VMware's requirements:

| **Comparison Factor** | **Windows Server 2022/2025**<br>*Hyper-V + Failover Cluster (WSFC)* | **Azure Local**<br>*Hyper-Converged HCI OS* | **VMware vSphere/VCF 9.0**<br>*(for comparison)* |
|-----------------------|-------------------------------------------------------------------------|-----------------------------------------------|----------------------------------------------------|
| **Hardware Flexibility** | **High:** Can reuse existing servers (even mixed models, if compatible). Supports broad range of certified hardware. | **Low:** Generally **requires new, vendor-validated nodes**. Existing hardware only usable if it exactly matches a supported config. Uniform servers (same model) required in cluster. | **Medium:** vSphere supports a wide hardware range *in general*, but **upgrading to 9.0 will drop support for many older devices** (e.g., some HBAs, NICs). Likely requires hardware refresh or component upgrades for older servers. |
| **Storage Architecture** | Flexible: Use **external SAN/NAS** or **Storage Spaces Direct** (local disks) – your choice. Can integrate with existing Fibre Channel/iSCSI storage (Azure Local cannot). | **Hyper-converged only:** Uses **Storage Spaces Direct** with internal drives. **No support for external SAN** or shared SAS enclosures. All nodes use local SSD/NVMe for storage, replicated across cluster. | Flexible: Supports traditional SAN/NAS or vSAN (HCI) if you have appropriate licenses. vSAN (like S2D) requires local disks and usually homogeneous nodes, whereas using a SAN is still an option in vSphere (one reason some may stick with VMware). |
| **Hardware Requirements** | Standard Windows Server HCL certification for NICs, HBAs, etc. **Cluster validation** must pass on chosen config. Recommended to use similar servers, but not strictly required. | Must purchase from **Azure Local Catalog** of solutions. Typically 2-16 nodes, all-flash or hybrid drives, with 10–100 GbE RDMA networking. **Strict validation** – non-certified components (RAID cards, older NICs) are not allowed. Ongoing Azure subscription per core for the OS. | **Requires devices on VMware's compatibility list.** ESXi 9.0 deprecates certain older devices – they'll operate in 8.x but must be replaced before 9.0. Otherwise, standard x86 server requirements (similar to WSFC in CPU/RAM needs). |
| **Ideal Use Case** | Best when you want to **maximize existing investments** – e.g., keep using a current SAN or defer new hardware costs. Also suitable for mixed environments and gradual upgrades. | Best when undertaking a **full infrastructure refresh** and wanting a cloud-integrated solution. Ideal if you plan to modernize to HCI and can invest in new hardware that aligns with Azure's hybrid vision. | Best if you intend to **stay with VMware** and are willing to refresh hardware as needed. (If you have a significant investment in VMware-specific tooling and skills, you may prefer this route, but watch out for Broadcom/VMware's licensing and support changes.) |

*(Note: AVS – Azure VMware Solution – is not covered in detail here since it’s essentially outsourcing VMware onto Azure’s hardware. That involves a different calculus: you avoid buying hardware entirely, but you pay cloud rental fees and must fit into Azure’s instance constraints. In this post, we focus on on-premises alternatives where you control the hardware.)*

## Conclusion: Choose the Path that Fits Your Needs

As you plan your post-VMware journey, the hardware dimension is as important as cost and licensing. Microsoft’s two on-premises offerings present two different philosophies:

* **Windows Server + Hyper-V (WSFC)** empowers you to **build your cloud on *your* terms** – you can start with what you have and evolve gradually. It’s a proven, enterprise-grade platform that, despite getting less hype these days, continues to run mission-critical workloads worldwide. This path is about **pragmatism**: if you’re staring down a VMware exit but don’t have the budget (or desire) to rip-and-replace your infrastructure, WSFC lets you transition to a supported, modern virtualization platform with minimal hardware changes. You can always perform a phased hardware refresh later, on your schedule (for instance, replace aging servers with newer ones for your Hyper-V cluster over time, without changing the software stack).

* **Azure Local** offers a more **prescriptive, cloud-connected** on-prem solution – great for organizations that want the latest tech and tight Azure integration, and are ready to invest in that upfront. It brings the benefits of hyper-converged design and Azure Arc management, but it’s less forgiving of legacy gear. This path makes sense if you’ve decided to modernize your data center and have budget allocated for new HCI nodes (or if your existing hardware is truly at end-of-life and *needs* replacement anyway). It’s the route Microsoft’s sales teams will often promote for “transforming” your on-premises environment.

Ultimately, the choice comes down to your **business requirements and timelines**. If avoiding a big capital spend and extending equipment lifespan is a priority, then leveraging Windows Server 2025 with Hyper-V on your existing hardware can be a smart move – it provides a **fully supported platform** without forcing you into new purchases. If, on the other hand, you desire a cutting-edge, cloud-hybrid infrastructure and are prepared to standardize on new hardware, Azure Local can deliver that experience (just go in with eyes open about the ongoing subscription and the one-time hardware costs).

### Quick Decision Framework

Use this simple flowchart to guide your hardware strategy:

**Start Here: What's your primary constraint?**

🔸 **Budget/Timeline Pressure?** → **Windows Server 2025**
- Reuse existing servers and SAN
- Immediate VMware exit possible
- Gradual modernization on your terms

🔸 **Need Modern Infrastructure?** → **Evaluate Further:**
- **Have recent SAN investment?** → **Windows Server 2025** (protect SAN investment)
- **Ready for full refresh + cloud integration?** → **Azure Local**
- **Complex VMware environment?** → **Windows Server 2025** (flexibility during transition)

🔸 **Staying with VMware?** → **Plan Hardware Refresh**
- Audit against KB 391170 by Q3 2025
- Budget for ESXi 9.0 compatibility upgrades
- Consider Windows Server as backup plan

**Key Decision Points:**
1. **Can you afford 12-20 weeks for new hardware delivery?** (Azure Local requirement)
2. **Do you have a recent SAN that Azure Local can't use?** (Drives toward Windows Server)
3. **Is your VMware deadline forcing immediate decisions?** (Windows Server provides fastest path)

Remember that there's no one-size-fits-all "better" option. It's about aligning the solution to your organization's needs. The good news is that **Microsoft gives you both options** – just don't let the marketing convince you that you *must* go the Azure Local route. As this series argues, **Windows Server + Hyper-V remains a rock-solid alternative** for those who want to run VMs on-premises without the cloud bells and whistles. 

In our next post, **Part IV: Feature Face-Off**, we'll dive into a head-to-head comparison of enterprise features – DRS vs. Live Migration, Fault Tolerance capabilities, backup ecosystem integration, and Hyper-V's unique Guarded Fabric security advantages. Spoiler: Hyper-V has evolved significantly and includes enterprise capabilities that sometimes get overlooked in the VMware-dominated conversation.

---

## My Personal Recommendations: The Windows Server Advantage

Having worked with organizations through countless virtualization migrations, I'll be direct: **Windows Server 2025 with Hyper-V is often the smartest path for most VMware refugees**. Here's why I consistently recommend it over Azure Local for the majority of post-VMware scenarios:

### For the Budget-Conscious (Most Organizations)

If you're facing VMware's new licensing costs and timeline pressures, Windows Server lets you **escape immediately without a hardware forklift**. Your existing servers that ran VMware reliably will almost certainly run Hyper-V just fine. Your SAN investment? Protected. Your networking gear? Probably adequate.

This isn't about settling for "good enough" – it's about being smart with capital allocation. Windows Server 2025 Datacenter gives you enterprise-grade virtualization with features that rival (and sometimes exceed) VMware's capabilities, all while preserving your hardware investments.

**Real Cost Example**: A typical 4-node cluster with 128 cores:

- **Windows Server Datacenter**: $20,800 (one-time purchase) + ~$4,000/year (Software Assurance)
- **Azure Local**: $15,360/year (service) + $35,798/year (Windows licensing) = $51,158/year
- **3-Year TCO Difference**: Windows Server saves ~$140,000 over Azure Local

### For the Pragmatic IT Professional

Let's talk reality. Azure Local sounds impressive in Microsoft's marketing materials, but it forces you into a very specific hardware model at a very specific time. What if your budget approval process takes months? What if your preferred vendor can't deliver validated nodes quickly? What if your existing SAN still has three years of useful life?

Windows Server doesn't care – it works with what you have **today** and scales with your actual business timeline, not Microsoft's sales cycle. **Hardware delivery reality**: Azure Local validated nodes typically require 8-16 weeks delivery, while Windows Server can be deployed on existing hardware in days.

### For Organizations Seeking True Independence

Here's something the cloud vendors don't want you to realize: **disconnected scenarios still matter**. Not every workload needs to phone home to Azure. Windows Server clusters can run completely offline if needed – no internet dependency, no cloud billing surprises, no questions about data sovereignty. You control the entire stack.

### The Arc-Enabled Middle Ground

That said, if you *want* some cloud benefits without the Azure Local hardware restrictions, Windows Server 2025 with **Azure Arc** gives you the best of both worlds.

**Azure Arc for Servers** provides:

- **Pricing**: $6/server/month for basic management
- **Capabilities**: Unified monitoring, policy enforcement, Azure Backup integration
- **No Hardware Restrictions**: Works on any Windows Server deployment
- **Optional Integration**: Enable selectively rather than mandatory from day one

**Arc-Enabled SCVMM: Enterprise Management Without Hardware Lock-In**

For organizations wanting Azure Local-class management capabilities, **System Center Virtual Machine Manager (SCVMM) with Azure Arc** delivers enterprise-grade virtualization management that rivals what Azure Local provides:

**SCVMM + Arc Integration Features**:

- **Unified Management**: Single pane of glass for multi-site Hyper-V environments
- **Cloud Integration**: Azure Arc-enabled SCVMM connects your on-premises infrastructure to Azure services
- **Automated Provisioning**: Template-based VM deployment across multiple clusters
- **Policy Management**: Consistent governance across hybrid environments
- **Backup Integration**: Native Azure Backup for VMs without additional agents
- **Update Management**: Coordinated patching through Azure Update Management

**The Enterprise Advantage**: Arc-enabled SCVMM provides many of the same centralized management, monitoring, and automation capabilities that make Azure Local attractive, but without forcing you into validated hardware constraints. You get:

- **Multi-cluster orchestration** across different server models
- **Hybrid cloud services** integration on your existing infrastructure
- **Enterprise-grade automation** and self-service capabilities
- **Azure services consumption** without infrastructure replacement

Arc-enabled Hyper-V clusters with SCVMM can provide many of the "hybrid cloud" benefits that Azure Local promises, without requiring validated nodes or ongoing per-core OS subscriptions. This approach gives you enterprise virtualization management that scales from branch offices to data centers, all while preserving your hardware investments.

### Cost Reality Check

Yes, Azure Local's per-core subscription model might look attractive on paper, especially if you're comparing it to VMware's new pricing. But factor in the **mandatory new hardware costs** and the reality that you're locked into that subscription model forever. With Windows Server, you buy the license once (or use existing licenses with Software Assurance), and your ongoing costs are just maintenance and support – not a monthly subscription that increases every time you add CPU cores.

### When Azure Local Actually Makes Sense

To be fair, Azure Local isn't wrong for everyone. Here are scenarios where it genuinely makes sense:

**✅ Azure Local is Right When:**

- **Greenfield deployment** with budget for new infrastructure
- **Branch offices** needing simplified, appliance-like management
- **Strong Azure integration requirements** from day one
- **Limited IT staff** who benefit from OEM-managed lifecycle
- **Regulatory requirements** that favor cloud-connected compliance tools

**❌ Azure Local is Wrong When:**

- **Recent SAN investment** that still has useful life
- **Budget constraints** limiting major infrastructure refresh
- **Mixed hardware environment** that needs gradual modernization
- **Air-gapped requirements** or data sovereignty concerns
- **VMware deadline pressure** requiring immediate migration

### Bottom Line Recommendation

Don't let Microsoft's marketing push you toward Azure Local unless you genuinely need a full infrastructure refresh and have budget allocated for it. **Windows Server + Hyper-V is still the enterprise workhorse** that powers countless production environments worldwide. It's proven, flexible, and respects your existing investments.

Sometimes the best cloud strategy is knowing when **not** to chase the latest cloud-native trend. For most VMware refugees, Windows Server 2025 provides the perfect balance: enterprise-grade virtualization without vendor lock-in, modern capabilities without mandatory subscriptions, and cloud integration when you want it – not when marketing demands it.

**The Reality Check**: Microsoft's sales teams will push Azure Local because it generates recurring revenue. But you're not optimizing for Microsoft's business model – you're optimizing for your organization's success. Choose accordingly.

---

**References:**

### Microsoft Official Documentation

1. Microsoft Learn – *"System requirements for Azure Local (23H2)"* (2024) – [Azure Local hardware requirements and validated configurations](https://learn.microsoft.com/en-us/azure-stack/hci/concepts/system-requirements)

2. Microsoft Learn – *"Failover clustering hardware requirements and storage options"* (2024) – [Windows Server clustering compatibility and validation requirements](https://learn.microsoft.com/en-us/windows-server/failover-clustering/clustering-requirements)

3. Microsoft Docs – *"Storage Spaces Direct overview"* (2024) – [Hyper-converged infrastructure design and implementation guide](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-direct-overview)

### Industry Analysis & Comparisons

4. Francesco Molfese – *"Windows Server 2025 vs. Azure Local: Who Wins the Virtualization Challenge?"* (Sep 2024) – [Hardware compatibility analysis](https://francescomolfese.it/en/category/windows-server-2025/) – Windows Server offers greater flexibility for reusing existing hardware compared to Azure Local's strict validation requirements.

5. Microsoft IT Ops Talk – *"Azure Stack HCI Hybrid is built-in: How does it really work?"* (2024) – [Official Microsoft session](https://learn.microsoft.com/en-us/shows/IT-Ops-Talk/OPS112-Azure-Stack-HCI-Hybrid-is-built-in-How-does-it-really-work) – Existing hardware can only be reused for Azure Local if it **exactly matches a current validated node**; otherwise new certified hardware is required.

### Hardware Vendor Documentation

6. Dell Technologies – *"Azure Local planning and deployment guide"* (2024) – [Comprehensive hardware sizing and validation guidance](https://www.dell.com/en-us/dt/solutions/cloud/azure-stack-hci.htm) – Emphasizes following the **validated hardware path** to avoid compatibility issues.

7. HPE – *"Azure Local solutions catalog and best practices"* (2024) – [ProLiant and Apollo validated configurations](https://www.hpe.com/us/en/solutions/cloud/azure-stack.html) – Hardware delivery timelines and GreenLake integration options.

8. Lenovo – *"ThinkAgile MX Azure Local appliances"* (2024) – [Pre-configured edge and branch office solutions](https://www.lenovo.com/us/en/servers-storage/solutions/microsoft-azure-stack/) – Simplified deployment for distributed environments.

### VMware/Broadcom Resources

9. Broadcom Knowledge Base – *"ESXi 9.0 deprecated and removed device drivers"* (KB#391170, 2025) – [Complete compatibility matrix](https://knowledge.broadcom.com/external/article/391170/) – Critical warning: upgrading to ESXi 9.0 with **unsupported (EOL) devices** can result in loss of storage or network access.

10. VMware vSphere 9.0 – *"Hardware compatibility and upgrade planning"* (2025) – [Official vSphere 9.0 documentation](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0.html) – Requirements for boot media (128GB), UEFI-only support, and increased memory minimums for container runtime support.

### Cost Analysis & Technical Comparisons

11. Brandon Lee, BDRSuite – *"Windows Server Hyper-V: SAN vs. Storage Spaces Direct"* (2017) – [Technical comparison analysis](https://www.virtualizationhowto.com/2017/09/differences-storage-spaces-storage-spaces-direct/) – Storage Spaces Direct often **much cheaper than high-end SANs**, with unified Windows Server management eliminating separate SAN administration tools.

12. Industry Cost Analysis – *"Azure Local subscription model vs. Windows Server perpetual licensing"* (2024) – [Comprehensive TCO comparison](https://www.bdrsuite.com/blog/hyper-v-storage-spaces-direct-disaggregated-vs-hyperconverged-deployments/) – Real-world TCO comparison showing Windows Server can save $140,000+ over three years compared to Azure Local's dual subscription model.

