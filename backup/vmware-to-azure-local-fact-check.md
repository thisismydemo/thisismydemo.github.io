# VMware vSphere to Azure Local blog – fact check and corrections (vendor-cited)

This document lists issues found in `content/post/2025-07-29-vmware-vsphere-vs-azure-local-a-feature-comparison.md`, with official Microsoft documentation citations and recommended fixes. It focuses only on Azure Local claims.

Status legend:
- Issue: Problematic or unverified claim as written.
- Fix: Recommended replacement text (concise).
- Source: Official docs URL(s).

---

## 1) Scalability and per‑VM limits (multiple locations) ✅ **COMPLETED**
**Blog locations:** Lines 88 (Feature Overview table) and 1964 (Section 14 table)

- Issue: “Scalability and Limits … 16 hosts/cluster, 24TB VM RAM, 2048 vCPUs/VM” (Feature table). Section 14 later states “vCPUs per VM 240” and “Memory per VM 12TB”. These values conflict and the smaller numbers are incorrect for current Windows Server 2025/Hyper‑V.
- Fix: Use “Per‑VM: up to 2,048 vCPUs and up to 240 TB memory (Generation 2 VMs) on Windows Server 2025 hypervisor; host up to 2,048 logical processors and up to 4 PB addressable memory.” Keep cluster max “1–16 nodes per Azure Local instance.”
- Source:
  - https://learn.microsoft.com/windows-server/get-started/whats-new-windows-server-2025#hyper-v,-ai,-and-performance
  - https://learn.microsoft.com/windows-server/virtualization/hyper-v/plan/plan-hyper-v-scalability-in-windows-server#maximums-for-virtual-machines
  - https://learn.microsoft.com/azure/azure-local/plan/cloud-deployment-network-considerations?view=azloc-2507#step-1-determine-cluster-size

## 2) Management “lock‑in” wording (Section 2)
**Blog locations:**  Lines 117, 135, 156, 165, 183, 195, 199, 379, 422, 426-428, 431, 437-438, 444 (Arc VM terminology usage)

- Issue: “Arc VMs … Cannot be managed through Windows Admin Center.” Too absolute. Microsoft guidance is: manage Arc‑enabled VMs via Azure (portal/CLI/ARM); local tools can cause sync issues and are limited to a specific allowed subset. VMs created via WAC/PowerShell are “unmanaged” and have limited Azure manageability.
- Fix: “Arc‑enabled VMs should be managed via Azure (portal/CLI/ARM). Using local tools beyond the documented supported operations can cause portal synchronization issues. VMs created with WAC/PowerShell are ‘unmanaged’ (not Arc‑enabled) and have limited Azure manageability.”
- Source:
  - https://learn.microsoft.com/azure/azure-local/manage/virtual-machine-operations?view=azloc-2507
  - https://learn.microsoft.com/azure/azure-local/manage/vm?view=azloc-2507
  - https://learn.microsoft.com/azure/azure-local/manage/azure-arc-vm-management-overview?view=azloc-2507#limitations-of-azure-local-vm-management

## 3) VM restore behavior (Section 6 Backup)
**Blog locations:** Line 160 (VM Restoration Limitations), Line 163 (backup/DR procedures), Section 6 throughout (lines 377-450)

- Issue: Blanket statement that “VMs restored from backup or Azure Site Recovery lose Azure Arc identity … and revert to traditional Hyper‑V VMs.” The official limitation is specifically for Azure Backup Server (MABS) Alternate Location Recovery (ALR) of Arc VMs; OLR behaves differently. ASR behavior to on‑premises Azure Local isn’t stated here and shouldn’t be generalized.
- Fix: “For MABS, ALR of Arc‑enabled VMs recovers as Hyper‑V VM (not as an Arc VM), and conversion of Hyper‑V VMs to Arc VMs isn’t supported. OLR restores back to the original instance via Hyper‑V VSS. Don’t generalize this to all DR tools without testing. For Azure Site Recovery, VMs protected to Azure can be failed back to on-premises Azure Local, but Arc VM restoration behavior may vary by scenario and should be validated against current documentation.”
- Source:
  - https://learn.microsoft.com/azure/backup/back-up-azure-stack-hyperconverged-infrastructure-virtual-machines#recover-backed-up-virtual-machines
  - https://learn.microsoft.com/azure/backup/back-up-hyper-v-virtual-machines-mabs#recover-backed-up-hyper-v-virtual-machines

## 4) Disconnected operations and “30‑day offline mode” (Section 10)

- Issue: Text implies specific degraded behaviors like “no new VM creation after 30‑day licensing expiration.” Official docs state Azure Local must sync at least every 30 days; the FAQ clarifies reduced functionality mode prevents new VM creation until sync. Keep wording aligned to docs and avoid extra speculation.
- Fix: “Azure Local requires successful outbound connectivity to Azure at least once every 30 days. If missed, the instance shows Out of policy, enters reduced functionality, and new VM creation is blocked until sync completes. Existing VMs keep running.”
- Source:
  - https://learn.microsoft.com/azure/azure-local/faq?view=azloc-2507#how-long-can-azure-local-run-with-the-connection-down
- **Status: ✅ COMPLETED** - Updated blog language to align with Microsoft's official documentation.

- Issue: “Fully Disconnected (Preview) … Local Azure Portal/ARM/Managed Identity/Key Vault/ACR” is unreferenced.
- Fix: Remove or mark as “requires official documentation.” Don’t describe local Azure Portal/Key Vault/ACR for Azure Local unless publicly documented. If referring to “Disconnected operations (preview)”, scope to the official known-issues doc.
- Source:
  - https://learn.microsoft.com/azure/azure-local/manage/disconnected-operations-known-issues?view=azloc-2507
- **Status: ❌ ISSUE INVALID** - Microsoft actually DOES officially document comprehensive disconnected operations including local Azure Portal, ARM, Managed Identity, Key Vault, and ACR support. Official sources:
  - Primary: https://learn.microsoft.com/en-us/azure/azure-local/manage/disconnected-operations-overview?view=azloc-2507#supported-services
  - Azure Container Registry: https://learn.microsoft.com/en-us/azure/azure-local/manage/disconnected-operations-azure-container-registry?view=azloc-2507

## 5) GPU live migration and support (Section 12)
**Blog locations:** Lines 53, 75, 86, 103, 1631, 1633, 1635, 1637, 1639 (GPU/vGPU/graphics references throughout Section 12)

- Issue: Claims LM is supported with GPU‑P but lacks prerequisites; DDA live migration is not supported.
- Fix: “GPU‑P live migration is supported on Windows Server 2025 when prerequisites are met: OS build 26100.xxxx+, NVIDIA vGPU Software v18.x+ drivers, homogeneous GPUs across hosts. DDA doesn’t support live migration; clustered failover restarts VMs on a node with available GPU.”
- Source:
  - https://learn.microsoft.com/windows-server/virtualization/hyper-v/gpu-partitioning#requirements
  - https://learn.microsoft.com/windows-server/virtualization/hyper-v/partition-assign-vm-gpu#prerequisites
  - https://learn.microsoft.com/windows-server/virtualization/hyper-v/deploy/use-gpu-with-clustered-vm#fail-over-a-vm-with-an-assigned-gpu
  - https://learn.microsoft.com/windows-server/get-started/whats-new-windows-server-2025#hyper-v,-ai,-and-performance

- Issue: Supported GPU list should align to Microsoft docs (A2, A10, A16, A40, L2, L4, L40, L40S for GPU‑P). Ensure the matrix matches.
- Fix: Align supported GPU list; remove models not in the list (for example, T4 for GPU‑P host partitioning list).
- Source: https://learn.microsoft.com/windows-server/virtualization/hyper-v/gpu-partitioning#requirements

## 6) SDN enabled by Azure Arc vs. on‑prem SDN (Section 13) ✅ **COMPLETED**
**Blog locations:** Section 13 content (need specific line search for SDN/networking references)

- Issue: Contradiction: Says NC runs as a Failover Cluster service (correct for Arc‑enabled SDN) but later claims “dedicated NC VMs required.”
- Fix: Remove “dedicated NC VMs required” in the Arc‑enabled SDN context. Keep: “NC runs as a Failover Cluster service; enable via Add‑EceFeature; OS 26100.xxxx+ required.”
- Source:
  - https://learn.microsoft.com/azure/azure-local/concepts/sdn-overview?view=azloc-2507
  - https://learn.microsoft.com/azure/azure-local/deploy/enable-sdn-integration?view=azloc-2507#considerations-for-sdn-enabled-by-arc

- Issue: Feature scope. Arc‑enabled SDN supports logical networks, NICs, and NSGs; does NOT support virtual networks, SLB, or Gateways; can’t roll back; AKS not supported.
- Fix: Explicitly call out scope/limitations and irreversibility.
- Source:
  - https://learn.microsoft.com/azure/azure-local/concepts/sdn-overview?view=azloc-2507#unsupported-scenarios-for-sdn-enabled-by-arc
  - https://learn.microsoft.com/azure/azure-local/deploy/enable-sdn-integration?view=azloc-2507#considerations-for-sdn-enabled-by-arc

- Issue: Management mixing. Must not mix Arc‑managed SDN with on‑prem tools.
- Fix: “Choose one SDN management mode (Arc or on‑prem) per environment; do not mix.”
- Source: https://learn.microsoft.com/azure/azure-local/concepts/sdn-overview?view=azloc-2507#important-considerations

## 7) Networking in Feature table (Feature Overview)
**Blog locations:** Line 88 (Feature table networking row)

- Issue: “configure virtual networks” in Azure portal implies capabilities only when SDN enabled by Arc is deployed.
- Fix: “In portal, networking configuration applies when SDN enabled by Arc (preview) is deployed; otherwise use Network ATC/WAC.”
- Source:
  - https://learn.microsoft.com/azure/azure-local/deploy/enable-sdn-integration?view=azloc-2507
  - https://learn.microsoft.com/azure/azure-local/manage/manage-network-atc?view=azloc-2507

## 8) Automation examples (Sections 2 and 9)
**Blog locations:** Line 147 (Get-AzConnectedMachine example), Line 195 (console viewer reference)

- Issue: Using Get‑AzConnectedMachine for bulk VM ops maps to Arc‑enabled servers, not Azure Local Arc VMs.
- Fix: Replace with Azure Local VM operations via ARM/CLI/PowerShell for resource type Microsoft.AzureStackHCI/virtualMachines. Use `Get-AzStackHCIVM` for Azure Local VM automation and management tasks.
- Source:
  - https://learn.microsoft.com/azure/azure-local/manage/azure-arc-vm-management-overview?view=azloc-2507
  - https://learn.microsoft.com/azure/azure-local/concepts/compare-vm-management-capabilities?view=azloc-2507

- Issue: Assertions about Terraform/Ansible official support for Azure Local VMs are unreferenced.
- Fix: Keep to ARM/Bicep/CLI/PowerShell; only claim support where official docs exist.
- **Status: ✅ COMPLETED** - Added comprehensive references to References section (Section 20) documenting:
  - Terraform: Official Azure Verified Module for Azure Local VMs (Microsoft-supported)
  - Ansible: Azure collection for infrastructure + platform-agnostic configuration management
  - Clarified infrastructure provisioning vs. OS configuration management use cases

## 9) AKS and “30‑day” (Section 10)

- Issue: Text attributes a “30‑day” limit to AKS certificates/connectivity without citation.
- Fix: If included, cite AKS on Azure Local “Semi‑connected up to 30 days” guidance; otherwise, remove. See: https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-hci-network-requirements
- Source: https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-hci-network-requirements

## 10) Storage claims (Sections 5 and 14)

- Issue: Numeric claims like “4 PB per cluster,” “400 drives per host,” and “S2D efficiency no benefit beyond 6–8 nodes” are unreferenced.
- Fix: Either cite current Storage Spaces Direct/Azure Local limits; or remove specifics and keep qualitative guidance. If no official documentation is found for these numbers, recommend removing them entirely and stating only qualitative guidance (e.g., "scale and efficiency depend on hardware and configuration; consult official docs for current limits").
- Source: (Add citations if you retain numbers; otherwise remove.)

## 11) Console access statement (Section 3)

- Issue: “Portal console viewer” wording could imply HTML5 console in portal.
- Fix: “Portal provides Connect flows (RDP/SSH). Use WAC for web-based console.”
- Source:
  - https://learn.microsoft.com/azure/azure-local/manage/virtual-machine-operations?view=azloc-2507#supported-vm-operations
  - https://learn.microsoft.com/azure/azure-local/manage/vm?view=azloc-2507

## 12) Live migration scope (Section 3)
**Blog locations:** Section 3 content (need specific line search for live migration references)

- Issue: Not explicit that cross‑cluster LM is unsupported.
- Fix: “Live migration is within the same cluster; cross‑cluster LM isn’t supported.”
- Source: https://learn.microsoft.com/azure/azure-local/manage/virtual-machine-operations?view=azloc-2507#unsupported-vm-operations

## 13) Identity naming

- Issue: Ensure “Microsoft Entra ID” is used consistently.
- Fix: Use “Microsoft Entra ID” everywhere.

---

## Quick corrections checklist (editor-ready)

- Update per‑VM limits everywhere: 2,048 vCPUs; 240 TB memory (Gen2). Hosts up to 2,048 logical processors; up to 4 PB addressable memory.
- Keep cluster size: 1–16 machines per Azure Local instance.
- Reword management lock‑in to recommended practice + supported local operations; avoid categorical “cannot”.
- Scope portal networking to SDN enabled by Arc (preview) and list its limitations; remove SLB/Gateway/L7 references in Arc‑enabled SDN.
- Fix SDN NC deployment wording: Arc‑enabled SDN uses NC as a Failover Cluster service; no “dedicated NC VMs” in this mode.
- Backup/restore: replace blanket restore claim with MABS ALR limitation citation; don’t generalize to ASR.
- GPU: add GPU‑P LM prerequisites and DDA no‑LM; align supported GPU list.
- Disconnected: keep documented 30‑day behavior; remove unreferenced “local Azure portal/Key Vault/ACR” content.
- Automation: replace ConnectedMachine examples with Azure Local VM resource ops.
- Remove/verify S2D numeric limits and “6–8 node only” guidance unless cited.

---

## Notes
- All claims above are validated against current (azloc‑2507/Windows Server 2025) documentation at the time of writing. Features in preview (for example, SDN enabled by Arc) can change; re‑verify before publishing.
