---
title: The Real Cost of Virtualization
description: A no-nonsense TCO comparison across VMware, Azure Local, and Hyper-V with Windows Server Datacenter licensing models and long-term projections.
date: 2026-02-11T12:00:00.000Z
series: The Hyper-V Renaissance
series_post: 2
series_total: 18
draft: false
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: real-cost-virtualization
lead: TCO Comparison - VMware, Azure Local, and Hyper-V
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Windows Server
tags:
    - Hyper-V
    - Windows Server 2025
    - VMware
    - Azure Local
    - TCO
    - Licensing
    - Cost Analysis
lastmod: 2026-02-07T00:06:24.680Z
---

The invoice arrived, and the meeting quickly followed.

For nearly two decades, the "cost of virtualization" was a line item we grumbled about but accepted. It was the "VMware Tax," the price of admission for a stable, feature-rich datacenter. But in the wake of the Broadcom acquisition and the subsequent licensing overhaul, that tax has, for many organizations, turned into a ransom.

This isn't just about price hikes. It's about a fundamental shift in how infrastructure is consumed. We are forcibly moving from a world of perpetual licenses and optional support to a world of mandatory subscriptions and bundled software stacks.

In this second post of the **Hyper-V Renaissance** series, we are going to look at the numbers. Not the marketing fluff, but the cold, hard Total Cost of Ownership (TCO) comparisons between three distinct paths: staying with **VMware**, adopting **Azure Local** (formerly Azure Stack HCI), or making the move to **Windows Server 2025 Hyper-V**.

> **Note:** To help you run these numbers for your specific environment, I've created a **TCO Calculator** (Excel) available in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/tools).

---

> **Important:**
> The information in this document and the numbers are what I found working on various other projects this past year. These numbers I tried to fact-check using various sources including AI. I may make mistakes, I am not perfect, and I don't work with licensing and various other areas all the time. Please make sure before using this page as fact that you also double-check the data.

---

## Understanding What You're Actually Buying

Before diving into numbers, it's critical to understand the fundamental differences in what each platform provides. This isn't just about hypervisor costs—it's about the complete stack required to run your virtual machines legally and effectively.

### The Complete Licensing Picture

Every virtualization deployment requires three things:

1. **Host Operating System / Hypervisor** – The software that runs on bare metal and hosts your VMs.
2. **Guest Operating System Licensing** – The right to run Windows (or Linux) inside your VMs.
3. **Client Access Licenses (CALs)** – The right for users or devices to access services running on those VMs.

How these components are licensed—and bundled—varies dramatically between platforms.

### Why This Matters for VMware Cloud Foundation (VCF)

With Broadcom's consolidation, VMware customers are now required to purchase VCF, which bundles not only the hypervisor (vSphere), but also storage virtualization (vSAN), network virtualization (NSX), operations automation (Aria Suite), and Kubernetes management (Tanzu). You pay for the entire stack, regardless of whether you use all components.

- **VCF is mandatory for new VMware customers.** Standalone vSphere, vSAN, or NSX are no longer available for new purchases.
- **Bundling impacts cost:** Unlike Hyper-V or Azure Local, where you can license only what you need, VCF forces you to buy the full suite.

### Comparison Preview

- **Hyper-V (Windows Server Datacenter):** Licensing includes unlimited Windows Server VMs and the hypervisor; you only pay extra for CALs.
- **Azure Local:** Host fee per core, guest OS licensing separate, Azure Hybrid Benefit can reduce costs.
- **VCF:** Mandatory bundle, per-core pricing, minimum purchase requirements, and separate Windows guest licensing.

---

## Platform Deep Dive: What Each Option Really Costs

### VMware Cloud Foundation (VCF) — The Only Path Forward

**Licensing Model:** Subscription-only, per physical core

Broadcom has consolidated the entire VMware product portfolio. Standalone purchases of vSphere, vSAN, and NSX are no longer available for new customers. The strategic product is **VMware Cloud Foundation (VCF)** — a mandatory, all-in-one bundle. vSphere Foundation (VVF) still exists but is positioned as a stepping stone; Broadcom's roadmap points every customer toward VCF.

**What this means for you:**

- **Perpetual licenses are eliminated for new purchases.** All new VMware acquisitions are subscription-only. Existing perpetual holders can renew support, but cannot purchase new perpetual licenses.
- **You buy the full stack whether you need it or not.** VCF bundles vSphere, vSAN, NSX, Aria Suite, and Tanzu into a single subscription. There is no option to purchase only the hypervisor.
- **16-core minimum per CPU (counting rule).** When calculating your core count, each physical CPU is counted as a minimum of 16 cores — even if the chip only has 8 or 12 cores. This inflates your billable total before you even get to the order.
- **72-core minimum per order (purchasing rule).** Once your cores are counted, Broadcom enforces a minimum purchase of 72 cores per VCF order line. Running a 2-socket server with 32 total cores? You're still buying 72. Running a single 16-core edge box? Still 72.

**What's Included (VCF):**

- vSphere (hypervisor)
- vSAN (1 TiB per core entitlement)
- NSX (network virtualization and micro-segmentation)
- Aria Suite (operations and automation)
- Tanzu (Kubernetes)

> Most organizations running traditional VM workloads will never use NSX, Aria, or Tanzu — but you're paying for all of them.

**What's NOT Included:**

- Guest OS licensing (Windows Server must be licensed separately)
- Client Access Licenses for Windows guests

**Current VCF Pricing (2026):**

| Product | Approximate Cost | Notes |
|---------|------------------|-------|
| VMware Cloud Foundation (VCF) | ~$350/core/year | 3-year subscription term; 72-core minimum per order |

*VCF pricing ranges from ~$300–$500/core/year depending on volume, term length, and negotiation. The ~$350/core/year figure reflects commonly reported 3-year commitment pricing from industry sources and reseller quotes. Always obtain a written quote from VMware/Broadcom or your authorized reseller.*

**The Double-Dip Problem:** With VMware, you pay Broadcom for the hypervisor platform AND Microsoft for Windows Server guest licensing. Two vendors, two contracts, two renewal cycles.

---

### Azure Local (formerly Azure Stack HCI)

**Licensing Model:** OpEx subscription, per physical core, billed through Azure

**The Model:**

- **Host service fee:** $10 USD per physical core per month
- **Guest OS licensing:** Separate (Windows Server subscription or bring existing licenses via Azure Hybrid Benefit)
- **Billing:** Monthly through your Azure subscription
- **Minimum:** 16 cores per host (no artificial minimums like VMware's 72-core floor)

**What's Included:**

- Azure Local operating system and hypervisor
- Azure integration (Azure Portal management, Azure Arc)
- Azure Kubernetes Service (AKS) on Azure Local at no extra charge (2402 release and later)
- Azure Virtual Desktop optimization features
- Free Extended Security Updates (ESU) for Windows Server 2012/R2 and Windows 10 VMs — no additional cost
- 60-day free trial

**What's NOT Included:**

- Windows Server guest OS licensing (unless using Azure Hybrid Benefit or Windows Server subscription)
- Azure service charges (Azure Monitor, Azure Backup, Azure Site Recovery, Defender for Cloud, etc.) — these are billed separately at standard Azure rates, even with AHB
- Azure Virtual Desktop per-vCPU service fee for AVD session hosts (if using AVD)

**Guest OS Licensing Options:**

| Option | Cost | CALs Required? | Requirements |
|--------|------|-----------------|--------------|
| Windows Server Subscription | ~$23/core/month | **No** — CALs included | Billed through Azure |
| Azure Hybrid Benefit (AHB) | $0 | **No** — included via SA | Requires WS Datacenter with active SA |
| Bring Your Own License | Varies | **Yes** — separate purchase | Existing perpetual licenses |

> **CAL Clarity:** When using the Windows Server subscription or Azure Hybrid Benefit, CALs are included — you do not need to purchase them separately. This is a meaningful cost advantage over standalone Hyper-V, where CALs are always a separate line item.

**⚠️ Hardware Requirement: The Hidden Cost**

Unlike standalone Hyper-V, which runs on virtually any x64 server, **Azure Local requires hardware validated through the [Azure Local Catalog](https://azurelocalsolutions.azure.microsoft.com)**. Three solution categories exist:

- **Premier Solutions:** Turnkey, fully validated and supported end-to-end by the OEM
- **Integrated Systems:** Pre-tested configurations with OEM-provided firmware/driver updates
- **Validated Nodes:** Individual server models tested for compatibility

**What this means:** If your existing servers aren't in the catalog, you're looking at a **mandatory hardware refresh** before Azure Local is even an option. For organizations with three-year-old servers that are perfectly capable of running VMs, this hardware requirement can add tens of thousands of dollars to the true cost of adoption — a cost that doesn't appear in Microsoft's subscription pricing.

Additional hardware requirements include:

- TPM 2.0 required and enabled
- Secure Boot required and enabled
- 1–16 nodes per cluster supported (single-node deployments are valid)

**OEM Pre-Installed License Option:**

Some OEM partners offer a **one-time prepaid Azure Local license** that bundles the host OS, AKS, and Windows Server Datacenter guest licensing into a single purchase — no annual subscription, no CALs required. This license is tied to the original hardware and does not include reassignment rights or upgrade rights to future Windows Server versions beyond 2025. Contact your OEM partner for pricing and availability.

**The Azure Dependency:**

Azure Local requires periodic Azure connectivity for billing validation and management. Here's what that looks like in practice:

- **Standard deployment:** Requires internet connectivity to Azure. Disconnected operation is supported for up to 30 days before the cluster enters a reduced functionality state.
- **Disconnected operations (preview):** For organizations with data sovereignty or air-gapped requirements, Microsoft offers a local control plane that provides a subset of Azure management capabilities without cloud connectivity. This requires a minimum 3-node management cluster (24 cores/node, 96GB RAM/node), an Enterprise Agreement, and validated hardware.

**Azure Hybrid Benefit Deep Dive:**

If you have Windows Server Datacenter licenses with active Software Assurance, Azure Hybrid Benefit can:

- **Waive the Azure Local host service fee** ($10/core/month)
- **Waive Windows Server subscription costs** for guests
- Does **NOT** waive supplemental Azure service charges (Backup, Monitor, Site Recovery, Defender, etc.)

This makes Azure Local potentially very cost-effective for organizations with existing Datacenter SA investments — but only if those licenses aren't already assigned elsewhere. And remember: the hardware must still be in the Azure Local Catalog.

**Free Extended Security Updates (ESU):**

VMs running on Azure Local receive **free ESUs** for legacy Windows Server (2012/R2) and Windows 10 at no additional cost. If your organization is still running end-of-support workloads, this can save significant money compared to purchasing ESU licenses separately through Azure Arc. No renewal action is required — once Azure verification for VMs is set up, ESU coverage continues automatically.

---

### Windows Server 2025 Datacenter with Hyper-V

**Licensing Model:** Perpetual (one-time purchase) + optional Software Assurance

**The Model:**

- **Core-based licensing:** Sold in 2-core packs and 16-core packs
- **Minimum licensing:** 16 cores per server (8 cores minimum per processor)
- **Virtualization rights:** Datacenter edition includes **unlimited Windows Server VMs** on the licensed host
- **Hypervisor:** Hyper-V is included — no separate cost
- **Hardware freedom:** Runs on virtually any x64 server — no HCL or vendor certification required

**Current Pricing (2026 list prices):**

| Component | List Price | Notes |
|-----------|------------|-------|
| Windows Server 2025 Datacenter (16-core base) | ~$6,771 | One-time purchase |
| Additional 2-core pack | ~$847 | For servers with >16 cores |
| Software Assurance | ~20% of license cost/year | Optional but recommended |
| Windows Server CAL (User) | ~$46 each | Per user accessing servers |
| Windows Server CAL (Device) | ~$38 each | Per device accessing servers |

*Prices shown are Microsoft list prices. Volume licensing, EA agreements, and reseller pricing typically reduce costs by 15–40%.*

**What's Included:**

- Host operating system (Windows Server 2025)
- Hyper-V hypervisor
- **Unlimited Windows Server VM licensing** (Datacenter only)
- Failover Clustering (Windows Server Failover Clustering / WSFC)
- Storage Spaces Direct (if desired)
- All Windows Server features (DNS, DHCP, File Services, etc.)

**What's NOT Included:**

- Client Access Licenses (CALs) — required for each user or device accessing Windows Server services
- Remote Desktop Services CALs (if using RDS)
- Management tooling beyond built-in (see Management Options below)
- Linux VM licensing (handled separately per distro)

**The Unlimited Virtualization Magic:**

This is the key insight that makes Windows Server Datacenter compelling for Windows-heavy environments:

> When you license a host with Windows Server Datacenter, you get unlimited rights to run Windows Server VMs on that host. The guest OS licensing is included. The hypervisor is included. You're not paying extra for virtualization — you're paying for Windows Server, and Hyper-V comes along for the ride.

**Pay-As-You-Go Alternative:**

Windows Server 2025 is also available as a **subscription through Azure Arc** — pay per core, per hour, billed to your Azure subscription. No product key required; Azure handles activation and billing. No CALs required for base functionality with this model. This is useful for short-lived servers, burst capacity, or organizations preferring OpEx.

**⚙️ Management Options: What Will It Cost to Run This?**

One of the most common questions when moving from VMware to Hyper-V is: *"Where's my vCenter?"* VMware charges separately for vCenter. Hyper-V management has a different model — with options ranging from free to enterprise-grade:

| Tool | Cost | Scale | Notes |
|------|------|-------|-------|
| **PowerShell** | Free (included) | Unlimited | Most powerful and flexible. Script everything. This series' recommended approach. |
| **Hyper-V Manager** | Free (included) | Single host | Built into Windows Server. Fine for one-off tasks, not for multi-host management. |
| **Windows Admin Center (WAC)** | Free (included) | Multi-host/cluster | Web-based GUI. Manages Hyper-V hosts, clusters, storage, networking. Extensible. Includes a VMware-to-Hyper-V VM conversion extension (preview). |
| **WAC Virtualization Mode (vMode)** | Free (preview) | Multi-host/cluster at scale | Purpose-built for Hyper-V fabric management. Centralized dashboard, global search, bulk VM operations, VM templates, Hyper-V Replica, and Azure Arc integration. Deployed as a stateful appliance with a built-in PostgreSQL database. Currently in **public preview** (launched Nov 2025, PP2 in Q1 2026); GA pricing TBD — free during preview. Requires Windows Server 2025 (2022 support coming via backported Network ATC). |
| **System Center Virtual Machine Manager (SCVMM)** | ~$3,607/2-core pack | Enterprise (up to 15,000 VMs) | The enterprise-grade option comparable to vCenter. Fabric management, service templates, multi-tenant networking, VM library, bare-metal provisioning. Requires System Center licensing. Supports Azure Arc integration for hybrid management. Current versions: SCVMM 2025, 2022. |

> **WAC vMode vs. SCVMM — Honest Assessment:**
>
> WAC vMode is Microsoft's answer to *"we need something between PowerShell and SCVMM."* It's purpose-built for Hyper-V virtualization management at scale — managing hundreds of hosts and tens of thousands of VMs from a single browser console. It's currently free, includes a built-in database for persistent state, and supports both standalone hosts and clusters.
>
> SCVMM is the battle-tested enterprise option — if you need service templates, bare-metal deployment, multi-site fabric management, or you're managing 10,000+ VMs across dozens of clusters, SCVMM is still the tool. But it comes with System Center licensing costs and its own management overhead.
>
> **For most organizations running 1–10 clusters with under 2,000 VMs, WAC + vMode + PowerShell will cover your needs at zero additional cost.** Budget for SCVMM only if your scale or operational requirements demand it.

**The Real TCO Picture for Hyper-V Clusters:**

Running production Hyper-V clusters isn't just the Windows Server license. Here's the complete picture:

| Component | Cost | Required? |
|-----------|------|-----------|
| Windows Server 2025 Datacenter | ~$423/core (one-time) | Yes |
| Software Assurance | ~20% of license/year | Recommended |
| Windows Server CALs | $38–$46/user or device | Yes |
| Windows Admin Center + vMode | $0 | Included |
| PowerShell | $0 | Included |
| SCVMM (if needed) | ~$3,607/2-core pack | Optional |
| Azure Arc (basic inventory) | $0 (free tier) | Optional |
| Azure Arc (extended management) | Varies by service | Optional |
| Backup solution (Veeam, DPM, etc.) | Varies | Recommended |
| Monitoring (Prometheus/Grafana, SCOM, etc.) | Varies | Recommended |

> **Key Takeaway:** For most Hyper-V deployments, the only mandatory costs are the Windows Server Datacenter license and CALs. Management tooling (WAC, vMode, PowerShell) is free. Everything else — SA, SCVMM, Azure Arc, backup, monitoring — is optional and adopted based on your needs and scale.

---

## Understanding Client Access Licenses (CALs)

A critical but often-overlooked cost component: **CALs are required for every user or device accessing Windows Server services** — but *how* you license determines whether you need to buy them separately.

### CAL Requirements by Platform

| Platform | Separate CALs Required? | Notes |
|----------|------------------------|-------|
| **VCF + Windows VMs** | **Yes** | CALs required for every Windows Server guest — no exceptions |
| **Azure Local + WS Subscription** | **No** | CALs are **included** in the Windows Server subscription (~$23/core/month) |
| **Azure Local + Azure Hybrid Benefit** | **No** | CALs are **included** — covered by Software Assurance |
| **Azure Local + OEM Pre-installed License** | **No** | CALs are **included** in the OEM license bundle |
| **Azure Local + BYOL (no SA)** | **Yes** | Traditional CALs required if bringing standalone licenses without SA |
| **Hyper-V (perpetual license)** | **Yes** | CALs required for every user or device accessing Windows Server |
| **Hyper-V (Pay-as-you-go via Azure Arc)** | **No** | CALs for standard functionality are **included** in the subscription (RDS CALs still separate) |

> **Why this matters:** If you're evaluating Azure Local with Windows Server subscription or Hyper-V with pay-as-you-go licensing, the CAL cost effectively disappears from your TCO. This is a significant hidden savings that most cost comparisons miss — 100 users × $46 = $4,600 that you may not need to spend.

**CAL Types (when required):**

- **User CAL (~$46):** Licenses one user across unlimited devices. Best for mobile/remote workers.
- **Device CAL (~$38):** Licenses one device for unlimited users. Best for shared workstations, kiosks.

**Important CAL Rules:**

1. **Version compatibility:** The CAL version must be **equal to or newer than** the server version being accessed. A Windows Server 2022 CAL **cannot** access a Server 2025 host — you'd need Server 2025 CALs. However, a Server 2025 CAL **can** access Server 2022 and older.
2. **Perpetual but version-locked:** CALs don't expire, but they don't upgrade either. When you upgrade your servers from 2022 → 2025, you need new CALs for the new version — unless you have **Software Assurance on your CALs**, which provides version upgrade rights.
3. **RDS CALs are always separate:** Remote Desktop Services CALs are an additional purchase regardless of licensing model. Even subscription-based models (Azure Local WS subscription, pay-as-you-go) do **not** include RDS CALs.

**Example CAL Cost (when applicable — 100 users):**

- 100 User CALs × $46 = **$4,600** (one-time, but version-locked)
- With SA on CALs: Add ~20% annually for upgrade rights
- With Azure Local WS subscription or pay-as-you-go: **$0** (included)

---

## Software Assurance: Is It Worth It?

Software Assurance (SA) is Microsoft's comprehensive maintenance program for perpetual Volume Licenses. It's optional but provides significant benefits — and for some scenarios, it's the only path to critical cost savings.

**What SA Provides:**

- **Version upgrade rights** — Automatically receive new Windows Server versions (Server 2025 → future releases) at no additional license cost
- **Azure Hybrid Benefit (AHB)** — Waives the Azure Local host fee (~$10/core/month) and Windows Server subscription fee; provides Linux-rate pricing for Azure VMs. **This benefit alone can save tens of thousands annually for hybrid environments.**
- **License Mobility** — Right to reassign licenses between servers and datacenters, critical for virtualization and migration flexibility
- **Azure Migration Allowance** — 180-day concurrent licensing during migration (Datacenter edition gets indefinite dual-use for Azure VMs)
- **Windows Server Management via Azure Arc** — SA holders (and pay-as-you-go customers) get these at no additional cost: Azure Update Manager, Change Tracking & Inventory, Machine Configuration (Azure Policy), Windows Admin Center in Azure, Remote Support, Best Practices Assessment, Azure Site Recovery Configuration, and Network HUD (WS2025)
- **24/7 problem resolution support**
- **Training vouchers and online e-learning**
- **Disaster recovery rights** — Passive secondary instance rights for failover scenarios
- **Step-up licensing** — Upgrade from Standard to Datacenter edition at reduced cost
- **Spread payments** — Amortize license + SA costs across three annual payments

**What SA Does NOT Include:**

- **Hotpatching** — This is a **separate Azure Arc subscription** at **$1.50/core/month**, billed through Azure. It does **not** require SA. Hotpatching is free on Windows Server Datacenter: Azure Edition (Azure IaaS and Azure Local). For on-premises WS2025 Standard or Datacenter, it's a standalone paid service via Azure Arc — SA holders and non-SA holders pay the same price.

**SA Cost:** Approximately **25% of license cost annually** (actual rates vary by agreement type — EA, Open Value, CSP, MPSA). SA is only available through Volume Licensing and must be purchased at time of initial license acquisition or renewal.

> ⚠️ **Critical: SA Expiration Kills Azure Hybrid Benefit.** If your SA lapses, you lose AHB immediately. Microsoft docs state: *"Workloads using Azure Hybrid Benefit can run only during the Software Assurance or subscription license term. When the SA term approaches expiration, you must either renew, disable the hybrid benefit, or deprovision those workloads."* For organizations using AHB to waive Azure Local fees or get discounted Azure VMs, losing SA doesn't just mean no upgrades — it means your Azure costs jump significantly.

**The Trade-off — Break-Even Math:**

| Scenario | SA Recommendation | The Math |
|----------|-------------------|----------|
| Upgrade every version (~3 years) | ✅ **SA is cost-effective** | SA over 3 years (~$5,078 for 16-core Datacenter) < buying new license (~$6,771) |
| Upgrade every other version (~6 years) | ❌ **Buying new licenses is cheaper** | SA over 6 years (~$10,156) > new license (~$6,771) — but you lose all other SA benefits |
| Using Azure Hybrid Benefit | ✅ **SA is required** | AHB savings (waived host fees + WS subscription on Azure Local) often exceed SA cost within the first year |
| Want hotpatching (on-prem) | ⚪ **SA not relevant** | Hotpatching is a separate $1.50/core/month Azure Arc subscription — no SA required |
| Want Windows Server Management via Arc | ✅ **SA qualifies you** | Free access to Update Manager, Change Tracking, WAC in Azure, and more |
| Break-even point | ~4 years | If you upgrade within ~4 years, SA wins. Beyond ~4 years, buying new licenses is cheaper (license cost only — you still lose SA's other benefits) |

**Bottom Line:** For most enterprise environments — especially those with Azure Local, Azure VMs, or hybrid workloads — SA pays for itself through Azure Hybrid Benefit alone. The version upgrade rights are a bonus. If you're running a purely on-premises Hyper-V environment with no Azure footprint and plan to skip server versions, SA may cost more than it saves in pure licensing terms — but you'd also lose License Mobility, disaster recovery rights, and the Azure Arc management suite.

---

## Scenario Analysis: Real-World Deployments

Let's model three common scenarios with complete cost breakdowns.

### Scenario 1: Small Business / Branch Office (3 Nodes)

| Specification | Value |
|---------------|-------|
| **Hosts** | 3 |
| **CPUs per Host** | 2× 24-core (48 cores/host) |
| **Total Physical Cores** | 144 |
| **RAM per Host** | 512 GB |
| **Windows VMs** | 50 |
| **Users Accessing Servers** | 75 |
| **Evaluation Period** | 5 Years |

#### Option A: VMware Cloud Foundation (VCF)

| Cost Component | Year 1 | Years 2–5 | 5-Year Total |
|----------------|--------|-----------|--------------|
| VCF Subscription (144 cores @ $350/core/year) | $50,400 | $201,600 | $252,000 |
| Windows Server Datacenter (guest licensing, 144 cores) | $50,000 | $20,000 SA | $70,000 |
| Windows Server CALs (75 users @ $46) | $3,450 | $0 | $3,450 |
| **Total** | **$103,850** | **$221,600** | **$325,450** |

*Note: VCF pricing shown at ~$350/core/year (3-year term). This is the only product path for new VMware customers — standalone vSphere is no longer available. You still pay Microsoft separately for Windows Server guest licensing.*

#### Option B: Azure Local

| Cost Component | Year 1 | Years 2–5 | 5-Year Total |
|----------------|--------|-----------|--------------|
| Azure Local Host Fee (144 cores @ $10/core/month) | $17,280 | $69,120 | $86,400 |
| Windows Server Subscription (144 cores @ $23/core/month) | $39,744 | $158,976 | $198,720 |
| **Subtotal (no existing licenses)** | **$57,024** | **$228,096** | **$285,120** |

**With Azure Hybrid Benefit (existing WS Datacenter + SA):**

| Cost Component | Year 1 | Years 2–5 | 5-Year Total |
|----------------|--------|-----------|--------------|
| Azure Local Host Fee | $0 (AHB) | $0 (AHB) | $0 |
| Windows Server Subscription | $0 (AHB) | $0 (AHB) | $0 |
| Existing WS Datacenter SA (144 cores) | $10,000 | $40,000 | $50,000 |
| **Total (with AHB)** | **$10,000** | **$40,000** | **$50,000** |

*Azure Hybrid Benefit dramatically reduces Azure Local costs—but only if you have existing Datacenter licenses with active SA that aren't already deployed elsewhere.*

#### Option C: Windows Server 2025 Datacenter (Hyper-V + Existing SAN)

This option assumes you already own a SAN (Pure Storage, NetApp, Dell PowerStore, HPE Nimble, etc.) — no new storage capital required. This is the most common path for VMware shops migrating to Hyper-V, since you're already running shared storage.

| Cost Component | Year 1 | Years 2–5 | 5-Year Total |
|----------------|--------|-----------|--------------|
| WS Datacenter 2025 (144 cores @ ~$423/core) | $60,912 | $0 | $60,912 |
| Software Assurance (~25%/year) | $15,228 | $45,684 | $60,912 |
| Windows Server CALs (75 users @ $46) | $3,450 | $0 | $3,450 |
| Storage (existing SAN — already owned) | $0 | $0 | $0 |
| **Total (with SA)** | **$79,590** | **$45,684** | **$125,274** |
| **Total (without SA)** | **$64,362** | **$0** | **$64,362** |

*Uses existing SAN infrastructure (FC/iSCSI). No new storage capital. Guest OS licensing included with Datacenter. Hypervisor included. CALs required. SAN maintenance/support costs are excluded as they exist regardless of hypervisor choice.*

#### Option D: Windows Server 2025 Datacenter (Hyper-V + Storage Spaces Direct)

This is the hyperconverged approach — local NVMe/SSDs in each node replace the SAN entirely. Storage Spaces Direct (S2D) provides built-in replication, tiering, and fault tolerance across nodes. No SAN to maintain, no FC switches, no storage licensing.

| Cost Component | Year 1 | Years 2–5 | 5-Year Total |
|----------------|--------|-----------|--------------|
| WS Datacenter 2025 (144 cores @ ~$423/core) | $60,912 | $0 | $60,912 |
| Software Assurance (~25%/year) | $15,228 | $45,684 | $60,912 |
| Windows Server CALs (75 users @ $46) | $3,450 | $0 | $3,450 |
| NVMe/SSD drives (3 nodes, ~$8,000–$15,000/node) | $24,000–$45,000 | $0 | $24,000–$45,000 |
| **Total (with SA)** | **$103,590–$124,590** | **$45,684** | **$149,274–$170,274** |
| **Total (without SA)** | **$88,362–$109,362** | **$0** | **$88,362–$109,362** |

*Eliminates SAN dependency entirely. S2D requires minimum 2 nodes for a failover cluster (3 nodes recommended for quorum). Drive costs vary significantly by capacity, tier (all-flash vs hybrid), and vendor. The range shown covers typical small business deployments (10–50 TB usable). S2D is included in Windows Server Datacenter — no additional storage software licensing.*

#### Scenario 1 Summary

| Platform | 5-Year TCO | Annual Average | Notes |
|----------|------------|----------------|-------|
| VMware VCF | $325,450 | $65,090/year | Full stack bundle + separate Windows licensing |
| Azure Local (no AHB) | $285,120 | $57,024/year | Subscription-only, ongoing costs |
| Azure Local (with AHB) | $50,000 | $10,000/year | Requires existing WS DC + SA |
| **Hyper-V + SAN (with SA)** | **$125,274** | **$25,055/year** | Existing SAN, perpetual + maintenance |
| **Hyper-V + SAN (no SA)** | **$64,362** | **$12,872/year** | Existing SAN, perpetual only |
| **Hyper-V + S2D (with SA)** | **$149,274–$170,274** | **$29,855–$34,055/year** | Hyperconverged, no SAN needed |
| **Hyper-V + S2D (no SA)** | **$88,362–$109,362** | **$17,672–$21,872/year** | Hyperconverged, perpetual only |

**Key Insight:** For Windows-heavy environments, Hyper-V with an existing SAN offers the lowest 5-year TCO by a significant margin. If you're also looking to eliminate SAN infrastructure entirely, the S2D option adds drive costs upfront but removes ongoing SAN maintenance, support contracts, and FC switch costs from your budget — costs that aren't captured in this licensing-only comparison.

---

### Scenario 2: Mid-Size Enterprise (8 Nodes)

| Specification | Value |
|---------------|-------|
| **Hosts** | 8 |
| **CPUs per Host** | 2× 32-core (64 cores/host) |
| **Total Physical Cores** | 512 |
| **Windows VMs** | 200 |
| **Users Accessing Servers** | 500 |
| **Evaluation Period** | 5 Years |

| Platform | 5-Year TCO | Annual Average | Notes |
|----------|------------|----------------|-------|
| VMware VCF | ~$1,119,000 | ~$223,800/year | Full stack bundle + separate Windows licensing |
| Azure Local (no AHB) | ~$1,013,760 | ~$202,752/year | Subscription-only, ongoing costs |
| Azure Local (with AHB) | ~$180,000 | ~$36,000/year | Requires existing WS DC + SA |
| **Hyper-V + SAN (with SA)** | **~$337,000** | **~$67,400/year** | Existing SAN, perpetual + maintenance |
| **Hyper-V + SAN (no SA)** | **~$240,000** | **~$48,000/year** | Existing SAN, perpetual only |
| **Hyper-V + S2D (with SA)** | **~$437,000–$497,000** | **~$87,400–$99,400/year** | Hyperconverged, no SAN needed |
| **Hyper-V + S2D (no SA)** | **~$340,000–$400,000** | **~$68,000–$80,000/year** | Hyperconverged, perpetual only |

*S2D drive costs estimated at ~$12,000–$20,000/node for mid-size enterprise workloads (8 nodes × $12K–$20K = $96K–$160K). Actual costs depend on capacity, performance tier, and drive vendor.*

---

### Scenario 3: Edge / ROBO Deployment (Single Node)

| Specification | Value |
|---------------|-------|
| **Hosts** | 1 |
| **CPUs per Host** | 1× 16-core |
| **Total Physical Cores** | 16 |
| **Windows VMs** | 5 |
| **Users Accessing Servers** | 25 |
| **Evaluation Period** | 5 Years |

**VMware Challenge:** The VCF 72-core order minimum means this 16-core deployment must license 72 cores — a **350% overhead**. Combined with VCF's ~$350/core/year pricing, this single edge server costs more in VMware licensing over 5 years than most organizations spend on the hardware itself.

| Platform | 5-Year TCO | Notes |
|----------|------------|-------|
| VMware VCF (72-core minimum) | ~$126,000 | Paying for 72 cores on 16-core hardware |
| Azure Local (no AHB) | ~$31,680 | Per-core, no artificial minimum |
| **Hyper-V + SAN (with SA)** | **~$12,500** | Existing SAN, 16 cores licensed + SA + CALs |
| **Hyper-V + SAN (no SA)** | **~$10,000** | Existing SAN, 16 cores licensed + CALs |
| **Hyper-V + local storage** | **~$10,000–$14,000** | Direct-attached drives, no clustering |

> **Note on S2D for Edge:** Storage Spaces Direct requires a **minimum of 2 nodes** for a failover cluster. For single-node edge/ROBO deployments, the typical approach is local direct-attached storage without S2D clustering. If you need HA at the edge, consider a 2-node S2D cluster or Azure Local (which supports 2-node deployments with a cloud witness).

**Edge Deployment Takeaway:** VCF's mandatory 72-core minimum and bundled pricing make small deployments catastrophically expensive — **over 10× the cost of Hyper-V**. Hyper-V and Azure Local both scale down to match your actual hardware. For edge sites with existing SAN connectivity (branch office with FC/iSCSI to a central SAN), the Hyper-V + SAN option is the lowest-cost path.

---

## The Hidden Costs of Change

TCO calculations must include the friction of migration. Here's a realistic assessment:

### Migration Effort Estimates

| Cost Category | Estimate (50 VMs) | Notes |
|---------------|-------------------|-------|
| VM Migration | 40–80 hours (estimate) | ~1–2 hours per VM for simple VMs; complex VMs can take significantly longer — estimate only |
| Storage reconfiguration (SAN path) | 16–24 hours | MPIO, LUN presentation, CSV setup — applies when reusing existing SAN |
| Storage reconfiguration (S2D path) | 16–32 hours | Drive provisioning, pool creation, volume configuration, CSV setup — applies when building hyperconverged |
| Network validation | 8–16 hours | NIC teaming, VLAN configuration |
| Backup reconfiguration | 8–16 hours | Veeam/Commvault job recreation |
| Training (team of 4) | 40–80 hours | WAC, WAC vMode, WSFC, PowerShell |
| Documentation | 16–24 hours | Runbooks, procedures |
| **Total Staff Time** | **128–248 hours** | At $75/hour = **$9,600–$18,600** |

> **Migration Accelerator:** Windows Admin Center includes a **VMware-to-Hyper-V VM conversion extension** (preview) that can automate much of the VM migration process — converting VMDKs to VHDXs and recreating VM configurations. This can significantly reduce the per-VM migration time estimate above. We'll cover this tool in detail in Post 7 of this series.

**Reality Check:** Even at the high end, migration costs are typically recovered within a few months of subscription savings when moving off VCF. Validate with a pilot and supplier quotes.

### Hidden Costs of Staying with VMware

- **Hardware compatibility:** Broadcom's HCL is shrinking. Older SANs and NICs may lose support.
- **Renewal risk:** Industry reports document material price increases (200–500%) after the Broadcom acquisition. What happens at your next renewal?
- **Forced bundling:** VCF forces you to pay for vSAN, NSX, Aria, and Tanzu whether you use them or not.
- **Partner ecosystem consolidation:** Broadcom has significantly reduced the number of authorized VMware partners, making it harder to find competitive quotes and qualified support.
- **Feature lock-in:** New VMware features require VCF. Perpetual license holders are stuck on legacy versions with no upgrade path.

### Hidden Costs of Switching to Hyper-V

- **Training investment:** Team needs to learn WSFC, WAC, WAC vMode, and PowerShell-based management. The concepts map well from VMware (vMotion → Live Migration, vCenter → WAC vMode, VMFS/vSAN → CSV/S2D, esxcli → PowerShell), but the tools and workflows are different.
- **Tooling gaps:** Terraform Hyper-V providers are community-maintained, not HashiCorp official. However, most Hyper-V shops use **PowerShell DSC**, **Ansible**, or **Azure Arc** for Infrastructure as Code rather than Terraform. If you have heavy Terraform investment from your VMware days, this is a real migration cost. We'll cover IaC approaches (Ansible + Terraform) for Hyper-V in detail in **Post 18** of this series.
- **Ecosystem adjustment:** Third-party tools may need reconfiguration (backup, monitoring, security). Most enterprise tools (Veeam, Commvault, Zerto, PRTG, Datadog) support Hyper-V natively, but job configs and policies need recreation.
- **Operational familiarity:** vSphere Client muscle memory doesn't transfer to WAC or PowerShell. Expect 2–4 weeks of reduced operational velocity as the team adjusts. The good news: WAC vMode is specifically designed to feel familiar to virtualization admins coming from centralized management consoles.

---

## The Decision Framework

### When Hyper-V Wins

1. **You run mostly Windows guests:** The Datacenter licensing overlap makes the hypervisor essentially free.
2. **You prefer CapEx:** Buy once, run for 5+ years without ongoing subscription pressure.
3. **You want CapEx AND OpEx flexibility:** Windows Server 2025 is also available as pay-as-you-go via Azure Arc — per-core, per-hour billing with no CALs required. You're not locked into one model.
4. **You already own a SAN:** Reuse your existing Pure Storage, NetApp, or Dell infrastructure. Zero new storage capital = lowest TCO path (Option C in our scenarios).
5. **You don't need the cloud stack:** You just need VMs, not vSAN/NSX/Aria.
6. **Free management tooling matters:** WAC + WAC vMode + PowerShell = $0 for management at scale. No equivalent to vCenter licensing costs.
7. **You value vendor simplicity:** One vendor (Microsoft) for host, hypervisor, and guests.
8. **You have edge/ROBO deployments:** No artificial minimum purchase requirements. License exactly the cores you have.
9. **You want hardware freedom:** Any x64 server — no HCL, no vendor certification required.
10. **You run a mixed Windows + Linux estate:** Datacenter licensing covers unlimited VMs of *any* OS. Every Linux VM on a Datacenter-licensed host adds zero incremental cost — the Windows license you already need pays for the hypervisor.

### When VMware Still Makes Sense

1. **Massive Linux estates:** If 90%+ of VMs are Linux *and* you have near-zero Windows guests, the Windows licensing advantage vanishes. But even a 50/50 mix tilts toward Datacenter — the Linux VMs ride free.
2. **Deep NSX investment:** You've built security around NSX micro-segmentation.
3. **Mature vSAN deployment:** Storage migration risk outweighs licensing savings — but remember, vSAN requires vSphere, which now requires VCF pricing.
4. **Active Broadcom EA with favorable terms:** If you just signed a 3-year VCF deal at pre-acquisition pricing, riding it out may be smarter than breaking the contract. Plan your exit for renewal.
5. **VMware-specific compliance certifications:** Some regulated industries (healthcare, financial services) have compliance frameworks certified specifically for VMware. Recertifying on Hyper-V has a real cost and timeline.
6. **Organizational inertia — but do the math:** We quantified migration at $9,600–$18,600 for 50 VMs and 2–4 weeks of reduced velocity. Compare that to your annual VCF subscription cost. In most cases, the migration pays for itself within a few months.

### When Azure Local Wins

1. **Azure integration is strategic:** You want Azure Portal as your single management pane.
2. **AKS is critical:** Azure Kubernetes Service on Azure Local is genuinely excellent.
3. **AVD optimization:** Azure Virtual Desktop runs best on Azure Local.
4. **You have existing WS Datacenter SA:** Azure Hybrid Benefit makes Azure Local very cost-effective — waives both host fee and WS subscription.
5. **You want HCI with Azure management:** Simpler than standalone Hyper-V + S2D, with Azure-managed updates and monitoring built in.
6. **CAL elimination matters:** The Windows Server subscription on Azure Local **includes CALs** — no separate purchase needed. For organizations with large user counts, this is a significant hidden savings.
7. **You have legacy Windows Server VMs:** Azure Local provides **free Extended Security Updates** for Windows Server 2012/2012 R2 guests — no separate ESU purchase required.
8. **You prefer validated hardware:** The Azure Local HCL (200+ pre-validated solutions) means tested, certified hardware combinations. For risk-averse organizations, this is a feature, not a limitation.

### Choosing Your Storage: SAN (Option C) vs. S2D (Option D)

If you've decided on Hyper-V, the next question is storage architecture:

| Factor | Existing SAN (Option C) | Storage Spaces Direct (Option D) |
|--------|------------------------|----------------------------------|
| **Best for** | Shops with existing SAN investment | Greenfield or SAN-exit scenarios |
| **Upfront cost** | $0 (SAN already owned) | $8,000–$20,000/node in NVMe/SSDs |
| **Ongoing cost** | SAN maintenance + support contracts | $0 (drives are owned, S2D is included in Datacenter) |
| **Complexity** | FC/iSCSI networking, MPIO, LUN management | Drive pools, volumes, CSV — simpler day-2 ops |
| **Minimum nodes** | 1 (single host can connect to SAN) | 2 for cluster (3 recommended for quorum) |
| **Scaling** | Scale storage and compute independently | Scale together (add nodes = add storage + compute) |
| **Lock-in** | Tied to SAN vendor (Pure, NetApp, Dell) | No vendor lock-in — use any NVMe/SSD drives |

> **Rule of thumb:** If your SAN is paid off and under active support, use it (Option C). If your SAN is approaching end-of-life or you're paying $50K+/year in SAN maintenance, S2D (Option D) may be cheaper over 5 years even with the upfront drive investment.

---

## Key Takeaways

1. **VMware VCF's 72-core order minimum and bundled pricing** create disproportionate costs for small and medium deployments — a single 16-core edge server costs over $126,000 in VCF licensing over 5 years.

2. **Azure Local's value depends heavily on Azure Hybrid Benefit.** Without existing WS Datacenter SA, it's the second most expensive option — still cheaper than VCF, but significantly more than Hyper-V. With AHB, it can be the cheapest.

3. **Windows Server Datacenter includes unlimited VM licensing.** If you're running Windows guests, the hypervisor is effectively free.

4. **CALs are required with perpetual licensing — but subscription models eliminate them.** With Azure Local WS subscription, Azure Hybrid Benefit, or Hyper-V pay-as-you-go via Azure Arc, CALs are included. Don't assume CALs are always a separate cost — your licensing model determines this.

5. **Migration costs are real but recoverable.** Most organizations recover migration investments within 3–6 months of subscription savings.

---

## Next Steps

We've established that the money makes sense. But does the technology hold up?

*"Hyper-V is old tech, right?"*

In the next post, **[Post 3: The Myth of 'Old Tech'](/post/hyper-v-myth-old-tech)**, we're going to tear down that misconception. We'll look at the verified specs of Windows Server 2025: 2,048 vCPUs per VM, 240 TB RAM per VM, GPU partitioning with live migration, workgroup clusters, and NVMe tiering.

Spoiler: It's not old tech. It runs Azure.

---

## Resources

- **TCO Calculator (Excel):** [github.com/thisismydemo/hyper-v-renaissance/tools](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/tools)
- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)
- **Post 1:** [Welcome to the Hyper-V Renaissance](/post/hyper-renaissance)


### References

- Windows Server pricing and licensing (Windows Server 2025): https://www.microsoft.com/en-us/windows-server/pricing
- Azure Local pricing (Azure Local / Azure Stack HCI): https://azure.microsoft.com/en-us/pricing/details/azure-local/
- Azure Hybrid Benefit for Azure Local (Microsoft Docs): https://learn.microsoft.com/en-us/azure/azure-local/concepts/azure-hybrid-benefit
- Windows Server editions and virtualization rights (Microsoft Docs): https://learn.microsoft.com/en-us/windows-server/get-started/editions-comparison
- Hyper-V scalability limits (Microsoft Docs): https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/maximum-scale-limits
- VMware vSphere product and edition pages (VMware/Broadcom): https://www.vmware.com/products/vsphere.html
- VMware vSAN product pages and datasheets: https://www.vmware.com/products/vsan.html
- VMware by Broadcom licensing and portfolio simplification (Broadcom official): https://news.broadcom.com/company/vmware-by-broadcom-business-transformation
- Terraform Registry (provider provenance): https://registry.terraform.io/
- SPEC and industry benchmark resources (for performance references): https://www.spec.org/

*Note: Links above are authoritative starting points. For VMware pricing and minimums, obtain a written quote from VMware/Broadcom or your authorized reseller; pricing and contractual terms vary by agreement type and geography.*

---

*Disclaimer: Pricing models discussed are based on publicly available information as of early 2026. VMware/Broadcom pricing varies significantly by agreement type, volume, and negotiation. Microsoft pricing varies by licensing program (EA, CSP, SPLA, retail). Always consult your licensing specialist, VAR, or Microsoft/Broadcom representative for quotes specific to your environment. This analysis is for educational purposes and does not constitute licensing advice.*
