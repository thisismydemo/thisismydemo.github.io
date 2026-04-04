---
title: Security Architecture for Hyper-V Clusters
description: Comprehensive security guide covering cluster-level hardening, VM-level isolation, and compliance requirements for Hyper-V environments.
date: 2026-04-15T00:00:00.000Z
series: The Hyper-V Renaissance
series_post: 10
series_total: 20
draft: true
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: hyper-v-security-architecture
lead: Hardening, VBS, and Shielded VMs
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Virtualization
    - Security
    - Windows Server
tags:
    - Hyper-V
    - Security
    - Credential Guard
    - Shielded VMs
    - VBS
    - Compliance
lastmod: 2026-04-04T17:48:14.550Z
---

Security isn't a feature you bolt on after the cluster is built. It's a design decision you make from the start.

A Hyper-V host is a high-value target. Compromise the host and you compromise every VM running on it. Compromise the cluster and you compromise the entire workload. The attack surface is real, and the defaults — while better in Windows Server 2025 than any prior release — are still not enough for production without deliberate hardening.

In this tenth post of the **Hyper-V Renaissance** series, we'll build a security architecture in layers: host hardening first, then cluster communication, then VM-level isolation. We'll separate the achievable hardening that every organization should implement from the advanced features that require significant investment. No security theater — just practical, defensible configuration.

> **Repository:** All scripts from this post are available in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/scripts).

---

## Security in Layers

| Layer | What It Protects | Complexity |
|-------|-----------------|------------|
| **Host Hardening** | The Hyper-V host OS itself | Low — do this first |
| **Cluster Security** | Communication between cluster nodes | Low–Medium |
| **VM Isolation** | VMs from each other and from the host | Medium |
| **Advanced Protection** | Shielded VMs, HGS, attestation | High — evaluate carefully |

---

## Layer 1: Host Hardening

These are baseline configurations that every Hyper-V host should have. If you followed Post 5, some of these are already in place.

### Credential Guard

Credential Guard uses Virtualization-Based Security (VBS) to isolate domain credentials in a protected container that even a compromised kernel can't access. On Windows Server 2025, Credential Guard is **enabled by default** on systems that meet the hardware requirements (UEFI Secure Boot, TPM 2.0).

```powershell
# ============================================================
# Credential Guard Configuration
# ============================================================

# Verify Credential Guard status
$DevGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
Write-Host "VBS Status: $($DevGuard.VirtualizationBasedSecurityStatus)"
Write-Host "Credential Guard: $($DevGuard.SecurityServicesRunning -contains 1)"
# SecurityServicesRunning: 1 = Credential Guard, 2 = HVCI

# If not enabled, configure via registry
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
    -Name "EnableVirtualizationBasedSecurity" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "LsaCfgFlags" -Value 1 -Type DWord
# Value 1 = Enabled without UEFI lock (can be disabled remotely)
# Value 2 = Enabled with UEFI lock (requires physical access to disable)
```

> **Critical:** Credential Guard breaks CredSSP-based authentication. If you're using CredSSP for live migration (common in lab environments), you must switch to **Kerberos constrained delegation** before enabling Credential Guard. This is why Post 5 recommended Kerberos from the start. See Post 5's Kerberos delegation section if you need to make this change.

### Memory Integrity (HVCI)

Hypervisor-Protected Code Integrity (HVCI) runs kernel-mode code integrity checks inside the VBS-isolated environment. On Windows Server 2025, HVCI is enabled by default and cannot be permanently disabled.

```powershell
# Verify HVCI is active
$DevGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
$HVCIRunning = $DevGuard.SecurityServicesRunning -contains 2
Write-Host "HVCI Active: $HVCIRunning"

# If needed, ensure HVCI is configured
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
    -Name "HypervisorEnforcedCodeIntegrity" -Value 1 -Type DWord
```

### Windows Defender Configuration

Windows Defender automatically configures exclusions when the Hyper-V role is installed. Verify they're in place and add any custom VM storage paths:

```powershell
# ============================================================
# Windows Defender Configuration for Hyper-V
# ============================================================

# Verify automatic Hyper-V exclusions are active
$Exclusions = Get-MpPreference
Write-Host "Excluded Extensions:" -ForegroundColor Cyan
$Exclusions.ExclusionExtension | ForEach-Object { Write-Host "  $_" }
Write-Host "`nExcluded Paths:" -ForegroundColor Cyan
$Exclusions.ExclusionPath | ForEach-Object { Write-Host "  $_" }
Write-Host "`nExcluded Processes:" -ForegroundColor Cyan
$Exclusions.ExclusionProcess | ForEach-Object { Write-Host "  $_" }

# Add exclusions for custom VM storage paths (e.g., CSV paths)
$CustomPaths = @(
    "C:\ClusterStorage",
    "D:\VMs",
    "D:\VHDs"
)
foreach ($Path in $CustomPaths) {
    Add-MpPreference -ExclusionPath $Path
}

# Add Hyper-V process exclusions (should be automatic, but verify)
$HyperVProcesses = @(
    "$env:SystemRoot\System32\vmms.exe",
    "$env:SystemRoot\System32\vmwp.exe",
    "$env:SystemRoot\System32\vmcompute.exe"
)
foreach ($Process in $HyperVProcesses) {
    Add-MpPreference -ExclusionProcess $Process
}

# Add VM disk file extension exclusions
$VMExtensions = @("vhd", "vhdx", "avhd", "avhdx", "vhds", "vhdpmem",
                   "iso", "rct", "mrt", "vsv", "vmcx", "vmrs")
foreach ($Ext in $VMExtensions) {
    Add-MpPreference -ExclusionExtension $Ext
}

# Enable real-time protection (should be on by default)
Set-MpPreference -DisableRealtimeMonitoring $false

# Enable cloud-delivered protection for latest definitions
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendAllSamples
```

### Disable Unnecessary Services

Reduce the attack surface by disabling services that have no business running on a Hyper-V host:

```powershell
# Services to disable on Hyper-V hosts
$DisableServices = @(
    "Browser",           # Computer Browser — not needed
    "lltdsvc",           # Link-Layer Topology Discovery Mapper
    "rspndr",            # Link-Layer Topology Discovery Responder
    "SharedAccess",      # Internet Connection Sharing
    "WlanSvc",           # WLAN AutoConfig — no WiFi on servers
    "MapsBroker",        # Downloaded Maps Manager
    "lfsvc",             # Geolocation Service
    "Fax",               # Fax service
    "XblAuthManager",    # Xbox Live Auth Manager (yes, it exists on Server)
    "XblGameSave"        # Xbox Live Game Save
)

foreach ($Svc in $DisableServices) {
    $Service = Get-Service -Name $Svc -ErrorAction SilentlyContinue
    if ($Service) {
        Stop-Service -Name $Svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Svc -StartupType Disabled
        Write-Host "Disabled: $Svc" -ForegroundColor Yellow
    }
}
```

### Windows Firewall Hardening

Don't disable the firewall. Harden it:

```powershell
# Ensure firewall is enabled on all profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Verify Hyper-V management rules are enabled
Get-NetFirewallRule -Group "Hyper-V" | Format-Table DisplayName, Enabled, Direction -AutoSize
Get-NetFirewallRule -Group "Windows Remote Management" |
    Format-Table DisplayName, Enabled, Direction -AutoSize

# Block inbound on public profile (defense in depth)
Set-NetFirewallProfile -Profile Public -DefaultInboundAction Block

# Log dropped connections for forensics
Set-NetFirewallProfile -Profile Domain -LogBlocked True `
    -LogFileName "%SystemRoot%\System32\LogFiles\Firewall\pfirewall.log" `
    -LogMaxSizeKilobytes 16384
```

---

## Layer 2: Cluster Security

### SMB Signing and Encryption

Windows Server 2025 **requires SMB signing by default** on all connections — both client and server. This provides integrity protection against tampering. For confidentiality (protecting against eavesdropping), you need SMB encryption, which must be explicitly enabled.

```powershell
# ============================================================
# SMB Security Configuration
# ============================================================

# Verify SMB signing is required (default in WS2025)
Get-SmbServerConfiguration | Select-Object RequireSecuritySignature
Get-SmbClientConfiguration | Select-Object RequireSecuritySignature
# Both should be True

# Enable SMB encryption for all server shares
Set-SmbServerConfiguration -EncryptData $true -Force

# Require encryption on the client side as well
Set-SmbClientConfiguration -RequireEncryption $true -Force

# Configure encryption ciphers (AES-256-GCM preferred)
Set-SmbServerConfiguration -EncryptionCiphers "AES_256_GCM, AES_128_GCM" -Force

# Verify configuration
Get-SmbServerConfiguration |
    Select-Object EncryptData, RequireSecuritySignature, EncryptionCiphers |
    Format-List
```

> **Note:** When SMB encryption is active, it supersedes signing — encryption already provides tamper protection, so the separate signing overhead is removed automatically.

### Cluster Communication Security

Secure the communication channels between cluster nodes:

```powershell
# ============================================================
# Cluster Security Configuration
# ============================================================

# Enable cluster communication encryption
# This encrypts Cluster Shared Volume (CSV) I/O traffic between nodes
(Get-Cluster).BlockCacheSize = 0  # Disable block cache if enabling encryption

# Enable BitLocker on Cluster Shared Volumes (data at rest)
# Run on the CSV owner node
$CSVs = Get-ClusterSharedVolume
foreach ($CSV in $CSVs) {
    $VolumePath = $CSV.SharedVolumeInfo.FriendlyVolumeName
    $Volume = Get-Volume | Where-Object { $_.Path -like "*$($CSV.SharedVolumeInfo.Partition.Name)*" }
    if ($Volume) {
        Write-Host "Consider enabling BitLocker on: $VolumePath" -ForegroundColor Yellow
        # Enable-BitLocker requires careful planning for cluster environments
        # See: https://learn.microsoft.com/en-us/windows-server/failover-clustering/bitlocker-on-csv-in-ws-2022
    }
}

# Restrict cluster communication to specific networks
# Ensure cluster traffic only uses the intended networks
Get-ClusterNetwork | ForEach-Object {
    Write-Host "$($_.Name): Role = $($_.Role)" -ForegroundColor White
    # Role 0 = Do not allow cluster network communication
    # Role 1 = Allow cluster network communication only
    # Role 3 = Allow cluster and client network communication
}
```

### Administrative Access Control

Limit who can manage the cluster and how:

```powershell
# Review cluster access permissions
Get-ClusterAccess | Format-Table Identity, AccessControlType, Rights -AutoSize

# Add specific admin group (don't rely on domain admins for everything)
Grant-ClusterAccess -User "YOURDOMAIN\HyperV-Admins" -Full

# Enable audit logging for cluster operations
auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable
```

---

## Layer 3: VM Isolation and Security

### Secure Boot for VMs

Secure Boot on Generation 2 VMs prevents unauthorized boot loaders and rootkits from loading. It's enabled by default on new Gen 2 VMs, but verify your existing VMs:

```powershell
# ============================================================
# VM Secure Boot Configuration
# ============================================================

# Check Secure Boot status on all Gen 2 VMs
Get-VM | Where-Object Generation -eq 2 | ForEach-Object {
    $Firmware = Get-VMFirmware -VMName $_.Name
    $Color = if ($Firmware.SecureBoot -eq "On") { "Green" } else { "Yellow" }
    Write-Host "$($_.Name): SecureBoot=$($Firmware.SecureBoot) Template=$($Firmware.SecureBootTemplate)" `
        -ForegroundColor $Color
}

# Enable Secure Boot on a Windows VM
Set-VMFirmware -VMName "MyWindowsVM" -EnableSecureBoot On `
    -SecureBootTemplate MicrosoftWindows

# Enable Secure Boot on a Linux VM (different template)
Set-VMFirmware -VMName "MyLinuxVM" -EnableSecureBoot On `
    -SecureBootTemplate MicrosoftUEFICertificateAuthority

# Available Secure Boot templates:
# - MicrosoftWindows              — for Windows guests
# - MicrosoftUEFICertificateAuthority  — for Linux guests
# - OpenSourceShieldedVM          — for open-source shielded scenarios
```

### Virtual TPM (vTPM)

A virtual TPM enables BitLocker, Windows Hello, and measured boot inside guest VMs. In Windows Server 2025, vTPM works with a **local key protector** — Host Guardian Service is not required.

```powershell
# ============================================================
# Virtual TPM Configuration
# ============================================================

# Add vTPM to a VM (VM must be off)
Stop-VM -Name "MyVM" -Force

# Create a local key protector (host-bound — no HGS needed)
Set-VMKeyProtector -VMName "MyVM" -NewLocalKeyProtector

# Enable the virtual TPM
Enable-VMTPM -VMName "MyVM"

Start-VM -Name "MyVM"

# Verify vTPM is enabled
Get-VMTPM -VMName "MyVM" | Format-List

# Enable vTPM on all Gen 2 VMs that don't have it
Get-VM | Where-Object { $_.Generation -eq 2 -and $_.State -eq 'Off' } | ForEach-Object {
    $TPM = Get-VMTPM -VMName $_.Name
    if (-not $TPM.Enabled) {
        Set-VMKeyProtector -VMName $_.Name -NewLocalKeyProtector
        Enable-VMTPM -VMName $_.Name
        Write-Host "Enabled vTPM on $($_.Name)" -ForegroundColor Green
    }
}
```

> **Important:** VMs with a local key protector are bound to the host that created the protector. They **cannot be live migrated** to another host. For VMs that need both vTPM and live migration, you need Host Guardian Service (see Advanced Protection below) or you need to accept the trade-off of removing vTPM on those VMs.

### Network Isolation

Use VLANs and port ACLs to isolate VM traffic:

```powershell
# ============================================================
# VM Network Security
# ============================================================

# Assign VMs to specific VLANs
Set-VMNetworkAdapterVlan -VMName "WebServer-01" -Access -VlanId 100
Set-VMNetworkAdapterVlan -VMName "DBServer-01" -Access -VlanId 200

# Add port ACLs to restrict traffic (example: block VM from management subnet)
Add-VMNetworkAdapterAcl -VMName "WebServer-01" `
    -RemoteIPAddress "10.10.10.0/24" `
    -Direction Outbound `
    -Action Deny

# Allow only specific traffic (example: allow web VM to talk to DB on port 1433)
Add-VMNetworkAdapterAcl -VMName "WebServer-01" `
    -RemoteIPAddress "10.10.200.0/24" `
    -Direction Outbound `
    -Action Allow

# View ACLs on a VM
Get-VMNetworkAdapterAcl -VMName "WebServer-01" | Format-Table Direction, Action, RemoteIPAddress -AutoSize

# Disable MAC address spoofing (default, but verify)
Set-VMNetworkAdapter -VMName "WebServer-01" -MacAddressSpoofing Off

# Enable DHCP guard (prevents rogue DHCP in VMs)
Set-VMNetworkAdapter -VMName "WebServer-01" -DhcpGuard On

# Enable Router guard (prevents rogue routing)
Set-VMNetworkAdapter -VMName "WebServer-01" -RouterGuard On
```

### Guest VBS (Virtualization-Based Security Inside VMs)

Windows Server 2025 enables guest VBS on Generation 2 VMs by default. This allows VBS features (Credential Guard, HVCI) to work inside VMs without nested virtualization:

```powershell
# Check if guest VBS is available for a VM
Get-VM -Name "MyVM" | Select-Object Name, VirtualizationBasedSecurityOptOut

# Ensure guest VBS is not opted out
Set-VM -Name "MyVM" -VirtualizationBasedSecurityOptOut $false
```

---

## Layer 4: Advanced Protection (Evaluate Carefully)

### Shielded VMs and Host Guardian Service

Shielded VMs provide the highest level of VM isolation available in Hyper-V. They encrypt VM state and virtual disks, prevent fabric administrators from inspecting VM contents, and use attestation to ensure VMs only run on approved hosts.

**What Shielded VMs protect against:**
- Compromised fabric administrators accessing VM data
- Unauthorized hosts running copies of the VM
- Offline attacks against VM disk files
- Inspection of VM memory from the host

**What you need to deploy Shielded VMs:**

| Requirement | Details |
|-------------|---------|
| **Host Guardian Service (HGS)** | Separate Windows Server cluster (3 nodes recommended) in its own AD forest |
| **TPM 2.0** | Required on all guarded hosts for TPM attestation |
| **UEFI Secure Boot** | Required on all guarded hosts |
| **Attestation mode** | TPM attestation (recommended) or Host Key attestation |
| **PKI** | Certificates for HGS communication |

> **Deprecated:** Admin-trusted attestation was deprecated in Windows Server 2019. Use TPM attestation or Host Key attestation.

**Honest assessment:** Shielded VMs and HGS add significant complexity. The HGS cluster is a separate AD forest with its own infrastructure requirements. TPM attestation requires managing attestation policies and code integrity policies across all guarded hosts. This makes sense for:
- Hosting providers running untrusted multi-tenant workloads
- Organizations with strict compliance requirements for VM isolation
- High-security environments where fabric admin compromise is in the threat model

For single-organization private clouds where you trust your infrastructure team, **vTPM with local key protector** (Layer 3) often provides sufficient protection without the operational overhead of HGS.

### HGS Readiness Assessment

Before committing to Shielded VMs, verify your readiness:

```powershell
# ============================================================
# HGS Readiness Check
# Run on each potential guarded host
# ============================================================

Write-Host "=== HGS Readiness Assessment ===" -ForegroundColor Cyan

# 1. TPM 2.0 check
$TPM = Get-Tpm
Write-Host "`n1. TPM:" -ForegroundColor White
Write-Host "   Present: $($TPM.TpmPresent)" -ForegroundColor $(if ($TPM.TpmPresent) { "Green" } else { "Red" })
Write-Host "   Ready: $($TPM.TpmReady)" -ForegroundColor $(if ($TPM.TpmReady) { "Green" } else { "Red" })
Write-Host "   Version: $((Get-CimInstance -Namespace root/cimv2/Security/MicrosoftTpm -ClassName Win32_Tpm).SpecVersion)"

# 2. UEFI Secure Boot
$SecureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
Write-Host "`n2. UEFI Secure Boot: $SecureBoot" -ForegroundColor $(if ($SecureBoot) { "Green" } else { "Red" })

# 3. VBS status
$VBS = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
Write-Host "`n3. Virtualization-Based Security:" -ForegroundColor White
Write-Host "   Status: $($VBS.VirtualizationBasedSecurityStatus)"
Write-Host "   Services Running: $($VBS.SecurityServicesRunning -join ', ')"

# 4. Hyper-V Host Guardian feature
$HGFeature = Get-WindowsFeature -Name HostGuardian
Write-Host "`n4. Host Guardian Feature:" -ForegroundColor White
Write-Host "   Installed: $($HGFeature.InstallState)" -ForegroundColor White
if ($HGFeature.InstallState -ne "Installed") {
    Write-Host "   Install with: Install-WindowsFeature HostGuardian -IncludeManagementTools" -ForegroundColor Yellow
}

# Summary
Write-Host "`n=== Assessment ===" -ForegroundColor Cyan
if ($TPM.TpmPresent -and $TPM.TpmReady -and $SecureBoot) {
    Write-Host "This host meets hardware requirements for HGS TPM attestation." -ForegroundColor Green
} else {
    Write-Host "This host does NOT meet all hardware requirements." -ForegroundColor Red
    Write-Host "Consider Host Key attestation as an alternative." -ForegroundColor Yellow
}
```

---

## Security Hardening Checklist

Use this checklist to track your hardening progress. Items are tiered by complexity:

### Tier 1 — Baseline (Every Environment)

| Item | Status |
|------|--------|
| Credential Guard enabled | ☐ |
| HVCI / Memory Integrity active | ☐ |
| Windows Defender with Hyper-V exclusions | ☐ |
| Unnecessary services disabled | ☐ |
| Windows Firewall enabled on all profiles | ☐ |
| SMB signing required (WS2025 default) | ☐ |
| SMB encryption enabled | ☐ |
| Live migration using Kerberos (not CredSSP) | ☐ |
| Secure Boot enabled on all Gen 2 VMs | ☐ |
| VM DHCP Guard and Router Guard enabled | ☐ |
| Administrative access limited to specific groups | ☐ |
| Audit logging enabled for cluster operations | ☐ |

### Tier 2 — Enhanced (Recommended for Production)

| Item | Status |
|------|--------|
| vTPM enabled on Gen 2 VMs (local key protector) | ☐ |
| BitLocker on CSV volumes (data at rest encryption) | ☐ |
| VM network isolation via VLANs | ☐ |
| Port ACLs on VM network adapters | ☐ |
| Guest VBS enabled in VMs | ☐ |
| SMB encryption ciphers set to AES-256-GCM | ☐ |
| Firewall logging enabled | ☐ |

### Tier 3 — Advanced (Evaluate Based on Threat Model)

| Item | Status |
|------|--------|
| Host Guardian Service deployed | ☐ |
| TPM attestation configured | ☐ |
| Shielded VMs for sensitive workloads | ☐ |
| Code integrity policies on guarded hosts | ☐ |

---

## Compliance Mapping

If you're subject to compliance frameworks, here's how Hyper-V security features map:

| Requirement | CIS Benchmark | NIST 800-53 | Feature |
|-------------|---------------|-------------|---------|
| Credential protection | 18.x (Credential Guard) | IA-5 | Credential Guard |
| Encryption at rest | 18.x (BitLocker) | SC-28 | BitLocker on CSV |
| Encryption in transit | 18.x (SMB signing/encryption) | SC-8 | SMB encryption |
| Boot integrity | 18.x (Secure Boot) | SI-7 | Secure Boot, HVCI |
| Access control | 1.x (Account policies) | AC-2, AC-3 | AD groups, cluster ACLs |
| Audit logging | 17.x (Audit policies) | AU-2 | Event logs, audit policies |
| Network segmentation | 9.x (Firewall rules) | SC-7 | VLANs, port ACLs, firewall |

> **Reference:** The CIS Benchmark for Windows Server 2025 (v1.0.0, released March 2025) provides specific hardening recommendations. Download from [cisecurity.org](https://www.cisecurity.org/benchmark/microsoft_windows_server).

---

## Next Steps

Your cluster is now hardened at the host, cluster, and VM levels. But security configuration is only as good as your ability to manage it at scale. In the next post, **[Post 11: Management Tools for Production](/post/management-tools-hyperv)**, we'll cover the management tooling landscape — WAC, SCVMM, Failover Cluster Manager, and PowerShell remoting patterns — so you can operate your secured environment efficiently.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)

### Microsoft Documentation
- [Credential Guard overview](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/)
- [Enable memory integrity (HVCI)](https://learn.microsoft.com/en-us/windows/security/hardware-security/enable-virtualization-based-protection-of-code-integrity)
- [Guarded fabric and shielded VMs overview](https://learn.microsoft.com/en-us/windows-server/security/guarded-fabric-shielded-vm/guarded-fabric-and-shielded-vms)
- [Generation 2 VM security features](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/generation-2-virtual-machine-security-features)
- [SMB security enhancements](https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-security)
- [Antivirus exclusions for Hyper-V hosts](https://learn.microsoft.com/en-us/troubleshoot/windows-server/virtualization/antivirus-exclusions-for-hyper-v-hosts)
- [BitLocker on Cluster Shared Volumes](https://learn.microsoft.com/en-us/windows-server/failover-clustering/bitlocker-on-csv-in-ws-2022)
- [CIS Microsoft Windows Server 2025 Benchmark](https://www.cisecurity.org/benchmark/microsoft_windows_server)

---

**Series Navigation**
← Previous: [Post 9 — Monitoring and Observability](/post/hyper-v-monitoring-observability)
→ Next: [Post 11 — Management Tools for Production](/post/management-tools-hyperv)

---
