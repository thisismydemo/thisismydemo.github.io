---
title: Three-Tier Storage Integration
description: Practical guide to integrating external storage arrays with Hyper-V clusters covering universal principles and implementation examples.
date: 2026-03-24T00:00:00.000Z
series: The Hyper-V Renaissance
series_post: 6
series_total: 21
draft: false
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: three-tier-storage-integration
lead: iSCSI, Fibre Channel, and SMB3 Integration
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Storage
    - Windows Server
tags:
    - Hyper-V
    - Storage
    - iSCSI
    - Fibre Channel
    - SMB3
    - Pure Storage
lastmod: 2026-04-05T02:14:44.684Z
---

Not everything needs to be hyper-converged.

There's a strong narrative in the infrastructure world that three-tier architecture—separate compute, network, and storage tiers—is outdated. That hyper-converged infrastructure (HCI) is the only path forward. That separating your storage from your compute is a legacy pattern.

That narrative is incomplete.

Three-tier architecture remains the right answer for many workloads and many organizations. If you have an existing SAN investment, if your workloads require deterministic storage performance, if you need storage-level replication for disaster recovery, or if your team has deep storage operations expertise—three-tier isn't just viable, it's often superior.

In this sixth post of the **Hyper-V Renaissance** series, we're going to connect your freshly built Hyper-V hosts to external storage arrays. We'll cover the universal principles that apply regardless of vendor, then walk through a detailed Pure Storage implementation as a reference example.

> **Repository:** All scripts from this post are available in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/02-foundation-building/post-6-storage-integration).

---

## Why Three-Tier Still Matters

Before we get into the plumbing, let's establish why this architecture pattern deserves a dedicated post:

| Factor | Three-Tier Advantage |
|--------|---------------------|
| **Existing investment** | Leverage your current SAN and storage expertise |
| **Performance isolation** | Storage performance isn't affected by compute contention |
| **Independent scaling** | Add compute or storage capacity independently |
| **Storage-level DR** | SAN-level replication (synchronous/async) between sites |
| **Data services** | Snapshots, clones, thin provisioning, deduplication at the array level |
| **Workload suitability** | Databases, file services, and I/O-intensive workloads with predictable latency |

Three-tier also avoids the Storage Spaces Direct (S2D) requirement for Windows Server 2025 Datacenter edition on every node, identical disk configurations, and specific NIC requirements. With three-tier, your compute nodes are simpler.

> **Cross-reference:** For storage-level replication and multi-site architecture, see [Post 14: Multi-Site Resilience](/post/multi-site-resilience). For advanced CSV architecture and performance optimization, see [Post 12: Storage Architecture Deep Dive](/post/storage-architecture-deep-dive).

---

## Storage Protocol Decision Framework

The first decision is which storage protocol to use. Each has trade-offs:

| Protocol | Best For | Bandwidth | Latency | Cost | Complexity |
|----------|---------|-----------|---------|------|------------|
| **iSCSI** | Most environments, especially those without existing FC | 10-100 GbE | Good (can be excellent with RDMA) | Low (uses existing Ethernet) | Low |
| **Fibre Channel** | Large enterprises with existing FC fabric | 32-64 Gbps | Excellent | High (dedicated HBAs, switches) | Medium |
| **SMB3** | File-based workloads, Hyper-V with SMB shares | 10-100 GbE | Good (excellent with RDMA) | Low (uses existing Ethernet) | Low |

### Decision Guidance

**Choose iSCSI when:**
- You don't have existing Fibre Channel infrastructure
- You want to use existing Ethernet switches (with dedicated VLANs)
- Your storage vendor supports iSCSI well (most do)
- Budget is a consideration

**Choose Fibre Channel when:**
- You have existing FC switches and HBAs
- Your workloads demand the absolute lowest latency
- You need FC-specific features like FC zoning for security isolation
- Your storage team has deep FC operational experience

**Choose SMB3 when:**
- Your storage target supports SMB3 (e.g., Windows-based file servers, NetApp, Dell EMC)
- You want file-level access rather than block-level
- You're using SMB Direct (RDMA) for high-performance file access
- Hyper-V VMs will use SMB shares for VM storage (supported configuration)

For most organizations transitioning from VMware, **iSCSI is the recommended starting point**. It's simpler, uses your existing network infrastructure, and performs excellently with proper configuration.

---

## Universal Principles (Any Vendor)

Regardless of which storage array you're using, these principles apply:

### 1. Dedicated Storage Networks

Never run storage traffic on the same network as management or VM traffic. Create dedicated VLANs and subnets for storage connectivity. If you followed Post 5, you already have a storage vNIC on a dedicated VLAN.

### 2. Redundant Paths (MPIO)

Always configure at least two paths between each host and the storage array. This provides both fault tolerance and load balancing. MPIO (Multipath I/O) manages these paths automatically.

### 3. Jumbo Frames (MTU 9000)

For iSCSI and SMB3, enable jumbo frames (MTU 9000) end-to-end: on the host NICs, the physical switches, and the storage array ports. This significantly reduces CPU overhead for storage traffic.

```powershell
# Enable jumbo frames on storage vNICs
Set-NetAdapterAdvancedProperty -Name "vEthernet (Storage)" `
    -RegistryKeyword "*JumboPacket" -RegistryValue "9014"

# Verify MTU
Get-NetAdapterAdvancedProperty -Name "vEthernet (Storage)" `
    -RegistryKeyword "*JumboPacket"

# Test jumbo frame connectivity end-to-end
# If this fails, there's a device in the path that doesn't support jumbo frames
ping -f -l 8972 10.10.30.100
```

> **Important:** Jumbo frames must be configured consistently on every device in the path—host NIC, physical switch ports, and storage array ports. A single device with standard MTU (1500) will cause fragmentation and degrade performance.

### 4. Flow Control

Enable flow control on storage network interfaces to prevent buffer overflows:

```powershell
# Enable flow control on physical NICs used for storage
Set-NetAdapterAdvancedProperty -Name "NIC1" `
    -RegistryKeyword "*FlowControl" -RegistryValue 3  # Rx & Tx Enabled
```

### 5. Consistent Configuration Across All Nodes

Every node in the cluster must have identical storage connectivity: same number of paths, same MPIO policies, same timeout values. Cluster validation (Test-Cluster) checks for this consistency.

---

## iSCSI Integration (Detailed)

iSCSI is the most common protocol for new Hyper-V deployments. Here's the complete configuration.

### Host-Side Configuration

If you followed Post 5, MPIO and the iSCSI Initiator are already configured. Here we'll cover the detailed best practices:

```powershell
# ============================================================
# iSCSI Best Practice Configuration
# ============================================================

# Verify MPIO is configured for iSCSI
Get-MSDSMAutomaticClaimSettings

# Set the global MPIO load balance policy
# Options: None, FOO (Fail Over Only), RR (Round Robin),
#          LQD (Least Queue Depth), WP (Weighted Path)
Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy RR

# Configure iSCSI timeout values for production reliability
# These registry values improve failover behavior
$iSCSIParams = @{
    Path = "HKLM:\SYSTEM\CurrentControlSet\Services\iScsiPrt\Parameters"
}

# MaxRequestHoldTime - seconds to hold requests during path failover (default: 60)
Set-ItemProperty @iSCSIParams -Name "MaxRequestHoldTime" -Value 90 -Type DWord

# LinkDownTime - seconds before declaring a link is down (default: 15)
Set-ItemProperty @iSCSIParams -Name "LinkDownTime" -Value 35 -Type DWord

# Disk timeout - seconds before Windows retries a failed I/O
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\disk" `
    -Name "TimeOutValue" -Value 60 -Type DWord
```

### Connecting to Multiple Targets

For a production cluster, you typically present multiple LUNs from your storage array. Here's a scripted approach for connecting to multiple targets with full MPIO:

```powershell
# ============================================================
# Connect to iSCSI Targets with Full MPIO
# ============================================================

# Define your storage target portals (storage array iSCSI interface IPs)
$TargetPortals = @("10.10.30.100", "10.10.30.101")

# Define the initiator (host) IP on the storage network
$InitiatorIP = "10.10.30.11"

# Add all target portals
foreach ($Portal in $TargetPortals) {
    New-IscsiTargetPortal -TargetPortalAddress $Portal `
        -InitiatorPortalAddress $InitiatorIP `
        -ErrorAction SilentlyContinue
}

# Discover targets
$Targets = Get-IscsiTarget
Write-Host "Discovered $($Targets.Count) iSCSI targets:" -ForegroundColor Cyan
$Targets | ForEach-Object { Write-Host "  $($_.NodeAddress)" -ForegroundColor White }

# Connect to each target through all available portals
foreach ($Target in $Targets) {
    foreach ($Portal in $TargetPortals) {
        Connect-IscsiTarget -NodeAddress $Target.NodeAddress `
            -TargetPortalAddress $Portal `
            -InitiatorPortalAddress $InitiatorIP `
            -IsPersistent $true `
            -IsMultipathEnabled $true `
            -ErrorAction SilentlyContinue
    }
    Write-Host "Connected to $($Target.NodeAddress) via all portals." -ForegroundColor Green
}

# Verify connections
Write-Host "`nActive iSCSI Sessions:" -ForegroundColor Cyan
Get-IscsiSession | Format-Table TargetNodeAddress, IsConnected,
    IsPersistent, NumberOfConnections -AutoSize

# Verify MPIO paths per disk
Write-Host "`nMPIO Disk Paths:" -ForegroundColor Cyan
mpclaim -s -d
```

### LUN Presentation Best Practices

When configuring LUNs on your storage array for a Hyper-V cluster:

| Consideration | Recommendation |
|--------------|----------------|
| **LUN size** | Size for workload, not for the maximum. You can always add LUNs. |
| **Alignment** | Modern arrays and Windows handle alignment automatically. Verify with `fsutil fsinfo ntfsinfo C:` |
| **Block size** | Use 64KB NTFS allocation unit size for Cluster Shared Volumes |
| **Thin provisioning** | Enable on the array. Windows Server 2025 supports UNMAP/TRIM for space reclamation. |
| **Masking** | Present LUNs only to the cluster nodes that need them (LUN masking/zoning) |
| **Naming** | Use consistent naming: CSV-Prod-01, CSV-Prod-02, etc. |

### Format LUNs for CSV

Once LUNs are visible on the host, prepare them for use as Cluster Shared Volumes:

```powershell
# List new SAN disks (not yet initialized)
$NewDisks = Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" -and $_.BusType -eq "iSCSI" }

foreach ($Disk in $NewDisks) {
    Write-Host "Initializing Disk $($Disk.Number) ($([math]::Round($Disk.Size/1GB))GB)" -ForegroundColor Yellow

    # Initialize with GPT
    Initialize-Disk -Number $Disk.Number -PartitionStyle GPT

    # Create partition
    $Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize -AssignDriveLetter

    # Format with 64KB allocation unit size (recommended for CSV)
    Format-Volume -Partition $Partition -FileSystem NTFS `
        -AllocationUnitSize 65536 -NewFileSystemLabel "CSV-Vol-$($Disk.Number)" -Confirm:$false

    Write-Host "  Formatted as CSV-Vol-$($Disk.Number) with 64KB allocation units" -ForegroundColor Green
}
```

> **Note:** These disks will be added to the cluster as Cluster Shared Volumes after cluster creation (covered in Post 8). For now, they should be visible, initialized, and formatted.

---

## Fibre Channel Integration

If you have an existing FC fabric, Hyper-V integration is straightforward because most of the heavy lifting is done by the FC HBA and the SAN switches.

### Host Configuration for FC

```powershell
# Verify FC HBAs are detected
Get-InitiatorPort | Where-Object { $_.ConnectionType -eq "Fibre Channel" } |
    Select-Object NodeAddress, PortAddress, ConnectionType, OperationalStatus |
    Format-Table -AutoSize

# Install vendor Host Utilities
# Broadcom/Emulex: OneCommand Manager
# Marvell/QLogic: QConvergeConsole
# These set appropriate timeout values and MPIO policies for FC

# MPIO should claim FC devices automatically if the vendor DSM is installed
# Verify with:
Get-MPIOAvailableHW | Format-Table VendorId, ProductId -AutoSize
```

### FC-Specific Best Practices

| Item | Recommendation |
|------|----------------|
| **Zoning** | Use single-initiator, single-target zoning on FC switches |
| **HBA firmware** | Keep current with vendor-recommended firmware levels |
| **Host Utilities** | Always install vendor-specific host utilities (they set critical timeouts) |
| **Queue depth** | Adjust HBA queue depth based on storage vendor recommendations |
| **NPIV** | Not required for basic Hyper-V; useful for direct VM-to-SAN access |

### FC MPIO Verification

```powershell
# Verify FC MPIO paths
Get-PhysicalDisk | Where-Object { $_.BusType -eq "SAS" -or $_.BusType -eq "Fibre Channel" } |
    Select-Object FriendlyName, Size, BusType, OperationalStatus |
    Format-Table -AutoSize

# Check MPIO devices
Get-MSDSMSupportedHW | Format-Table VendorId, ProductId -AutoSize

# View path details per disk
mpclaim -s -d
```

---

## SMB3 Integration

SMB3 with SMB Direct (RDMA) provides excellent performance for Hyper-V VM storage. This is particularly attractive if you have a Windows-based file server or a NAS that supports SMB3.

### SMB3 for Hyper-V Storage

Hyper-V natively supports storing VM files on SMB3 shares. This is a fully supported configuration:

```powershell
# Verify SMB3 is available
Get-SmbConnection | Format-Table ServerName, ShareName, Dialect -AutoSize

# Verify SMB Direct (RDMA) status
Get-SmbClientNetworkInterface |
    Select-Object InterfaceIndex, FriendlyName, RdmaCapable |
    Format-Table -AutoSize

# Test SMB connectivity to file server
Test-SmbConnection -ServerName "fileserver.yourdomain.local"

# Create a Hyper-V VM on an SMB share
# First, set the default path to the SMB share
Set-VMHost -VirtualMachinePath "\\fileserver\HyperV-VMs" `
           -VirtualHardDiskPath "\\fileserver\HyperV-VHDs"

# SMB encryption for storage traffic (recommended)
Set-SmbClientConfiguration -RequireSecuritySignature $true -Force
```

### SMB3 Configuration Requirements

| Requirement | Details |
|-------------|---------|
| **SMB version** | SMB 3.0 or later (Windows Server 2012+) |
| **Permissions** | The Hyper-V host computer accounts need Full Control on the share |
| **Delegation** | Kerberos constrained delegation required for live migration with SMB storage |
| **Continuously Available** | Enable CA on the share for transparent failover |
| **RDMA** | Use SMB Direct with RDMA NICs for best performance |

---

## Pure Storage Reference Implementation

The principles above apply to any storage vendor. Here's a detailed implementation example using Pure Storage FlashArray, which is one of the most common enterprise arrays deployed with Hyper-V.

> **Vendor Disclosure:** This section uses Pure Storage as a concrete example because their Hyper-V integration is well-documented and their PowerShell module simplifies management. The principles apply equally to NetApp, Dell PowerStore, HPE Primera/Alletra, or any other enterprise array.

### Install the Pure Storage PowerShell Module

```powershell
# Install the Pure Storage PowerShell SDK
Install-Module -Name PureStoragePowerShellSDK2 -Force -Scope AllUsers

# Import the module
Import-Module PureStoragePowerShellSDK2

# Connect to the FlashArray
$FlashArray = Connect-Pfa2Array -EndPoint "pure-array-01.yourdomain.local" -Credential (Get-Credential)
```

### Create Volumes and Host Groups

```powershell
# ============================================================
# Pure Storage: Create Volumes for Hyper-V Cluster
# ============================================================

# Create a host group for the Hyper-V cluster
New-Pfa2HostGroup -Array $FlashArray -Name "HyperV-Cluster-01"

# Get the iSCSI IQN from each Hyper-V host and create host objects
$ClusterNodes = @(
    @{ Name = "HV-NODE-01"; IQN = (Invoke-Command -ComputerName "HV-NODE-01" { (Get-InitiatorPort).NodeAddress }) },
    @{ Name = "HV-NODE-02"; IQN = (Invoke-Command -ComputerName "HV-NODE-02" { (Get-InitiatorPort).NodeAddress }) }
)

foreach ($Node in $ClusterNodes) {
    # Create host on the array
    New-Pfa2Host -Array $FlashArray -Name $Node.Name -IqnList $Node.IQN

    # Add host to the host group
    New-Pfa2HostGroupHost -Array $FlashArray -GroupName "HyperV-Cluster-01" -MemberName $Node.Name

    Write-Host "Added $($Node.Name) to host group with IQN: $($Node.IQN)" -ForegroundColor Green
}

# Create volumes for Cluster Shared Volumes
$Volumes = @(
    @{ Name = "CSV-Prod-01"; Size = 2TB },
    @{ Name = "CSV-Prod-02"; Size = 2TB },
    @{ Name = "CSV-Quorum"; Size = 5GB }
)

foreach ($Vol in $Volumes) {
    New-Pfa2Volume -Array $FlashArray -Name $Vol.Name -Provisioned $Vol.Size

    # Connect volume to the host group (presents to all cluster nodes)
    New-Pfa2Connection -Array $FlashArray -VolumeName $Vol.Name `
        -HostGroupName "HyperV-Cluster-01"

    Write-Host "Created and connected $($Vol.Name) ($($Vol.Size))" -ForegroundColor Green
}
```

### Rescan and Verify on Hosts

```powershell
# Run on each Hyper-V host to pick up the new LUNs
Update-HostStorageCache

# Rescan iSCSI targets
Get-IscsiSession | Update-IscsiTarget

# Verify new disks are visible
Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" } |
    Select-Object Number, Size, BusType, FriendlyName |
    Format-Table -AutoSize
```

### Pure Storage Best Practices for Hyper-V

| Setting | Recommendation | Why |
|---------|---------------|-----|
| **MPIO Policy** | Round Robin | Balances I/O across all paths |
| **Thin Provisioning** | Enabled (default on Pure) | Pure handles this natively; Windows supports UNMAP |
| **Deduplication** | Enabled (always-on with Pure) | Transparent to the host |
| **Protection Groups** | Create per-cluster | Enables consistent snapshots across all CSVs |
| **Host Personality** | Set to "Windows" | Optimizes LUN presentation for Windows hosts |

---

## Vendor-Specific Integration Resources

If you're using a different storage vendor, here are the official Hyper-V integration guides:

| Vendor | Resource | Notes |
|--------|----------|-------|
| **Pure Storage** | [Microsoft Platform Guide](https://support.purestorage.com/bundle/m_microsoft_platform_guide) | Comprehensive Hyper-V + WSFC guide |
| **NetApp** | [Windows Server 2025 for FCP and iSCSI with ONTAP](https://docs.netapp.com/us-en/ontap-sanhost/hu-windows-2025.html) | Host Utilities required; covers MPIO and timeout configuration |
| **Dell** | [Dell PowerStore with Microsoft Hyper-V](https://infohub.delltechnologies.com) | Search InfoHub for current deployment guides |
| **HPE** | [HPE Alletra/Primera with Hyper-V](https://support.hpe.com) | Includes HPE MPIO DSM for optimized path management |
| **Hitachi** | [Hitachi VSP with Windows Server](https://knowledge.hitachivantara.com) | Covers Hitachi Dynamic Link Manager DSM |

> **Important:** Most storage vendors provide their own Device-Specific Module (DSM) for MPIO that optimizes path selection beyond the built-in Microsoft DSM. Always install the vendor-provided DSM for production deployments.

---

## Verification Checklist

Before moving on, verify your storage integration:

| Check | Command | Expected Result |
|-------|---------|-----------------|
| iSCSI sessions active | `Get-IscsiSession` | All sessions Connected, IsPersistent = True |
| MPIO paths per disk | `mpclaim -s -d` | 2+ paths per disk, all Active |
| Disks visible | `Get-Disk` | All LUNs visible, correct sizes |
| Jumbo frames working | `ping -f -l 8972 <storage IP>` | No fragmentation |
| MPIO policy set | `Get-MSDSMGlobalDefaultLoadBalancePolicy` | Round Robin (or vendor recommendation) |
| Consistent across nodes | Run checks on all nodes | Identical results on each node |

---

## Next Steps

Your Hyper-V hosts are now connected to enterprise storage with redundant paths, proper timeout configurations, and vendor-optimized settings. The foundation is solid.

In the next post, **[Post 7: Migrating VMs from VMware to Hyper-V](/post/migrating-vms-vmware-hyper-v)**, we'll cover the actual process of getting your virtual machines off VMware and onto your new Hyper-V infrastructure using the WAC VM Conversion Extension, SCVMM, StarWind V2V, and manual methods.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)
- **Previous Posts:**
  - [Post 1: Welcome to the Hyper-V Renaissance](/post/hyper-renaissance)
  - [Post 2: The Real Cost of Virtualization](/post/real-cost-virtualization)
  - [Post 3: The Myth of "Old Tech"](/post/myth-tech)
  - [Post 4: Reusing Your Existing VMware Hosts](/post/reusing-existing-vmware-hosts)
  - [Post 5: Build and Validate a Cluster-Ready Host](/post/build-validate-cluster-ready-host)

### Microsoft Documentation
- [iSCSI Storage Connectivity Troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/iscsi-storage-connectivity-troubleshooting)
- [MPIO Troubleshooting Guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/windows-server-mpio-troubleshooting)
- [Hyper-V on SMB3 Overview](https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-direct)
- [Failover Clustering Hardware Requirements](https://learn.microsoft.com/en-us/windows-server/failover-clustering/clustering-requirements)

---

**Series Navigation**
← Previous: [Post 5 — Build and Validate a Cluster-Ready Host](/post/build-validate-cluster-ready-host)
→ Next: [Post 7 — Migrating VMs from VMware to Hyper-V](/post/migrating-vms-vmware-hyper-v)

---
