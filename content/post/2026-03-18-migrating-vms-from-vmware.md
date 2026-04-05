---
title: Migrating VMs from VMware to Hyper-V
description: Complete guide to converting and migrating virtual machines from VMware vSphere to Hyper-V including tools, procedures, and validation.
date: 2026-03-25T00:00:00.000Z
series: The Hyper-V Renaissance
series_post: 7
series_total: 21
draft: false
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: migrating-vms-vmware-hyper-v
lead: VM Conversion Tools and Migration Procedures
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Migration
    - Windows Server
tags:
    - Hyper-V
    - VMware
    - Migration
    - VM Conversion
    - V2V
lastmod: 2026-04-05T02:14:44.691Z
---

You've built the case, validated the hardware, configured the hosts, and connected the storage. Now comes the part everyone's been waiting for (and dreading): actually moving the virtual machines.

VM migration from VMware to Hyper-V is not a single-click operation. Disk formats differ (VMDK vs. VHDX). Virtual hardware differs (VMware paravirtual drivers vs. Hyper-V synthetic drivers). Guest integration tools differ (VMware Tools vs. Hyper-V Integration Services). But the tooling has improved dramatically, and in 2026, you have more options than ever—including a free, Microsoft-supported tool that performs online migration with minimal downtime.

In this seventh post of the **Hyper-V Renaissance** series, we'll cover every major migration path, help you choose the right tool for your situation, and walk through the process from pre-migration assessment to post-migration validation.

> **Repository:** All scripts and checklists from this post are available in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/02-foundation-building/post-7-vm-migration).

---

## Migration Tool Landscape

Let's establish the playing field. Here are the viable tools in 2026:

| Tool | Online Migration | Cost | Scale | Best For |
|------|-----------------|------|-------|----------|
| **WAC VM Conversion Extension** | Yes (replication-based) | Free | Batch of 10 VMs | Most migrations — free, Microsoft-supported, online |
| **SCVMM 2025** | No (offline conversion) | System Center license | Enterprise scale (100+ parallel) | Large-scale migrations with existing SCVMM investment |
| **StarWind V2V Converter** | Limited (ESXi-to-Hyper-V sync) | Free | Individual VMs | Quick conversions, format flexibility |
| **Veeam Backup & Replication** | Yes (via restore) | Licensed | Large environments | Organizations already using Veeam |
| **Manual (disk conversion)** | No | Free | Individual VMs | Edge cases, Linux VMs, troubleshooting |

> **Deprecated:** Microsoft Virtual Machine Converter (MVMC) reached end of support and should not be used for new migrations.

---

## Pre-Migration Assessment

Before converting a single VM, assess your VMware environment to identify potential issues.

### Inventory Your VMware VMs

```powershell
# If you have VMware PowerCLI installed, generate an inventory
# Install-Module VMware.PowerCLI -Scope AllUsers

Connect-VIServer -Server "vcenter.yourdomain.local"

$VMInventory = Get-VM | Select-Object Name,
    @{N='GuestOS'; E={$_.Guest.OSFullName}},
    @{N='vCPUs'; E={$_.NumCpu}},
    @{N='MemoryGB'; E={$_.MemoryGB}},
    @{N='ProvisionedGB'; E={[math]::Round(($_.ProvisionedSpaceGB), 2)}},
    @{N='UsedGB'; E={[math]::Round(($_.UsedSpaceGB), 2)}},
    @{N='VMToolsStatus'; E={$_.Guest.ToolsStatus}},
    @{N='FirmwareType'; E={$_.ExtensionData.Config.Firmware}},
    @{N='DiskCount'; E={($_ | Get-HardDisk).Count}},
    @{N='NICCount'; E={($_ | Get-NetworkAdapter).Count}},
    @{N='Snapshots'; E={($_ | Get-Snapshot).Count}},
    PowerState

$VMInventory | Export-Csv -Path "VMware-Inventory.csv" -NoTypeInformation
$VMInventory | Format-Table -AutoSize
```

### Migration Compatibility Matrix

Not every VM converts cleanly. Assess each VM against this matrix:

| Factor | Impact | Action Required |
|--------|--------|----------------|
| **BIOS firmware** | Converts to Gen 1 Hyper-V VM | Works as-is; consider converting to Gen 2 post-migration |
| **UEFI firmware** | Converts to Gen 2 Hyper-V VM | Ideal — enables Secure Boot, larger boot disk support |
| **VMware Paravirtual SCSI** | Must be replaced with standard controller | Tools handle this automatically in most cases |
| **VMXNET3 NIC** | Must be replaced with Hyper-V synthetic NIC | Tools handle this automatically |
| **VMware Tools installed** | Must be uninstalled (or removed post-migration) | Uninstall before migration for cleanest conversion |
| **Active snapshots** | Must be consolidated before migration | Consolidate all snapshots first |
| **Shared VMDK disks** | Not directly convertible | Requires re-architecture (use iSCSI pass-through or shared VHDX) |
| **RDM (Raw Device Mapping)** | Not directly convertible | Re-map at the Hyper-V/storage level |
| **vGPU** | Requires GPU-P reconfiguration | Plan for post-migration GPU-P setup |
| **Linux guest (VMware Tools)** | open-vm-tools must be removed; Hyper-V LIS drivers needed | Install LIS drivers before or during migration |

### Pre-Migration Checklist

Complete this for every VM before starting the conversion:

| Item | Status |
|------|--------|
| VM snapshots consolidated | ☐ |
| VMware Tools status documented | ☐ |
| Firmware type identified (BIOS/UEFI) | ☐ |
| Current IP configuration documented | ☐ |
| Application-specific dependencies noted | ☐ |
| Backup of VM taken | ☐ |
| Downtime window approved (if needed) | ☐ |
| Target Hyper-V host and storage identified | ☐ |

---

## Method 1: WAC VM Conversion Extension (Recommended)

The **VM Conversion Extension for Windows Admin Center** is the biggest improvement in the VMware-to-Hyper-V migration story in years. This free tool performs online, replication-based migration with minimal downtime for both Windows and Linux guests.

> **Preview Notice:** As of early 2026, the VM Conversion Extension is available as a **Preview** extension in Windows Admin Center. It is fully functional and Microsoft-documented, but preview extensions may have limited support and could change before general availability. Test thoroughly in your environment before relying on it for production migrations.

### Why This Is the Recommended Approach

- **Free** — included with Windows Admin Center at no additional cost
- **Online migration** — the source VM stays running during initial replication; only a brief cutover window is needed
- **Supports Windows and Linux** — including Ubuntu 20.04/24.04, Debian 11/12, Alma Linux, CentOS, RHEL 9.0
- **Batch migration** — supports migrating up to 10 VMs simultaneously
- **Preserves static IP configurations** — reduces post-migration work
- **Automatic VMware Tools cleanup** — removes VMware Tools from Windows guests post-migration
- **Secure Boot configuration** — automatically configures Secure Boot based on OS type
- **Multi-disk support** — migrates all attached virtual disks

### Prerequisites

| Requirement | Details |
|-------------|---------|
| **Windows Admin Center** | Latest version installed on a management machine or gateway server |
| **VMware vCenter** | Version 6.x, 7.x, or 8.x with admin credentials |
| **Target Hyper-V host** | Windows Server 2025 or 2022 with Hyper-V role |
| **Network** | WAC gateway must be able to reach both vCenter and target Hyper-V host |
| **Linux guests** | Must have Hyper-V drivers installed before migration for successful boot |

### Step-by-Step Migration

**Step 1: Install the VM Conversion Extension**

In Windows Admin Center, navigate to **Settings > Extensions > Available extensions**, search for "VM Conversion," and install it.

**Step 2: Add VMware vCenter Connection**

Open the VM Conversion extension and add your vCenter endpoint. You can add multiple vCenter connections and switch between them.

**Step 3: Select VMs for Migration**

Browse your vCenter inventory and select the VMs to migrate. Group them strategically:

- **Application dependency** — VMs that belong to the same application stack
- **Cluster dependency** — VMs that need to land on nodes within the same cluster
- **Business boundaries** — separate batches for different business units

**Step 4: Configure Migration Settings**

For each VM, configure:
- Target Hyper-V host
- Storage location on the target host
- Network mapping (VMware port group → Hyper-V virtual switch)
- VM generation (Gen 1 for BIOS, Gen 2 for UEFI)
- Secure Boot settings (automatically detected based on OS)

**Step 5: Start Synchronization**

The extension begins replicating the VM data from VMware to Hyper-V while the source VM continues running. Initial synchronization time depends on VM disk size and network bandwidth.

**Step 6: Cutover**

When synchronization is complete and you're ready for the final cutover:
1. The source VM is briefly paused
2. Final delta data is synchronized
3. The VM is powered on in Hyper-V
4. VMware Tools are removed (Windows guests)
5. Static IP configuration is preserved

### Post-Migration for Linux Guests

Linux VMs require Hyper-V drivers (Linux Integration Services) to be installed before migration. For modern distributions (kernel 4.x+), the drivers are built into the kernel. For older distributions, install them manually before starting the migration:

```bash
# For Ubuntu/Debian (usually built-in on modern versions)
# Verify Hyper-V modules are available
lsmod | grep hv_

# If not present, install:
sudo apt-get install linux-tools-virtual linux-cloud-tools-virtual

# For RHEL/CentOS (usually built-in on 7.x+ with kernel 3.10+)
# Verify:
lsmod | grep hv_
```

---

## Method 2: SCVMM 2025

System Center Virtual Machine Manager 2025 provides enterprise-scale VMware-to-Hyper-V conversion with enhanced performance—up to four times faster than previous versions. This is the right tool for large-scale migrations where you're converting hundreds of VMs.

### How It Works

SCVMM connects directly to your vCenter Server, discovers VMware VMs, and converts them to Hyper-V format. The process is offline—the source VM must be powered off during conversion.

### SCVMM Conversion Process

1. **Add VMware vCenter to SCVMM fabric** — In the VMM console, under Fabric, add your vCenter Server using a Run As account with administrator privileges.

2. **Add ESXi hosts** — After vCenter discovery, add the ESXi hosts that contain the VMs you want to convert.

3. **Convert VMs** — In VMs and Services, select Create Virtual Machine > Convert Virtual Machine. The wizard walks you through:
   - Selecting the source VMware VM
   - Choosing Generation 1 (BIOS) or Generation 2 (UEFI)
   - Specifying the target Hyper-V host
   - Configuring storage location, network, and VM settings

4. **Monitor conversion** — SCVMM handles disk conversion (VMDK to VHDX), driver injection, and VM registration on the target host.

### SCVMM Conversion Limitations

| Limitation | Details |
|-----------|---------|
| **Offline only** | Source VMware VMs must be powered off during conversion |
| **VMware Tools** | Must be uninstalled from the guest OS before conversion |
| **BIOS VMs with 4+ disks** | IDE bus limitations mean not all disks attach automatically; manual re-attachment needed |
| **Parallelism** | Recommended maximum of 10 parallel conversions per ESXi-to-Hyper-V pair; up to 100 total with different source-destination pairs |
| **Licensing** | Requires System Center license |

### When to Use SCVMM

SCVMM makes sense when:
- You have hundreds of VMs to convert and need orchestration
- You already have SCVMM deployed or planned
- You need to co-manage VMware and Hyper-V during the transition period
- Offline conversion windows are acceptable

---

## Method 3: StarWind V2V Converter (Free)

StarWind V2V Converter is a free, community-trusted tool for converting virtual machine disk formats. It's been the go-to solution for VMware-to-Hyper-V conversions for years and supports all major formats: VMDK, VHD/VHDX, QCOW2, and RAW IMG.

### Key Capabilities

- **Free** with no licensing requirements
- **Bi-directional conversion** between all major formats
- **Direct ESXi-to-Hyper-V conversion** without intermediate file copies
- **Windows Repair Mode** for VHDX conversions (helps VMs adapt to new hardware environment)
- **P2V migration** from physical to virtual
- **Windows Server 2025 compatibility** (fixed in recent releases)

### StarWind Conversion Process

```
1. Download and install StarWind V2V Converter from starwindsoftware.com
2. Launch the converter and select source:
   - Local file (VMDK)
   - Remote VMware ESXi Server
   - Remote VMware vCenter Server
3. Select the VM or disk to convert
4. Select destination:
   - Remote Microsoft Hyper-V Server
   - Local file (VHDX)
5. Configure destination settings (VHDX format, dynamic/fixed)
6. Start conversion
7. Register the converted VM in Hyper-V
```

### When to Use StarWind

StarWind is ideal for:
- Converting individual VMs or small batches
- Quick format conversions without infrastructure setup
- Situations where you need maximum control over the conversion process
- Converting VMs to test in a lab before production migration
- Converting between formats not supported by other tools (e.g., QCOW2)

### Limitations

- VMs must be powered off for conversion (no online migration)
- No batch automation through GUI (command-line available for scripting)
- No automatic VMware Tools removal or driver injection

---

## Method 4: Manual Disk Conversion

For edge cases, troubleshooting, or maximum control, you can convert disks manually and build the Hyper-V VM from scratch.

### Convert VMDK to VHDX Using PowerShell

Windows Server 2025 includes native cmdlets for working with virtual disks:

```powershell
# ============================================================
# Manual VMDK to VHDX Conversion
# ============================================================

# Option 1: Using qemu-img (most reliable for VMDK conversion)
# Install qemu-img via Chocolatey or download from qemu.org
# choco install qemu-img -y

# Convert VMDK to VHDX
qemu-img convert -f vmdk -O vhdx "source-vm-disk.vmdk" "converted-disk.vhdx"

# Option 2: For split VMDK files, first combine them
# qemu-img convert -f vmdk "source-vm-disk.vmdk" -O raw "temp.raw"
# Then convert to VHDX:
# qemu-img convert -f raw "temp.raw" -O vhdx "converted-disk.vhdx"

# Optimize the VHDX (convert to dynamic if needed)
Optimize-VHD -Path "converted-disk.vhdx" -Mode Full
```

### Create the Hyper-V VM from Converted Disks

```powershell
# Create a new VM using the converted VHDX
$VMName = "Migrated-VM-01"
$VHDPath = "D:\VHDs\converted-disk.vhdx"

# Determine generation based on source firmware
# UEFI source → Generation 2
# BIOS source → Generation 1

# For a BIOS (Generation 1) VM:
New-VM -Name $VMName `
    -MemoryStartupBytes 4GB `
    -VHDPath $VHDPath `
    -SwitchName "SET-Switch" `
    -Generation 1

# For a UEFI (Generation 2) VM:
New-VM -Name $VMName `
    -MemoryStartupBytes 4GB `
    -VHDPath $VHDPath `
    -SwitchName "SET-Switch" `
    -Generation 2

# Configure VM settings
Set-VM -Name $VMName `
    -ProcessorCount 4 `
    -DynamicMemory `
    -MemoryMinimumBytes 2GB `
    -MemoryMaximumBytes 8GB

# For Generation 2 VMs, you may need to adjust boot order
# and disable Secure Boot initially for Linux guests
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off  # Re-enable after first boot

# Add additional converted disks if the source VM had multiple disks
Add-VMHardDiskDrive -VMName $VMName -Path "D:\VHDs\converted-data-disk.vhdx"

# Start the VM
Start-VM -Name $VMName
```

### Post-Conversion: Windows Guest Cleanup

After starting a manually converted Windows VM:

```powershell
# Run inside the migrated Windows VM

# 1. Uninstall VMware Tools (if not done before migration)
$VMwareTools = Get-WmiObject -Class Win32_Product |
    Where-Object { $_.Name -like "*VMware*" }
if ($VMwareTools) {
    $VMwareTools.Uninstall()
    Write-Host "VMware Tools uninstalled. Reboot required." -ForegroundColor Yellow
}

# 2. Verify Hyper-V Integration Services are running
Get-Service -Name "vmicheartbeat","vmicshutdown","vmicexchange","vmictimesync" |
    Format-Table Name, Status, StartType -AutoSize

# 3. Update network adapter drivers
# Windows should automatically use Hyper-V synthetic NIC drivers
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status -AutoSize

# 4. Verify disk controllers
Get-WmiObject Win32_SCSIController |
    Select-Object Name, Manufacturer, Status |
    Format-Table -AutoSize
```

### Post-Conversion: Linux Guest Cleanup

```bash
# Run inside the migrated Linux VM

# 1. Remove VMware Tools / open-vm-tools
sudo apt remove open-vm-tools open-vm-tools-desktop  # Debian/Ubuntu
# or
sudo yum remove open-vm-tools  # RHEL/CentOS

# 2. Verify Hyper-V modules are loaded
lsmod | grep hv_
# Should see: hv_vmbus, hv_storvsc, hv_netvsc, hv_balloon, hv_utils

# 3. If Hyper-V modules are not present, install them
# Ubuntu/Debian:
sudo apt install linux-tools-virtual linux-cloud-tools-virtual

# 4. Regenerate initramfs to include Hyper-V drivers
sudo update-initramfs -u  # Debian/Ubuntu
# or
sudo dracut --force  # RHEL/CentOS

# 5. Verify network adapter is detected
ip addr show

# 6. Update GRUB if needed
sudo update-grub  # Debian/Ubuntu
# or
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # RHEL/CentOS
```

---

## Post-Migration Validation

Regardless of which migration method you used, run this validation on every converted VM:

```powershell
# ============================================================
# Post-Migration Validation Script
# Run from the Hyper-V host
# ============================================================

$VMName = "Migrated-VM-01"

Write-Host "=== Post-Migration Validation: $VMName ===" -ForegroundColor Cyan

# 1. VM State
$VM = Get-VM -Name $VMName
Write-Host "`n1. VM State: $($VM.State)" -ForegroundColor $(if ($VM.State -eq 'Running') { 'Green' } else { 'Red' })

# 2. Integration Services
$IS = Get-VMIntegrationService -VMName $VMName
Write-Host "`n2. Integration Services:" -ForegroundColor White
$IS | ForEach-Object {
    $color = if ($_.Enabled -and $_.PrimaryStatusDescription -eq "OK") { "Green" } else { "Yellow" }
    Write-Host "   $($_.Name): Enabled=$($_.Enabled) Status=$($_.PrimaryStatusDescription)" -ForegroundColor $color
}

# 3. Network Connectivity
$NetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
Write-Host "`n3. Network Adapter:" -ForegroundColor White
Write-Host "   Switch: $($NetworkAdapter.SwitchName)" -ForegroundColor White
Write-Host "   MAC: $($NetworkAdapter.MacAddress)" -ForegroundColor White
Write-Host "   Status: $($NetworkAdapter.Status)" -ForegroundColor $(if ($NetworkAdapter.Status -eq 'Ok') { 'Green' } else { 'Yellow' })

# 4. Disk Configuration
$Disks = Get-VMHardDiskDrive -VMName $VMName
Write-Host "`n4. Disks:" -ForegroundColor White
foreach ($Disk in $Disks) {
    $VHD = Get-VHD -Path $Disk.Path
    Write-Host "   $($Disk.Path)" -ForegroundColor White
    Write-Host "     Size: $([math]::Round($VHD.Size/1GB, 2)) GB | Used: $([math]::Round($VHD.FileSize/1GB, 2)) GB | Format: $($VHD.VhdFormat)" -ForegroundColor White
}

# 5. Checkpoint Status (should have none post-migration)
$Checkpoints = Get-VMSnapshot -VMName $VMName -ErrorAction SilentlyContinue
if ($Checkpoints) {
    Write-Host "`n5. WARNING: VM has checkpoints that should be removed" -ForegroundColor Yellow
} else {
    Write-Host "`n5. Checkpoints: None (clean)" -ForegroundColor Green
}

# 6. Generation and Firmware
Write-Host "`n6. VM Generation: $($VM.Generation)" -ForegroundColor White
if ($VM.Generation -eq 2) {
    $Firmware = Get-VMFirmware -VMName $VMName
    Write-Host "   Secure Boot: $($Firmware.SecureBoot)" -ForegroundColor White
}

Write-Host "`n=== Validation Complete ===" -ForegroundColor Cyan
```

---

## Migration Strategy: Phased Approach

For production migrations, don't try to convert everything at once. Use a phased approach:

### Phase 1: Pilot (Week 1-2)
- Convert 3-5 non-critical VMs (dev/test workloads)
- Validate the conversion process and tooling
- Document any issues and workarounds
- Build team confidence and muscle memory

### Phase 2: Non-Critical Production (Week 3-6)
- Convert file servers, print servers, monitoring systems
- Validate application functionality post-migration
- Refine the process based on pilot learnings

### Phase 3: Business Applications (Week 7-12)
- Convert application servers, web servers, middleware
- Coordinate with application owners for validation
- Schedule maintenance windows for cutover

### Phase 4: Critical Infrastructure (Week 13-16)
- Convert database servers, domain controllers (if virtualized), email
- Require extended validation periods
- Maintain VMware rollback capability until confirmed stable

### Phase 5: Decommission VMware (Week 17+)
- Verify all workloads are running on Hyper-V
- Remove VMware licenses, uninstall ESXi
- Reclaim VMware-specific infrastructure (vCenter, NSX controllers)
- Update documentation and runbooks

---

## Common Pitfalls and Solutions

| Pitfall | Symptom | Solution |
|---------|---------|----------|
| VMware Tools left installed | Phantom NICs, performance issues, blue screens | Uninstall VMware Tools before or immediately after conversion |
| Wrong VM generation | VM won't boot | BIOS source → Gen 1; UEFI source → Gen 2 |
| Linux VM won't boot | Kernel panic, no root filesystem | Install Hyper-V LIS drivers and regenerate initramfs before migration |
| Static IPs lost | VM gets DHCP address | WAC extension preserves IPs; manual conversions require re-configuration |
| PVSCSI driver dependency | Blue screen on boot | Inject standard SCSI driver before conversion, or use tools that handle this automatically |
| Time sync issues | Clock drift after migration | Enable Hyper-V Time Synchronization integration service |
| Application licensing | License deactivation | Some applications tie licenses to hardware IDs that change during conversion; re-activate as needed |

---

## Next Steps

With your VMs migrated to Hyper-V, you've completed the core of the Foundation Building section. But before moving to production architecture, let's tie everything together.

In the next post, **[Post 8: POC Like You Mean It](/post/poc-like-you-mean-it)**, we'll build a complete, functional Hyper-V cluster from scratch in a single afternoon—combining everything from Posts 5, 6, and 7 into a cohesive, reproducible deployment that proves your environment works before you stake production on it.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)
- **Previous Posts:**
  - [Post 5: Build and Validate a Cluster-Ready Host](/post/build-validate-cluster-ready-host)
  - [Post 6: Three-Tier Storage Integration](/post/three-tier-storage-integration)

### Microsoft Documentation
- [VM Conversion Extension for Windows Admin Center](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/use/vm-conversion-extension-overview)
- [Migrate VMware VMs to Hyper-V in Windows Admin Center](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/use/migrate-vmware-to-hyper-v)
- [Convert VMware VMs to Hyper-V using SCVMM](https://learn.microsoft.com/en-us/system-center/vmm/vm-convert-vmware?view=sc-vmm-2025)
- [Supported Linux Distributions for Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-linux-and-freebsd-virtual-machines-for-hyper-v-on-windows)

### Third-Party Tools
- [StarWind V2V Converter](https://www.starwindsoftware.com/starwind-v2v-converter) (free download)
- [Veeam Backup & Replication](https://www.veeam.com/blog/vmware-to-hyper-v-migration.html) (migration via instant recovery)

---

**Series Navigation**
← Previous: [Post 6 — Three-Tier Storage Integration](/post/three-tier-storage-integration)
→ Next: [Post 8 — POC Like You Mean It](/post/poc-like-you-mean-it)

---
