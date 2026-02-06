---
title: Welcome to the Hyper-V Renaissance
description: VMware's Broadcom pricing crisis creates opportunity. Explore Hyper-V with Windows Server 2025 as a cost-effective alternative that preserves existing hardware.
date: 2026-02-04T05:14:22.386Z
series: The Hyper-V Renaissance
series_post: 1
series_total: 19
draft: false
lastmod: 2026-02-06T00:05:55.575Z
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: hyper-renaissance
lead: Why It's Time to Reevaluate Microsoft's On-Prem Champion
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Windows Server
tags:
    - Hyper-V
    - Windows Server 2025
    - Virtualization
    - VMware
    - Azure Local
    - Infrastructure
    - PowerShell
    - Migration
    - TCO
    - Enterprise IT
---


# Introduction
## A Perfect Storm Creates Opportunity

If you've been watching the virtualization market over the past eighteen months, you've witnessed something extraordinary: a once-stable industry thrown into chaos by a single acquisition. When **Broadcom completed its $69 billion purchase of VMware in November 2023**, few anticipated how dramatically—and rapidly—the landscape would shift. What followed wasn't just a pricing adjustment; it was a **fundamental restructuring** that has sent shockwaves through data centers worldwide.

Meanwhile, Hyper-V—which **has been a serious enterprise virtualization platform since the Windows Server 2012 and 2016 releases**—received substantial enhancements with **Windows Server 2025** in November 2024. Despite persistent rumors of its demise, Hyper-V **has never been "dead."** It has powered production workloads for over a decade and continues to run **every virtual machine in Microsoft's Azure cloud**. The timing of these 2025 enhancements couldn't be more significant. For IT professionals and architects now questioning their virtualization strategy, there's never been a better moment to reevaluate Microsoft's on-premises champion.

This is the first post in a 19-part series that will take you from strategic evaluation through production deployment. Whether you're a VMware veteran considering alternatives, an Azure Local evaluator questioning subscription costs, or an infrastructure architect designing new deployments—this series is for you.

Welcome to the Hyper-V Renaissance.

---

# The VMware Upheaval
## What Actually Happened

Let's be direct about what VMware customers are facing. Broadcom's changes weren't subtle refinements—they were a complete restructuring of the business model.

## The End of Perpetual Licensing

**January 22, 2024**: Broadcom ended the sale of perpetual VMware licenses entirely. The one-time purchase model that many organizations built their budgets around? **Gone**. Every customer must now commit to subscription licensing, transforming what were **capital expenditures into recurring operational costs**.

For organizations that previously stretched VMware license renewals across three-to-five-year cycles, this shift fundamentally alters IT budget structures. You now face predictable but unavoidable annual expenses—miss a payment, and you risk losing access to support, updates, and potentially your virtualization environment.

## The 72-Core Minimum Reality

**April 10, 2025**: VMware enforces a **minimum 72-core license subscription**—up from the previous 16-core minimum. Consider what this means in practice: if you have a single server with eight cores, you **still purchase licensing for 72 cores**. You're paying for **9x more capacity than you actually use**.

For small and medium businesses, for edge deployments, for remote offices with modest infrastructure—this minimum represents a **massive cost penalty**. Reports from the field indicate price increases ranging from **150% to over 1,000%**, with small businesses seeing **350-450% increases** specifically due to this core minimum requirement.

## The Bundle Consolidation

Broadcom reduced VMware's extensive product catalog from approximately 8,000 SKUs to just four primary bundles: VMware Cloud Foundation (VCF), VMware vSphere Foundation (VVF), VMware vSphere Standard (VVS), and VMware vSphere Essential Plus (VVEP).

While "simplification" sounds positive, the reality is different. Organizations must now purchase bundled products like NSX and vSAN even if they don't need them. The flexibility to buy exactly what you needed? That's gone. You're paying for capabilities you may never use.

## The Partner Ecosystem Collapse

In 2025, Broadcom reduced the number of authorized VMware Cloud Service Providers from **over 4,500 globally** to a dramatically smaller number—just **12 Pinnacle partners** and approximately **300 Premier partners** in the US. This isn't just a business restructuring; it's a **fundamental change in how organizations can access VMware expertise and support**.

## The Compliance Pressure

Perpetual license holders with expired support contracts have received **cease-and-desist letters** warning them to stop using any updates or patches issued since their support expiration. There's now an **up to 25% late-renewal penalty** for subscription contracts, applied retroactively. Broadcom's VMware is **significantly more aggressive about license compliance**, with telemetry and "phone home" features enabled by default on vSphere+ components.

---

# Is This Series for You?
## A Decision Tree

Before committing to an 18-post journey, let's determine if this series matches your situation.

## This Series IS for You If:

- **You're a VMware Customer Facing Renewal**: Your VMware renewal is approaching, and you've seen the new pricing. You need to understand alternatives quickly and make an informed decision. This series provides the **technical depth and practical guidance** to evaluate Hyper-V seriously.

- **You're Building New Infrastructure**: You're designing a new virtualization environment and want to evaluate all options without vendor bias. Even for greenfield deployments, you value the **flexibility to choose hardware based on technical merit and budget**—not vendor certification requirements. I'll give you honest comparisons across **VMware, Azure Local, and Hyper-V**, including what hardware freedom actually means for procurement and lifecycle planning.

- **You're Evaluating Azure Local but Questioning the True Cost**: Azure Local offers compelling Azure integration, but the economics give you pause. Beyond the **$10/physical core/month subscription fee** (plus separate guest OS licensing), Azure Local requires **Hardware Compatibility List (HCL) certified hardware**. That means many existing deployments face a **mandatory hardware refresh** before Azure Local is even an option. Your servers with three years of useful life remaining? They likely don't meet Azure Local's strict requirements. The true cost comparison isn't just subscription vs. perpetual licensing—it's **subscription + hardware replacement + guest OS licensing** vs. leveraging existing infrastructure with perpetual Windows Server Datacenter licensing. You want to understand what traditional **Hyper-V + WSFC** offers as an alternative, with **selective Azure integration on your terms** and the flexibility to run on hardware you already own—or to choose new hardware based on performance and value, not vendor certification lists.

- **You Have Existing Hardware Investments**: You've invested significantly in server hardware, storage arrays, and networking equipment with years of useful service remaining. Your servers may not be on Azure Local's Hardware Compatibility List, but they're **perfectly capable of running production workloads**. You want a virtualization platform that **leverages these investments** rather than forcing replacement. **Hyper-V runs on virtually any x64 server** that meets basic requirements—no vendor certification needed, no mandatory hardware refresh, no artificial compatibility restrictions. That three-year-old Dell, HPE, or Lenovo server? **It works**. That storage array you purchased two years ago? **It works**. Your existing network switches? **They work**. You maintain control over your hardware lifecycle based on **actual technical obsolescence**—not vendor requirements.

- **You Value Operational Autonomy**: You prefer infrastructure you **own and control**, without mandatory cloud connectivity or subscription dependencies. You want **hybrid capabilities as options, not requirements**. You're comfortable making your own technology choices for storage, networking, and management—selecting tools based on **technical merit** rather than because they're bundled into a mandatory package.

- **You're Comfortable with PowerShell**: This series takes a **PowerShell-first approach**. If you're comfortable scripting or willing to learn, you'll get maximum value. GUI procedures exist, but I emphasize **automation and repeatability**. PowerShell is the most powerful tool for Hyper-V management, configuration as code, and infrastructure automation.
## This Series is NOT for You If:

- **You're Committed to Full Azure Integration**: If unified Azure management across cloud and on-premises is your primary goal, **Azure Local is purpose-built for that scenario**. I'll cover when Azure Local makes sense (Post 16), but this series focuses on traditional Hyper-V.

- **You Need VMware-Specific Features Today**: Some VMware features don't have direct Hyper-V equivalents. If your environment depends on specific vSphere capabilities, you'll need to evaluate **feature parity carefully**. Post 3 provides detailed comparisons.

- **You're Looking for a Quick Fix**: Migrating virtualization platforms is a **significant undertaking**. This series provides thorough guidance, but there's **no shortcut** to proper planning, testing, and execution.

---

# The Search for Autonomy
Across conversations with IT leaders, infrastructure architects, and decision-makers, a consistent theme emerges: the desire for autonomy.
Organizations aren't just looking for cheaper alternatives—though cost matters enormously. They're seeking control over their own infrastructure destiny. They want predictable licensing that doesn't change dramatically year-over-year. They want to own their virtualization platform rather than rent it at increasingly unpredictable rates.
This desire for autonomy manifests in several ways:
- Budget Predictability: Organizations want to plan multi-year infrastructure investments without worrying that vendor pricing will change 4-10x overnight.
- Technology Choices: IT teams want to select storage, networking, and management tools based on technical merit—not because they're bundled into a mandatory package.
- Operational Independence: There's growing resistance to mandatory cloud connectivity, telemetry requirements, and subscription dependencies that tie infrastructure to external services.
- Investment Protection: Organizations with significant hardware investments—servers, storage arrays, networking equipment—want confidence that their existing infrastructure remains valuable.

---

# Why Hyper-V Deserves Your Attention
## The Right Time to Reevaluate

Against this backdrop, Hyper-V occupies a unique position. It's not a new entrant hoping to capitalize on VMware's troubles. It's a mature, enterprise-grade virtualization platform that has powered Windows Server deployments for over 15 years—and that powers every Azure virtual machine in Microsoft's cloud.

**A note on accuracy**: Azure runs on a customized variant of the Hyper-V hypervisor, optimized for Microsoft's cloud scale and requirements. The on-premises Hyper-V you deploy shares the same core architecture and benefits from the same development investment—but they're not identical implementations. That said, if Hyper-V's core technology wasn't enterprise-ready, Microsoft's entire cloud business would be at risk.

## Windows Server 2025
### The Improvements You Might Have Missed

Windows Server 2025, released in November 2024, brought substantial Hyper-V improvements that address many long-standing feature requests. Let's break down what changed and why it matters.

---

### Scalability & Performance: Enterprise-Class Limits

These limits make Hyper-V competitive with VMware for the largest enterprise workloads:

#### Per-VM Limits (Generation 2 VMs)

- **Up to 2,048 vCPUs per VM** (requires PowerShell configuration; UI limited to 1,024)
- **Maximum RAM increased to 240TB per VM**
- **256 virtual SCSI disks per VM, 64 virtual NICs per VM**

*Real-World Impact*: You can now run the most demanding SQL Server, SAP HANA, or Oracle databases without hitting Hyper-V limits.

#### Cluster-Wide Limits

- **Host memory: 4PB RAM** (with 5-level paging support)
- **Cluster scaling: 64 nodes, 8,000 VMs per cluster**

> **Important**: These maximums apply to Generation 2 VMs. Generation 1 VMs have significantly lower limits (64 vCPUs, 1TB RAM). Generation 2 is now the default for new VMs in Windows Server 2025.

> **Tip**: Configuring more than 1,024 vCPUs requires PowerShell. The Windows Admin Center and Hyper-V Manager GUI are limited to 1,024 vCPUs maximum.

---

### GPU Partitioning with Live Migration and High Availability

This was one of Hyper-V's most requested features, especially for AI/ML workloads:

GPU partitioning (GPU-P) allows a physical GPU to be logically separated and shared between multiple VMs. This shipped in Windows Server 2025 GA with **full support for live migration and failover clustering**. For AI, ML, CAD, and rendering workloads, this removes what was previously a significant Hyper-V limitation.

*Real-World Impact*: You can now live migrate VMs with GPU workloads for maintenance without downtime. GPU-enabled VMs also benefit from high availability—if a host fails, the VM automatically restarts on another cluster node.

---

### Accelerated Networking (AccelNet)

Streamlined SR-IOV management for VMs with reduced latency, jitter, and CPU utilization. The high-performance data path is now simpler to configure and maintain.

*Real-World Impact*: High-frequency trading, real-time analytics, and latency-sensitive applications see measurable performance improvements with less CPU overhead on the host.

---

### Operational Flexibility: Simplified Deployment Options

#### Workgroup Clusters Without Active Directory

Deploy Hyper-V clusters without requiring Active Directory domain membership. Live migration in workgroup clusters is supported via certificate-based authentication. This is particularly valuable for edge deployments, isolated environments, or organizations wanting simpler cluster topologies.

*Real-World Impact*: Edge locations, DMZ environments, or air-gapped facilities can now run full Hyper-V clusters without AD infrastructure.

#### Improved Live Migration

- **Data compression** reduces bandwidth requirements and speeds migrations by approximately 2x
- **RDMA offload** allows migrations without CPU overhead on hosts with compatible NICs
- **Dynamic processor compatibility mode** maximizes available CPU features across cluster nodes

> **Hardware Note**: RDMA offload requires compatible network adapters. Check your hardware compatibility before assuming this feature is available.

#### Enhanced Storage Live Migration

VMs can now move between storage volumes with zero downtime through improved disk mirroring and seamless switchover. **Shared Nothing Live Migration** allows VM transfers between hosts without shared storage—ideal for moving workloads across standalone servers or clusters with no common storage.

*Real-World Impact*: Storage maintenance, array migrations, and rebalancing workloads no longer require scheduled downtime.

---

### Security & Compliance: Hardened by Default

Windows Server 2025 brings security features that are now **enabled by default**—a significant shift from previous versions where many were optional:

#### Secure File Access
- **SMB over QUIC** now available in all Windows Server 2025 editions (previously Azure Edition only) for secure, encrypted file access over untrusted networks
- **SMB signing** required by default for all inbound and outbound connections
- **SMB encryption** enforced for all outbound SMB client connections

#### Identity & Access Protection
- **Credential Guard** and **VBS (Virtualization-Based Security)** enabled by default on domain-joined servers meeting hardware requirements
- **TLS 1.3 support** for LDAP connections with enhanced cryptographic security
- **LDAP signing** required by default for all new Active Directory deployments

*Real-World Impact*: Your default installation is significantly more secure against relay attacks, credential theft, and man-in-the-middle attacks—no additional configuration required.

---

# The Three-Tier Architecture
## Still Relevant, Still Superior for Many Workloads

One of the core themes of this series is that **traditional three-tier architecture—separate compute, network, and storage tiers—remains not just viable but often superior** for specific workloads and organizational contexts.

The industry narrative has heavily favored hyperconverged infrastructure (HCI) for the past several years. And HCI absolutely has its place—simplified management, predictable scaling, single-vendor support. For many workloads and organizations, HCI is excellent.

But three-tier architecture offers advantages that deserve honest consideration:

## Independent Scaling

With three-tier, you scale compute, storage, and network independently based on actual requirements. Need more processing power but your storage is fine? Add compute nodes. Need more storage capacity without changing your compute footprint? Expand your storage array. HCI forces you to add complete nodes even when you only need one resource type.

## Specialized Storage Capabilities

Enterprise storage arrays from Pure Storage, NetApp, Dell, HPE, and others offer capabilities that software-defined storage in HCI may not match for your specific requirements: advanced data reduction, enterprise replication, storage-level encryption, sophisticated tiering, proven data protection features developed over decades. For organizations with significant storage investments, these capabilities represent real value.

## Failure Domain Separation

In three-tier architecture, a storage array failure doesn't take down your compute infrastructure, and vice versa. The failure domains are distinct and manageable. In HCI, storage and compute are tightly coupled—which can simplify some operations but creates different failure scenarios.

## Workload Optimization

Some workloads genuinely benefit from dedicated storage infrastructure. High-performance databases, large-scale analytics, video production, medical imaging—these often perform better with purpose-built storage systems optimized for their specific I/O patterns.

## Existing Investments

Many organizations have made substantial investments in storage arrays with years of useful life remaining. Three-tier architecture lets you leverage these investments rather than abandoning them for an HCI approach.

This series will show you how to build production Hyper-V clusters using three-tier architecture with external storage. Post 6 covers universal storage integration principles with Pure Storage as a detailed example. Post 12 provides advanced storage architecture patterns. And Post 16 gives you an honest comparison of S2D, three-tier, and Azure Local—because the right architecture depends on your specific requirements.

---

# Hybrid Without Handcuffs
## Selective Cloud Integration on Your Terms

Here's an important distinction: **you can adopt hybrid cloud capabilities without surrendering control**.

Azure Local (formerly Azure Stack HCI) offers deep Azure integration, unified management, and services like AKS enabled by Arc. These are genuinely valuable capabilities for organizations committed to the Azure management plane.

But Azure Local also requires mandatory Azure connectivity, carries a $10/physical core/month subscription cost (plus separate guest OS licensing), and ties your on-premises infrastructure to Azure billing and connectivity.

Traditional Hyper-V with Windows Server Failover Clustering offers a different path: **selective cloud integration**. You maintain full ownership and control of your virtualization infrastructure while adopting Azure services where they add value:
- Azure Backup for Hyper-V protects your VMs to Azure-based storage
- Azure Site Recovery provides disaster recovery to Azure or another site
- Azure Arc offers optional inventory, monitoring, and management (free tier available for basic inventory)
- Azure Update Management handles patching across your infrastructure
- Hotpatching (with Azure Arc) enables security updates with minimal reboots

The key word is *optional*. You adopt these services when they make sense for your requirements, not because they're mandatory for your virtualization platform to function.

---

# The Cost Reality
## Three Platforms Compared

We'll dive deep into TCO analysis in Post 2, but here's the framework. Note that Broadcom licensing has been a moving target—verify current pricing at evaluation time.

## VMware (Post-Broadcom)

- Subscription-only licensing (perpetual no longer available)
- 72-core minimum purchase requirement
- Bundled products you may not need
- Per-core pricing on modern CPUs
- Reported increases of 150% to 1,000%
- Up to 25% late-renewal penalty

## Azure Local

- $10/physical core/month subscription (host service fee)
- Guest OS licensing separate (Windows Server subscription or bring your own license)
- Requires Azure connectivity (30-day grace period for disconnection)
- AKS on Azure Local included at no extra charge (2402 release and later)
- 60-day free trial available

## Hyper-V with Windows Server Datacenter

- Perpetual licensing available (also available as subscription via Azure Arc)
- Unlimited virtualization rights with Datacenter edition
- No mandatory cloud connectivity
- No subscription costs for base virtualization
- Your existing hardware works
- **Management options**: PowerShell (free), Windows Admin Center (free), or System Center Virtual Machine Manager (SCVMM) for enterprise-scale management

For a typical mid-size deployment—say, four hosts with 64 cores each (256 total cores)—the annual cost differences can be substantial. I'll build out realistic scenarios in Post 2, including often-overlooked costs: training investment, tooling ecosystem changes, operational familiarity loss, and migration effort. **Note**: SCVMM licensing adds cost for organizations requiring vCenter-equivalent enterprise management—I'll break down when SCVMM is worth the investment versus free alternatives.

---

# What This Series Will Cover

Over 19 posts across four sections, I'll take you from evaluation through production deployment:

## The Case for Change (Posts 1-4)

- **Post 1** (This post): Introduction, market context, and series roadmap
- **Post 2**: The Real Cost of Virtualization—TCO comparison with calculator template
- **Post 3**: The Myth of "Old Tech"—feature comparison and specification verification
- **Post 4**: Reusing Your Existing VMware Hosts—hardware validation process

## Foundation Building (Posts 5-8)

- **Post 5**: Build and Validate a Cluster-Ready Host—PowerShell deployment with comprehensive validation
- **Post 6**: Three-Tier Storage Integration—universal principles plus Pure Storage example
- **Post 7**: Migrating VMs from VMware to Hyper-V—conversion tools, procedures, and validation
- **Post 8**: POC Like You Mean It—complete hands-on cluster you can build this afternoon

## Production Architecture (Posts 9-15)

- **Post 9**: Monitoring and Observability—from built-in tools to Prometheus/Grafana, including when SCVMM justifies its cost
- **Post 10**: Security Architecture—cluster hardening and VM isolation
- **Post 11**: Management Tools for Production: WAC vMode, WAC, SCVMM, PowerShell for day-2 operations
- **Post 12**: Storage Architecture Deep Dive—advanced patterns and CSV internals
- **Post 13**: Backup and Disaster Recovery Strategies—comprehensive data protection
- **Post 14**: Live Migration Internals—mechanics, optimization, and troubleshooting
- **Post 15**: WSFC at Scale—multi-site clusters, cluster sets, and large deployments

## Strategy & Automation (Posts 16-19)

- **Post 16**: Hybrid Without the Handcuffs—selective Azure integration
- **Post 17**: S2D vs. Three-Tier and When Azure Local Makes Sense—honest platform comparison
- **Post 18**: PowerShell Automation Patterns (2026 Edition)—DSC, remoting, and CI/CD integration
- **Post 19**: Infrastructure as Code with Ansible and Terraform—IaC patterns with realistic expectations

---

# Series Assets

Throughout this series, I'll provide practical, immediately useful resources:
- GitHub Repository: All scripts, modules, templates, and IaC configurations
- Cost Calculator: Excel-based TCO comparison tool (Post 2)
- Reference Architectures: Visio/draw.io diagrams for storage, networking, multi-site
- Checklists: PDF downloads for validation, security, migration, backup
- Complete Lab Guide: POC deployment package (Post 8)
- Decision Matrices: Infrastructure selection, storage protocol, monitoring approach

Every PowerShell script will be tested. Every procedure will be validated. This isn't theoretical content—it's practical guidance you can use.

---

# A PowerShell-First Approach
This series takes a PowerShell-first philosophy: PowerShell remains the most powerful and flexible tool for Hyper-V management and automation.

## Management Tool Options

Hyper-V offers three primary management approaches:

1. **PowerShell** (Free, included): Most powerful and flexible—emphasis of this series
2. **Windows Admin Center** (Free): Modern web-based GUI for multi-host management
3. **System Center Virtual Machine Manager (SCVMM)**: Enterprise management platform for large-scale deployments—comparable to vCenter but requires separate licensing

While SCVMM provides comprehensive enterprise features (fabric management, service templates, multi-tenant networking, VMM library), many organizations successfully manage production Hyper-V environments using PowerShell and Windows Admin Center alone. I'll address when SCVMM's capabilities justify its cost in Post 10 (Monitoring and Observability).

PowerShell enables:

- **Repeatable deployments**: Script once, deploy consistently
- **Configuration as code**: Version control your infrastructure
- **Idempotent operations**: Run scripts safely multiple times
- **Integration**: Connect with any system that has a CLI or API
- **Validation**: Test configurations before applying them

Post 17 covers PowerShell automation patterns in depth, including Desired State Configuration (DSC) for configuration management and CI/CD integration. Post 18 extends this with Ansible and Terraform for organizations using those tools—with honest assessments of tooling maturity.

Throughout the series, I'll provide PowerShell examples for every major task. If you can do it in the GUI, I'll show you how to script it—making your deployments repeatable, documented, and automation-ready.

---

# My Philosophy
## Honest Evaluation, Not Advocacy

A note on series philosophy: **honest evaluation beats advocacy**.

This series advocates for giving Hyper-V serious consideration not for blindly choosing it over alternatives. I'll be direct about Hyper-V's strengths, and equally direct about scenarios where VMware, Azure Local, or other platforms may be better choices.

Post 16 specifically addresses when Storage Spaces Direct (HCI) outperforms three-tier architecture, and when Azure Local's integrated Azure management justifies its subscription costs. Post 3 compares features honestly, including areas where VMware maintains advantages.

If you complete this series and decide Hyper-V isn't right for your situation, you'll have made an informed decision. That's a win.

---

# The Bottom Line

Hyper-V with Windows Server 2025 is a mature, enterprise-ready virtualization platform that deserves serious consideration—especially now.

**Why it matters:**

- **Not "old tech"**: It powers Microsoft's cloud infrastructure. Windows Server 2025 brings significant improvements in scalability, GPU support, live migration, and security.

- **Cost-effective**: Perpetual licensing remains available. You can avoid subscription models entirely if that's your preference.

- **Preserves your investments**: Your existing servers, storage arrays, and networking equipment work just fine.

- **Hybrid on your terms**: Adopt Azure services selectively, without mandatory cloud dependencies.

This series will give you the technical depth and practical guidance to evaluate, deploy, and operate Hyper-V in production—whether you're migrating from VMware, comparing against Azure Local, or designing from scratch.

---

# What's Next

**Post 2: The Real Cost of Virtualization** provides detailed TCO analysis across VMware (post-Broadcom), Azure Local, and Hyper-V with Windows Server Datacenter. I'll break down licensing models, hidden costs, and provide a spreadsheet template you can customize for your own comparisons.

---

*Have questions or topics you'd like covered? Leave a comment below or reach out directly. Your feedback shapes this series.*

---

# Additional Resources

## Microsoft Documentation
- [What's New in Windows Server 2025](https://learn.microsoft.com/en-us/windows-server/get-started/whats-new-windows-server-2025)
- [Hyper-V on Windows Server](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-on-windows-server)
- [Windows Server Failover Clustering](https://learn.microsoft.com/en-us/windows-server/failover-clustering/failover-clustering-overview)
- [Azure Local Overview](https://learn.microsoft.com/en-us/azure/azure-local/)
- [Azure Local Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-local/)
## Vendor Resources
- [Lenovo: Implementing Hyper-V on Windows Server 2025](https://lenovopress.lenovo.com/servers/microsoft)
- [HPE Reference Architectures for Hyper-V](https://www.hpe.com/us/en/solutions/microsoft.html)
- [Dell Technologies: Windows Server Solutions](https://www.dell.com/en-us/dt/solutions/microsoft/windows-server.htm)
- [Pure Storage: Microsoft Platform Guide](https://www.purestorage.com/products/storage-as-a-service/portworx/microsoft-azure.html)
## Community Resources
- [Virtualization Review](https://virtualizationreview.com/)
- [StarWind Blog - Windows Server 2025 Coverage](https://www.starwindsoftware.com/blog/)