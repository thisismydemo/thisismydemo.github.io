---
title: Rethinking Virtualization Post-VMware
description: In a rapidly shifting virtualization landscape, many organizations are reevaluating their reliance on VMware. This blog series explores practical, cost-effective alternatives centered on Hyper-V, Windows Server Failover Clustering, and Azure Local. From licensing clarity to real-world migration playbooks, we examine how Microsoft’s hybrid ecosystem offers a stable, scalable, and secure path forward in a post-VMware era.
date: 2025-05-26T19:36:45.162Z
preview: /img/rethinkvmware/bloglogo.png
draft: true
tags:
  - Azure Local
  - WIndows Server 2025
  - Windows Server Failover Cluster
  - VMware
categories:
  - Azure Local
  - WIndows Server Failover Cluster
lastmod: 2025-05-27T16:58:36.082Z
thumbnail: /img/rethinkvmware/bloglogo.png
lead: How Hyper-V with Windows Server Clustering Stays Relevant in an Azure-First World
slug: rethinking-virtualization-post-vmware
---

## From My Perspective as a Microsoft Azure Hybrid MVP – Two Decades in Microsoft Hybrid & HCI

I write this blog as a longtime Microsoft advocate. In this blog series I’ll draw on two decades of hands on experience—from early HyperV in 2008 to today’s Azure Local.  To explore where Windows Server Failover Clustering still shines, where Azure’s hybrid offerings excel, and how decision makers can strike the right balance.

I’m not coming at this topic as a Microsoft sceptic—in fact, my professional journey has been tightly interwoven with every generation of Microsoft’s hybrid and hyper-converged story:

* **2008–2015 — HyperV foundations**. When HyperV first shipped with Windows Server 2008 (and matured through 2008 R2, 2012, and 2012 R2), I architected and deployed highly available, resilient HyperV clusters—pioneering best practices around Cluster Shared Volumes, Live Migration, and multi-site replication long before “HCI” became a buzzword.

* **2016 — Windows Server 2016 & WSSD launch**. As soon as Windows Server 2016 went to GA, I built some of the first production Storage Spaces Direct clusters certified under the original Windows Server SoftwareDefined (WSSD) solutions program, managing them with System Center VMM.

* **2017–2018 — Azure Stack Hub GA & early adoption**. Following Azure Stack’s general availability in mid2017 (later rebranded Azure Stack Hub), my team at NTT Data Services deployed one of the earliest Dell EMC 14G Azure Stack Hub integrated systems outside Microsoft’s own labs.

* **2019–2020 — Azure Stack Edge & first Azure Stack HCI previews**. When Microsoft unveiled Azure Stack Edge (GA 2019) and the initial Azure Stack HCI 19H2/20H2 previews, I championed Edge appliances for field analytics and dove headfirst into testing the new HCI OS that would eventually become Azure Local—offering both praise and constructive criticism as the platform evolved.

* **2021–present** — TierPoint & Dell APEX for Microsoft Azure solution. With Azure Stack HCI officially GA (version 20H2, refreshed 21H2/22H2), I joined TierPoint as a Product Technology Architect and helped launch one of the first managed Azure Stack HCI (Azure Local) services in the U.S. via Dell APEX Cloud Services with Azure Stack HCI (publicly announced 2022). I continue to present at MMSMOA, MC2MC, and MVP events on Azure Arc, Site Recovery, and hybrid strategy.

From that vantage point, I remain a strong advocate of Microsoft hybrid solutions—yet I also see where the messaging around **Windows Server + Hyper-V** can get drowned out by the Azure first drumbeat. This article (and the series that follows) aims to offer a balanced, experienced-driven perspective: celebrating **Azure Local** where it excels, while reminding decision makers not to overlook the rock solid foundation **Windows Server Failover Clustering** still provides.

> **Disclaimer — Views Are My Own**
> *The opinions expressed in this blog are solely my own and do not necessarily reflect those of my current employer, TierPoint LLC, its subsidiaries, partners, or clients. References to any TierPoint services or positions are incidental; no endorsement or approval by TierPoint should be inferred.*

## Things in the blog

- [From My Perspective as a Microsoft Azure Hybrid MVP – Two Decades in Microsoft Hybrid \& HCI](#from-my-perspective-as-a-microsoftazure-hybridmvp-twodecades-in-microsoft-hybridhci)
- [Things in the blog](#things-in-the-blog)
- [Microsoft’s Positioning of WSFC and Hyper-V vs. Azure Local (Azure Stack HCI)](#microsofts-positioning-of-wsfc-and-hyper-v-vs-azure-local-azure-stack-hci)
- [Where WSFC/Hyper-V Still Shines: Workloads and Architectures](#where-wsfchyper-v-still-shines-workloads-and-architectures)
- [Azure Local vs. Windows Server: Guidance and Gaps in Microsoft’s Messaging](#azure-local-vswindowsserver-guidanceandgapsinmicrosoftsmessaging)
- [Cost and Hardware Flexibility: WSFC vs. Azure Local vs. VMware \& Others](#cost-and-hardware-flexibility-wsfc-vs-azure-local-vs-vmware--others)
- [Feature Comparison: Gaps and Advantages vs. VMware vSphere](#feature-comparison-gaps-and-advantages-vs-vmware-vsphere)
  - [Where might WSFC/Hyper-V be a better fit than VMware?](#where-might-wsfchyper-v-be-a-better-fit-than-vmware)
  - [Reliability and Performance](#reliability-and-performance)
    - [Feature Comparison](#feature-comparison)
    - [Operational Considerations](#operational-considerations)
- [Legacy Hardware Support and Constraints](#legacy-hardware-support-and-constraints)
- [Microsoft’s Missed Opportunities and How to Leverage WSFC as a VMware Alternative](#microsofts-missed-opportunities-and-how-to-leverage-wsfc-as-a-vmware-alternative)
- [Quick Recap: What You Learned in This Post](#quick-recap-what-you-learned-in-this-post)
- [Blog Series Roadmap: Modernizing OnPremises with Microsoft](#blog-series-roadmap-modernizing-onpremises-with-microsoft)
- [References \& Further Reading](#references--further-reading)

## Microsoft’s Positioning of WSFC and Hyper-V vs. Azure Local (Azure Stack HCI)

Microsoft today maintains two parallel on-premises infrastructure paths: the traditional Windows Server with Hyper-V and Failover Clustering (WSFC), and the newer Azure Stack HCI (now under the “Azure Local” brand). Both are actively supported and intended for different, complementary purposes. Azure Local (formerly Azure Stack HCI) is positioned as Microsoft’s “premier” hyper-converged platform for running VMs and virtual desktops on-premises with hybrid cloud integration. It emphasizes cloud-connected management, frequent feature updates, and simplified all-in-one HCI architecture. In contrast, Windows Server (with Hyper-V and WSFC) is presented as a versatile, multi-purpose OS that can do more than just host VMs – it includes a full suite of server roles (Active Directory, file services, DNS, etc.) and allows traditional usage with Client Access Licenses (CALs) for direct client connections.

From Microsoft’s messaging, Azure Local is recommended to modernize datacenters with HCI: it offers industry-leading performance with low latency storage (via Storage Spaces Direct) and easy scaling for VM workloads. It also provides seamless hybrid cloud extensibility, plugging into Azure services like backup, monitoring, Azure Arc, and Azure Kubernetes Service (AKS) for modern apps. By contrast, Windows Server with WSFC/Hyper-V is framed as the right choice for scenarios needing a general-purpose server OS – for example, running traditional 3-tier apps, file servers, or domain controllers on bare metal, or hosting VMs that use external storage such as a Fiber Channel SAN. Microsoft explicitly notes that Windows Server remains ideal for “traditional infrastructure” setups like VMs connected to a SAN, which Azure Local does not support. In short, Microsoft positions Azure Local as the future-forward HCI/cloud-connected solution, while reassuring that Windows Server Hyper-V is still a strategic component for enterprises that need a flexible on-prem OS.

Notably, Microsoft has been reassuring customers that Hyper-V and WSFC are here to stay. In a 2024 Microsoft blog, the Hyper-V team emphasized that “Hyper-V is a strategic technology at Microsoft”, used broadly across Azure, Windows Server, Azure Local, and even Windows 11 and Xbox. They highlighted that if you own Windows Server, Hyper-V is built-in at no extra cost, and that Windows Server Datacenter edition’s unlimited VM rights combined with Hyper-V, Storage Spaces Direct (S2D), and software-defined networking deliver “the best bang for your buck” for virtualization. This messaging is clearly aimed at enterprise decision-makers: Microsoft indicates that even as it pushes Azure Local, it continues to invest in Windows Server for on-premises virtualization. In fact, the next Windows Server 2025 is adding new WSFC/Hyper-V features like GPU partitioning for VMs and Workgroup Clusters (clusters that don’t require Active Directory) to simplify edge deployments – concrete proof that Hyper-V/WSFC is evolving alongside Azure Local. Microsoft’s current stance is that both Azure Local and traditional WSFC have roles to play, and many organizations may deploy both for different needs.

## Where WSFC/Hyper-V Still Shines: Workloads and Architectures

Despite the buzz around HCI, Windows Server Failover Clustering (WSFC) with Hyper-V remains a proven solution for many enterprise workloads and architectures. Its strengths lie in flexibility and compatibility with both modern and “classic” infrastructure designs:

* **Traditional 3-Tier Apps and Shared Storage** – WSFC is ideal for scenarios that require shared external storage or specialized hardware. For example, clustering enterprise databases or file servers using a dedicated SAN (iSCSI/Fibre Channel) is a long-standing pattern fully supported by WSFC. Many enterprises have existing SAN/NAS investments; a Windows Server Hyper-V cluster can utilize those by treating LUNs on the SAN as Cluster Shared Volumes. Azure Local, by design, does not support external SAN storage or multi-path shared disks. If you need a classic two-node failover cluster with a shared disk array for something like a SQL Server Failover Cluster Instance or a clustered file server, WSFC is the go-to solution. Legacy application clustering (e.g. older versions of SQL, custom apps expecting shared storage) also relies on WSFC with SAN – a scenario where WSFC has no Azure Local equivalent.

* **Storage Spaces Direct (S2D) Clusters** – Windows Server Datacenter edition introduced S2D, and you can build hyper-converged clusters with WSFC using local disks (essentially the same concept as Azure Stack HCI). In fact, the core technologies – Hyper-V, S2D, and SDN – exist in both Windows Server and Azure Local. This means organizations can deploy a Hyper-V + S2D cluster on Windows Server 2019/2022 for an integrated compute+storage solution. Many have done so to run virtualization on smaller budgets by repurposing existing servers. While Azure Local offers additional bells and whistles (like Rack Aware clusters (private preview), kernel soft reboot, and streamlined updates available only in Azure Local editions), the fundamental ability to run VMs on a self-contained cluster with mirrored local storage is available in WSFC. For moderately sized private clouds, a WSFC Hyper-V cluster with S2D can deliver similar benefits to other HCI solutions – using familiar Windows Admin Center or Failover Cluster Manager tools. Microsoft still supports S2D on Windows Server, though some new S2D features (for example, single-node S2D deployments or certain performance enhancements) have been exclusive to Azure Local.

* **Multi-Purpose Clusters and Mixed Workloads** – A key advantage of WSFC is that a cluster can host a variety of cluster roles, not just virtual machines. Enterprises might run a mix of VM workloads and traditional roles (like file server clusters, print clusters, or even DHCP clusters) on the same Windows Server cluster. Hyper-V VMs can coexist with other clustered roles under WSFC’s umbrella of high availability. Azure Local, on the other hand, is purpose-built only to host VMs (and containers via AKS) – you cannot, for instance, install and cluster a SQL Server instance directly on the Azure Local host OS, since it’s a trimmed, purpose-specific OS without those higher-level roles. Windows Server still excels when you need servers that do double-duty: e.g. a 2-node branch office cluster that runs some VMs and also provides a highly available file share or domain controller. This “Swiss army knife” flexibility of WSFC is valuable in many enterprise and edge scenarios that don’t fit neatly into an all-HCI model.

* **Guest Clustering and Disaster Recovery** – For applications requiring inside-VM clustering (like an Always On SQL cluster or MSMQ cluster across VMs), Windows Server Hyper-V fully supports guest clusters using shared VHDX/VHD Sets or SMB3-based storage for the guest cluster’s shared disk. These are niche but important use cases (e.g. clustering at the application layer for zero downtime during guest OS patching). Hyper-V has features like VHD Set (shared virtual disks for guest clusters) to facilitate this. Competing platforms like VMware support guest clustering too, but the Windows ecosystem integration can make it easier (e.g. using Spaces Direct in guest or an S2D SOFS file server cluster as shared storage for guest VMs). Moreover, Hyper-V’s Replica feature allows asynchronous VM replication to a secondary host for DR, which can be useful for lightweight DR on WSFC clusters or standalone hosts. (Azure Local integrates with Azure Site Recovery for DR, but if an org doesn’t use Azure cloud, Hyper-V Replica is an on-prem alternative.)

In summary, WSFC/Hyper-V remains a robust choice for enterprises needing hardware and workload flexibility. It’s ideal for scenarios where you want to leverage existing storage infrastructure, run a mix of roles, or simply maintain the familiar operational model of Windows Server. Microsoft’s documentation explicitly guides customers to use Windows Server in cases where they need built-in roles or direct user connections (enabled via CALs) that Azure Local’s appliance-like model doesn’t allow. As one Microsoft document puts it, “Many organizations choose to deploy both [Azure Local and Windows Server] as they are intended for different and complementary purposes.”

## Azure Local vs. Windows Server: Guidance and Gaps in Microsoft’s Messaging

Microsoft provides some official guidance on when to choose **Azure Local** (formerly Azure Stack HCI) versus **Windows Server + Hyper-V**, but the messaging can be subtle. The clearest guidance is on Microsoft Learn, which suggests Azure Local for the “best virtualization host to modernize your infrastructure” with tight cloud integration, and Windows Server for traditional roles or scenarios needing a general purpose OS. The pivot is often cloud connectivity: if you want a cloud managed, always updated solution and plan to use Azure Arc and hybrid services, Azure Local is the recommended path. If you simply need a reliable on-prem OS that runs VMs and other services without cloud dependencies, Windows Server remains fully supported.

**Azure-first, everything-else-later**, In practice, Microsoft’s sales and marketing motion puts pure Azure at the top of the conversation stack. At keynotes, Solution Assessments, and partner briefings, the order of recommendations typically looks like this:

* **Azure native migration** (refactor or rehost directly to Azure IaaS/PaaS)

* **Azure VMware Solution (AVS)** – lift-and-shift vSphere estates into a managed Azure service when refactoring isn’t feasible

* **Azure Local (Azure Stack HCI)** – for workloads that must stay on-prem due to latency, sovereignty, or edge requirements

* **Windows Server Failover Clustering & HyperV** – a stay-put option that rarely gets headline airtime.

While each step has merit, this hierarchy can unintentionally overshadow the perfectly valid—and often most cost-effective—choice of modernizing in-place with WSFC + HyperV.

* **Event spotlight imbalance**. At Ignite, Build, and partner roadshows, Azure Local demonstrations share the main stage with Arc-enabled services, whereas classic WSFC/HyperV success stories are seldom featured. AVS, meanwhile, enjoys dedicated sessions and splashy customer spotlights as Microsoft’s “fastest onramp” for VMware estates.

* **Collateral firehose**. A quick scan of recent Microsoft solution playbooks reveals dozens of assets for Azure migrations, AVS ROI calculators, and Azure Local architecture guides—but virtually no new case studies centered on HyperV/WSFC alone. Customers who could benefit from using existing licenses and hardware often end up searching MVP blogs rather than Microsoft.com.

The **rebranding to “Azure Local”** itself signals that Microsoft views Azure Local as an extension of Azure’s distributed cloud strategy. There is correspondingly less fanfare around Windows Server Failover Clusters. For instance, one IT professional on a forum asked, *‘I keep finding Azure Local case studies, but almost nothing new about Hyper-V clusters—does Microsoft even talk about WSFC anymore?’*  This highlights a gap in Microsoft’s outreach: organizations evaluating a move off VMware seldom find material that directly pitches “**HyperV on Windows Server**” as a standalone alternative.

Indeed, Microsoft has been actively encouraging VMware customers to consider Azure Local, especially after Broadcom’s VMware acquisition stirred uncertainty. (Witness webinars titled “What’s your VMware exit strategy? – Azure Stack HCI.”) Yet the singular focus on Azure Local can leave a void for firms who prefer a familiar, Capex-licensed option. Microsoft’s own compare docs stress that Azure Local is delivered as a subscription service, whereas Windows Server uses a traditional perpetual model—but there’s no equally loud campaign stating, *“If you don’t want an Azure-managed solution, HyperV on Windows Server 2025 remains a modern, secure platform.”*

**Migration guidance is limited**, if you currently operate a Windows Server Failover Cluster with Hyper-V, an in-place upgrade to Azure Local is not possible; typically, new hardware must be implemented, or existing hosts must be reconfigured before transferring the VMs. Microsoft’s official documentation outlines basic methods such as exporting VMs or copying VHD files with Robocopy, but this process involves more manual steps compared to VMware's rolling cluster upgrades. Tools or ROI calculators that assist administrators in evaluating whether to maintain their current Hyper-V cluster or transition to Azure Local are still scarce.

To Microsoft's credit, the company has begun addressing several long-standing blockers for Azure Local (formerly Azure Stack HCI). Version 23H2 introduced support for disconnected operations in private preview, enabling clusters to function without continuous Azure connectivity, a critical feature for edge and government customers. Deployments without an Active Directory (AD-less) are now available in private preview, allowing for simplified identity management using Azure Key Vault and certificate-based authentication. Dell continues to offer a one-time “OEM License for Azure Local,” previously known as the “Azure Stack HCI OEM License,” providing a perpetual entitlement to the OS and cluster management features, thus avoiding recurring monthly Azure subscription fees for infrastructure services.

From a platform stability perspective, Azure Local has steadily matured, particularly on the Azure-connected side. Extensions such as Azure Arc, Update Management, and Azure Monitor have become more reliable and performant, with improved integration across hybrid and edge scenarios. However, some users still report challenges with extension version mismatches, dependency delays, or limited rollback options when Azure services change unexpectedly. Microsoft continues to enhance update transparency and platform resilience, especially for disconnected and highly regulated environments.

Still, the overarching narrative coming from Redmond is unmistakably cloud-centric. That creates a perfect opening for our blog series: **Make the balanced case for WSFC/Hyper-V**—highlighting cost, hardware reuse, and operational simplicity for IT leaders not yet ready (or able) to tether every workload to Azure.

## Cost and Hardware Flexibility: WSFC vs. Azure Local vs. VMware & Others

One of the most significant considerations for IT decision-makers is the cost model and hardware flexibility of competing platforms. Here’s how Windows Server WSFC/Hyper-V compares with Azure Local and other alternatives like VMware, Nutanix, OpenShift, and Proxmox:

* **Licensing & Upfront Costs**: Windows Server Hyper-V comes essentially “free” with the OS – if you own Windows Server Datacenter licenses, you can run unlimited VMs on those hosts at no extra hypervisor cost. This is a compelling CapEx model: you buy Windows Server (often already part of enterprise agreements) and you’re done. Azure Local, until recently, required a subscription fee per physical core per month (about $10 per core/month list price). Over a typical 5-year server lifespan, those fees can add up significantly – for example, a 2-socket server with 32 cores total at ~$10/core/month is ~$19,200 in Azure Local fees over 5 years, on top of still needing Windows licenses for the guest VMs. This OpEx model makes Azure Local’s TCO higher in many cases than a one-time Windows Server license (roughly ~$6k for 16-core Datacenter). Microsoft recognized this concern and now allows OEMs to offer a one-time Azure Stack HCI license with hardware, which can lower long-term costs. Still, Azure Local effectively bundles continuous feature delivery and support into that price – good for some, but if an organization prefers to sweat assets over 5-7 years with minimal changes, Windows Server’s one-time licensing is often cheaper. VMware vSphere, for comparison, has traditionally been sold as a per-socket (or per-core) license plus mandatory support contracts. VMware’s pricing has a high upfront cost (and VMware’s recent licensing changes and price hikes have been pain points for customers). However, once you’ve paid for VMware, there’s no monthly meter running. Nutanix is a proprietary HCI solution that also sells per-node or per-core licenses for its software (pricier than VMware in many cases, but it includes storage and management functionality). OpenShift (for containerized workloads) uses a per-core annual subscription model (often even more expensive per core than VMware or Windows, since it’s an all-in-one platform for containers). Proxmox and other KVM-based open-source hypervisors (XCP-ng, etc.) are free to use – you can download and run them with zero licensing cost, paying only if you want support. This makes Proxmox very attractive for budget-sensitive scenarios, albeit you trade off official vendor support and perhaps polish. In summary, WSFC/Hyper-V on Windows Server often has the lowest software cost for a Microsoft-stack shop (especially if you already own Windows licenses under an EA). Azure Local introduces ongoing subscription costs which need to be justified by the additional capabilities and cloud integration it brings.

* **Hardware Flexibility**: Windows Server runs on practically any server hardware that is certified for that OS – which is a broad list including many older models. Azure Stack HCI (Azure Local) by design is restricted to validated hardware solutions from its catalog. All nodes must be of the same model and configuration in an Azure Local cluster, and they’re expected to be equipped with certain minimum specs (e.g. all-flash or flash+SSD disks for S2D, RDMA NICs for storage networking, etc.). In fact, Azure Local explicitly does not support using any external SAN or RAID controllers – it requires direct-attached disks in HBA mode. This means if you have an existing investment in a high-end SAN or even a DAS enclosure that connects to multiple servers, Azure Local won’t utilize it. WSFC, on the other hand, can mix and match hardware to a degree and can certainly use SAN, NAS, or JBOD storage. It’s not uncommon in a WSFC to have nodes that are similar but not 100% identical (e.g. one might have more RAM than another or even be a different server model – it’s supported as long as they pass cluster validation). The best practice is to use homogeneous nodes in any cluster, but WSFC is a bit more forgiving here. (By contrast, HCI solutions like Azure Local and Nutanix demand homogeneity to ensure balanced performance and supportability.) For organizations with legacy servers, this is critical. Azure Local might require newer CPU generations (it supports Intel Nehalem and newer, roughly 2008+ servers, but realistically most validated nodes are much newer) and specific hardware features. If you have, say, some 5–7-year-old servers that are still running fine, they may not be on the Azure Local validated list – but you can still run Windows Server 2025 Hyper-V on them (if they’re 64-bit and supported by Windows). In fact, many companies with branch offices repurpose older servers as Hyper-V hosts rather than dispose of them; Hyper-V’s modest requirements (SLAT-capable CPU, which most since 2010 have) mean you can run it on a wide range of gear. Proxmox similarly will run on almost any x86_64 hardware. VMware has an HCL for support as well but is known to run on a broad array of servers (admins sometimes run ESXi on non-certified hardware for labs or even production, though it’s not officially supported). Nutanix is more restrictive – they either sell their own appliances or require specific server models from Dell, HPE, etc., with their software. OpenShift can run on any servers that can run Red Hat Enterprise Linux, which again is broad (though for full support you’d use supported configurations). The bottom line: **WSFC/Hyper-V offers excellent hardware flexibility**. You could have a 2-node cluster using some existing rack servers and a JBOD shelf, or even temporarily add a node with slightly different specs to a cluster in a pinch (not ideal, but possible). Azure Local is geared toward buying new, identical nodes (often in a 2, 4, or 8-node configuration) from a certified vendor. If you require small deployments, Azure Local now supports 1-node and 2-node options, but those still must be certified systems. Proxmox and other KVM solutions will give flexibility like Windows in terms of working on commodity hardware. For C-level decision-makers, this affects capital costs and vendor choice: Windows Server lets you leverage any “Certified for Windows Server” hardware (over 1000+ systems) and even continue using older gear if it meets basic requirements. Azure Local narrows your choices to ~200 validated solutions – which are high-quality, but often from top-tier vendors with associated price tags. If vendor lock-in and hardware procurement flexibility are concerns, WSFC has an edge.

* **Scaling and Upgrade Costs**: With Windows Server Hyper-V, scaling out means purchasing additional Windows Server licenses for new hosts (unless you already have Datacenter licensing that covers unlimited VMs). With Azure Local, each new host adds an ongoing per-core subscription. There is also a version-management cost to consider. Azure Local follows Microsoft’s Modern Lifecycle policy, so the platform receives a small cumulative security/quality patch every month, a fully validated baseline builds roughly every quarter, and a larger feature update about twice a year. Administrators must keep the cluster within six months of the most recent feature release, or the environment drops out of support. Windows Server, by contrast, keeps the classic LTSC model—one feature-frozen release that is supported for ten years—so nothing forces you to adopt new capabilities during that span. For organizations that value absolute predictability in training, change control, and compliance, that static model can lower operational overhead. On the other hand, shops that want the fastest access to performance gains or Azure-integrated features may view Azure Local’s rapid, cloud-style servicing as an ongoing investment that pays for itself (for example, Azure Local delivered accelerated S2D rebuilds and GPU clustering before they appeared in Windows Server). Ultimately, it’s a choice between “subscription to innovation” and “ownership of a stable platform.”

To compare with **VMware**: VMware’s vSAN (their HCI) similarly requires all-flash in modern versions and works best on homogeneous nodes, but VMware also supports traditional SAN/NAS if you choose not to use vSAN. Cost-wise, VMware can be expensive upfront, but their users often amortize that over several years of use without constant fees. **Nutanix** tends to be one of the more expensive per-node solutions (you pay for the convenience of its integrated software and management). **OpenShift** is costly but is aimed at a different paradigm (app modernization rather than VM density). **Proxmox** is cost-effective (free) but the organization must support it or buy a modest support contract; it’s popular for small businesses and labs, and even some enterprises for edge or DR sites, precisely because it avoids licensing fees.

In summary, **Windows Server WSFC/Hyper-V remains a very cost-effective and flexible option** for on-premises virtualization, particularly for organizations already in the Microsoft ecosystem. As one Microsoft PM noted, if you already license Windows Server Datacenter, you have a full virtualization and software-defined storage stack at your fingertips – “unlimited use rights…deliver the best bang for your buck”. Azure Local adds value through Azure integration and rapid innovation, but at the cost of a tighter hardware coupling and ongoing fees (mitigated somewhat by new licensing options). Decision-makers should weigh whether they need the cloud-connected bells and whistles, or if a tried-and-true Hyper-V cluster on the hardware of their choice could meet requirements at a lower TCO.

## Feature Comparison: Gaps and Advantages vs. VMware vSphere

When evaluating WSFC/Hyper-V against VMware vSphere (the market leader), there are feature differences to consider. VMware has long been praised for its rich enterprise feature set and polish, but Hyper-V has closed much of the gap over the years. Still, a few technical differentiators remain:

* **Live Migration vs. vMotion & DRS**: Both Hyper-V and VMware support live migration of running VMs (vMotion in VMware, Live Migration in Hyper-V) for zero-downtime host maintenance. VMware’s vMotion is very mature and can migrate VMs with minimal fuss; Hyper-V’s Live Migration also works well, though some argue VMware handles high-load scenarios a bit more gracefully. The bigger distinction is VMware’s Distributed Resource Scheduler (DRS) – an automated load balancing system that moves VMs around based on resource usage. Out of the box, Windows Server does not have a DRS equivalent that is fully automated at the hypervisor level. System Center Virtual Machine Manager (SCVMM) offers “Dynamic Optimization,” which can rebalance VMs across hosts on a schedule, but it’s not as real-time or as commonly used as VMware DRS. Many Hyper-V deployments rely on manual or scripted load management, whereas VMware DRS users often set it and let the cluster auto-tune resource distribution. For a C-level audience, the question is whether you need that level of autonomous optimization – in smaller environments it might not be critical, but in large clusters it helps maximize utilization.

* **Fault Tolerance**: VMware vSphere has a unique feature called Fault Tolerance (FT) that can run a “lockstep” secondary VM on another host, delivering zero downtime even if a host fails (the secondary instantly takes over). This is used for a handful of mission-critical VMs where even a brief failover restart is unacceptable. Hyper-V/WSFC currently has no direct analog to VMware FT. If a host fails in a Hyper-V cluster, the VMs restart on another node (usually within 30 seconds to a few minutes, depending on OS boot time). For 99% of workloads this is fine, but for that 1% (financial transactions, very sensitive systems), VMware FT can be a selling point. Microsoft typically covers those scenarios through other means (like clustering at the application level or using Azure services for HA), but it doesn’t provide the hypervisor-level FT that vSphere does.

* **Memory Overcommitment**: VMware is known for robust memory overcommit technologies – including transparent page sharing, ballooning, compression – which allow the system to allocate more total RAM to VMs than physically installed, with clever techniques to reclaim unused memory. Hyper-V’s approach is simpler via Dynamic Memory, which also allows overcommit to an extent by adjusting VM RAM on the fly, but it’s not quite as advanced in fine-grained sharing of memory between VMs. In practice, memory overcommitment is less important nowadays (servers have ample RAM and VMware even dialed back some techniques like default TPS due to security concerns), but it’s historically been a VMware strength for maximizing density. Hyper-V Dynamic Memory does a similar job of optimizing RAM usage by ballooning within VMs and can achieve high density as well, but administrators may find VMware gives more transparency and control in this area.

* **Management Tools and Ecosystem**: VMware’s vCenter is a single, unified management pane that many admins love for its completeness (performance charts, vMotion/DRS controls, update management, etc.). Hyper-V management is a bit more fragmented – you have Windows Admin Center (modern web UI, improving rapidly) and traditional tools like Failover Cluster Manager and Hyper-V Manager, or SCVMM for a centralized console. In recent years, WAC has provided a friendly dashboard for Hyper-V clusters (and even integrates into Azure Arc for cloud monitoring), but some users still perceive VMware’s management as more straightforward for large-scale environments. That said, organizations deeply invested in Microsoft System Center or Azure Arc may find Hyper-V management fits naturally into their existing toolchains (e.g. using System Center Operations Manager for monitoring, or Azure Arc + Log Analytics). It’s a matter of familiarity: VMware has a larger installed base in enterprises, so IT teams often have VMware expertise on staff. Microsoft’s ecosystem is equally rich (and many admins know PowerShell, which can automate Hyper-V extensively). But if a company has built a lot of operational process around vCenter and its APIs, switching to Hyper-V means retooling those processes.

* **Advanced Networking and Security Features**: VMware’s NSX offers very advanced network virtualization and security (micro segmentation, virtual routers, etc.) which is a significant add-on. Microsoft’s analogous capability is Software-Defined Networking (SDN) in Windows Server Datacenter, but it’s arguably less commonly deployed outside of Azure Stack environments. Hyper-V does have strong network virtualization (Hyper-V Network Virtualization and the newer Azure-inspired SDN controllers) and features like Switch Embedded Teaming and virtual network encryption. However, VMware’s networking stack (with NSX) is often seen as more feature-rich for software-defined data centers. On security, both hypervisors offer virtual TPM support, shielded VMs/Encrypted VMs, etc. Microsoft’s Guarded Fabric and Shielded VMs were quite innovative, ensuring even admins can’t see VM data – a similar concept to VMware’s VM Encryption tied to vCenter. Both platforms leverage hardware-assisted security (VBS in Windows, which Hyper-V underpins, and VMware’s virtualization-based security features for Windows VMs). It’s mostly at parity here, with each vendor integrating security into their stack (e.g., Microsoft’s Defender for Cloud can integrate with Azure Local, while VMware has partnerships for endpoint security).

* **Storage Integration**: If using external SAN/NAS, VMware’s ecosystem historically has tighter integrations (VAAI for offloaded SAN operations, a plethora of certified storage arrays, etc.). Hyper-V works with SANs via standard protocols (offering e.g. ODX for offload with some arrays, and SMB3 for NAS shares). Both support all-flash performance and modern storage protocols. VMware vSAN versus Windows S2D are analogous as software-defined storage: both can use NVMe/SSD and both offer compression, mirroring, etc. Some admins report that vSAN felt more stable in early days compared to early S2D, but S2D in Windows Server 2022/Azure Local 22H2 is quite mature now. Microsoft’s S2D does lack one feature compared to vSAN: true data deduplication for VMs (Windows has ReFS deduplication but only in Azure Local at present). VMware has had dedupe and compression in vSAN for a while. Depending on workload, this could tilt the efficiency.

It’s also worth mentioning **Nutanix** in features: Nutanix AHV (their Hyper-V-like KVM hypervisor) and software stack have strong multi-cluster management, easy one-click upgrades, and built-in data services. Hyper-V with WSFC can achieve similar outcomes but might require multiple tools (WAC, PowerShell, etc.) rather than a single GUI workflow. **OpenShift** vs **Hyper-V** is a bit of apples-to-oranges: OpenShift is about container orchestration; it doesn’t provide live migration of containers in the same way (it reschedules containers, which is a different paradigm). If a company is considering OpenShift, it’s usually part of a digital transformation into cloud-native apps rather than a direct replacement of VMware for existing VMs. In some cases, though, OpenShift’s KubeVirt component allows running VMs on the OpenShift cluster (using KVM under the covers), which could replace a portion of VMware or Hyper-V usage, but this is typically for specific scenarios (like running a legacy VM alongside containers).

### Where might WSFC/Hyper-V be a better fit than VMware?

Cost is a significant factor; a Windows Datacenter license covers a host and unlimited Windows VMs, making it very cost-effective for organizations primarily using Windows. Integration with Microsoft's ecosystem is another advantage. For instance, Azure Arc can manage on-premises VMs—Azure Local integrates natively, but even WSFC environments can be Arc-enabled with an agent, providing a unified management pane for both Azure and on-premises resources. Additionally, Azure Arc-enabled SCVMM allows organizations using System Center Virtual Machine Manager to connect their VMM environment to Azure, enabling VM lifecycle operations such as start, stop, pause, and delete directly from the Azure portal. This integration extends Azure's security, governance, and management capabilities to SCVMM-managed infrastructure, offering consistent management experience across hybrid environments

Edge deployments also benefit from Hyper-V's capabilities; Windows Server now supports "workgroup clusters" without Active Directory, simplifying deployments at small remote sites compared to setting up a full vSphere cluster. Hyper-V's smaller footprint—especially when using the free Hyper-V Server 2019 or a core installation—allows it to run on less powerful hardware, which is advantageous for edge scenarios. Moreover, organizations that rely heavily on Microsoft technologies, such as Windows Admin Center or System Center for monitoring, backup, and orchestration, may find that staying with Hyper-V provides a more unified and streamlined experience.

### Reliability and Performance

Both Hyper-V and VMware vSphere are mature, stable, and high-performing hypervisors. Microsoft's Azure cloud platform operates extensively on Hyper-V, demonstrating its scalability and reliability on a massive scale. Hyper-V supports hosts with up to 48TB of RAM and hundreds of logical processors, accommodating demanding workloads.

There aren’t many workloads that require VMware from a purely technical perspective; it often comes down to operational preference and specific feature needs.

#### Feature Comparison

While both platforms offer robust features, there are distinctions:

* **VMware Fault Tolerance (FT)**: VMware provides FT, allowing a secondary VM to run in lockstep with the primary. In the event of a host failure, the secondary VM takes over instantly, ensuring zero downtime. Hyper-V does not have a direct equivalent to this feature.

* **Hyper-V and Virtualization-Based Security (VBS)**: Hyper-V is integral to Windows' security infrastructure. VBS uses Hyper-V to create isolated regions of memory, enhancing protection against sophisticated attacks. This integration underscores Hyper-V's role beyond virtualization, serving as a foundation for security features in Windows 11 and Windows Server.

#### Operational Considerations

The choice between Hyper-V and VMware often hinges on specific organizational needs:

* **Cost**: Hyper-V can be more cost-effective, especially for organizations already invested in the Microsoft ecosystem, as Windows Server Datacenter licensing includes Hyper-V rights.

* **Ecosystem Integration**: For organizations utilizing Azure services, Hyper-V offers seamless integration, facilitating hybrid cloud deployments.

* **Feature Requirements**: Organizations requiring features like VMware's FT may prefer vSphere for its advanced capabilities in certain high-availability scenarios.

In summary, VMware vSphere still has an edge in some enterprise features and ecosystem maturity (especially if a business runs diverse OSes and wants a proven multi-OS hypervisor – though Hyper-V supports Linux and FreeBSD well now). But Hyper-V is functionally very close for most use cases, often at a fraction of the licensing cost. If an organization’s strategy is strongly Microsoft-aligned (O365, Azure, Windows everywhere), Hyper-V fits naturally and avoids the “VMware tax.” Each platform has areas it shines: VMware in ultra-large multi-tenant environments and when you need that last 5% of features; Hyper-V in environments where simplicity, cost, and Microsoft integration are paramount.

## Legacy Hardware Support and Constraints

A practical consideration in choosing an on-prem platform is what hardware you can use – especially if you want to extend the life of existing investments. Windows Server Failover Clustering can breathe new life into older or non-standard hardware setups that Azure Local or other HCI stacks won’t accept:

* **Older Servers**: Azure Local’s requirement for certified hardware generally means relatively modern servers (typically those designed or certified for Windows Server 2019/2022/2025). While its official CPU minimum is Intel Nehalem (c. 2008) or later, vendors validate Azure Local on newer Xeon Scalable families and AMD EPYC. If you have older rack servers (say 2012-era), they might run Azure Local OS technically but won’t be supported by Microsoft unless on the catalog. Windows Server 2025, by contrast, can be installed on any machine that meets the OS requirements. For example, a 10-year-old server that still has the Certified for Windows Server logo can join a failover cluster after a RAM or disk upgrade, even if it’s far from cutting-edge. This can be useful for test/dev clusters or less critical workloads. An Azure Local cluster is more of a fresh start approach – typically new hardware with identical configs.

* **Heterogeneous Nodes**: As mentioned, Azure Local requires all nodes same make/model and configuration. WSFC technically supports mixing node types (all nodes must run the same Windows version and pass cluster validation, but they could be different models). One could cluster a Dell server and an HPE server if both run Windows and see the shared storage. It’s not ideal, but possible – and sometimes necessary in DR situations or during hardware refreshes (mixing old and new nodes temporarily). VMware vSphere clusters also allow mixed server models (within compatibility limits), giving flexibility during hardware refresh cycles. So, in this regard, WSFC and VMware are more accommodating than Azure Local’s strict homogeneous stance.

* **Use of Existing Storage**: If an organization has an expensive Fiber Channel SAN or high-end NAS, they likely want to continue using it. WSFC/Hyper-V lets you present LUNs or SMB shares to your cluster for VM storage. Azure Local cannot use those; it insists on local attached disks (it doesn’t even have an option to connect to a SAN for CSVs). So, any legacy SAN arrays would be repurposed or retired if moving fully to Azure Local. For some, that’s unacceptable – e.g., they may have just invested in an all-flash SAN that still has 5 years of depreciation. Sticking with WSFC means you can modernize the compute (Hyper-V in place of ESXi perhaps) but still use that shared storage. This incremental approach – swap hypervisor, keep storage – is a common migration path for VMware-to-Hyper-V converts, as it lowers initial cost by not forcing a complete redesign of storage.

* **Hardware Peripherals and Niche Support**: Windows Server can make use of various specialized hardware – older RAID controllers (if not doing S2D), GPU cards for VDI or compute, etc. Azure Local does support GPUs and in fact introduced GPU high availability in its recent versions, but again only certain modern GPUs and through Azure integration. If you had, say, an older Nvidia GPU that isn’t on the Azure Local support matrix, you might still use it in a Hyper-V server for a specific workload (with some manual setup). Similarly, certain legacy networking gear or topologies might not fit the reference architectures of Azure Local, which often assume dual-switch, RDMA networks. WSFC can be more forgiving (you can even do a cluster with a single switch or 10GbE without RDMA – you’d lose some performance, but it works).

* **Software Version Support**: Another aspect of “legacy” is older software compatibility. If you need to run an older OS or application that isn’t containerizable, you might stick with a plain Windows Server host or VM. Both Azure Local and WSFC support guest VMs running quite old OS versions (even Windows Server 2008 R2 guests are supported on modern Hyper-V, and Linux guests as well). However, Azure Local follows a more frequent update cadence: monthly quality and security updates, quarterly baseline updates, and annual feature updates. To remain in a supported state, updates must be applied within six months of their release. In contrast, a Windows Server LTSC provides 5+5 years of support without feature changes. If you have some “don’t touch it” legacy app VM, you might be more comfortable hosting it on a cluster that isn’t subject to frequent update requirements.

In short, **WSFC/Hyper-V can leverage legacy assets and handle non-standard scenarios** in a way that Azure Local (and many competing HCI products) cannot. For organizations with considerable sunk costs in hardware, this is a big deal. Azure Local tends to be deployed on **brand-new, identical nodes** – essentially a greenfield approach. WSFC can be **brownfield**, sliding into existing environments (e.g., joining a Windows Server node to an existing cluster to expand capacity, or clustering two repurposed older servers for a secondary site). Proxmox and KVM-based solutions similarly allow a lot of reuses – you can install Proxmox on older servers and even combine different servers in a cluster (though mixed performance nodes might not be ideal for VM distribution). VMware is somewhere in between: flexible with hardware, but each major vSphere version has its own HCL and older servers eventually drop off support as ESXi requires newer drivers.

For IT leaders, the question is whether maximizing the use of **legacy hardware** is a priority or if standardizing on new HCI nodes for the next 5+ years is the plan. If you want to extend the life of older equipment or have more choice in vendors, WSFC/Hyper-V (or open-source hypervisors) give you that leeway. If you are ready to invest in new hardware and want a tightly integrated stack, Azure Local (or Nutanix, etc.) provides a clean, optimized slate – but at the cost of abandoning some legacy compatibility.

## Microsoft’s Missed Opportunities and How to Leverage WSFC as a VMware Alternative

Given all the above, it appears Microsoft could better capitalize on WSFC/Hyper-V’s strengths when positioning against VMware – especially for customers not fully sold on cloud integration. Some **opportunities Microsoft may be missing** include:

* **Highlighting Hyper-V as “VMware without the Cost”** – In the current climate, many enterprises are re-evaluating VMware due to rising costs and uncertainty (e.g., the Broadcom acquisition). Microsoft has a golden opportunity to market Windows Server Hyper-V as a straightforward, **cost-effective alternative for virtualization**. The technology is proven (running Azure and countless enterprises), and the cost savings can be substantial (often 30-50% lower TCO versus VMware by eliminating hypervisor licensing fees). While Microsoft does push Azure Local in this context, not every VMware customer wants an Azure-connected solution. By not equally pushing the message “Stay on-prem, replace ESXi with Hyper-V on existing Windows licenses,” Microsoft leaves a segment of the market to consider other options like Proxmox or remain with VMware. A strong campaign with case studies of companies who migrated from vSphere to Hyper-V (especially if they weren’t ready to go HCI) could resonate. This content is currently sparse – most Microsoft case studies center on Azure Local or full Azure migrations.

* **Catering to the “CapEx-focused” Customers** – Some organizations, especially in government, finance, or others with CapEx budgeting and long hardware lifecycle, prefer upfront investments to ongoing subscriptions. Microsoft’s Azure-first messaging might alienate those who just want to **refresh a data center every 5-7 years and not worry about monthly bills**. WSFC/Hyper-V fits that model perfectly, but Microsoft hasn’t been loudly beating that drum. In contrast, Dell and other OEMs recognized this and introduced the one-time Azure Local licensing – essentially doing the marketing that “you can have HCI without a subscription.” Microsoft should emphasize that with Windows Server; you already have what you need to build a private cloud. This could be a convincing angle for CxOs: **leverage existing licenses and skills to get cloud-like virtualization without new costs**.

* **Touting Recent Innovations in Windows Server** – Many decision-makers might assume Windows Server is “old tech” and all innovation is only in Azure Local. But as we saw, Windows Server 2025 is bringing impressive features (GPU partitioning, AD-less clusters). These directly address modern needs: GPU partitioning helps run AI/ML or VDI workloads efficiently on-prem, and workgroup clustering simplifies edge deployments where running a domain may be overkill. Microsoft could market these as “**Hyper-V evolves for the future**”, demonstrating that even if you don’t adopt Azure Local, you’re not stuck on a stagnant platform. The “Hyper-V is a strategic tech, and we never stop innovating it” message should be communicated beyond just tech forums. This would assure CTOs that choosing Hyper-V now isn’t choosing a dead-end – it will continue to get better, just as VMware releases new versions.

* **Improving Management Experience** – One reason VMware is often preferred is the ease of management at scale. Microsoft is addressing this (Windows Admin Center is getting richer, Azure Arc can manage multiple clusters, etc.), but they could do more to package a compelling management story for WSFC. Perhaps a lightweight “Azure Arc for Hyper-V” bundle that offers vCenter-like functionality (monitoring, VM moves, etc.) through the Azure portal for those who opt in, or enhancements in SCVMM to match newer features. Microsoft has all the pieces; it’s a matter of demonstrating to IT managers that operating Hyper-V is as convenient as operating vSphere. Success stories of organizations managing hundreds of Hyper-V hosts with ease (using WAC, PowerShell, SCVMM, etc.) could help counter the perception that Hyper-V is only good for smaller environments. (In reality, Hyper-V powers Azure, so it clearly can handle massive scale.)

* **Emphasizing Microsoft Ecosystem Synergy** – For a Microsoft-focused audience, one should underscore how well WSFC/Hyper-V integrates with the rest of the stack: Azure for hybrid backup, System Center for data protection (DPM), Azure Monitor for logging, etc. Things like Azure Backup and Azure Site Recovery support both Azure Local and Windows Server clusters, giving a seamless hybrid experience if desired. Active Directory and Azure AD work out-of-the-box with Windows Server (e.g., using Group Policy for Hyper-V host settings, something you can’t do on a vSphere host). For developers, Hyper-V can host Windows containers or provide dev/test VMs at no extra cost (especially using the free Hyper-V features on Windows 10/11 or Windows Server). Basically, if a company is all-in on Microsoft 365, Dynamics, SharePoint, etc., having the virtualization layer also be Microsoft simplifies vendor management and support.

In conclusion, **Windows Server Failover Clustering with Hyper-V** remains a formidable, modern solution that can absolutely stand toe-to-toe with VMware for many enterprise needs. Microsoft’s current messaging tilts toward Azure Local as the shiny new thing, but savvy IT leaders recognize that WSFC is battle-tested and continues to evolve. By carefully evaluating costs, workload needs, and the desired level of cloud integration, organizations can choose the path that fits them best—whether that means adopting Azure Local for a cloud-connected experience or leveraging WSFC/Hyper-V to maximize existing investments and minimize costs.

## Quick Recap: What You Learned in This Post

Before we jump into the roadmap, here’s a 30second refresher of the key takeaways you can bring to your next strategy meeting:

* **The market moment**: Broadcom’s VMware shakeup is forcing IT leaders to reevaluate on-prem hypervisors.

* **Why it still matters**: Windows Server Failover Clusters on HyperV remain a viable, cost effective, and fully supported alternative—even if Microsoft’s marketing puts Azure first.

* **Author’s lens**: Two decades of HyperV and Azure Stack experience inform a balanced, insider view—not an antiAzure rant.

* **Messaging gap**: Microsoft’s goto hierarchy (Azure ➜ AVS ➜ Azure Local ➜ “oh, and Windows Server”) leaves traditional HyperV clusters underrepresented.

* **Decision triggers**: Hardware reuse, perpetual licensing, and edge/disconnected scenarios often tilt the scales back toward plain WSFC.

Armed with those observations, the rest of this series will drill into the numbers, tooling and real-world stories you need to act.

## Blog Series Roadmap: Modernizing OnPremises with Microsoft

To guide decision makers from strategy to hands-on execution, upcoming posts will expand on each key decision point:

* **Post 1 – CapEx vs. Subscription: TCO Modelling for Hyper-V, AVS & Azure Local**
  Which stack is cheapest over five years for a 100 VM footprint?

* **Post 2 – License Models Demystified: Per Core, Per Socket, Per Subscription**
  How do Windows Server, Azure Local, and AVS licensing really compare—and where do hidden costs lurk?

* **Post 3 – Hardware Considerations: Build Your Cloud on Your Terms**
  Can you reuse existing SANs and mixed servers, or do you need validated nodes?

* **Post 4 – Feature Face Off: Does Hyper-V Meet Enterprise Needs?**
  A head-to-head on DRS, FT, backup ecosystems, and Guarded Fabric advantages.

* **Post 5 – Arc Enable Everything: Monitoring Hyper-V Clusters Next to Azure Local**
  Achieving a single pane of glass with Azure Arc policy and insights.

* **Post 6 – Disconnected & Rugged: Azure Local vs. Workgroup Clusters at the Edge**
  Choosing the best option when bandwidth is scarce and AD isn’t feasible.

* **Post 7 – From ESXi to Hyper-V in 30 Days: A Pilot Migration Playbook**
  Scripts, storage cut-over, and user impact mitigation for a low-risk sprint.

* **Post 8 – Three Paths Off VMware: Real World Journeys of Hyper-V, AVS & Azure Local**
  Mini case studies on cost savings, performance wins, and operational trade-offs.

* **Post 9 – What’s Next for Microsoft On-Prem? Windows Server & Azure Local**
  How upcoming releases will shape long-term hybrid strategy.

Series Flow

* Strategy & Cost (Posts 12)
* Technology Reality (Posts 35)
* Deployment & Edge (Posts 67)
* Proof & Future (Posts 89)

Stay tuned—and drop a comment on which topics you’d like prioritized!

## References & Further Reading

Below is a consolidated list of primary sources, whitepapers, and community articles cited throughout this post.

* **Microsoft Learn – Compare Azure Local vs. Windows Server 2022**
  [Compare Azure Local to Windows Server](https://learn.microsoft.com/en-us/azure/azure-local/concepts/compare-windows-server?view=azloc-24112)

* **Microsoft Tech Community Blog – Hyper-V Is a Strategic Technology at Microsoft**
  [The Future of Windows Server Hyper-V is Bright!](https://techcommunity.microsoft.com/blog/windowsservernewsandbestpractices/the-future-of-windows-server-hyper-v-is-bright/4074940)

* **Dell Technologies – Azure Stack HCI OEM License Datasheet**
  [Microsoft Azure Stack HCI | Dell USA](https://www.dell.com/en-us/dt/hyperconverged-infrastructure/microsoft-azure-stack/microsoft-azure-stack-hci.htm)

* **Gartner – Cost Implications of Broadcom’s Acquisition of VMware**
  [Given the proposed increases in costs around VMware since the Broadcom acquisition, what are the realistic alternatives in the virtualization category?](https://www.gartner.com/peer-community/post/given-proposed-increases-costs-around-vmware-since-broadcom-acquisition-realistic-alternatives-virtualisation-category)

* **IDC White Paper – Evaluating TCO for Hyper-Converged vs. Traditional Infrastructure**
  [Converged, Hyperconverged and Composable Infrastructure](https://my.idc.com/getdoc.jsp?containerId=IDC_P19654)

* **Azure Architecture Center – Azure VMware Solution Pricing**
  [Azure VMware Solution Introduction](https://learn.microsoft.com/en-us/azure/azure-vmware/introduction)

* **Microsoft Docs – Workgroup Cluster Deployment Guide (Windows Server 2025 Preview)**
  [Create a workgroup cluster in Windows Server](https://learn.microsoft.com/en-us/windows-server/failover-clustering/create-workgroup-cluster)

* **Storage Spaces Direct Performance Benchmarks (Microsoft Engineering)**
  [Storage Spaces Direct overview](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-direct-overview)

* **VMware Docs – vSphere Fault Tolerance Overview**
  [vSphere Availability - Broadcom Techdocs](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.avail.doc/GUID-39731BEC-EB0C-48C9-813B-CAF9DE884FD5.html)

* **Microsoft Azure Arc Documentation – Enable Arc on Windows Server Hyper-V Host**
  [Azure Arc-enabled servers Overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
