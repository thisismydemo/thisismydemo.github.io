---
title: Reusing Your Existing VMware Hosts
description: Practical guidance on repurposing existing VMware hardware for Hyper-V deployments including compatibility validation and driver considerations.
date: 2026-02-25T00:00:00.000Z
series: The Hyper-V Renaissance
series_post: 4
series_total: 18
draft: true
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: hyper-v-reusing-vmware-hosts
lead: Hardware Compatibility and Repurposing Strategy
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Windows Server
    - Hardware
tags:
    - Hyper-V
    - Windows Server 2025
    - VMware
    - VMware Cloud Foundation
    - VCF
    - Azure Local
    - Hardware Compatibility
    - Migration
    - Server Hardware
    - Three-Tier Architecture
lastmod: 2026-02-10T05:18:29.006Z
---

Your servers aren't broken. Your CPUs haven't slowed down. Your storage arrays haven't lost capacity. Your network fabric still pushes packets at line rate.

But according to VMware Cloud Foundation 9 and Azure Local, your hardware might no longer be welcome.

This is the uncomfortable reality facing thousands of organizations in 2026: **perfectly functional enterprise hardware—servers with years of useful life remaining—is being orphaned by platform requirements that have nothing to do with the hardware's actual capabilities.** VCF 9's ESXi installer will block installation on entire CPU generations. Azure Local requires validated catalog hardware with Storage Spaces Direct. Your Dell R640s, HPE DL380 Gen10s, and Lenovo SR650s—servers you purchased three to five years ago with seven-year lifecycle expectations—may not qualify for either platform's current requirements.

But they'll run Windows Server 2025 with Hyper-V without hesitation.

In this fourth post of the **Hyper-V Renaissance** series, we're going to examine why your existing hardware may be locked out of VCF 9 and Azure Local, why it works perfectly with Hyper-V and three-tier storage, and how to validate and prepare your infrastructure for the transition. This isn't about buying new equipment. It's about refusing to throw away hardware that still has years of productive life.

---

## The Hardware Refresh Dilemma

Let's be specific about what's happening. You're leaving VMware—that decision is made. The question is: **where do you go, and does "where" force a hardware refresh you didn't budget for?**

### VCF 9: Your CPUs May Be Blocked

VMware Cloud Foundation 9.0, released in June 2025, includes ESXi 9.0 (also referred to as vSphere 9). The ESXi installer now **actively blocks installation** on CPU generations that Broadcom has designated as "discontinued." This isn't a warning you can click through—the installer will not proceed.

According to Broadcom KB 82794 (*CPU Support Deprecation and Discontinuation in vSphere Releases*), the following CPU families are **discontinued in ESXi 9.0/VCF 9.x** and blocked from installation:

**Intel CPUs Blocked by ESXi 9.0:**

| CPU Family | Code Name | Server Examples | Approx. Purchase Era |
|------------|-----------|----------------|----------------------|
| Xeon E5-2600-V4, E5-1600-V4 | Broadwell-EP | Dell R630/R730, HPE DL360/DL380 Gen9 | 2016–2018 |
| Xeon E5-4600-V4 | Broadwell-EP | Dell R930, HPE DL580 Gen9 | 2016–2018 |
| Xeon E7-8800/4800-V4 | Broadwell-EX | HPE DL580 Gen9, Lenovo x3850 X6 | 2016–2018 |
| Xeon D-1500 Series | Broadwell-DE | Edge/embedded platforms | 2015–2018 |
| Xeon Platinum 8100 Series | Skylake-SP | Dell R640/R740, HPE DL360/DL380 Gen10 | 2017–2020 |
| Xeon Gold 6100/5100 Series | Skylake-SP | Dell R640/R740, HPE DL360/DL380 Gen10 | 2017–2020 |
| Xeon Silver 4100 Series | Skylake-SP | Dell R440/R540, HPE DL360 Gen10 | 2017–2020 |
| Xeon Bronze 3100 Series | Skylake-SP | Entry-level 1U/2U servers | 2017–2020 |
| Xeon D-2100 Series | Skylake-D | Edge platforms | 2018–2020 |
| Xeon W-2100 Series | Skylake-W | Workstation-class servers | 2017–2020 |
| Xeon E3-1200-V5/V6 Series | Skylake-S/Kaby Lake | Single-socket servers | 2015–2019 |

**Intel CPUs Deprecated in ESXi 9.0 (Blocked in Future VCF Release):**

| CPU Family | Code Name | Server Examples | Approx. Purchase Era |
|------------|-----------|----------------|----------------------|
| Xeon Platinum/Gold/Silver 8200/6200/5200/4200 Series | Cascade Lake-SP | Dell R650/R750*, HPE DL360/DL380 Gen10 Plus | 2019–2022 |
| Xeon (various) | Ice Lake-SP | Dell R650/R750, HPE DL380 Gen10 Plus | 2021–2023 |

*Some Dell R650/R750 models shipped with both Cascade Lake and Ice Lake options.*

**What "deprecated" means in practice:** The ESXi installer displays a warning during installation but allows you to proceed—for now. However, Broadcom has stated that deprecated CPUs will be discontinued (blocked) in the **next** major VCF release after 9.x. Organizations installing VCF 9 on Cascade Lake or Ice Lake hardware today are building on a foundation with a stated expiration date.

**AMD CPUs** follow a similar pattern. Older EPYC Naples (7001 series) processors were already discontinued in ESXi 8.0. EPYC Rome (7002 series) is deprecated in ESXi 9.0 and will be blocked in a future release.

**The Bottom Line for VCF 9:** If your servers have Skylake-SP or Broadwell CPUs—which includes the majority of the 1st Generation Intel Xeon Scalable Processor family and all previous generations—ESXi 9.0 will refuse to install. These are servers that organizations purchased as recently as 2020, many with support contracts running through 2027 or beyond.

### Azure Local: Catalog-Only Hardware with Storage Constraints

Azure Local (formerly Azure Stack HCI) takes a different approach to hardware requirements, but the outcome is similar for organizations with existing infrastructure.

**The Catalog Requirement:** Azure Local is only supported on hardware listed in the [Azure Local Catalog](https://azurestackhcisolutions.azure.microsoft.com/). You must purchase validated hardware from certified partners—Dell, HPE, Lenovo, DataON, and others—as either Integrated Systems (pre-installed and configured) or Validated Nodes. You cannot repurpose arbitrary existing hardware and receive Microsoft support.

**The Storage Constraint:** For the standard deployment model, Azure Local requires Storage Spaces Direct (S2D) for cluster storage. Per Microsoft's official system requirements documentation:

> *"Have direct-attached drives that are physically attached to one machine each. RAID controller cards or SAN (Fibre Channel, iSCSI, FCoE) storage, shared SAS enclosures connected to multiple machines, or any form of multi-path IO (MPIO) where drives are accessible by multiple paths, aren't supported."*

This means your existing Fibre Channel SAN, iSCSI arrays, and RAID controllers are **not supported** for the standard Azure Local deployment. Storage controllers must be configured in simple HBA pass-through mode—no RAID.

**The FC SAN Preview (November 2025):** Microsoft announced preview support for external Fibre Channel SAN storage with Azure Local at Ignite 2025. This is a significant development, but critical context matters:
- As of early 2026, FC SAN support is in **limited preview** for **nonproduction workloads only**
- It requires partner-validated solutions (Dell PowerFlex is the first generally available option)
- Hardware must still come from the Azure Local catalog
- Standard S2D remains the primary supported storage model
- iSCSI SAN support is not yet available (may follow in later phases)

**Additional Azure Local Requirements:**
- TPM 2.0 hardware **required** and enabled
- Secure Boot **required** and enabled
- All servers must be the same manufacturer and model
- Azure subscription required (per-core billing at ~$10/core/month)
- Azure Arc integration mandatory
- Minimum 32 GB ECC RAM per node
- 10 GbE minimum for multi-node deployments with dedicated storage intent

**The Bottom Line for Azure Local:** Even if your hardware meets the technical specs, if it's not in the Azure Local catalog, it's not supported. Your existing SAN infrastructure is either unsupported (standard S2D deployment) or requires specific partner-validated solutions still in preview. And the ongoing $10/core/month subscription applies regardless of hardware age.

### Windows Server 2025 Hyper-V: No Artificial Barriers

Windows Server 2025 with Hyper-V takes a fundamentally different approach to hardware requirements:

- **No CPU generation restrictions** beyond basic x86-64 with virtualization extensions (Intel VT-x/AMD-V)
- **No blocked or deprecated CPU families**—Sandy Bridge (2011) and newer all work
- **No hardware catalog requirement**—the Windows Server Catalog exists for formal certification but is not mandatory for functionality
- **Full SAN support**—Fibre Channel, iSCSI, SMB 3.x, all supported natively and in production
- **RAID controllers supported**—not just HBA pass-through mode
- **No manufacturer matching requirement**—mix Dell, HPE, and Lenovo in the same cluster if needed
- **TPM 2.0 recommended** but not required for basic Hyper-V operation
- **Secure Boot optional** but recommended
- **No Azure subscription required** for base virtualization
- **1 GbE functional** (10 GbE+ recommended for production)

---

## The CPU Compatibility Matrix

Here's the comparison that matters. For each CPU generation, can you install and run the platform?

| CPU Generation | Code Name | Example Server | ESXi 9.0 (VCF 9) | Azure Local | Windows Server 2025 |
|---------------|-----------|----------------|-------------------|-------------|---------------------|
| Intel Xeon E5 v3 | Haswell-EP | Dell R630, HPE DL380 Gen9 | ❌ Blocked (since ESXi 8) | ❌ Not in catalog | ✅ Supported |
| Intel Xeon E5 v4 | Broadwell-EP | Dell R630/R730, HPE DL380 Gen9 | ❌ Blocked | ❌ Not in catalog | ✅ Supported |
| Intel Xeon Scalable 1st Gen | Skylake-SP | Dell R640/R740, HPE DL360/DL380 Gen10 | ❌ Blocked | ⚠️ Limited catalog | ✅ Supported |
| Intel Xeon Scalable 2nd Gen | Cascade Lake-SP | Dell R650/R750, HPE DL380 Gen10 Plus | ⚠️ Deprecated* | ⚠️ Some in catalog | ✅ Supported |
| Intel Xeon Scalable 3rd Gen | Ice Lake-SP | Dell R650/R750, HPE DL360/DL380 Gen10 Plus | ⚠️ Deprecated* | ✅ In catalog | ✅ Supported |
| Intel Xeon Scalable 4th Gen | Sapphire Rapids | Dell R660/R760, HPE DL360/DL380 Gen11 | ✅ Supported | ✅ In catalog | ✅ Supported |
| Intel Xeon Scalable 5th Gen | Emerald Rapids | Dell R660/R760 (refresh), HPE DL380a Gen11 | ✅ Supported | ✅ In catalog | ✅ Supported |
| AMD EPYC 7001 | Naples | HPE DL385 Gen10 | ❌ Blocked (since ESXi 8) | ❌ Not in catalog | ✅ Supported |
| AMD EPYC 7002 | Rome | Dell R7525, HPE DL385 Gen10 Plus | ⚠️ Deprecated* | ⚠️ Some in catalog | ✅ Supported |
| AMD EPYC 7003 | Milan | Dell R6525/R7525 | ✅ Supported | ✅ In catalog | ✅ Supported |
| AMD EPYC 9004 | Genoa | Dell R6625/R7625, HPE DL385 Gen11 | ✅ Supported | ✅ In catalog | ✅ Supported |

*\*Deprecated = installs with warning today, blocked in next major VCF release.*

**The pattern is clear.** Windows Server 2025 supports every CPU generation that VCF 9 blocks or deprecates. For organizations with Skylake-SP hardware purchased between 2017 and 2020—which represents a massive installed base—Hyper-V is the only major virtualization platform that doesn't require a hardware refresh.

---

## The Storage Architecture Divide

CPU compatibility is only half the story. Storage architecture requirements create an equally significant divide between platforms.

### Three-Tier Architecture: The Hyper-V Advantage

Three-tier architecture—separate compute, network, and storage tiers—is the deployment model this series centers on. It's how most enterprise datacenters have operated for decades, and it's where Hyper-V's flexibility shines.

**What Three-Tier Means in Practice:**
- **Compute:** Hyper-V hosts running Windows Server 2025
- **Network:** Standard Ethernet fabric (with optional RDMA)
- **Storage:** External SAN or NAS arrays providing shared storage to hosts via Fibre Channel, iSCSI, or SMB 3.x

**Why This Matters for Hardware Reuse:**

Your existing storage infrastructure—the Pure Storage FlashArrays, NetApp FAS/AFF systems, Dell PowerStore/Unity arrays, HPE Nimble/3PAR/Primera systems—represents significant capital investment. These arrays have their own support lifecycles, their own firmware update paths, and their own data services (snapshots, replication, deduplication, compression) that are independent of the hypervisor.

With Hyper-V and three-tier architecture:
- Your existing FC HBAs continue working with inbox Windows drivers
- Your existing iSCSI configurations work natively with Windows MPIO
- Your existing SMB 3.x file shares work as first-class Hyper-V storage
- Your RAID controllers remain supported—no need to reconfigure as HBA pass-through
- Your storage array's data services remain intact and fully functional
- You scale compute and storage independently based on actual need

**The Three-Tier Storage Compatibility Summary:**

| Storage Protocol | Hyper-V (Three-Tier) | VCF 9 | Azure Local (Standard) | Azure Local (FC Preview) |
|-----------------|---------------------|-------|----------------------|-------------------------|
| **Fibre Channel (VMFS/NTFS)** | ✅ Native, production | ✅ Principal storage (greenfield) | ❌ Not supported | ⚠️ Preview, nonproduction |
| **iSCSI** | ✅ Native, production | ⚠️ Not greenfield principal; supplemental or brownfield only | ❌ Not supported | ❌ Not supported |
| **SMB 3.x** | ✅ Native, production | ❌ Not supported | ❌ Not supported | ❌ Not supported |
| **NFS v3** | ❌ Not native | ✅ Principal storage (greenfield) | ❌ Not supported | ❌ Not supported |
| **NFS v4.1** | ❌ Not native | ⚠️ Supplemental or brownfield only | ❌ Not supported | ❌ Not supported |
| **RAID Controllers** | ✅ Supported | ✅ Supported | ❌ Must be HBA pass-through | ❌ Must be HBA pass-through |
| **MPIO** | ✅ Native Windows MPIO | ✅ Native ESXi multipathing | ❌ Not supported | ⚠️ Via partner solution |

**Note on VCF 9 Storage:** VCF 9.0 significantly expanded external storage options compared to VCF 5.x, where vSAN was the only option for the management domain. However, external storage in VCF 9 still requires ESXi 9.0-compatible CPUs—your storage array works, but if your servers have Skylake CPUs, the ESXi installer still blocks you.

### When Storage Spaces Direct Makes Sense

To be fair, Storage Spaces Direct (S2D) is available on Windows Server 2025 and deserves consideration. S2D enables hyperconverged infrastructure (HCI) where compute and storage run on the same servers using direct-attached drives.

**S2D on Windows Server 2025:**
- Available with Datacenter edition licensing
- Uses direct-attached drives (NVMe, SSD, HDD)
- Requires 10 GbE+ networking (RDMA recommended)
- Minimum 2 nodes for production (single-node available for edge)
- RAID controllers NOT supported—HBA pass-through mode required
- No external SAN integration for the S2D pool
- Supports up to 4 PB of raw capacity per pool

**When S2D is a Good Fit:**
- **New deployments** where you're purchasing servers specifically for HCI
- **Edge/remote sites** where simplicity matters more than storage features
- **Workloads with predictable growth** where scaling compute and storage together makes sense
- **Environments without existing SAN investments** to protect

**When Three-Tier is the Better Choice:**
- **Existing SAN infrastructure** with years of remaining support and amortization
- **Storage-heavy workloads** that benefit from dedicated storage array capabilities (advanced deduplication, replication, encryption, tiering)
- **Independent scaling** needs—you want more compute without buying more storage, or vice versa
- **Diverse failure domains**—a storage array failure shouldn't take down your compute, and vice versa
- **Organizations with storage expertise** and established SAN operations teams
- **RAID controller investments**—your servers have RAID controllers configured for local boot/scratch storage, and reconfiguring to HBA mode isn't practical

**The Key Decision:** If you have existing SAN infrastructure and servers with RAID controllers, three-tier with Hyper-V lets you reuse everything as-is. S2D requires reconfiguring storage controllers, purchasing new direct-attached drives, and abandoning your SAN investment for that cluster's storage. For organizations migrating off VMware with existing hardware, three-tier is almost always the lower-friction path.

---

## Real-World Hardware Scenarios

Let's walk through specific server models that organizations commonly run in VMware environments and assess their compatibility across platforms.

### Scenario 1: Dell PowerEdge R640 (2017–2020)

| Specification | Value |
|---------------|-------|
| **CPU** | 2× Intel Xeon Gold 6130 (Skylake-SP, 16 cores each) |
| **RAM** | 384 GB DDR4 |
| **Boot** | Dell BOSS-S1 M.2 |
| **Storage Controller** | PERC H730P (RAID) |
| **Network** | 4× 25GbE (Intel XXV710) |
| **FC HBA** | 2× 32Gb Emulex LPe35002 |
| **Purchase Date** | 2019, support through 2026 |

| Platform | Compatible? | Reason |
|----------|-------------|--------|
| **VCF 9** | ❌ No | Skylake-SP CPUs are discontinued in ESXi 9.0 |
| **Azure Local** | ❌ No | Not in Azure Local catalog; RAID controller not compatible with S2D |
| **Hyper-V (Three-Tier)** | ✅ Yes | Full support—CPU, RAID controller, FC HBAs, all functional |

**What Hyper-V Gets You:** This server has 32 cores, 384 GB RAM, and FC connectivity to your existing SAN. It's a production-grade Hyper-V host that can run 30-50 VMs depending on workload. With three more years of vendor support remaining, retiring it for a CPU compatibility list makes no financial sense.

### Scenario 2: HPE ProLiant DL380 Gen10 (2017–2021)

| Specification | Value |
|---------------|-------|
| **CPU** | 2× Intel Xeon Gold 6248 (Cascade Lake-SP, 20 cores each) |
| **RAM** | 512 GB DDR4 |
| **Boot** | HPE NS204i-p NVMe |
| **Storage Controller** | HPE P816i-a (Smart Array RAID) |
| **Network** | 2× 100GbE (Mellanox ConnectX-5) |
| **FC HBA** | 2× 32Gb QLogic QLE2772 |
| **Purchase Date** | 2020, support through 2027 |

| Platform | Compatible? | Reason |
|----------|-------------|--------|
| **VCF 9** | ⚠️ With warning | Cascade Lake deprecated—installs today but blocked in next VCF release |
| **Azure Local** | ⚠️ Possibly | Some Gen10 Plus models in catalog, but RAID controller and FC setup incompatible with S2D |
| **Hyper-V (Three-Tier)** | ✅ Yes | Full support—40 cores, 512 GB RAM, 100GbE, FC—an excellent Hyper-V host |

**The VCF 9 Trap:** This server installs ESXi 9.0 today with a deprecation warning. But you're building on infrastructure that Broadcom has publicly stated will be blocked in the next major release. Budget for a hardware refresh in 2-3 years, or migrate to a platform that doesn't artificially obsolete your hardware.

### Scenario 3: Lenovo ThinkSystem SR650 (2017–2021)

| Specification | Value |
|---------------|-------|
| **CPU** | 2× Intel Xeon Silver 4214 (Cascade Lake-SP, 12 cores each) |
| **RAM** | 256 GB DDR4 |
| **Boot** | Lenovo ThinkSystem M.2 |
| **Storage Controller** | RAID 930-8i |
| **Network** | 4× 10GbE (Intel X710) |
| **iSCSI Storage** | Connected to NetApp FAS8200 via iSCSI |
| **Purchase Date** | 2020, support through 2027 |

| Platform | Compatible? | Reason |
|----------|-------------|--------|
| **VCF 9** | ⚠️ With warning (CPU) + ❌ iSCSI not greenfield principal | Cascade Lake deprecated; iSCSI can't be used as principal storage for greenfield VCF management domain |
| **Azure Local** | ❌ No | Not in catalog; iSCSI SAN not supported; RAID controller incompatible with S2D |
| **Hyper-V (Three-Tier)** | ✅ Yes | Full support—iSCSI native with Windows MPIO, RAID controller supported |

**The iSCSI Problem:** This scenario highlights a double constraint. VCF 9 expanded external storage support, but iSCSI is still not available as principal storage for greenfield management domain deployments (only FC VMFS and NFS v3 qualify). For brownfield environments being converged into VCF, iSCSI is supported—but that still requires ESXi 9.0-compatible CPUs. Azure Local doesn't support iSCSI SAN at all in its standard deployment model. Only Hyper-V treats iSCSI as a fully supported, first-class storage protocol.

### Scenario 4: Mixed Fleet with Existing FC SAN

| Component | Details |
|-----------|---------|
| **Servers** | 6× Dell R740 (Skylake-SP, 2× Xeon Gold 6140, 18c each) |
| **SAN** | Pure Storage FlashArray//X50 R3, dual FC fabric |
| **FC Switches** | Brocade 6510, 24-port |
| **Network** | Dell S5248F-ON switches, 25GbE to hosts |
| **Total Investment** | ~$450,000 in servers + ~$300,000 in SAN + ~$50,000 in FC fabric |

| Platform | Path Forward | Estimated Additional Cost |
|----------|-------------|--------------------------|
| **VCF 9** | Replace all 6 servers (Skylake blocked) | $180,000–$300,000 for new servers |
| **Azure Local** | Replace all servers (catalog required) + reconfigure storage or purchase validated FC solution (preview) | $250,000–$400,000 |
| **Hyper-V (Three-Tier)** | Install Windows Server 2025 on existing servers | ~$50,000 (Windows Server Datacenter licensing) + migration labor |

**The math speaks for itself.** The Pure Storage array, FC fabric, and network infrastructure carry over unchanged. The only investment is Windows Server licensing and the staff time for migration—recovered in months from eliminated VMware subscription costs (as detailed in [Post 2](/post/real-cost-virtualization)).

---

## The Hardware Validation Process

With the business case established, let's get technical. Here's the systematic process for validating your existing hardware for Windows Server 2025 and Hyper-V.

### Step 1: Document Your Current Inventory

Export your VMware host inventory to a spreadsheet. You likely have this in vCenter:

```powershell
# Run from PowerCLI connected to vCenter
# Export host hardware details

Get-VMHost | Select-Object Name, 
    @{N='Model';E={$_.ExtensionData.Hardware.SystemInfo.Model}},
    @{N='CPUs';E={$_.ExtensionData.Hardware.CpuInfo.NumCpuPackages}},
    @{N='Cores';E={$_.ExtensionData.Hardware.CpuInfo.NumCpuCores}},
    @{N='RAM_GB';E={[math]::Round($_.MemoryTotalGB,0)}},
    @{N='NICs';E={($_ | Get-VMHostNetworkAdapter | Where-Object {$_.Name -like 'vmnic*'}).Count}} |
    Export-Csv -Path "VMwareHostInventory.csv" -NoTypeInformation

# Get NIC details
Get-VMHost | ForEach-Object {
    $hostName = $_.Name
    $_ | Get-VMHostNetworkAdapter -Physical | Select-Object @{N='Host';E={$hostName}}, 
        Name, 
        @{N='Driver';E={$_.ExtensionData.Driver}},
        @{N='Speed';E={$_.ExtensionData.LinkSpeed.SpeedMb}},
        Mac
} | Export-Csv -Path "VMwareHostNICs.csv" -NoTypeInformation

# Get storage adapter details
Get-VMHost | ForEach-Object {
    $hostName = $_.Name
    $_ | Get-VMHostHba | Select-Object @{N='Host';E={$hostName}},
        Device,
        Type,
        Model,
        Driver
} | Export-Csv -Path "VMwareHostHBAs.csv" -NoTypeInformation
```

### Step 2: Verify Windows Server 2025 Requirements

Windows Server 2025 has deliberately modest requirements:

| Component | Minimum | Recommended for Hyper-V |
|-----------|---------|-------------------------|
| **CPU** | 1.4 GHz 64-bit | 2+ GHz, multiple cores |
| **RAM** | 512 MB (Core), 2 GB (Desktop Experience) | 4+ GB for host OS; size for VM density |
| **Storage** | 32 GB | 100+ GB for host; separate VM storage |
| **Network** | Gigabit Ethernet | 10+ GbE; redundant paths |
| **Virtualization Extensions** | Required | Intel VT-x/VT-d or AMD-V/AMD-Vi |
| **UEFI** | Required for Secure Boot | UEFI 2.3.1c+ recommended |
| **TPM** | TPM 2.0 recommended | Required for some security features (Shielded VMs) |

**Reality check:** Any server purchased for VMware in the last 10 years significantly exceeds these requirements.

### Step 3: Check the Windows Server Catalog

Search the [Windows Server Catalog](https://www.windowsservercatalog.com/) for your specific server models. If your server is from a major vendor, there's an excellent chance it's already certified for Windows Server 2025 or 2022 (most 2022-certified hardware works with 2025).

**What if my server isn't listed?** Not being in the catalog doesn't mean the hardware won't work. It means the vendor may not have submitted it for formal certification. The catalog matters most for Microsoft support eligibility and compliance requirements that mandate certified hardware. For functional testing and most production deployments, meeting the basic requirements is sufficient.

### Step 4: Validate Critical Components

Not all components are equal. Focus validation efforts on these categories:

#### Storage Controllers

| Vendor | Common Controllers | Windows Server 2025 Status | Notes |
|--------|-------------------|---------------------------|-------|
| **Dell** | PERC H755, H755N, H355, H730P, BOSS-S2 | ✅ Supported | Inbox drivers available |
| **HPE** | P816i-a, P408i-a, NS204i-p | ✅ Supported | Inbox drivers available |
| **Lenovo** | 930-8i, 930-16i, 940-8i | ✅ Supported | Inbox drivers available |
| **Broadcom (LSI)** | MegaRAID 9500/9400 series | ✅ Supported | Vendor drivers recommended |
| **Microchip (Adaptec)** | SmartRAID 3200 series | ✅ Supported | Vendor drivers recommended |

**Important:** Unlike Azure Local (which requires HBA pass-through mode), Windows Server 2025 fully supports RAID controllers for both boot drives and local storage. Your existing RAID configuration remains intact.

#### Network Adapters

This is where you need the most careful validation. Not all NICs that work with ESXi have feature-complete Windows drivers—particularly for advanced features like RDMA.

| Vendor | Common NICs | Windows Server 2025 Status | RDMA Support | Notes |
|--------|-------------|---------------------------|--------------|-------|
| **Intel** | E810, X710, XXV710 | ✅ Supported | iWARP, RoCEv2 | Excellent Windows support |
| **Mellanox/NVIDIA** | ConnectX-5, ConnectX-6, ConnectX-7 | ✅ Supported | RoCEv2 | Excellent Windows support |
| **Broadcom** | P2100G, N1100T, BCM57416 | ✅ Supported | RoCEv2 | Good Windows support |
| **QLogic/Marvell** | FastLinQ QL45000 | ✅ Supported | RoCEv2, iWARP | Good Windows support |
| **Chelsio** | T6 series | ✅ Supported | iWARP | Good Windows support |

**RDMA Considerations:** If you plan to use RDMA for live migration traffic or SMB Direct storage, verify that your NICs support RDMA under Windows and that you have the appropriate vendor drivers (not just inbox drivers). Some NICs support RDMA under VMware but require different firmware or configuration for Windows RDMA.

**Driver Recommendation:** For all NICs, download vendor drivers from the manufacturer's website rather than relying on Windows Update inbox drivers. Vendor drivers enable advanced features that inbox drivers may not support.

#### HBAs (Fibre Channel)

| Vendor | Common HBAs | Windows Server 2025 Status | Notes |
|--------|-------------|---------------------------|-------|
| **Broadcom/Emulex** | LPe35000, LPe36000, LPe32000 | ✅ Supported | Excellent Windows support |
| **Marvell/QLogic** | QLE2770, QLE2870, QLE2692 | ✅ Supported | Excellent Windows support |

Fibre Channel HBAs from major vendors have mature, well-tested Windows drivers. This is the component category where VMware-to-Hyper-V transitions encounter the fewest issues.

#### GPUs

If your VMware hosts have GPUs for VDI, AI/ML, or graphics workloads:

| Vendor | GPU Series | Windows Server 2025 Status | GPU-P Support | Notes |
|--------|------------|---------------------------|---------------|-------|
| **NVIDIA** | A100, A40, L40S, T4 | ✅ Supported | Yes | Excellent support |
| **NVIDIA** | RTX 4000/5000 series | ✅ Supported | Yes | Workstation GPUs |
| **AMD** | Instinct MI series | ✅ Supported | Limited | Verify specific model |

**GPU Partitioning (GPU-P):** As we covered in [Post 3](/post/hyper-v-myth-old-tech), Windows Server 2025 supports GPU-P with live migration and high availability—a capability VCF's hypervisor doesn't offer natively.

---

## Vendor-Specific Resources

Each major server vendor provides tools and documentation for Windows Server deployment. These are essential for driver packages, firmware updates, and deployment automation.

### Dell Technologies

| Resource | Purpose |
|----------|---------|
| [Dell OpenManage](https://www.dell.com/openmanage) | Server management suite |
| [Dell Support](https://www.dell.com/support) | Drivers, firmware, documentation |
| [Dell Repository Manager](https://www.dell.com/support/kbdoc/en-us/000177083) | Create custom driver repositories |
| **Lifecycle Controller** (embedded) | Firmware updates, OS deployment |
| [Dell InfoHub](https://infohub.delltechnologies.com) | Official deployment guides |

**Dell Tips:** Use iDRAC Lifecycle Controller for driver injection during OS deployment. Dell Repository Manager can create bootable ISOs with all drivers included. BOSS boot controllers are well-supported; ensure latest firmware.

### HPE (Hewlett Packard Enterprise)

| Resource | Purpose |
|----------|---------|
| [HPE Support Center](https://support.hpe.com) | Drivers, firmware, documentation |
| [HPE Service Pack for ProLiant (SPP)](https://support.hpe.com) | Comprehensive firmware/driver bundle |
| **HPE iLO** (embedded) | Remote management, deployment |
| **HPE Intelligent Provisioning** (embedded) | OS deployment with drivers |
| [HPE InfoSight](https://infosight.hpe.com) | Reference architectures |

**HPE Tips:** SPP (Service Pack for ProLiant) includes Windows-tested driver bundles. HPE Intelligent Provisioning automates driver injection. Smart Array controllers have excellent Windows support. iLO Virtual Media simplifies remote OS deployment.

### Lenovo

| Resource | Purpose |
|----------|---------|
| [Lenovo Support](https://support.lenovo.com) | Drivers, firmware, documentation |
| [Lenovo XClarity Administrator](https://www.lenovo.com/us/en/software/xclarity-administrator) | Centralized management |
| **Lenovo XClarity Controller (XCC)** (embedded) | BMC management interface |
| [Lenovo Press](https://lenovopress.lenovo.com) | Reference architectures, deployment guides |

**Lenovo Tips:** XClarity Administrator can push firmware updates fleet-wide. Lenovo Press has excellent Windows Server deployment guides, including a specific guide for [Implementing Hyper-V on Windows Server 2025](https://lenovopress.lenovo.com/lp2198-implementing-hyper-v-on-microsoft-windows-server-2025).

### Cisco (UCS)

| Resource | Purpose |
|----------|---------|
| **Cisco UCS Manager** (embedded/CIMC) | Server management |
| [Cisco Host Upgrade Utility (HUU)](https://software.cisco.com) | Firmware bundle |
| [Cisco UCS Hardware Compatibility](https://ucshcltool.cloudapps.cisco.com/public/) | Compatibility matrix |

**Cisco Tips:** UCS Manager service profiles can be reconfigured for Hyper-V. Verify VIC (Virtual Interface Card) firmware supports Windows RDMA if needed. HUU includes Windows-compatible firmware bundles.

---

## BIOS/UEFI Configuration Checklist

Some BIOS settings may need adjustment when transitioning from ESXi to Windows Server. Review these settings:

| Setting | ESXi Typical | Windows/Hyper-V Optimal | Notes |
|---------|--------------|-------------------------|-------|
| **Virtualization (VT-x/AMD-V)** | Enabled | Enabled | Required for Hyper-V |
| **VT-d/AMD-Vi (IOMMU)** | Enabled | Enabled | Required for DDA/GPU passthrough |
| **SR-IOV** | Varies | Enabled | If using RDMA or SR-IOV NICs |
| **Secure Boot** | Often Disabled | Enabled | Recommended for Windows Server |
| **TPM** | Varies | Enabled | Required for some security features |
| **Boot Mode** | UEFI | UEFI | Required for Gen2 VMs, Secure Boot |
| **Power Profile** | Performance | Performance | Or OS-controlled |
| **C-States** | Varies | OS Controlled or Disabled | Test for your workload |
| **Hyper-Threading** | Enabled | Enabled | Unless security policy requires disabled |

**Important:** Document current BIOS settings before making changes. Some organizations require formal change management for BIOS modifications.

---

## Pre-Migration Hardware Validation Process

Before migrating production VMware hosts, follow this phased approach:

### Phase 1: Firmware Baseline

Before changing operating systems, update firmware to current supported versions:

1. **Download latest firmware bundle from vendor** (Dell Lifecycle Controller, HPE SPP, Lenovo UpdateXpress)
2. **Review release notes** for Windows Server 2025 compatibility
3. **Apply firmware updates while still running ESXi** (optional but recommended—reduces variables)
4. **Document firmware versions post-update**

### Phase 2: Driver Package Preparation

```powershell
# Create a driver folder structure for deployment
$DriverPath = "C:\Drivers\WS2025"

@(
    "$DriverPath\Chipset",
    "$DriverPath\Storage",
    "$DriverPath\Network",
    "$DriverPath\Management"
) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force }

# Populate from vendor downloads:
# - Dell: Dell Command | Deploy Driver Packs
# - HPE: SPP or individual drivers from support.hpe.com
# - Lenovo: XClarity or individual drivers from support.lenovo.com
```

### Phase 3: Test System Validation

**Never convert production hosts without testing on representative hardware first.**

1. Select a test server matching production hardware
2. Install Windows Server 2025 (use vendor deployment tools where available)
3. Verify all hardware detected
4. Install Hyper-V role and test basic functionality
5. Test storage connectivity (SAN, iSCSI, or SMB)
6. Test network functionality (all NICs, RDMA if applicable)

```powershell
# Install Hyper-V role
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart

# After restart, verify Hyper-V is functional
Get-VMHost | Select-Object Name, LogicalProcessorCount, MemoryCapacity

# Create and start a test VM
New-VM -Name "TestVM" -MemoryStartupBytes 2GB -NewVHDPath "C:\VMs\TestVM.vhdx" -NewVHDSizeBytes 50GB -Generation 2
Start-VM -Name "TestVM"
Get-VM -Name "TestVM" | Select-Object Name, State
```

---

## Pre-Migration Validation Script

Here's a comprehensive validation script to run on a test Windows Server 2025 installation before committing to production migration:

```powershell
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Pre-migration validation script for Hyper-V deployment
.DESCRIPTION
    Validates that hardware is properly configured for Hyper-V
    Run this on a test system before production migration
.NOTES
    Part of the Hyper-V Renaissance series
    Repository: github.com/thisismydemo/hyper-v-renaissance
#>

$Results = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Hyper-V Pre-Migration Validation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Check Virtualization Extensions
Write-Host "`n[1/10] Checking virtualization extensions..." -ForegroundColor Yellow
$cpu = Get-WmiObject -Class Win32_Processor
$vmSupport = $cpu.VirtualizationFirmwareEnabled
$slat = (Get-WmiObject -Class Win32_ComputerSystem).HypervisorPresent

$Results += [PSCustomObject]@{
    Check = "Virtualization Extensions"
    Status = if ($vmSupport) { "PASS" } else { "FAIL" }
    Details = "VT-x/AMD-V: $vmSupport"
}

# 2. Check Hyper-V Requirements
Write-Host "[2/10] Checking Hyper-V requirements..." -ForegroundColor Yellow
$hyperVReq = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
$hyperVInstalled = $hyperVReq.State -eq "Enabled"

$Results += [PSCustomObject]@{
    Check = "Hyper-V Feature"
    Status = if ($hyperVInstalled) { "PASS" } else { "INFO - Not Installed" }
    Details = "State: $($hyperVReq.State)"
}

# 3. Check Memory
Write-Host "[3/10] Checking memory configuration..." -ForegroundColor Yellow
$memory = Get-WmiObject -Class Win32_PhysicalMemory
$totalMemoryGB = [math]::Round(($memory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)

$Results += [PSCustomObject]@{
    Check = "Physical Memory"
    Status = if ($totalMemoryGB -ge 32) { "PASS" } else { "WARN - Low Memory" }
    Details = "$totalMemoryGB GB"
}

# 4. Check Network Adapters
Write-Host "[4/10] Checking network adapters..." -ForegroundColor Yellow
$adapters = Get-NetAdapter -Physical
$adapterCount = $adapters.Count
$linkedAdapters = ($adapters | Where-Object { $_.Status -eq "Up" }).Count

$Results += [PSCustomObject]@{
    Check = "Network Adapters"
    Status = if ($linkedAdapters -ge 2) { "PASS" } else { "WARN - Limited Redundancy" }
    Details = "$adapterCount total, $linkedAdapters linked"
}

# 5. Check RDMA Capability
Write-Host "[5/10] Checking RDMA capability..." -ForegroundColor Yellow
$rdmaAdapters = Get-NetAdapterRdma -ErrorAction SilentlyContinue
$rdmaEnabled = ($rdmaAdapters | Where-Object { $_.Enabled -eq $true }).Count

$Results += [PSCustomObject]@{
    Check = "RDMA Capability"
    Status = if ($rdmaEnabled -gt 0) { "PASS" } elseif ($rdmaAdapters) { "INFO - RDMA Disabled" } else { "INFO - No RDMA" }
    Details = "$rdmaEnabled RDMA-enabled adapters"
}

# 6. Check Storage Controllers
Write-Host "[6/10] Checking storage controllers..." -ForegroundColor Yellow
$storageControllers = Get-WmiObject -Class Win32_SCSIController
$healthyControllers = ($storageControllers | Where-Object { $_.Status -eq "OK" }).Count

$Results += [PSCustomObject]@{
    Check = "Storage Controllers"
    Status = if ($healthyControllers -gt 0) { "PASS" } else { "FAIL" }
    Details = "$healthyControllers healthy controllers"
}

# 7. Check for Unknown Devices
Write-Host "[7/10] Checking for unknown devices..." -ForegroundColor Yellow
$unknownDevices = Get-WmiObject Win32_PNPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 }
$unknownCount = ($unknownDevices | Measure-Object).Count

$Results += [PSCustomObject]@{
    Check = "Unknown Devices"
    Status = if ($unknownCount -eq 0) { "PASS" } else { "WARN - $unknownCount unknown" }
    Details = if ($unknownCount -gt 0) { ($unknownDevices | Select-Object -First 3 -ExpandProperty Name) -join ", " } else { "None" }
}

# 8. Check UEFI and Secure Boot
Write-Host "[8/10] Checking UEFI and Secure Boot..." -ForegroundColor Yellow
$secureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue

$Results += [PSCustomObject]@{
    Check = "Secure Boot"
    Status = if ($secureBoot) { "PASS" } else { "INFO - Disabled or N/A" }
    Details = "Secure Boot Enabled: $secureBoot"
}

# 9. Check TPM
Write-Host "[9/10] Checking TPM..." -ForegroundColor Yellow
$tpm = Get-Tpm -ErrorAction SilentlyContinue

$Results += [PSCustomObject]@{
    Check = "TPM"
    Status = if ($tpm.TpmPresent -and $tpm.TpmReady) { "PASS" } else { "WARN - TPM Issues" }
    Details = "Present: $($tpm.TpmPresent), Ready: $($tpm.TpmReady)"
}

# 10. Check Disk Space
Write-Host "[10/10] Checking disk space..." -ForegroundColor Yellow
$systemDrive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeSpaceGB = [math]::Round($systemDrive.FreeSpace / 1GB, 2)

$Results += [PSCustomObject]@{
    Check = "System Disk Free Space"
    Status = if ($freeSpaceGB -ge 100) { "PASS" } else { "WARN - Low Space" }
    Details = "$freeSpaceGB GB free"
}

# Display Results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VALIDATION RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$Results | ForEach-Object {
    $color = switch ($_.Status) {
        { $_ -like "PASS*" } { "Green" }
        { $_ -like "WARN*" } { "Yellow" }
        { $_ -like "FAIL*" } { "Red" }
        default { "White" }
    }
    Write-Host "`n$($_.Check)" -ForegroundColor White
    Write-Host "  Status: $($_.Status)" -ForegroundColor $color
    Write-Host "  Details: $($_.Details)" -ForegroundColor Gray
}

# Summary
$passCount = ($Results | Where-Object { $_.Status -like "PASS*" }).Count
$warnCount = ($Results | Where-Object { $_.Status -like "WARN*" }).Count
$failCount = ($Results | Where-Object { $_.Status -like "FAIL*" }).Count

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY: $passCount PASS, $warnCount WARN, $failCount FAIL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($failCount -eq 0) {
    Write-Host "`nThis system appears ready for Hyper-V deployment." -ForegroundColor Green
} else {
    Write-Host "`nAddress FAIL items before proceeding with Hyper-V deployment." -ForegroundColor Red
}

# Export results
$Results | Export-Csv -Path "HyperV-Validation-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" -NoTypeInformation
Write-Host "`nResults exported to CSV file." -ForegroundColor Gray
```

---

## Common Issues and Resolutions

### Issue 1: NIC Not Detected After Windows Installation

**Symptoms:** Network adapter missing from Device Manager

**Resolution:**
1. Verify NIC is seated properly
2. Check BIOS for disabled slots
3. Download and install vendor driver package
4. Some NICs require specific firmware versions for Windows support

```powershell
# Check for unknown devices that may be unrecognized NICs
Get-WmiObject Win32_PNPEntity | 
    Where-Object { $_.Status -eq 'Error' } | 
    Select-Object Name, DeviceID
```

### Issue 2: RDMA Not Working

**Symptoms:** `Get-NetAdapterRdma` shows RDMA disabled or not capable

**Resolution:**
1. Install vendor drivers (not inbox)
2. Verify RDMA enabled in NIC firmware
3. Configure RDMA protocol (iWARP vs RoCEv2)
4. For RoCEv2, install and configure Data Center Bridging (DCB)

```powershell
# Check RDMA status
Get-NetAdapterRdma

# Enable RDMA if supported but disabled
Enable-NetAdapterRdma -Name "NIC1"

# For RoCEv2, install DCB
Install-WindowsFeature -Name "Data-Center-Bridging"
```

### Issue 3: Storage Controller Performance Issues

**Symptoms:** Slow local storage performance compared to ESXi

**Resolution:**
1. Verify controller write-back cache is enabled and battery/capacitor healthy
2. Install vendor driver (may enable features inbox driver doesn't)
3. For SAN storage, configure MPIO
4. Check queue depth settings

```powershell
# Verify disk health
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, HealthStatus

# Check MPIO paths for SAN storage
Get-MPIOpath | Format-Table -AutoSize
```

### Issue 4: Secure Boot Failures

**Symptoms:** Windows Server won't boot with Secure Boot enabled

**Resolution:**
1. Update UEFI firmware to current version
2. Ensure boot media is UEFI-compatible
3. Check for non-signed drivers that block Secure Boot
4. Temporarily disable Secure Boot to identify the issue, then re-enable

### Issue 5: FC SAN LUNs Not Visible

**Symptoms:** Fibre Channel storage not appearing after Windows installation

**Resolution:**
1. Verify FC HBA drivers are installed
2. Check FC switch zoning (same zones work—ESXi and Windows use same WWPNs from HBA hardware)
3. Install MPIO feature and add vendor DSM if required
4. Verify LUN masking on the storage array includes the new host

```powershell
# Install Multipath I/O feature
Install-WindowsFeature -Name Multipath-IO -Restart

# After restart, check for MPIO devices
Get-MPIOAvailableHW
```

---

## Hardware Compatibility Checklist

Use this checklist for each host you plan to migrate:

| Item | Status | Notes |
|------|--------|-------|
| **Server Model** | ☐ | Document make/model |
| **CPU Generation** | ☐ | Confirm not relevant for WS2025 (all supported) |
| **Windows Server Catalog Check** | ☐ | Listed or test validated |
| **Firmware Updated** | ☐ | Current vendor firmware applied |
| **BIOS Settings Documented** | ☐ | Before any changes |
| **Driver Package Prepared** | ☐ | NIC, Storage, Chipset from vendor |
| **CPU Virtualization Enabled** | ☐ | VT-x/AMD-V, VT-d/AMD-Vi |
| **UEFI Boot Mode** | ☐ | Not Legacy BIOS |
| **TPM Enabled** | ☐ | If available |
| **Secure Boot Enabled** | ☐ | After Windows install |
| **All NICs Have Drivers** | ☐ | Vendor drivers preferred over inbox |
| **Storage Controller Validated** | ☐ | All local disks visible |
| **FC HBAs Detected** | ☐ | If using Fibre Channel |
| **SAN LUNs Visible** | ☐ | MPIO configured, paths verified |
| **iSCSI Connectivity Tested** | ☐ | If using iSCSI |
| **RDMA Tested** | ☐ | If required for live migration or SMB Direct |
| **BMC Accessible** | ☐ | iDRAC/iLO/XCC functional |
| **Test VM Created** | ☐ | Basic Hyper-V operations confirmed |

---

## Next Steps

Your existing VMware servers are confirmed compatible with Windows Server 2025 and Hyper-V. The hardware that VCF 9 blocks and Azure Local doesn't support in its catalog will run Hyper-V without complaint—CPUs, RAID controllers, FC HBAs, and all.

In the next post, **[Post 5: Build and Validate a Cluster-Ready Host](/post/build-validate-cluster-ready-host)**, we'll deploy Windows Server 2025 with Hyper-V from scratch using PowerShell. We'll cover the full process: OS installation, role configuration, networking setup, storage preparation, and comprehensive validation to ensure your host is ready for cluster membership.

Time to turn hardware into a hypervisor.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)
- **Pre-Migration Validation Script:** [github.com/thisismydemo/hyper-v-renaissance/scripts/Validate-HyperVHardware.ps1](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/scripts)
- **Previous Posts:**
  - [Post 1: Welcome to the Hyper-V Renaissance](/post/hyper-v-renaissance)
  - [Post 2: The Real Cost of Virtualization](/post/real-cost-virtualization)
  - [Post 3: The Myth of "Old Tech"](/post/hyper-v-myth-old-tech)

### Vendor Resources
- **Dell:** [Dell Technologies InfoHub](https://infohub.delltechnologies.com)
- **HPE:** [HPE Support Center](https://support.hpe.com)
- **Lenovo:** [Lenovo Press](https://lenovopress.lenovo.com)
- **Microsoft:** [Windows Server Catalog](https://www.windowsservercatalog.com)

### Platform Documentation
- **Broadcom KB 82794:** [CPU Support Deprecation and Discontinuation in vSphere Releases](https://knowledge.broadcom.com/external/article?legacyId=82794)
- **VCF 9.0 Storage Models:** [VCF Storage Documentation](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0)
- **Azure Local System Requirements:** [System Requirements for Azure Local](https://learn.microsoft.com/en-us/azure/azure-local/concepts/system-requirements-23h2)
- **Azure Local External Storage (Preview):** [External Storage Support](https://learn.microsoft.com/en-us/azure/azure-local/concepts/external-storage-support)
- **Storage Spaces Direct Hardware Requirements:** [S2D Requirements](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-direct-hardware-requirements)

### Microsoft Documentation
- [Plan for Hyper-V on Windows Server](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-for-hyper-v-on-windows-server)
- [Hyper-V System Requirements](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/system-requirements-for-hyper-v-on-windows)
- [Supported Linux Distributions for Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-linux-and-freebsd-virtual-machines-for-hyper-v-on-windows)

---

**Series Navigation**  
← Previous: [Post 3 - The Myth of "Old Tech"](/post/hyper-v-myth-old-tech)  
→ Next: [Post 5 - Build and Validate a Cluster-Ready Host](/post/build-validate-cluster-ready-host)

---

*Post 4 of 18 in The Hyper-V Renaissance series*  
*Last updated: February 2026*

---

*Disclaimer: Hardware compatibility information is based on vendor documentation and official platform requirements as of early 2026. VCF 9 CPU deprecation lists are sourced from Broadcom KB 82794. Azure Local catalog and storage requirements are sourced from Microsoft Learn documentation. Platform requirements may change with updates—always verify against current official documentation before making decisions. Azure Local FC SAN support is in limited preview and subject to change.*
