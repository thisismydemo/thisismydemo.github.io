---
title: POC Like You Mean It—A Hands-On Hyper-V Cluster You Can Build This Afternoon
description: Complete workshop-style guide to building a functional Hyper-V cluster from scratch as a confidence-building checkpoint.
date: 2026-03-26T00:00:00.000Z
series: The Hyper-V Renaissance
series_post: 8
series_total: 21
draft: false
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: poc-like-you-mean-it
lead: Reproducible Lab Environment in One Afternoon
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Windows Server
    - Labs
tags:
    - Hyper-V
    - Clustering
    - POC
    - Lab
    - Hands-On
lastmod: 2026-04-05T02:14:44.693Z
---

If you can build it in a POC, you can build it in production.

The previous three posts gave you the components: host deployment (Post 5), storage integration (Post 6), and VM migration (Post 7). This post ties them all together into a single, cohesive deployment that you can complete in one afternoon. No hand-waving. No "left as an exercise for the reader." A real cluster, with real storage, running real VMs.

This is your confidence checkpoint. If you can complete this POC successfully, you have the skills and infrastructure knowledge to plan a production deployment.

> **Repository:** The complete deployment script from this post is available in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/02-foundation-building/post-8-poc-cluster).

---

## What We're Building

By the end of this afternoon, you'll have:

| Component | Configuration |
|-----------|--------------|
| **Cluster** | 2-node Windows Server Failover Cluster |
| **Hyper-V** | Hyper-V role on both nodes with SET networking |
| **Storage** | Shared storage (iSCSI or local for lab) as Cluster Shared Volumes |
| **Witness** | File share witness or cloud witness for quorum |
| **VMs** | At least one highly available VM that live migrates between nodes |
| **Validation** | Full Test-Cluster pass, successful live migration, simulated failover |

---

## Minimum Requirements

### Option A: Physical Hardware (Recommended)

| Component | Minimum | Notes |
|-----------|---------|-------|
| **Servers** | 2× with VT-x/AMD-V | Former VMware hosts from Post 4 are perfect |
| **RAM** | 16 GB per server | 32 GB+ preferred for running multiple VMs |
| **Storage** | Shared iSCSI target or FC LUNs | Even a Windows iSCSI target works for POC |
| **Network** | 2× NICs per server (minimum) | 4× for proper traffic separation |
| **OS** | Windows Server 2025 Datacenter eval | 180-day evaluation is fine for POC |

### Option B: Nested Virtualization (Lab/Dev)

If you don't have spare physical hardware, you can run this POC using nested virtualization on a single physical machine or in Azure/Hyper-V:

| Component | Minimum | Notes |
|-----------|---------|-------|
| **Host machine** | 64 GB RAM, 8+ cores | Needs to run two nested Hyper-V VMs |
| **Storage** | 200 GB free space | For two node VMs plus shared storage |
| **Hypervisor** | Windows Server 2025 or Windows 11 Pro/Enterprise | Nested Hyper-V must be enabled |

```powershell
# Enable nested virtualization on the host for each node VM
# Run on the physical Hyper-V host, NOT inside the VM
Set-VMProcessor -VMName "HV-NODE-01" -ExposeVirtualizationExtensions $true
Set-VMProcessor -VMName "HV-NODE-02" -ExposeVirtualizationExtensions $true

# Enable MAC address spoofing (required for nested VM networking)
Set-VMNetworkAdapter -VMName "HV-NODE-01" -MacAddressSpoofing On
Set-VMNetworkAdapter -VMName "HV-NODE-02" -MacAddressSpoofing On
```

### Option C: Quick iSCSI Target (No SAN Required)

If you don't have a storage array for the POC, you can use a third server (or even a third VM) as a Windows iSCSI Target:

```powershell
# Run on a third server/VM acting as iSCSI target
Install-WindowsFeature FS-iSCSITarget-Server -IncludeManagementTools

# Create iSCSI virtual disks
New-IscsiVirtualDisk -Path "D:\iSCSIDisks\CSV-Vol-01.vhdx" -SizeBytes 100GB
New-IscsiVirtualDisk -Path "D:\iSCSIDisks\CSV-Vol-02.vhdx" -SizeBytes 100GB
New-IscsiVirtualDisk -Path "D:\iSCSIDisks\Quorum.vhdx" -SizeBytes 1GB

# Create an iSCSI target
New-IscsiServerTarget -TargetName "HyperV-POC" `
    -InitiatorIds @(
        "IQN:iqn.1991-05.com.microsoft:hv-node-01.yourdomain.local",
        "IQN:iqn.1991-05.com.microsoft:hv-node-02.yourdomain.local"
    )

# Map virtual disks to the target
Add-IscsiVirtualDiskTargetMapping -TargetName "HyperV-POC" `
    -Path "D:\iSCSIDisks\CSV-Vol-01.vhdx"
Add-IscsiVirtualDiskTargetMapping -TargetName "HyperV-POC" `
    -Path "D:\iSCSIDisks\CSV-Vol-02.vhdx"
Add-IscsiVirtualDiskTargetMapping -TargetName "HyperV-POC" `
    -Path "D:\iSCSIDisks\Quorum.vhdx"

Write-Host "iSCSI Target configured. Target IPs for your cluster nodes:" -ForegroundColor Green
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -notlike "Loopback*" } |
    Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize
```

---

## The Build: Step by Step

Set a timer. Seriously. Track how long this takes you. Knowing your deployment velocity matters when you're planning production.

### ✅ Checkpoint 0: Prerequisites Verified (Time: 0:00)

Before you start the clock:
- [ ] Two servers (or VMs) powered on and accessible
- [ ] Windows Server 2025 Datacenter installed on both
- [ ] Both servers domain-joined to the same domain
- [ ] Shared storage accessible (iSCSI target, SAN, or Windows iSCSI Target)
- [ ] Network connectivity between both nodes confirmed
- [ ] Administrative credentials ready

### Step 1: Configure Both Nodes (Time: 0:00 - 0:30)

Run the following on **each node**. This is the condensed version of Post 5:

```powershell
# ============================================================
# POC Node Configuration Script
# Run on EACH node - adjust variables per node
# ============================================================

# --- Variables (CHANGE THESE PER NODE) ---
$NodeNumber = "01"  # Change to "02" for second node
$HostName = "HV-NODE-$NodeNumber"
$MgmtIP = "10.10.10.1$NodeNumber"     # .11 for node 1, .12 for node 2
$MigrationIP = "10.10.20.1$NodeNumber"
$StorageIP = "10.10.30.1$NodeNumber"
$Gateway = "10.10.10.1"
$DNS = @("10.10.10.5")
$iSCSITargetIP = "10.10.30.100"

# --- Install Roles and Features ---
Write-Host "[$HostName] Installing roles and features..." -ForegroundColor Yellow
Install-WindowsFeature -Name Hyper-V, Failover-Clustering, Multipath-IO, `
    RSAT-Clustering-PowerShell, RSAT-Hyper-V-Tools, Hyper-V-PowerShell `
    -IncludeManagementTools -Restart
```

After the reboot, continue:

```powershell
# --- Networking (simplified for POC with 2 NICs) ---
Write-Host "[$HostName] Configuring networking..." -ForegroundColor Yellow

# Get physical NIC names
$NICs = (Get-NetAdapter -Physical).Name

# Create SET switch with available NICs
New-VMSwitch -Name "SET-Switch" -NetAdapterName $NICs `
    -EnableEmbeddedTeaming $true -AllowManagementOS $true `
    -MinimumBandwidthMode Weight

# Rename default management vNIC
Rename-VMNetworkAdapter -ManagementOS -Name "SET-Switch" -NewName "Management"

# Create additional vNICs (skip VLANs if your POC lab is flat)
Add-VMNetworkAdapter -ManagementOS -SwitchName "SET-Switch" -Name "LiveMigration"
Add-VMNetworkAdapter -ManagementOS -SwitchName "SET-Switch" -Name "Storage"

# Assign IPs
New-NetIPAddress -InterfaceAlias "vEthernet (Management)" `
    -IPAddress $MgmtIP -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Management)" `
    -ServerAddresses $DNS

New-NetIPAddress -InterfaceAlias "vEthernet (LiveMigration)" `
    -IPAddress $MigrationIP -PrefixLength 24

New-NetIPAddress -InterfaceAlias "vEthernet (Storage)" `
    -IPAddress $StorageIP -PrefixLength 24

# --- Storage ---
Write-Host "[$HostName] Configuring storage..." -ForegroundColor Yellow

Enable-MSDSMAutomaticClaim -BusType iSCSI
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service -Name MSiSCSI

# Connect to iSCSI target
New-IscsiTargetPortal -TargetPortalAddress $iSCSITargetIP `
    -InitiatorPortalAddress $StorageIP

# Discover and connect to all targets
$Targets = Get-IscsiTarget
foreach ($Target in $Targets) {
    Connect-IscsiTarget -NodeAddress $Target.NodeAddress `
        -TargetPortalAddress $iSCSITargetIP `
        -InitiatorPortalAddress $StorageIP `
        -IsPersistent $true -IsMultipathEnabled $true
}

# --- Hyper-V Configuration ---
Write-Host "[$HostName] Configuring Hyper-V..." -ForegroundColor Yellow
Enable-VMMigration
Set-VMMigrationNetwork "$($MigrationIP.Substring(0, $MigrationIP.LastIndexOf('.'))).0/24"
Set-VMHost -VirtualMachineMigrationAuthenticationType CredSSP  # Simpler for POC
Set-VMHost -MaximumVirtualMachineMigrations 2

Write-Host "[$HostName] Node configuration complete!" -ForegroundColor Green
```

> **POC Simplification:** We're using CredSSP for live migration authentication instead of Kerberos. CredSSP is simpler to set up (no constrained delegation required) and is fine for a POC. For production, switch to Kerberos (see Post 5).

### ✅ Checkpoint 1: Both Nodes Configured (Target: 0:30)

Verify on both nodes:
```powershell
# Quick verification
Get-WindowsFeature Hyper-V, Failover-Clustering, Multipath-IO |
    Format-Table Name, InstallState
Get-VMSwitch | Format-Table Name, EmbeddedTeamingEnabled
Get-IscsiSession | Format-Table TargetNodeAddress, IsConnected
```

---

### Step 2: Validate and Create the Cluster (Time: 0:30 - 1:00)

Run this from either node (or a management workstation with RSAT):

```powershell
# ============================================================
# Cluster Creation
# ============================================================

$Nodes = @("HV-NODE-01", "HV-NODE-02")
$ClusterName = "HV-CLUSTER-01"
$ClusterIP = "10.10.10.20"

# Run cluster validation
Write-Host "Running cluster validation (this takes 10-20 minutes)..." -ForegroundColor Yellow
$ValidationResult = Test-Cluster -Node $Nodes

# Check the result
$ReportPath = Get-ChildItem "$env:SystemRoot\Cluster\Reports" -Filter "Validation*" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
Write-Host "Validation report: $($ReportPath.FullName)" -ForegroundColor Cyan

# If validation passes, create the cluster
Write-Host "Creating cluster $ClusterName..." -ForegroundColor Yellow
New-Cluster -Name $ClusterName -Node $Nodes -StaticAddress $ClusterIP `
    -NoStorage  # We'll add storage manually

# Verify cluster creation
Get-Cluster | Format-List Name, Domain
Get-ClusterNode | Format-Table Name, State
```

### ✅ Checkpoint 2: Cluster Created (Target: 1:00)

```powershell
# Verify cluster health
Get-Cluster | Format-List Name, Domain
Get-ClusterNode | Format-Table Name, State -AutoSize
# Both nodes should show "Up"
```

---

### Step 3: Configure Cluster Storage (Time: 1:00 - 1:30)

Now add the shared storage to the cluster:

```powershell
# ============================================================
# Cluster Storage Configuration
# ============================================================

# Initialize the shared disks on ONE node only (the owner)
# First, check which disks are available
Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" } |
    Select-Object Number, Size, BusType | Format-Table -AutoSize

# Initialize and format each shared disk
$SharedDisks = Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" -and $_.Size -gt 5GB }
foreach ($Disk in $SharedDisks) {
    Initialize-Disk -Number $Disk.Number -PartitionStyle GPT
    $Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize
    Format-Volume -Partition $Partition -FileSystem NTFS `
        -AllocationUnitSize 65536 `
        -NewFileSystemLabel "CSV-$($Disk.Number)" -Confirm:$false
    Write-Host "Initialized and formatted Disk $($Disk.Number)" -ForegroundColor Green
}

# Initialize the quorum disk (smaller disk)
$QuorumDisk = Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" -and $_.Size -le 5GB }
if ($QuorumDisk) {
    Initialize-Disk -Number $QuorumDisk.Number -PartitionStyle GPT
    $Partition = New-Partition -DiskNumber $QuorumDisk.Number -UseMaximumSize
    Format-Volume -Partition $Partition -FileSystem NTFS `
        -NewFileSystemLabel "Quorum" -Confirm:$false
}

# Add available disks to the cluster
Get-ClusterAvailableDisk | Add-ClusterDisk

# Verify cluster disks
Get-ClusterResource | Where-Object { $_.ResourceType -eq "Physical Disk" } |
    Format-Table Name, State, OwnerNode -AutoSize

# Convert cluster disks to Cluster Shared Volumes
# (Skip the quorum disk — that stays as a regular cluster disk)
$ClusterDisks = Get-ClusterResource |
    Where-Object { $_.ResourceType -eq "Physical Disk" -and $_.Name -notlike "*Quorum*" }

foreach ($Disk in $ClusterDisks) {
    Add-ClusterSharedVolume -Name $Disk.Name
    Write-Host "Converted $($Disk.Name) to CSV" -ForegroundColor Green
}

# Verify CSVs
Get-ClusterSharedVolume | Format-Table Name, State, OwnerNode -AutoSize

# Check CSV paths
Get-ChildItem "C:\ClusterStorage" | Format-Table Name, FullName -AutoSize
```

### Configure Cluster Quorum

```powershell
# Option A: Disk witness (if you have a small shared disk)
$QuorumResource = Get-ClusterResource |
    Where-Object { $_.ResourceType -eq "Physical Disk" -and $_.Name -like "*Quorum*" }
if ($QuorumResource) {
    Set-ClusterQuorum -DiskWitness $QuorumResource.Name
    Write-Host "Quorum configured with disk witness." -ForegroundColor Green
}

# Option B: File Share Witness (if you have a file server)
# Set-ClusterQuorum -FileShareWitness "\\fileserver\ClusterQuorum"

# Option C: Cloud Witness (Azure storage account — great for production)
# Set-ClusterQuorum -CloudWitness `
#     -AccountName "storageaccountname" `
#     -AccessKey "storageaccountkey" `
#     -Endpoint "core.windows.net"

# Verify quorum configuration
Get-ClusterQuorum | Format-List *
```

### ✅ Checkpoint 3: Storage and Quorum Configured (Target: 1:30)

```powershell
Get-ClusterSharedVolume | Format-Table Name, State, OwnerNode
Get-ClusterQuorum | Format-List ClusterQuorumType, QuorumResource
# CSVs should be Online, quorum should be configured
```

---

### Step 4: Deploy a Highly Available VM (Time: 1:30 - 2:00)

Now let's create a VM on the cluster and make it highly available:

```powershell
# ============================================================
# Create a Highly Available VM
# ============================================================

$VMName = "POC-TestVM-01"
$CSVPath = (Get-ClusterSharedVolume | Select-Object -First 1).SharedVolumeInfo.FriendlyVolumeName

# Create VM directory structure on CSV
$VMPath = Join-Path $CSVPath "VMs\$VMName"
New-Item -Path $VMPath -ItemType Directory -Force

# Create the VM
New-VM -Name $VMName `
    -MemoryStartupBytes 2GB `
    -NewVHDPath "$VMPath\$VMName.vhdx" `
    -NewVHDSizeBytes 40GB `
    -SwitchName "SET-Switch" `
    -Generation 2 `
    -Path $VMPath

# Configure VM settings
Set-VM -Name $VMName `
    -ProcessorCount 2 `
    -DynamicMemory `
    -MemoryMinimumBytes 512MB `
    -MemoryMaximumBytes 4GB `
    -AutomaticStartAction Start `
    -AutomaticStopAction ShutDown

# Add the VM to the cluster (makes it highly available)
Add-ClusterVirtualMachineRole -VMName $VMName

# Verify the VM is a cluster resource
Get-ClusterGroup $VMName | Format-Table Name, State, OwnerNode -AutoSize

Write-Host "VM $VMName created and added to cluster." -ForegroundColor Green
```

### Mount an ISO and Install a Guest OS (Optional)

```powershell
# If you have a guest OS ISO:
$ISOPath = "C:\ISOs\WindowsServer2025.iso"  # or any OS ISO
if (Test-Path $ISOPath) {
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath

    # Set boot order for Gen 2 VM (boot from DVD first)
    $DVDDrive = Get-VMDvdDrive -VMName $VMName
    Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive
}

# Start the VM
Start-VM -Name $VMName

# Connect to the console
# vmconnect localhost $VMName  # Run from Desktop Experience host
```

### ✅ Checkpoint 4: HA VM Running (Target: 2:00)

```powershell
Get-ClusterGroup $VMName | Format-Table Name, State, OwnerNode
Get-VM $VMName | Format-Table Name, State, CPUUsage, MemoryAssigned
# VM should be Running as a cluster group
```

---

### Step 5: Test Failover and Live Migration (Time: 2:00 - 2:30)

This is the payoff. Prove that high availability works.

### Test Live Migration

```powershell
# ============================================================
# Live Migration Test
# ============================================================

$VMName = "POC-TestVM-01"

# Check current owner
$CurrentOwner = (Get-ClusterGroup $VMName).OwnerNode
Write-Host "VM is currently on: $CurrentOwner" -ForegroundColor Cyan

# Determine the target node
$TargetNode = (Get-ClusterNode | Where-Object { $_.Name -ne $CurrentOwner }).Name
Write-Host "Migrating to: $TargetNode" -ForegroundColor Yellow

# Time the live migration
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Move-ClusterVirtualMachineRole -Name $VMName -Node $TargetNode -MigrationType Live
$Stopwatch.Stop()

# Verify
$NewOwner = (Get-ClusterGroup $VMName).OwnerNode
Write-Host "Migration complete in $($Stopwatch.Elapsed.TotalSeconds) seconds." -ForegroundColor Green
Write-Host "VM is now on: $NewOwner" -ForegroundColor Green

# If the guest OS is running, ping it during migration to verify no connectivity loss
# From another machine: ping -t <VM-IP-Address>
```

### Test Simulated Failover

```powershell
# ============================================================
# Simulated Failover Test
# ============================================================

$VMName = "POC-TestVM-01"
$CurrentOwner = (Get-ClusterGroup $VMName).OwnerNode

Write-Host "Simulating failure of node: $CurrentOwner" -ForegroundColor Yellow
Write-Host "VM should automatically move to the other node." -ForegroundColor Yellow

# Stop the cluster service on the current owner (simulates node failure)
# WARNING: This will move ALL resources off this node
Invoke-Command -ComputerName $CurrentOwner -ScriptBlock {
    Stop-Service ClusSvc -Force
}

# Wait for failover
Start-Sleep -Seconds 15

# Check where the VM ended up
$NewOwner = (Get-ClusterGroup $VMName -ErrorAction SilentlyContinue).OwnerNode
$State = (Get-ClusterGroup $VMName -ErrorAction SilentlyContinue).State

Write-Host "VM is now on: $NewOwner (State: $State)" -ForegroundColor $(if ($State -eq 'Online') { 'Green' } else { 'Yellow' })

# Restart the cluster service on the "failed" node
Invoke-Command -ComputerName $CurrentOwner -ScriptBlock {
    Start-Service ClusSvc
}

# Wait for the node to rejoin
Start-Sleep -Seconds 15
Get-ClusterNode | Format-Table Name, State -AutoSize
```

### Test Quick Migration (Planned Failover)

```powershell
# Quick migration moves the VM with a brief pause (saves state, moves, restores)
Move-ClusterVirtualMachineRole -Name $VMName -Node "HV-NODE-01" -MigrationType Quick
```

### ✅ Checkpoint 5: Failover Validated (Target: 2:30)

```powershell
Get-ClusterNode | Format-Table Name, State
Get-ClusterGroup $VMName | Format-Table Name, State, OwnerNode
# Both nodes should be Up, VM should be Online
```

---

### Step 6: Final Validation and Documentation (Time: 2:30 - 3:00)

```powershell
# ============================================================
# Final POC Validation Report
# ============================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HYPER-V POC VALIDATION REPORT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Cluster Health
Write-Host "`n--- Cluster Status ---" -ForegroundColor White
$Cluster = Get-Cluster
Write-Host "  Cluster Name: $($Cluster.Name)"
Write-Host "  Domain: $($Cluster.Domain)"

# Node Status
Write-Host "`n--- Node Status ---" -ForegroundColor White
Get-ClusterNode | ForEach-Object {
    $color = if ($_.State -eq "Up") { "Green" } else { "Red" }
    Write-Host "  $($_.Name): $($_.State)" -ForegroundColor $color
}

# CSV Status
Write-Host "`n--- Cluster Shared Volumes ---" -ForegroundColor White
Get-ClusterSharedVolume | ForEach-Object {
    $color = if ($_.State -eq "Online") { "Green" } else { "Red" }
    $Info = $_.SharedVolumeInfo
    Write-Host "  $($_.Name): $($_.State) on $($_.OwnerNode)" -ForegroundColor $color
    Write-Host "    Path: $($Info.FriendlyVolumeName)"
    Write-Host "    Size: $([math]::Round($Info.Partition.Size/1GB, 2)) GB | Free: $([math]::Round($Info.Partition.FreeSpace/1GB, 2)) GB"
}

# Quorum
Write-Host "`n--- Quorum ---" -ForegroundColor White
$Quorum = Get-ClusterQuorum
Write-Host "  Type: $($Quorum.QuorumType)"
Write-Host "  Resource: $($Quorum.QuorumResource)"

# VMs
Write-Host "`n--- Virtual Machines ---" -ForegroundColor White
Get-ClusterGroup | Where-Object { $_.GroupType -eq "VirtualMachine" } | ForEach-Object {
    $color = if ($_.State -eq "Online") { "Green" } else { "Yellow" }
    Write-Host "  $($_.Name): $($_.State) on $($_.OwnerNode)" -ForegroundColor $color
}

# Network
Write-Host "`n--- Cluster Networks ---" -ForegroundColor White
Get-ClusterNetwork | ForEach-Object {
    Write-Host "  $($_.Name): $($_.State) - Role: $($_.Role)" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  POC VALIDATION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
```

---

## POC Success Criteria

Your POC is successful if you can check every box:

| Test | Pass? |
|------|-------|
| Two-node cluster created and both nodes show "Up" | ☐ |
| Cluster Shared Volumes online and accessible from both nodes | ☐ |
| Quorum configured (disk, file share, or cloud witness) | ☐ |
| At least one VM created on CSV storage | ☐ |
| VM added as a highly available cluster role | ☐ |
| Live migration completes successfully between nodes | ☐ |
| Simulated failover moves VM to surviving node automatically | ☐ |
| "Failed" node rejoins cluster after restart | ☐ |
| Cluster validation report saved (no red X failures) | ☐ |

---

## Troubleshooting the POC

### Cluster Creation Fails

| Issue | Cause | Fix |
|-------|-------|-----|
| "Unable to determine a suitable domain" | DNS/domain issues | Verify both nodes resolve each other by FQDN |
| "Cluster network not found" | No shared subnet between nodes | Ensure both nodes have IPs on the same subnet |
| Storage tests fail | iSCSI not connected on both nodes | Verify iSCSI sessions on all nodes |

### Live Migration Fails

| Issue | Cause | Fix |
|-------|-------|-----|
| "Virtual machine migration failed" | Authentication issue | Verify CredSSP or Kerberos delegation |
| "No available connection" | Migration network not configured | Run `Set-VMMigrationNetwork` with correct subnet |
| Very slow migration | Using management network | Verify migration uses the dedicated migration vNIC |

### VM Won't Start on Second Node

| Issue | Cause | Fix |
|-------|-------|-----|
| "Cannot access VHD" | CSV not accessible | Verify CSV is online: `Get-ClusterSharedVolume` |
| "Configuration error" | VM stored on local path | VM files must be on CSV, not local storage |

---

## From POC to Production: What Changes

This POC proves the concept. Here's what you'd add or change for a production deployment:

| POC Setting | Production Change | Why |
|-------------|-------------------|-----|
| **CredSSP authentication** | Kerberos constrained delegation | Better security |
| **2 nodes** | 3+ nodes (or 2 with witness) | Better availability |
| **Windows iSCSI target** | Enterprise SAN | Performance, reliability, data services |
| **Flat network** | VLAN-separated traffic | Security, performance isolation |
| **Manual deployment** | Scripted/automated | Consistency, speed, repeatability |
| **Basic quorum** | Cloud witness | No dependency on shared storage for quorum |
| **No backup** | Backup solution integrated | Data protection (see Post 13) |
| **No monitoring** | WAC + monitoring stack | Operational visibility (see Post 9) |

---

## What You've Accomplished

In roughly three hours, you've built a fully functional Hyper-V failover cluster from bare metal. You've deployed Windows Server 2025, configured SET networking, connected shared storage, created a failover cluster, deployed a highly available VM, and proven that live migration and automatic failover work.

This is the same architecture pattern that runs production workloads in thousands of organizations. The difference between your POC and production is scale, redundancy, and operational maturity—not fundamental architecture.

You're ready for production planning.

---

## The Foundation Building Section: Complete

With this post, we've finished the Foundation Building section of the Hyper-V Renaissance series:

| Post | Topic | Status |
|------|-------|--------|
| 5 | Build and Validate a Cluster-Ready Host | ✅ |
| 6 | Three-Tier Storage Integration | ✅ |
| 7 | Migrating VMs from VMware to Hyper-V | ✅ |
| 8 | POC Like You Mean It | ✅ |

Next up is **Production Architecture** (Posts 9-16), where we go deep on monitoring, security, management tools, advanced storage, backup, multi-site resilience, live migration internals, and WSFC at scale. The foundation is solid. Time to build on it.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)
- **Previous Posts:**
  - [Post 5: Build and Validate a Cluster-Ready Host](/post/build-validate-cluster-ready-host)
  - [Post 6: Three-Tier Storage Integration](/post/three-tier-storage-integration)
  - [Post 7: Migrating VMs from VMware to Hyper-V](/post/migrating-vms-vmware-hyper-v)

### Microsoft Documentation
- [Create a failover cluster](https://learn.microsoft.com/en-us/windows-server/failover-clustering/create-failover-cluster)
- [Configure and manage quorum](https://learn.microsoft.com/en-us/windows-server/failover-clustering/manage-cluster-quorum)
- [Cluster Shared Volumes overview](https://learn.microsoft.com/en-us/windows-server/failover-clustering/failover-cluster-csvs)
- [Live Migration overview](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/manage/live-migration-overview)
- [Deploy a Cloud Witness](https://learn.microsoft.com/en-us/windows-server/failover-clustering/deploy-cloud-witness)

---

**Series Navigation**
← Previous: [Post 7 — Migrating VMs from VMware to Hyper-V](/post/migrating-vms-vmware-hyper-v)
→ Next: [Post 9 — Monitoring and Observability](/post/monitoring-observability)

---
