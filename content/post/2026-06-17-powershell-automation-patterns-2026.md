---
title: "PowerShell Automation Patterns (2026 Edition)"
description: PowerShell 7 automation for Hyper-V — DSC v3, idempotent modules, CI/CD pipelines, and SecretManagement.
date: 2026-04-04T08:00:00.000Z
series: The Hyper-V Renaissance
series_post: 19
series_total: 20
draft: true
preview: /img/hyper-v-renaissance/banner-main.png
fmContentType: post
slug: hyper-v-powershell-automation-2026
lead: DSC v3, Idempotent Modules, and CI/CD for Infrastructure
thumbnail: /img/hyper-v-renaissance/banner-main.png
categories:
    - Azure
tags:
    - PowerShell
    - Ansible
    - Azure
    - Azure DevOps
    - Windows Server
lastmod: 2026-04-04T17:48:14.534Z
---

"PowerShell Returned to Its Throne" isn't just a series tagline. It's the architectural reality.

Every post in this series has used PowerShell for configuration, validation, and management. But there's a difference between running scripts manually and building an automation practice. Manual scripts are better than clicking through GUIs, but they're still manual — someone has to run them, remember the parameters, hope the environment hasn't drifted since last time.

This post bridges that gap. We'll build a structured automation framework that makes your Hyper-V infrastructure reproducible, testable, and pipeline-driven — using PowerShell 7, DSC v3, idempotent module patterns, and CI/CD pipelines that work with GitHub Actions, GitLab CI, and Azure DevOps.

In this nineteenth post of the **Hyper-V Renaissance** series, we'll turn the scripts from the entire series into a professional automation practice.

> **Repository:** The complete module, DSC configurations, CI/CD pipeline examples, and variable templates are in the [series repository](https://github.com/thisismydemo/hyper-v-renaissance/tree/main/04-strategy-automation/post-19-powershell-automation).

---

## The Automation Architecture

![PowerShell Automation Architecture](/img/hyper-v-renaissance/ps-automation-architecture.svg)

The framework has four layers:

| Layer | Purpose | Components |
|-------|---------|------------|
| **Configuration** | Define desired state | Variable files, DSC configurations, naming standards |
| **Modules** | Reusable, idempotent functions | PowerShell module with Get/Test/Set pattern |
| **Orchestration** | Execute across hosts | PSRemoting, CIM sessions, pipeline triggers |
| **Pipelines** | CI/CD integration | GitHub Actions, GitLab CI, Azure DevOps |

---

## PowerShell 7 — The Runtime

All automation in this framework targets **PowerShell 7.4+ LTS** (pwsh). On Windows Server 2025, both the Hyper-V and FailoverClusters modules run natively in PowerShell 7 — no compatibility shims required.

**Why PowerShell 7:**
- Cross-platform (management scripts run from Linux/macOS management stations)
- Pipeline parallelism (`ForEach-Object -Parallel`)
- Improved error handling (`$ErrorActionPreference` with `$PSNativeCommandUseErrorActionPreference`)
- Ternary operator, null-coalescing, pipeline chain operators
- Active development (PS 5.1 is maintenance-only)

Every script in the companion repository starts with:

```powershell
#Requires -Version 7.0
#Requires -RunAsAdministrator
```

---

## Naming Standards — CAF/WAF for On-Prem

Before writing any automation, establish naming conventions. We adapt Microsoft's Cloud Adoption Framework pattern for on-premises resources:

**Pattern:** `<type>-<workload>-<environment>-<site>-<instance>`

| Resource | Convention | Example |
|----------|-----------|---------|
| **Hyper-V host** | `hv-<role>-<env>-<site>-<###>` | `hv-host-prod-sea01-001` |
| **Cluster** | `cl-<workload>-<env>-<site>` | `cl-hvhost-prod-sea01` |
| **VM** | `vm-<workload>-<env>-<site>-<###>` | `vm-sql-prod-sea01-001` |
| **Virtual switch** | `vsw-<purpose>` | `vsw-set-prod` |
| **CSV volume** | `csv-<tier>-<###>` | `csv-tier1-001` |
| **vNIC** | `vnic-<traffic>` | `vnic-mgmt`, `vnic-migration`, `vnic-storage` |

**NetBIOS constraint:** Hostnames are limited to 15 characters. Abbreviate site codes and use numeric instances.

These conventions are defined in a central variables file that all automation scripts consume.

---

## The Variables File — Single Source of Truth

Every script in the framework pulls configuration from a central variables file. No hardcoded values. Override at runtime with parameters.

The companion repository includes `variables/` templates:

```
04-strategy-automation/post-19-powershell-automation/
  variables/
    environment.prod.json       # Production environment config
    environment.dev.json        # Dev/test environment config
    environment.template.json   # Template for new environments
```

**Structure** (JSON consumed by `ConvertFrom-Json`):

```json
{
  "environment": {
    "name": "prod",
    "site": "sea01",
    "domain": "yourdomain.local"
  },
  "naming": {
    "hostPrefix": "hv-host",
    "clusterPrefix": "cl-hvhost",
    "vmPrefix": "vm",
    "switchName": "vsw-set-prod"
  },
  "network": {
    "management": { "vlanId": 10, "subnet": "10.10.10.0/24", "gateway": "10.10.10.1" },
    "migration":  { "vlanId": 20, "subnet": "10.10.20.0/24" },
    "storage":    { "vlanId": 30, "subnet": "10.10.30.0/24" }
  },
  "storage": {
    "iscsiTargets": ["10.10.30.100", "10.10.30.101"],
    "csvAllocationUnit": 65536,
    "mpioPolicy": "RR"
  },
  "cluster": {
    "name": "cl-hvhost-prod-sea01",
    "ip": "10.10.10.20",
    "quorumType": "CloudWitness",
    "nodes": ["hv-host-prod-sea01-001", "hv-host-prod-sea01-002"]
  }
}
```

**Loading in scripts:**

```powershell
param(
    [string]$EnvironmentFile = "$PSScriptRoot/variables/environment.prod.json",
    [string]$HostName        # Override: takes precedence over file
)

$Config = Get-Content $EnvironmentFile | ConvertFrom-Json

# Parameter overrides take precedence
$EffectiveHostName = if ($HostName) { $HostName }
                     else { "$($Config.naming.hostPrefix)-$($Config.environment.name)-$($Config.environment.site)-001" }
```

---

## Module Architecture — The Get/Test/Set Pattern

The core of the automation framework is a PowerShell module that follows the **Get/Test/Set** pattern — the same pattern DSC resources use. Every function has three variants:

- **Get-** — returns current state
- **Test-** — returns `$true` if current state matches desired state, `$false` if not
- **Set-** — applies desired state (only if Test returns `$false`)

This makes every function **idempotent** — safe to run repeatedly without side effects.

### Module Structure

```
modules/HVAutomation/
  HVAutomation.psd1              # Module manifest
  HVAutomation.psm1              # Module loader (dot-sources Public/Private)
  Public/
    Get-HVHostState.ps1          # Returns current host config
    Test-HVHostState.ps1         # Validates host matches desired state
    Set-HVHostState.ps1          # Applies desired host configuration
    Get-HVNetworkState.ps1       # Returns current network config
    Test-HVNetworkState.ps1      # Validates network matches desired state
    Set-HVNetworkState.ps1       # Applies desired network configuration
    Get-HVStorageState.ps1       # Returns current storage config
    Test-HVStorageState.ps1      # Validates storage matches desired state
    Set-HVStorageState.ps1       # Applies desired storage configuration
    New-HVClusterVM.ps1          # Creates a VM following naming standards
  Private/
    Resolve-HVNamingConvention.ps1  # Generates names from config
    Write-HVLog.ps1                 # Structured logging helper
    Import-HVConfig.ps1             # Config file loader with validation
  Tests/
    HVAutomation.Tests.ps1       # Pester 5.x integration tests
```

### Example: Idempotent Network Configuration

```powershell
function Test-HVNetworkState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Config
    )

    $desired = $Config.network
    $switchName = $Config.naming.switchName

    # Check SET switch exists
    $switch = Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue
    if (-not $switch) { return $false }

    # Check vNICs exist with correct VLANs
    foreach ($traffic in @('management', 'migration', 'storage')) {
        $vnic = Get-VMNetworkAdapter -ManagementOS -Name $traffic -ErrorAction SilentlyContinue
        if (-not $vnic) { return $false }

        $vlan = Get-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName $traffic
        if ($vlan.AccessVlanId -ne $desired.$traffic.vlanId) { return $false }
    }

    return $true
}

function Set-HVNetworkState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Config
    )

    if (Test-HVNetworkState -Config $Config) {
        Write-Verbose "Network already in desired state. No changes needed."
        return
    }

    # Apply network configuration...
    # (Full implementation in companion repository)
}
```

The key: `Set-HVNetworkState` calls `Test-HVNetworkState` first. If the state already matches, it returns without changes. This is idempotency.

---

## DSC v3 — Desired State Configuration for 2026

DSC has evolved significantly. Here's the landscape in 2026:

| Version | Status | Engine | Config Format | Best For |
|---------|--------|--------|---------------|----------|
| **DSC v2** | Mature, maintenance mode | WMI-based LCM (Windows only) | PowerShell → MOF | Existing DSC investments, large resource ecosystem |
| **DSC v3** | GA (v3.0.0 March 2025, v3.1 June 2025) | Rust CLI (`dsc.exe`), cross-platform | YAML / JSON | New greenfield, CI/CD-triggered, cross-platform |
| **Azure Machine Configuration** | GA (uses DSC v2 internally) | Azure Policy + Arc | PowerShell → MOF → Azure | Azure-managed compliance (requires Arc) |

### DSC v3 — What Changed

DSC v3 is a complete rewrite:

- **No LCM.** No background service, no pull server. You invoke `dsc.exe` explicitly — from a script, a scheduled task, or a CI/CD pipeline.
- **No MOF files.** Configurations are YAML or JSON, not compiled PowerShell.
- **Cross-platform.** Runs on Linux and macOS, not just Windows.
- **Resource adapters.** DSC v3 can consume existing v2 resources via adapters, so your investment in DSC v2 resources carries forward.

### DSC v3 Configuration Example — Hyper-V Host

```yaml
# dsc-config/hyperv-host.dsc.yaml
# Desired State Configuration for a Hyper-V cluster node
$schema: https://raw.githubusercontent.com/PowerShell/DSC/main/schemas/2024/04/config/document.json
resources:
  - name: Ensure Hyper-V role
    type: Microsoft.Windows/WindowsFeature
    properties:
      featureName: Hyper-V
      ensure: Present

  - name: Ensure Failover Clustering
    type: Microsoft.Windows/WindowsFeature
    properties:
      featureName: Failover-Clustering
      ensure: Present

  - name: Ensure MPIO
    type: Microsoft.Windows/WindowsFeature
    properties:
      featureName: Multipath-IO
      ensure: Present

  - name: Ensure iSCSI service running
    type: Microsoft.Windows/Service
    properties:
      serviceName: MSiSCSI
      startupType: Automatic
      state: Running
```

Apply with: `dsc config set --file hyperv-host.dsc.yaml`
Test with: `dsc config test --file hyperv-host.dsc.yaml`

### Recommended Approach

For this series' audience (on-premises Hyper-V, WS2025):

- **Use DSC v3** for new automation where you want CI/CD-triggered configuration (YAML is pipeline-friendly)
- **Keep DSC v2** for existing configurations that work — migration isn't urgent
- **Use Azure Machine Configuration** only if hosts are Arc-enrolled and you need Azure Policy compliance reporting
- **Combine with the Get/Test/Set module** — DSC handles role installation and service state; the module handles Hyper-V-specific configuration (switches, VLANs, storage) that DSC doesn't cover natively

---

## Secrets Management — No Hardcoded Credentials

The `Microsoft.PowerShell.SecretManagement` module provides a unified API for retrieving secrets from any vault backend. Never hardcode credentials in scripts.

| Vault Extension | Backend | Use Case |
|-----------------|---------|----------|
| `SecretStore` | Local encrypted file | Development, single-host scripts |
| `Az.KeyVault` | Azure Key Vault | Shared secrets across teams (requires Azure) |
| `SecretManagement.HashiCorp.Vault.KV` | HashiCorp Vault | Multi-platform, on-prem vault |
| `SecretManagement.KeePass` | KeePass database | Teams already using KeePass |

**Usage in automation scripts:**

```powershell
# One-time setup (per host)
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
Register-SecretVault -Name 'HVAutomation' -ModuleName 'Microsoft.PowerShell.SecretStore'
Set-Secret -Name 'DomainJoinCred' -Secret (Get-Credential)

# In automation scripts
$cred = Get-Secret -Name 'DomainJoinCred' -Vault 'HVAutomation'
Add-Computer -DomainName $Config.environment.domain -Credential $cred
```

---

## CI/CD Pipelines — Infrastructure as Code in Practice

The final layer connects your automation to version-controlled pipelines. When a configuration change is committed, the pipeline validates and applies it — no manual intervention.

### Architecture

All three CI/CD platforms use the same pattern: a **self-hosted runner** on your on-premises network that executes PowerShell against your Hyper-V hosts.

| Platform | Self-Hosted Component | Configuration File |
|----------|----------------------|-------------------|
| **GitHub Actions** | GitHub Actions Runner (Windows service) | `.github/workflows/deploy.yml` |
| **GitLab CI** | GitLab Runner (shell executor) | `.gitlab-ci.yml` |
| **Azure DevOps** | Azure Pipelines Agent (Windows service) | `azure-pipelines.yml` |

The self-hosted runner sits on a management server in your network (the same server where you'd run WAC, not on a Hyper-V host). It has PowerShell remoting access to all Hyper-V hosts.

### Pipeline Flow

```
Developer commits config change → Pipeline triggers →
Self-hosted runner picks up job →
Runner loads variables file →
Runner invokes Test-HVHostState on target hosts →
If drift detected: Runner invokes Set-HVHostState →
Runner runs Pester validation tests →
Pipeline reports success/failure
```

### GitHub Actions Example

The companion repository includes complete pipeline definitions for all three platforms. Here's the GitHub Actions pattern:

```yaml
# .github/workflows/validate-hosts.yml
name: Validate Hyper-V Host Configuration
on:
  push:
    paths: ['variables/**', 'modules/**', 'dsc-config/**']
  workflow_dispatch:

jobs:
  validate:
    runs-on: [self-hosted, windows, hyperv-mgmt]
    steps:
      - uses: actions/checkout@v4

      - name: Load configuration
        shell: pwsh
        run: |
          $Config = Get-Content ./variables/environment.prod.json | ConvertFrom-Json
          echo "CLUSTER_NAME=$($Config.cluster.name)" >> $env:GITHUB_ENV

      - name: Test host state
        shell: pwsh
        run: |
          Import-Module ./modules/HVAutomation/HVAutomation.psd1
          $Config = Get-Content ./variables/environment.prod.json | ConvertFrom-Json
          foreach ($node in $Config.cluster.nodes) {
            $result = Invoke-Command -ComputerName $node -ScriptBlock {
              param($cfg)
              Import-Module HVAutomation
              Test-HVHostState -Config $cfg
            } -ArgumentList $Config
            if (-not $result) {
              Write-Error "Host $node has configuration drift"
              exit 1
            }
          }
          Write-Host "All hosts match desired state"

      - name: Run Pester tests
        shell: pwsh
        run: |
          Invoke-Pester ./modules/HVAutomation/Tests/ -Output Detailed -CI
```

### GitLab CI and Azure DevOps

The companion repository includes equivalent pipeline definitions:

- `.gitlab-ci.yml` — GitLab CI with shell executor on Windows runner
- `azure-pipelines.yml` — Azure DevOps with self-hosted agent pool

All three follow the same pattern: checkout → load config → test state → remediate (if configured) → validate with Pester.

---

## Toolkit Directory Structure

The companion repository organizes everything for real-world use:

```
04-strategy-automation/post-19-powershell-automation/
├── modules/
│   └── HVAutomation/
│       ├── HVAutomation.psd1
│       ├── HVAutomation.psm1
│       ├── Public/
│       ├── Private/
│       └── Tests/
├── dsc-config/
│   ├── hyperv-host.dsc.yaml        # DSC v3: role and service configuration
│   ├── hyperv-security.dsc.yaml    # DSC v3: security baseline
│   └── README.md
├── variables/
│   ├── environment.prod.json
│   ├── environment.dev.json
│   └── environment.template.json
├── pipelines/
│   ├── github-actions/
│   │   └── validate-hosts.yml
│   ├── gitlab-ci/
│   │   └── .gitlab-ci.yml
│   └── azure-devops/
│       └── azure-pipelines.yml
├── scripts/
│   ├── Deploy-HyperVHost.ps1       # Orchestrator: full host deployment
│   ├── Test-EnvironmentDrift.ps1   # Drift detection across all hosts
│   └── New-EnvironmentReport.ps1   # Capacity and compliance report
└── README.md
```

---

## Putting It Together — The Automation Maturity Path

| Level | Practice | Tools |
|-------|----------|-------|
| **1. Scripts** | Manual PowerShell execution | Ad-hoc scripts, no version control |
| **2. Structured Scripts** | Variables file, consistent naming | JSON config, parameterized scripts |
| **3. Modules** | Get/Test/Set idempotent functions | HVAutomation module, Pester tests |
| **4. DSC** | Declarative desired state | DSC v3 YAML configs, drift detection |
| **5. Pipelines** | CI/CD-triggered automation | GitHub/GitLab/Azure DevOps, self-hosted runners |

You don't need to jump to Level 5 on day one. Start at Level 2 (variables file + naming standards) and grow. Each level builds on the previous one. The companion repository supports all five levels.

---

## Next Steps

PowerShell is the automation foundation. But it's not the only IaC tool in the ecosystem. In the final post of the series, **[Post 20: Infrastructure as Code with Ansible and Terraform](/post/hyper-v-iac-ansible-terraform)**, we'll cover Ansible playbooks for Windows/Hyper-V management and the Terraform community provider — with an honest assessment of maturity and when each tool makes sense alongside or instead of PowerShell.

PowerShell returned to its throne. The question is how far you take it.

---

## Resources

- **Series Repository:** [github.com/thisismydemo/hyper-v-renaissance](https://github.com/thisismydemo/hyper-v-renaissance)

### Microsoft Documentation
- [PowerShell 7 module compatibility — Windows Server 2025](https://learn.microsoft.com/en-us/powershell/windows/module-compatibility?view=windowsserver2025-ps)
- [DSC v3 announcement](https://devblogs.microsoft.com/powershell/announcing-dsc-v3/)
- [DSC v3 on Windows Server 2025](https://techcommunity.microsoft.com/blog/itopstalkblog/using-desired-state-configuration-dsc-v3-on-windows-server-2025/4415382)
- [SecretManagement module overview](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview)
- [CAF naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [CAF resource abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

### Community
- [Pester testing framework](https://pester.dev/)
- [DSC Community resources](https://dsccommunity.org/)
- [GitHub Actions self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)

---

**Series Navigation**
← Previous: [Post 18 — S2D vs. Three-Tier and Azure Local](/post/hyper-v-s2d-three-tier-azure-local)
→ Next: [Post 20 — Infrastructure as Code with Ansible and Terraform](/post/hyper-v-iac-ansible-terraform)

---
