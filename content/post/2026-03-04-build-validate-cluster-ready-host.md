---
title: Build and Validate a Cluster-Ready Host
description: Step-by-step PowerShell guide to deploying a Hyper-V host ready for clustering with comprehensive pre-production validation procedures.
date: 2026-03-23T00:00:00.000Z
series: The Hyper-V Renaissance
series_post: 5
series_total: 20
draft: false
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: build-validate-cluster-ready-host
lead: PowerShell Deployment and Validation
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Windows Server
    - PowerShell
tags:
    - Hyper-V
    - Windows Server 2025
    - Clustering
    - PowerShell
    - Automation
    - Validation
lastmod: 2026-04-04T22:25:34.991Z
---

This is where the keyboards come out.

Posts 1 through 4 made the business case, dismantled the myths, and confirmed your hardware is ready. Now it's time to build something. In this fifth post of the **Hyper-V Renaissance** series, we're going to take a bare-metal server—or a freshly wiped former VMware host—and turn it into a production-ready Hyper-V node that's fully validated for cluster membership.

Every step is scripted. Every configuration is documented. If you can't reproduce it with PowerShell, it doesn't belong in a production deployment.

> **Repository:** All scripts from this post are available in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/02-foundation-building/post-5-cluster-host).

---

## What We're Building

By the end of this post, you'll have a Hyper-V host with the following configuration:

| Component | Configuration |
|-----------|--------------|
| **OS** | Windows Server 2025 Datacenter (Server Core or Desktop Experience) |
| **Roles** | Hyper-V, Failover Clustering |
| **Networking** | Switch Embedded Teaming (SET) virtual switch with separated traffic (Management, Live Migration, Storage, VM) |
| **Storage** | MPIO configured, iSCSI or FC connectivity ready |
| **Validation** | Test-Cluster passed, network validated, storage latency baselined |

You'll repeat this process for each node in your cluster. Post 8 ties it all together into a complete cluster deployment.

---

## Prerequisites

Before you begin, ensure you have the following:

| Requirement | Details |
|-------------|---------|
| **Server hardware** | Validated per [Post 4](/post/reusing-existing-vmware-hosts) (BIOS configured, firmware current) |
| **Windows Server 2025 media** | ISO or USB boot media with Datacenter edition |
| **Licensing** | Windows Server 2025 Datacenter product key or KMS/ADBA activation |
| **Network infrastructure** | At least two physical NICs (four recommended), switch ports configured with appropriate VLANs |
| **Storage infrastructure** | iSCSI target or FC fabric accessible from the host (covered in detail in Post 6) |
| **Active Directory** | Domain controller accessible on the management network |
| **DNS** | Forward and reverse lookup zones configured |

---

## Phase 1: Windows Server 2025 Installation

Install Windows Server 2025 Datacenter from your preferred media. If you're automating at scale, use an unattended answer file or your existing deployment solution (MDT, SCCM/MECM, or PXE). For a single host build, a standard interactive install works fine.

**Server Core vs. Desktop Experience**: Server Core is the recommended deployment option for Hyper-V hosts. It has a smaller attack surface, fewer updates, and lower resource overhead. Everything we do in this guide works on both options. If your team isn't comfortable with Server Core yet, Desktop Experience works—you can always convert later.

Once Windows is installed and you've set the local administrator password, connect via RDP or the console and open an elevated PowerShell session.

### Initial Host Configuration

```powershell
# ============================================================
# Phase 1: Base OS Configuration
# ============================================================

# Set the hostname
$HostName = "HV-NODE-01"
Rename-Computer -NewName $HostName -Force

# Set the time zone (adjust for your location)
Set-TimeZone -Id "Eastern Standard Time"

# Configure Windows Update to download but not auto-install
# (You control when hosts reboot, not Microsoft)
$AutoUpdate = (New-Object -ComObject Microsoft.Update.AutoUpdate)
# For Server Core, use Group Policy or registry:
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -Name "AUOptions" -Value 3 -Type DWord -Force

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" -Value 0 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Enable Remote Management (for WAC and remote PowerShell)
Enable-PSRemoting -Force
winrm quickconfig -quiet

# Restart to apply hostname change
Restart-Computer -Force
```

After the reboot, reconnect and join the domain:

```powershell
# Join Active Directory domain
$Credential = Get-Credential -Message "Enter domain admin credentials"
Add-Computer -DomainName "yourdomain.local" -Credential $Credential `
    -OUPath "OU=Hyper-V Hosts,OU=Servers,DC=yourdomain,DC=local" -Force
Restart-Computer -Force
```

---

## Phase 2: Install Required Roles and Features

After the domain join, install all the roles and features needed for a cluster-ready Hyper-V host in a single pass:

```powershell
# ============================================================
# Phase 2: Roles and Features Installation
# ============================================================

# Install Hyper-V, Failover Clustering, and supporting features
$Features = @(
    "Hyper-V",
    "Failover-Clustering",
    "Multipath-IO",
    "RSAT-Clustering-PowerShell",
    "RSAT-Hyper-V-Tools",
    "Hyper-V-PowerShell",
    "Data-Center-Bridging"
)

Install-WindowsFeature -Name $Features -IncludeManagementTools -Restart

# After reboot, verify installation
Get-WindowsFeature | Where-Object { $_.Installed -eq $true -and $_.Name -in $Features } |
    Format-Table Name, InstallState -AutoSize
```

**What each feature provides:**

| Feature | Purpose |
|---------|---------|
| **Hyper-V** | The hypervisor role itself |
| **Failover-Clustering** | Windows Server Failover Clustering for HA |
| **Multipath-IO** | Redundant storage paths (iSCSI/FC) |
| **RSAT-Clustering-PowerShell** | Cluster management cmdlets |
| **RSAT-Hyper-V-Tools** | Hyper-V management tools (includes Hyper-V Manager on Desktop Experience) |
| **Hyper-V-PowerShell** | Hyper-V PowerShell module |
| **Data-Center-Bridging** | Required for RDMA/RoCEv2 and priority flow control |

---

## Phase 3: Network Configuration

Networking is where most Hyper-V deployments either shine or fall apart. We're going to build this right from the start using **Switch Embedded Teaming (SET)**, which is the supported and recommended approach for Windows Server 2025 Hyper-V hosts.

### Why SET Instead of LBFO NIC Teaming

Traditional LBFO NIC Teaming is **deprecated for Hyper-V deployments** as of Windows Server 2022. Microsoft explicitly recommends Switch Embedded Teaming (SET) for Hyper-V virtual switches. SET combines the virtual switch and the NIC team into a single construct, which simplifies management, supports RDMA on host virtual NICs, and is compatible with SR-IOV on Windows Server 2025.

### Network Design

For a production cluster, you need separated traffic types. Here's the reference architecture:

| Traffic Type | VLAN | Subnet | Bandwidth | Purpose |
|-------------|------|--------|-----------|---------|
| **Management** | 10 | 10.10.10.0/24 | 1-10 Gbps | RDP, WAC, domain communication |
| **Live Migration** | 20 | 10.10.20.0/24 | 10-25 Gbps | VM live migration traffic |
| **Storage** | 30 | 10.10.30.0/24 | 10-25 Gbps | iSCSI, SMB3 storage traffic |
| **VM Network** | 100 | 10.10.100.0/24 | 10-25 Gbps | Virtual machine production traffic |

### Inventory Your Physical NICs

Before configuring anything, document what you're working with:

```powershell
# Discover physical network adapters
Get-NetAdapter -Physical |
    Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress, Status |
    Format-Table -AutoSize

# Check for RDMA capability
Get-NetAdapterRdma | Format-Table Name, Enabled, OperationalState -AutoSize

# Check for SR-IOV capability
Get-NetAdapterSriov | Format-Table Name, Enabled, NumVFs -AutoSize
```

### Create the SET Virtual Switch

This is the core networking construct. We're creating a single SET-enabled virtual switch that bonds multiple physical NICs and provides all traffic segregation through virtual NICs (vNICs):

```powershell
# ============================================================
# Phase 3: SET Virtual Switch Configuration
# ============================================================

# Define the physical NICs to include in the SET team
# Replace with your actual adapter names from Get-NetAdapter
$TeamMembers = @("NIC1", "NIC2", "NIC3", "NIC4")

# Create the SET virtual switch
New-VMSwitch -Name "SET-Switch" `
    -NetAdapterName $TeamMembers `
    -EnableEmbeddedTeaming $true `
    -AllowManagementOS $true `
    -MinimumBandwidthMode Weight

Write-Host "SET Switch created successfully." -ForegroundColor Green
```

### Create Host Virtual NICs (vNICs)

Now create separate virtual NICs for each traffic type and assign VLANs:

```powershell
# The management vNIC is created automatically when AllowManagementOS = $true
# Rename it for clarity
Rename-VMNetworkAdapter -ManagementOS -Name "SET-Switch" -NewName "Management"

# Create additional vNICs for separated traffic
Add-VMNetworkAdapter -ManagementOS -SwitchName "SET-Switch" -Name "LiveMigration"
Add-VMNetworkAdapter -ManagementOS -SwitchName "SET-Switch" -Name "Storage"

# Assign VLANs to each vNIC
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Management" -Access -VlanId 10
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "LiveMigration" -Access -VlanId 20
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Storage" -Access -VlanId 30

# Assign IP addresses
New-NetIPAddress -InterfaceAlias "vEthernet (Management)" `
    -IPAddress "10.10.10.11" -PrefixLength 24 -DefaultGateway "10.10.10.1"
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Management)" `
    -ServerAddresses "10.10.10.5","10.10.10.6"

New-NetIPAddress -InterfaceAlias "vEthernet (LiveMigration)" `
    -IPAddress "10.10.20.11" -PrefixLength 24

New-NetIPAddress -InterfaceAlias "vEthernet (Storage)" `
    -IPAddress "10.10.30.11" -PrefixLength 24

# Set bandwidth weights (ensure critical traffic gets priority)
Set-VMNetworkAdapter -ManagementOS -Name "Management" -MinimumBandwidthWeight 10
Set-VMNetworkAdapter -ManagementOS -Name "LiveMigration" -MinimumBandwidthWeight 30
Set-VMNetworkAdapter -ManagementOS -Name "Storage" -MinimumBandwidthWeight 40

Write-Host "Host vNICs configured with VLAN separation." -ForegroundColor Green
```

### Verify the Network Configuration

```powershell
# Verify SET switch team
Get-VMSwitch | Format-Table Name, SwitchType, EmbeddedTeamingEnabled -AutoSize
Get-VMSwitchTeam | Format-List *

# Verify host vNICs
Get-VMNetworkAdapter -ManagementOS |
    Select-Object Name, SwitchName, MacAddress, Status |
    Format-Table -AutoSize

# Verify VLAN assignments
Get-VMNetworkAdapterVlan -ManagementOS | Format-Table -AutoSize

# Verify IP addressing
Get-NetIPAddress -InterfaceAlias "vEthernet*" |
    Select-Object InterfaceAlias, IPAddress, PrefixLength |
    Format-Table -AutoSize

# Test connectivity on each vNIC
Test-NetConnection -ComputerName "10.10.10.1" -InformationLevel Detailed  # Gateway
Test-NetConnection -ComputerName "10.10.10.5" -InformationLevel Detailed  # DNS
```

### Enable RDMA on Host vNICs (Optional but Recommended)

If your NICs support RDMA (iWARP or RoCEv2), enable it on the Live Migration and Storage vNICs for significantly improved performance:

```powershell
# Enable RDMA on the Live Migration and Storage vNICs
Enable-NetAdapterRdma -Name "vEthernet (LiveMigration)"
Enable-NetAdapterRdma -Name "vEthernet (Storage)"

# Verify RDMA is enabled
Get-NetAdapterRdma -Name "vEthernet*" | Format-Table Name, Enabled -AutoSize

# For RoCEv2, configure Data Center Bridging (DCB) priority flow control
# This requires matching configuration on your physical switches
Install-WindowsFeature Data-Center-Bridging

# Create a QoS policy for RDMA traffic
New-NetQosPolicy -Name "SMB" -NetDirectPortMatchCondition 445 -PriorityValue8021Action 3
New-NetQosPolicy -Name "ClusterHeartbeat" -Cluster -PriorityValue8021Action 7

# Enable flow control for RDMA priority class
Enable-NetQosFlowControl -Priority 3
Disable-NetQosFlowControl -Priority 0,1,2,4,5,6,7

# Enable DCB on physical adapters
foreach ($Adapter in $TeamMembers) {
    Enable-NetAdapterQos -Name $Adapter
}

Write-Host "RDMA and DCB configured." -ForegroundColor Green
```

> **Important**: RDMA configuration (especially RoCEv2/DCB) requires matching configuration on your physical network switches. Work with your network team to ensure Priority Flow Control (PFC) and Enhanced Transmission Selection (ETS) are configured consistently end-to-end. iWARP-based RDMA is more forgiving and doesn't require DCB switch configuration.

---

## Phase 4: Storage Preparation

This phase prepares the host for external storage connectivity. We'll cover iSCSI here since it's the most common protocol for organizations without existing Fibre Channel infrastructure. Post 6 covers storage integration in detail across all protocols.

### Configure MPIO for iSCSI

```powershell
# ============================================================
# Phase 4: Storage Preparation
# ============================================================

# MPIO should already be installed from Phase 2
# Enable MPIO support for iSCSI devices
Enable-MSDSMAutomaticClaim -BusType iSCSI

# Verify MPIO is configured for iSCSI
Get-MSDSMAutomaticClaimSettings

# The server needs a reboot after enabling iSCSI MPIO claims
Restart-Computer -Force
```

After the reboot, configure the iSCSI Initiator:

```powershell
# Start the iSCSI Initiator service and set to auto-start
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service -Name MSiSCSI

# Get the iSCSI Initiator IQN (you'll need this for storage array configuration)
$IQN = (Get-InitiatorPort).NodeAddress
Write-Host "iSCSI Initiator IQN: $IQN" -ForegroundColor Cyan

# Add iSCSI target portals (replace with your storage array IPs)
New-IscsiTargetPortal -TargetPortalAddress "10.10.30.100" -InitiatorPortalAddress "10.10.30.11"
New-IscsiTargetPortal -TargetPortalAddress "10.10.30.101" -InitiatorPortalAddress "10.10.30.11"

# Discover available targets
Get-IscsiTarget

# Connect to targets with MPIO (repeat for each path)
# Replace the NodeAddress with the IQN from your storage array
$TargetIQN = "iqn.2010-06.com.storagevendor:targetname"

Connect-IscsiTarget -NodeAddress $TargetIQN `
    -TargetPortalAddress "10.10.30.100" `
    -InitiatorPortalAddress "10.10.30.11" `
    -IsPersistent $true `
    -IsMultipathEnabled $true

Connect-IscsiTarget -NodeAddress $TargetIQN `
    -TargetPortalAddress "10.10.30.101" `
    -InitiatorPortalAddress "10.10.30.11" `
    -IsPersistent $true `
    -IsMultipathEnabled $true

# Verify iSCSI sessions
Get-IscsiSession | Format-Table InitiatorNodeAddress, TargetNodeAddress,
    IsConnected, IsPersistent -AutoSize

# Verify MPIO paths
Get-IscsiConnection | Format-Table ConnectionIdentifier, InitiatorAddress,
    TargetAddress -AutoSize

# Check MPIO policy on connected disks
Get-MSDSMGlobalDefaultLoadBalancePolicy
mpclaim -s -d  # Shows multipath devices and paths
```

### Configure the SAN Policy

By default, Windows Server may keep SAN disks offline. Set the SAN policy to bring new disks online automatically:

```powershell
# Set SAN policy to online shared disks (required for clustering)
Set-StorageSetting -NewDiskPolicy OnlineAll
```

> **Note**: If you're using Fibre Channel instead of iSCSI, MPIO configuration is similar but the transport setup differs. Your FC HBA vendor provides host utilities that set appropriate timeout values and MPIO policies. See Post 6 for FC-specific guidance.

---

## Phase 5: Hyper-V Host Configuration

With roles installed, networking configured, and storage connected, configure the Hyper-V host settings:

```powershell
# ============================================================
# Phase 5: Hyper-V Host Configuration
# ============================================================

# Set default VM storage paths
$VMPath = "C:\ClusterStorage\Volume1\VMs"       # Will be a CSV after clustering
$VHDPath = "C:\ClusterStorage\Volume1\VHDs"      # Adjust per your storage design

# For now, set temporary local paths (updated after cluster creation)
Set-VMHost -VirtualMachinePath "D:\VMs" -VirtualHardDiskPath "D:\VHDs"

# Create the directories if they don't exist
New-Item -Path "D:\VMs" -ItemType Directory -Force
New-Item -Path "D:\VHDs" -ItemType Directory -Force

# Configure Live Migration settings
Enable-VMMigration
Set-VMMigrationNetwork "10.10.20.0/24"  # Use the Live Migration VLAN

# Set authentication protocol for live migration
# Kerberos is recommended for domain-joined hosts (constrained delegation required)
# CredSSP is simpler but less secure
Set-VMHost -VirtualMachineMigrationAuthenticationType Kerberos

# Set maximum simultaneous live migrations
# Rule of thumb: 1 per 10 Gbps of live migration bandwidth
Set-VMHost -MaximumVirtualMachineMigrations 4

# Set maximum storage migrations
Set-VMHost -MaximumStorageMigrations 2

# Enable NUMA spanning (default, but verify)
Set-VMHost -NumaSpanningEnabled $true

# Configure enhanced session mode (Desktop Experience only)
Set-VMHost -EnableEnhancedSessionMode $true

# Verify host configuration
Get-VMHost | Format-List VirtualMachinePath, VirtualHardDiskPath,
    VirtualMachineMigrationEnabled, VirtualMachineMigrationAuthenticationType,
    MaximumVirtualMachineMigrations, MaximumStorageMigrations, NumaSpanningEnabled
```

### Configure Kerberos Constrained Delegation (for Live Migration)

If you chose Kerberos authentication for live migration (recommended), configure constrained delegation in Active Directory. Run this from a domain controller or a machine with the AD PowerShell module:

```powershell
# Run on a domain controller or machine with RSAT-AD-PowerShell
# Allow HV-NODE-01 to delegate to HV-NODE-02 for CIFS and Microsoft Virtual System Migration Service

$SourceNode = "HV-NODE-01"
$TargetNode = "HV-NODE-02"

# Get the computer objects
$Source = Get-ADComputer $SourceNode
$Target = Get-ADComputer $TargetNode

# Configure delegation for live migration and shared storage
Set-ADComputer -Identity $Source -Add @{
    'msDS-AllowedToDelegateTo' = @(
        "cifs/$TargetNode",
        "cifs/$TargetNode.yourdomain.local",
        "Microsoft Virtual System Migration Service/$TargetNode",
        "Microsoft Virtual System Migration Service/$TargetNode.yourdomain.local"
    )
}

# Repeat in reverse direction
Set-ADComputer -Identity $Target -Add @{
    'msDS-AllowedToDelegateTo' = @(
        "cifs/$SourceNode",
        "cifs/$SourceNode.yourdomain.local",
        "Microsoft Virtual System Migration Service/$SourceNode",
        "Microsoft Virtual System Migration Service/$SourceNode.yourdomain.local"
    )
}

Write-Host "Kerberos constrained delegation configured for live migration." -ForegroundColor Green
```

---

## Phase 6: Pre-Cluster Validation

This is the "trust but verify" checkpoint. Before this host joins or forms a cluster, it must pass validation. Microsoft requires a passing cluster validation report as a condition of support for failover cluster configurations.

### Network Validation

```powershell
# ============================================================
# Phase 6: Comprehensive Validation
# ============================================================

# --- Network Validation ---

Write-Host "=== Network Validation ===" -ForegroundColor Cyan

# 1. Verify all vNICs are up
$vNICs = Get-NetAdapter -Name "vEthernet*"
foreach ($vNIC in $vNICs) {
    $status = if ($vNIC.Status -eq "Up") { "PASS" } else { "FAIL" }
    $color = if ($status -eq "PASS") { "Green" } else { "Red" }
    Write-Host "  $($vNIC.Name): $status ($($vNIC.LinkSpeed))" -ForegroundColor $color
}

# 2. Verify VLAN tagging
Get-VMNetworkAdapterVlan -ManagementOS | ForEach-Object {
    Write-Host "  $($_.ParentAdapter.Name): VLAN $($_.AccessVlanId)" -ForegroundColor White
}

# 3. Test connectivity on each network
$PingTests = @(
    @{ Name = "Gateway"; Target = "10.10.10.1"; Interface = "vEthernet (Management)" },
    @{ Name = "DNS"; Target = "10.10.10.5"; Interface = "vEthernet (Management)" },
    @{ Name = "DC"; Target = "10.10.10.5"; Interface = "vEthernet (Management)" }
)

foreach ($Test in $PingTests) {
    $Result = Test-NetConnection -ComputerName $Test.Target -WarningAction SilentlyContinue
    $status = if ($Result.TcpTestSucceeded -or $Result.PingSucceeded) { "PASS" } else { "FAIL" }
    $color = if ($status -eq "PASS") { "Green" } else { "Red" }
    Write-Host "  Ping $($Test.Name) ($($Test.Target)): $status" -ForegroundColor $color
}

# 4. Verify DNS resolution
$DNSTest = Resolve-DnsName -Name "yourdomain.local" -ErrorAction SilentlyContinue
if ($DNSTest) {
    Write-Host "  DNS Resolution: PASS" -ForegroundColor Green
} else {
    Write-Host "  DNS Resolution: FAIL" -ForegroundColor Red
}

# 5. Verify SET team health
$TeamInfo = Get-VMSwitchTeam
Write-Host "`n  SET Team Members:" -ForegroundColor White
foreach ($Member in $TeamInfo.NetAdapterInterfaceDescription) {
    $Adapter = Get-NetAdapter -InterfaceDescription $Member
    $color = if ($Adapter.Status -eq "Up") { "Green" } else { "Red" }
    Write-Host "    $($Adapter.Name): $($Adapter.Status) ($($Adapter.LinkSpeed))" -ForegroundColor $color
}
```

### Storage Validation

```powershell
# --- Storage Validation ---

Write-Host "`n=== Storage Validation ===" -ForegroundColor Cyan

# 1. Check iSCSI sessions
$Sessions = Get-IscsiSession
Write-Host "  Active iSCSI Sessions: $($Sessions.Count)" -ForegroundColor White
$Sessions | ForEach-Object {
    Write-Host "    Target: $($_.TargetNodeAddress) Connected: $($_.IsConnected)" -ForegroundColor White
}

# 2. Check MPIO paths
Write-Host "`n  MPIO Paths:" -ForegroundColor White
$MPIODisks = Get-MSDSMGlobalDefaultLoadBalancePolicy
Write-Host "    Default LB Policy: $MPIODisks" -ForegroundColor White

# 3. Check visible disks
$Disks = Get-Disk | Where-Object { $_.BusType -ne "NVMe" -and $_.BusType -ne "SATA" -and $_.Number -gt 0 }
Write-Host "`n  SAN Disks Visible: $($Disks.Count)" -ForegroundColor White
foreach ($Disk in $Disks) {
    Write-Host "    Disk $($Disk.Number): $([math]::Round($Disk.Size / 1GB, 2)) GB - $($Disk.BusType) - $($Disk.OperationalStatus)" -ForegroundColor White
}

# 4. Quick storage latency test (write to iSCSI disk if available)
if ($Disks.Count -gt 0) {
    Write-Host "`n  Running basic I/O test..." -ForegroundColor Yellow
    # Simple sequential write test using diskspd or a basic file operation
    # For a proper baseline, use DiskSpd:
    # https://aka.ms/diskspd
    Write-Host "  (Use DiskSpd for production-grade storage baseline testing)" -ForegroundColor Gray
}
```

### Role and Feature Validation

```powershell
# --- Role and Feature Validation ---

Write-Host "`n=== Role and Feature Validation ===" -ForegroundColor Cyan

$RequiredFeatures = @(
    "Hyper-V", "Failover-Clustering", "Multipath-IO",
    "RSAT-Clustering-PowerShell", "Hyper-V-PowerShell"
)

foreach ($Feature in $RequiredFeatures) {
    $Installed = Get-WindowsFeature -Name $Feature
    $status = if ($Installed.InstallState -eq "Installed") { "PASS" } else { "FAIL" }
    $color = if ($status -eq "PASS") { "Green" } else { "Red" }
    Write-Host "  $($Feature): $status" -ForegroundColor $color
}

# Verify Hyper-V hypervisor is running
$HypervisorPresent = (Get-CimInstance Win32_ComputerSystem).HypervisorPresent
$color = if ($HypervisorPresent) { "Green" } else { "Red" }
Write-Host "  Hypervisor Present: $HypervisorPresent" -ForegroundColor $color
```

### Run Test-Cluster (Pre-Cluster Validation)

When you have two or more nodes prepared, run the full cluster validation test. This is the most important validation step and produces the report that Microsoft requires for support.

```powershell
# --- Cluster Validation ---
# Run this when ALL nodes are prepared
# Replace node names with your actual hostnames

$Nodes = @("HV-NODE-01", "HV-NODE-02")

Write-Host "`n=== Running Cluster Validation ===" -ForegroundColor Cyan
Write-Host "This will take 10-30 minutes depending on configuration." -ForegroundColor Yellow

# Run all validation tests
Test-Cluster -Node $Nodes -Verbose

# The report is saved to:
# C:\Windows\Cluster\Reports\Validation Report <DateTime>.html
$ReportPath = Get-ChildItem "$env:SystemRoot\Cluster\Reports" -Filter "Validation*" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
Write-Host "`nValidation report saved to: $($ReportPath.FullName)" -ForegroundColor Green

# If you only want to run specific test categories:
# Test-Cluster -Node $Nodes -Include "Network","Inventory","System Configuration"
# Available categories: Cluster Configuration, Hyper-V Configuration,
#   Inventory, Network, Storage, System Configuration
```

### What Test-Cluster Validates

| Test Category | What It Checks |
|--------------|----------------|
| **Inventory** | Hardware, software, drivers, updates consistency across nodes |
| **Network** | Adapter configuration, connectivity between nodes, IP addressing, firewall rules |
| **Storage** | Disk access, MPIO paths, simultaneous access, failover behavior |
| **System Configuration** | AD configuration, OS versions, required services, time sync |
| **Hyper-V Configuration** | Hyper-V role settings, virtual switch consistency, live migration readiness |

### Interpreting Results

The validation report uses three indicators:

- **Green checkmark**: Test passed — configuration meets Microsoft requirements.
- **Yellow triangle**: Warning — the configuration works but doesn't meet all best practices. Investigate these, but they don't block cluster creation.
- **Red X**: Failure — this issue must be resolved before creating the cluster. Common failures include mismatched drivers between nodes, network connectivity issues, or storage path problems.

**Keep the validation report.** Microsoft Support will request it if you ever open a cluster-related support case.

---

## Phase 7: Host Hardening (Quick Wins)

Apply essential security hardening before putting this host into production. Full security architecture is covered in Post 10, but these are the baseline items:

```powershell
# ============================================================
# Phase 7: Basic Host Hardening
# ============================================================

# Enable Windows Defender (should be on by default)
Set-MpPreference -DisableRealtimeMonitoring $false

# Add exclusions for Hyper-V (prevents performance issues)
$HyperVExclusions = @(
    "D:\VMs",
    "D:\VHDs",
    "%ProgramData%\Microsoft\Windows\Hyper-V",
    "%SystemRoot%\System32\vmms.exe",
    "%SystemRoot%\System32\vmwp.exe",
    "%SystemRoot%\System32\vmcompute.exe"
)
foreach ($Exclusion in $HyperVExclusions) {
    Add-MpPreference -ExclusionPath $Exclusion
}
Add-MpPreference -ExclusionExtension "vhd","vhdx","avhd","avhdx","vhds","iso"

# Enable Credential Guard (protects domain credentials)
# Requires UEFI Secure Boot and TPM 2.0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
    -Name "EnableVirtualizationBasedSecurity" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "LsaCfgFlags" -Value 1 -Type DWord

# Disable unnecessary services
$DisableServices = @(
    "Browser",      # Computer Browser
    "lltdsvc",      # Link-Layer Topology Discovery Mapper
    "rspndr",       # Link-Layer Topology Discovery Responder
    "SharedAccess",  # Internet Connection Sharing
    "WlanSvc"       # WLAN AutoConfig (no WiFi on servers)
)
foreach ($Svc in $DisableServices) {
    $Service = Get-Service -Name $Svc -ErrorAction SilentlyContinue
    if ($Service) {
        Set-Service -Name $Svc -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $Svc -Force -ErrorAction SilentlyContinue
    }
}

# Enable SMB encryption for cluster communication
Set-SmbServerConfiguration -EncryptData $true -Force

Write-Host "Basic host hardening applied." -ForegroundColor Green
```

---

## The Complete Build Checklist

Use this checklist for each node you deploy:

| Phase | Item | Status |
|-------|------|--------|
| **OS** | Windows Server 2025 Datacenter installed | ☐ |
| **OS** | Hostname set, domain joined | ☐ |
| **OS** | Time zone and NTP configured | ☐ |
| **Roles** | Hyper-V role installed | ☐ |
| **Roles** | Failover Clustering installed | ☐ |
| **Roles** | MPIO installed and configured | ☐ |
| **Network** | SET virtual switch created | ☐ |
| **Network** | Management vNIC configured with IP/VLAN | ☐ |
| **Network** | Live Migration vNIC configured with IP/VLAN | ☐ |
| **Network** | Storage vNIC configured with IP/VLAN | ☐ |
| **Network** | RDMA enabled (if applicable) | ☐ |
| **Network** | All connectivity tests pass | ☐ |
| **Storage** | iSCSI/FC connectivity established | ☐ |
| **Storage** | MPIO paths verified | ☐ |
| **Storage** | SAN disks visible | ☐ |
| **Hyper-V** | Default paths configured | ☐ |
| **Hyper-V** | Live migration enabled and configured | ☐ |
| **Hyper-V** | Kerberos delegation configured | ☐ |
| **Security** | Windows Defender exclusions set | ☐ |
| **Security** | Credential Guard enabled | ☐ |
| **Validation** | Test-Cluster passes all tests | ☐ |
| **Validation** | Validation report saved | ☐ |

---

## Troubleshooting Common Issues

### SET Switch Creation Fails

If `New-VMSwitch` with `-EnableEmbeddedTeaming` fails, verify that:
- All specified NICs are the same speed (mixing 1 GbE and 10 GbE is not supported in a SET team)
- None of the NICs are already bound to another switch or LBFO team
- The NICs support the same driver version

### RDMA Doesn't Enable on vNICs

RDMA on SET host vNICs requires that the underlying physical NICs support RDMA and have current drivers. Verify with `Get-NetAdapterRdma -Name "PhysicalNICName"` on each team member. Also confirm that your physical switches support and have DCB/PFC configured if using RoCEv2.

### iSCSI Targets Not Discovered

Check that the iSCSI Initiator service is running (`Get-Service MSiSCSI`), the storage VLAN is correctly tagged, and the target portal IP is reachable from the storage vNIC (`Test-NetConnection -ComputerName "10.10.30.100" -Port 3260`).

### Test-Cluster Shows Network Warnings

The most common network warning is nodes having different network configurations. Ensure all nodes have the same VLANs, the same number of vNICs, consistent IP subnets, and matching MTU settings. Test-Cluster checks for consistency across all nodes.

---

## Next Steps

You now have a fully configured, validated Hyper-V host ready for cluster membership. Repeat this process on each additional node, keeping configurations consistent across all nodes.

In the next post, **[Post 6: Three-Tier Storage Integration](/post/three-tier-storage-integration)**, we'll connect your hosts to external storage arrays using iSCSI, Fibre Channel, and SMB3—covering universal principles that work with any vendor and including a detailed Pure Storage reference implementation.

The foundation is laid. Time to connect the storage.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)
- **Previous Posts:**
  - [Post 1: Welcome to the Hyper-V Renaissance](/post/hyper-renaissance)
  - [Post 2: The Real Cost of Virtualization](/post/real-cost-virtualization)
  - [Post 3: The Myth of "Old Tech"](/post/myth-tech)
  - [Post 4: Reusing Your Existing VMware Hosts](/post/reusing-existing-vmware-hosts)

### Microsoft Documentation
- [Create and configure a virtual switch with Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines)
- [Remote Direct Memory Access and Switch Embedded Teaming](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v-virtual-switch/rdma-and-switch-embedded-teaming)
- [Test-Cluster cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/failoverclusters/test-cluster)
- [Validate hardware for a failover cluster](https://learn.microsoft.com/en-us/troubleshoot/windows-server/high-availability/validate-hardware-failover-cluster)
- [Plan for Hyper-V on Windows Server](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-for-hyper-v-on-windows-server)
- [MPIO troubleshooting guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/windows-server-mpio-troubleshooting)

---

**Series Navigation**
← Previous: [Post 4 — Reusing Your Existing VMware Hosts](/post/reusing-existing-vmware-hosts)
→ Next: [Post 6 — Three-Tier Storage Integration](/post/three-tier-storage-integration)

---
