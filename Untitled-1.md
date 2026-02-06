# The Hyper-V Renaissance: Complete Blog Series Plan

**Series Tagline:** *PowerShell Returned to Its Throne*

**Purpose:** Demonstrate Hyper-V's capabilities as a mature, cost-effective virtualization platform, contrast costs against VMware and Azure Local, and provide practical guidance for organizations evaluating alternatives.

**Target Audience:** IT professionals, infrastructure architects, and decision-makers exploring VMware alternatives or evaluating Hyper-V for new deployments.

---

## Revision Notes (v2.1)

**Changes from v2.0:**
- Added new Post 11: Management Tools for Production Hyper-V (WAC, SCVMM, System Center)
- Moved Post 9 (Hybrid Without the Handcuffs) to Strategy & Automation section (now Post 16)
- Renumbered Production Architecture posts for better flow
- Updated total from 18 to 19 posts

**Changes from v2.0:**
- Added new Post 11: Management Tools for Production Hyper-V (WAC, SCVMM, System Center)
- Moved Post 9 (Hybrid Without the Handcuffs) to Strategy & Automation section (now Post 16)
- Renumbered Production Architecture posts for better flow
- Updated total from 18 to 19 posts

**Changes from v1.1:**
- Consolidated 22 posts to 18 posts (reduced overlap, tighter focus)
- Merged Posts 5 & 6 (host build + validation)
- Merged Posts 12 & 17 (unified security post)
- Restructured Posts 7 & 13 (clear getting-started vs. advanced distinction)
- Added new Post: VM Migration from VMware (gap fill)
- Added new Post: Backup and Disaster Recovery Strategies (gap fill)
- Enhanced Post 11 with modern tooling (WAC, Azure Monitor, Prometheus)
- Added realistic expectations for Terraform/Ansible tooling maturity
- Added technical verification notes for Windows Server 2025 claims

---

## Series Overview

| Section | Posts | Theme |
|---------|-------|-------|
| The Case for Change | 1-4 | Business case, challenge assumptions |
| Foundation Building | 5-8 | Hands-on getting started, build confidence |
| Production Architecture | 9-15 | Deep technical content for production |
| Strategy & Automation | 16-19 | Decision frameworks and modern operations |

**Total: 19 posts** (plus 2 recap posts)

---

## The Case for Change (Posts 1-4)

### Post 1: Welcome to the Hyper-V Renaissance

**Summary:** Sets the stage for the entire series. Addresses why now is the perfect time to revisit Hyper-V given VMware/Broadcom licensing upheaval and Windows Server 2025's significant improvements. Establishes the series thesis: traditional Hyper-V + WSFC + three-tier storage is a mature, production-ready platform that deserves serious consideration. Introduces the "PowerShell Returned to Its Throne" theme and provides a roadmap of what readers will learn.

**Scope Guidance:** Avoid making this a thin "welcome" post. Include concrete value: a quick "state of the market" summary with real Broadcom pricing examples, and a decision tree helping readers determine if this series is right for their situation.

**Key Deliverables:** Series roadmap, market context summary, "Is this series for you?" decision tree

---

### Post 2: The Real Cost of Virtualization

**Summary:** A no-nonsense TCO comparison across three platforms: VMware (post-Broadcom licensing), Azure Local, and Hyper-V with Windows Server Datacenter. Breaks down licensing models, hidden costs, and long-term projections. Addresses VMware's shift to subscription-only licensing with 72-core minimums and significant price increases. Compares Azure Local's per-core/month subscription model against Windows Server's perpetual licensing option. Shows when each platform makes financial sense.

**Scope Guidance:** Broadcom licensing has been a moving targetâ€”verify current models at publication time. Include often-missed costs: training investment, tooling ecosystem changes, operational familiarity loss, and migration effort. The spreadsheet template is high-value; make it genuinely useful.

**Key Deliverables:** Cost comparison framework, TCO calculator spreadsheet template, licensing model summary table

---

### Post 3: The Myth of "Old Tech"

**Summary:** Directly confronts the perception that Hyper-V is outdated or second-tier. Highlights Windows Server 2025 Hyper-V improvements with verified specifications: Generation 2 VMs supporting up to 2,048 vCPUs and 240TB RAM, GPU partitioning (GPU-P) with live migration and HA support, workgroup clusters enabling AD-free Hyper-V clustering, improved storage live migration, and dynamic processor compatibility mode. Compares feature-for-feature against VMware vSphere and demonstrates Hyper-V's enterprise readiness.

**Technical Verification Notes:**
- 2,048 vCPU maximum requires Generation 2 VM and PowerShell configuration (UI limited to 1,024)
- 240TB RAM maximum applies to Generation 2 VMs only
- GPU-P with live migration is shipping in Windows Server 2025 GA
- Host maximums: 4PB RAM, 64 cluster nodes, 8,000 VMs per cluster
- Workgroup clusters now support Hyper-V live migration via certificates

**Scope Guidance:** Be precise about Generation 1 vs. Generation 2 VM limitations. The "Azure runs on Hyper-V" point is valid but note that Azure uses a customized hypervisor stackâ€”frame it accurately.

**Key Deliverables:** Feature comparison matrix (with version/generation notes), myth-busting checklist, verified specification reference table

---

### Post 4: Reusing Your Existing VMware Hosts

**Summary:** Practical guidance on repurposing existing VMware hardware for Hyper-V deployments. Covers hardware compatibility validation, Windows Server Catalog considerations, driver availability, and firmware updates. Addresses common concerns about NIC compatibility (especially for RDMA), storage controller support, and BIOS/UEFI settings. Demonstrates that quality server hardware is hypervisor-agnosticâ€”your Dell, HPE, or Lenovo servers work with any virtualization platform.

**Scope Guidance:** Focus on the hardware validation process, not the VM conversion (that's covered in the new Post 7). Include vendor-specific resources: Dell OpenManage, HPE iLO/SPP, Lenovo XClarity. Address the reality that some VMware-optimized NICs may not have full Windows driver feature parity.

**Key Deliverables:** Hardware compatibility checklist, pre-migration validation script, vendor resource links, driver compatibility matrix template

---

## Foundation Building (Posts 5-8)

### Post 5: Build and Validate a Cluster-Ready Host

**Summary:** Step-by-step guide to deploying a Hyper-V host ready for clustering using PowerShell, including comprehensive pre-production validation. Covers Windows Server 2025 installation, Hyper-V role configuration, networking setup, storage preparation, and validation procedures. Includes network adapter teaming validation, RDMA configuration testing, storage connectivity verification, and Test-Cluster execution. Emphasizes automation and repeatabilityâ€”every step scriptable.

**Consolidated From:** Original Posts 5 and 6

**Scope Guidance:** This is the PowerShell-first foundation. No GUI steps except where absolutely necessary. The validation section should be substantialâ€”Test-Cluster, network validation, storage latency checks. Make it clear this is the "trust but verify" checkpoint before proceeding.

**Key Deliverables:** Complete PowerShell deployment script, validation script collection, pass/fail checklist template, configuration checklist

---

### Post 6: Three-Tier Storage Integration

**Summary:** Practical guide to integrating external storage arrays with Hyper-V clusters. Covers universal principles (iSCSI vs. Fibre Channel vs. SMB3 decision framework, MPIO configuration, LUN presentation best practices) with Pure Storage as a detailed implementation example. Demonstrates why three-tier architecture remains relevant for specific workloads. This is the "getting connected" postâ€”advanced architecture patterns come later.

**Revised From:** Original Post 7 (broadened scope beyond Pure-only)

**Scope Guidance:** Lead with universal principles that apply to any storage vendor. Pure-specific content is valuable but clearly labeled. Readers with NetApp, Nimble, Dell PowerStore, or other arrays should get the foundational knowledge they need. Include a "vendor-specific resources" section pointing to integration guides for major vendors.

**Key Deliverables:** Storage protocol decision matrix, MPIO configuration guide, Pure Storage + Hyper-V reference configuration, vendor resource links

---

### Post 7: Migrating VMs from VMware to Hyper-V

**Summary:** Complete guide to converting and migrating virtual machines from VMware vSphere to Hyper-V. Covers conversion tools (Microsoft Virtual Machine Converter alternatives, Veeam, StarWind V2V, manual methods), pre-conversion preparation, driver injection, post-conversion validation, and common pitfalls. Addresses both online and offline migration scenarios.

**NEW POST:** Gap fillâ€”original series covered hardware reuse but not actual VM migration

**Scope Guidance:** Microsoft Virtual Machine Converter (MVMC) is deprecatedâ€”focus on current tools. Address the reality that some VMs convert cleanly while others need manual intervention (especially Linux guests with VMware tools, or VMs using paravirtualized devices). Include validation procedures to confirm successful migration.

**Key Deliverables:** Migration tool comparison matrix, pre-migration assessment checklist, conversion procedure guide, post-migration validation script

---

### Post 8: POC Like You Mean Itâ€”A Hands-On Hyper-V Cluster You Can Build This Afternoon

**Summary:** The series checkpointâ€”a complete, workshop-style guide to building a functional Hyper-V cluster from scratch. Consolidates learnings from posts 5-7 into a cohesive, reproducible lab environment. Designed as a confidence-builder: if you can complete this POC, you're ready for production planning. Includes troubleshooting common issues and validation steps.

**Revised From:** Original Post 9 (renumbered, updated references)

**Scope Guidance:** This should be genuinely completable in an afternoon by someone following along. Provide minimum hardware requirements for a functional POC. Include "checkpoint" validation at each major step. The troubleshooting section should address the actual problems people encounter, not theoretical issues.

**Key Deliverables:** Complete POC lab guide, all-in-one deployment script, validation checklist, troubleshooting guide

---

## Production Architecture (Posts 9-15)

### Post 9: Hybrid Without the Handcuffs

**Summary:** How to integrate with Azure services selectively without committing to Azure Local's full model. Covers Azure Backup for Hyper-V, Azure Site Recovery for DR, Azure Arc for inventory and monitoring (optional), and Azure Update Management. Demonstrates that hybrid doesn't mean all-or-nothingâ€”you can adopt cloud services incrementally while maintaining on-premises control and avoiding subscription lock-in.

**Revised From:** Original Post 10 (renumbered)

**Scope Guidance:** Be specific about what each Azure service provides and what it costs. Azure Arc has a free tier for inventoryâ€”be clear about where costs begin. This post should help readers make informed decisions about which Azure integrations provide value for their situation.

**Key Deliverables:** Hybrid integration patterns, selective Azure adoption guide, cost/benefit analysis template

---

### Post 10: Monitoring and Observabilityâ€”From Built-In to Best-of-Breed

**Summary:** Comprehensive monitoring and observability strategy with a tiered approach. Tier 1: Native Windows tools (Windows Admin Center dashboards, Performance Monitor, Event Log analysis, PowerShell-based monitoring). Tier 2: Azure integration (Azure Monitor for on-premises, Log Analytics). Tier 3: Open-source stack (Prometheus + Grafana for those who prefer it). Demonstrates how to build effective alerting and capacity planning at any budget level.

**Revised From:** Original Post 11 (modernized tooling, expanded scope)

**Scope Guidance:** Windows Admin Center should be prominentâ€”it's the modern management interface. Performance Monitor and Event Viewer are still relevant but shouldn't dominate. Include Azure Monitor as an option for those already invested in Azure. Prometheus/Grafana appeals to teams with DevOps/SRE backgrounds. Don't force a single approach.

**Key Deliverables:** Monitoring architecture decision tree, WAC dashboard templates, PowerShell monitoring scripts, Prometheus exporter configuration examples

---

### Post 10: Security Architecture for Hyper-V Clusters

**Summary:** Comprehensive security guide covering both cluster-level hardening and VM-level isolation. Cluster security: SMB encryption, cluster communication encryption, Credential Guard, Windows Defender integration, secure administrative practices. VM security: Virtualization-Based Security (VBS), Secure Boot, TPM integration, and an introduction to Shielded VMs with Host Guardian Service (with honest assessment of prerequisites and complexity). Addresses compliance requirements and audit considerations.

**Consolidated From:** Original Posts 12 and 17 (unified security coverage)

**Scope Guidance:** Structure as achievable hardening first, then advanced topics. SMB encryption, Credential Guard, and cluster encryption are achievable for most organizations. Shielded VMs and HGS have significant prerequisites (PKI, attestation infrastructure)—be honest about the investment required. Include compliance mapping for common frameworks (CIS, NIST, PCI-DSS where applicable).

**Key Deliverables:** Security baseline configuration script, hardening checklist (tiered by complexity), compliance mapping guide, HGS readiness assessment

---

### Post 11: Management Tools for Production Hyper-V—WAC, SCVMM, System Center

**Summary:** Practical guide to selecting and using management tools for Hyper-V at scale. Covers Windows Admin Center (including v-mode for virtualized deployment), System Center Virtual Machine Manager (SCVMM) for lifecycle management, and System Center Operations Manager/Configuration Manager for monitoring, patching, and compliance. Addresses when to use each tool, integration patterns, and operational workflows. Focuses on day-2 operations: VM provisioning, patching, capacity planning, runbooks.

**NEW POST:** Gap fill—addresses management tooling decisions

**Scope Guidance:** This is tool-focused, not orchestration/IaC (that's Posts 18-19). Windows Admin Center is the modern baseline—cover capabilities, limitations, and v-mode deployment scenarios. SCVMM is powerful but requires SQL and licensing investment—be honest about when it's worth it. System Center (OpsMgr/ConfigMgr) appeals to existing System Center shops—show integration value. Include decision matrix based on scale, budget, and existing investments.

**Key Deliverables:** Management tool decision matrix (scale/budget/capability), Windows Admin Center deployment guide (including v-mode), SCVMM integration examples (networking, storage, library), System Center integration patterns (monitoring, patching workflows), operational runbook templates, PowerShell management examples for each tool

---

### Post 12: Storage Architecture Deep Dive

**Summary:** Comprehensive security guide covering both cluster-level hardening and VM-level isolation. Cluster security: SMB encryption, cluster communication encryption, Credential Guard, Windows Defender integration, secure administrative practices. VM security: Virtualization-Based Security (VBS), Secure Boot, TPM integration, and an introduction to Shielded VMs with Host Guardian Service (with honest assessment of prerequisites and complexity). Addresses compliance requirements and audit considerations.

**Consolidated From:** Original Posts 12 and 17 (unified security coverage)

**Scope Guidance:** Structure as achievable hardening first, then advanced topics. SMB encryption, Credential Guard, and cluster encryption are achievable for most organizations. Shielded VMs and HGS have significant prerequisites (PKI, attestation infrastructure)â€”be honest about the investment required. Include compliance mapping for common frameworks (CIS, NIST, PCI-DSS where applicable).

**Key Deliverables:** Security baseline configuration script, hardening checklist (tiered by complexity), compliance mapping guide, HGS readiness assessment

---

### Post 12: Storage Architecture Deep Dive

**Summary:** Advanced storage architecture patterns for enterprise Hyper-V deployments. Covers storage tiering strategies, Cluster Shared Volumes (CSV) architecture decisions, backup integration patterns, replication design, and performance optimization. Addresses protocol selection (iSCSI vs. FC vs. SMB3) for different workload profiles. Includes CSV internals: direct I/O vs. redirected I/O, CSV cache behavior, metadata operations, and failure scenarios.

**Consolidated From:** Original Posts 13 and 15 (storage architecture + CSV internals)

**Scope Guidance:** This is the advanced counterpart to Post 6. Readers should have completed their basic storage integration before diving into architecture patterns. The CSV internals section is valuable for troubleshooting and performance optimizationâ€”keep it practical rather than purely academic.

**Key Deliverables:** Storage reference architectures, design decision matrix, CSV troubleshooting decision tree, performance baseline methodology

---

### Post 13: Backup and Disaster Recovery Strategies

**Summary:** Complete backup and DR planning for Hyper-V environments. Covers Hyper-V-native backup approaches (Windows Server Backup, VSS integration), third-party backup solutions (Veeam, Commvault, Rubrik integration patterns), Azure Backup and Azure Site Recovery deep dive, and replication strategies (Hyper-V Replica, storage-level replication, third-party tools). Addresses RPO/RTO planning and testing procedures.

**NEW POST:** Gap fillâ€”original series mentioned Azure Backup/ASR but lacked comprehensive backup/DR coverage

**Scope Guidance:** Backup is non-negotiable for productionâ€”this deserves dedicated coverage. Be vendor-neutral where possible but acknowledge that Veeam dominates this space for Hyper-V. Include both on-premises and cloud-based DR scenarios. Emphasize testingâ€”untested backups aren't backups.

**Key Deliverables:** Backup strategy decision matrix, RPO/RTO planning worksheet, DR runbook template, backup validation procedures

---

### Post 14: Live Migration Internals and Optimization

**Summary:** Behind-the-scenes look at Hyper-V live migration mechanics. Covers memory pre-copy algorithm, dirty page tracking, network transfer optimization, final switchover process, and Windows Server 2025 improvements (compression, RDMA offload, dynamic processor compatibility mode, intelligent network selection). Helps administrators understand performance implications and troubleshoot migration issues.

**Revised From:** Original Post 16 (renumbered)

**Scope Guidance:** This is deep technical content that distinguishes the series. Focus on practical implications: what affects migration time, how to optimize for large-memory VMs, when compression helps vs. hurts, RDMA configuration for migration traffic. Include actual troubleshooting scenarios with solutions.

**Key Deliverables:** Live migration flow diagrams, performance optimization guide, troubleshooting scripts, migration time estimation methodology

---

### Post 15: WSFC at Scale

**Summary:** Scaling Windows Server Failover Clustering for large deployments. Covers multi-site clusters, stretched clusters, cluster sets (for managing multiple clusters as a unit), and managing large VM populations. Addresses operational challenges at scale: Cluster-Aware Updating, monitoring hundreds or thousands of VMs, capacity planning, and organizational processes. Windows Server 2025 supports up to 64 nodes and 8,000 VMs per cluster.

**Revised From:** Original Post 18 (renumbered)

**Scope Guidance:** Be realistic about when these scale features are needed. Most organizations don't need 64-node clusters or cluster sets. Focus on the transition points: when does a single cluster become unwieldy? When do you need multi-site? Include operational runbooks that actually help at scale.

**Key Deliverables:** Scale architecture patterns, operational runbooks for large deployments, capacity planning tools, multi-site design considerations

---

## Strategy & Automation (Posts 16-19)

### Post 16: Hybrid Without the Handcuffs

**Summary:** How to integrate with Azure services selectively without committing to Azure Local's full model. Covers Azure Backup for Hyper-V, Azure Site Recovery for DR, Azure Arc for inventory and monitoring (optional), and Azure Update Management. Demonstrates that hybrid doesn't mean all-or-nothing—you can adopt cloud services incrementally while maintaining on-premises control and avoiding subscription lock-in.

**Moved From:** Production Architecture (strategic decision framework fits better with platform/tooling selection)

**Scope Guidance:** Be specific about what each Azure service provides and what it costs. Azure Arc has a free tier for inventory—be clear about where costs begin. This post should help readers make informed decisions about which Azure integrations provide value for their situation.

**Key Deliverables:** Hybrid integration patterns, selective Azure adoption guide, cost/benefit analysis template

---

### Post 17: S2D vs. Three-Tier and When Azure Local Makes Sense

**Summary:** Fair, technical comparison of infrastructure approaches: Storage Spaces Direct (HCI/hyperconverged), traditional three-tier with external storage, and Azure Local (formerly Azure Stack HCI). Covers performance characteristics, failure domains, cost structures, operational complexity, and appropriate use cases for each. Provides honest evaluation of Azure Local's strengths (unified Azure management, integrated AKS, AVD optimization) and limitations (mandatory Azure connectivity, subscription costs). Helps readers make informed platform decisions.

**Consolidated From:** Original Posts 19 and 20 (unified decision framework)

**Scope Guidance:** This is the "elephant in the room" post. Readers need honest guidance, not advocacy. S2D and Azure Local have legitimate use casesâ€”acknowledge them. Three-tier isn't always superior. Be specific about scenarios where each approach excels. This builds credibility for the entire series.

**Key Deliverables:** Infrastructure decision matrix, workload fit assessment guide, Azure Local cost/benefit analysis, use case mapping

---

### Post 18: PowerShell Automation Patterns (2026 Edition)

**Summary:** Comprehensive PowerShell automation for Hyper-V operations. Covers PowerShell Desired State Configuration (DSC) for host and VM configuration management, PowerShell Remoting patterns for multi-host management, module-based VM provisioning, idempotent scripting practices, and integration with CI/CD pipelines. Demonstrates that PowerShell remains the most powerful and flexible tool for Hyper-V automation without requiring additional platforms.

**Revised From:** Original Post 21 (enhanced scope)

**Scope Guidance:** This should be substantial, not just "here are some scripts." DSC for configuration management is powerful but underusedâ€”show real patterns. CI/CD integration demonstrates modern practices. Idempotent scripting is crucial for reliability. Include a module structure that readers can adopt.

**Key Deliverables:** PowerShell module collection, DSC configurations for common scenarios, automation templates, CI/CD integration examples

---

### Post 19: Infrastructure as Code with Ansible and Terraform

**Summary:** Infrastructure-as-Code for Hyper-V using industry-standard tools. Covers Ansible modules for Windows/Hyper-V management (well-supported via WinRM), and Terraform community provider for Hyper-V (with honest assessment of maturity). Demonstrates patterns for declarative, repeatable infrastructure deployment. Shows how Hyper-V integrates with modern DevOps toolchains. Builds on PowerShell foundation from Post 18.

**Revised From:** Original Post 22 (added realistic expectations)

**Scope Guidance:** Be honest about tooling maturity. Ansible has solid Windows/WinRM support and is production-ready. The Terraform Hyper-V provider (taliesins/terraform-provider-hyperv) is community-maintained, not an official HashiCorp providerâ€”set appropriate expectations. For organizations heavily invested in Terraform, Azure Local with the AzureRM provider may be more appropriate. This post should help readers make informed tooling decisions.

**Key Deliverables:** Ansible playbooks for common scenarios, Terraform module examples (with caveats), IaC pattern documentation, tooling decision guide

---

## Series Assets (Cumulative)

- **GitHub Repository:** All scripts, modules, templates, and IaC configurations
- **Cost Calculator:** Excel-based TCO comparison tool (Post 2)
- **Reference Architectures:** Visio/draw.io diagrams for storage, networking, multi-site
- **Checklists:** PDF downloads for validation, security, migration, backup
- **Lab Guide:** Complete POC deployment package (Post 8)
- **Decision Matrices:** Infrastructure selection, storage protocol, monitoring approach

---

## Publishing Schedule Recommendation

| Week | Post | Section |
|------|------|---------|
| 1 | Post 1: Welcome to the Hyper-V Renaissance | The Case for Change |
| 2 | Post 2: The Real Cost of Virtualization | The Case for Change |
| 3 | Post 3: The Myth of "Old Tech" | The Case for Change |
| 4 | Post 4: Reusing Your Existing VMware Hosts | The Case for Change |
| 5 | *Recap / Engagement Post* | â€” |
| 6 | Post 5: Build and Validate a Cluster-Ready Host | Foundation Building |
| 7 | Post 6: Three-Tier Storage Integration | Foundation Building |
| 8 | Post 7: Migrating VMs from VMware | Foundation Building |
| 9 | Post 8: POC Checkpoint | Foundation Building |
| 10 | *Mid-Series Recap* | â€” |
| 11 | Post 9: Monitoring and Observability | Production Architecture |
| 12 | Post 10: Security Architecture | Production Architecture |
| 13 | Post 11: Management Tools | Production Architecture |
| 14 | Post 12: Storage Architecture Deep Dive | Production Architecture |
| 15 | Post 13: Backup and Disaster Recovery | Production Architecture |
| 16 | Post 14: Live Migration Internals | Production Architecture |
| 17 | Post 15: WSFC at Scale | Production Architecture |
| 18 | Post 16: Hybrid Without the Handcuffs | Strategy & Automation |
| 19 | Post 17: S2D vs. Three-Tier and Azure Local | Strategy & Automation |
| 20 | Post 18: PowerShell Automation (2026 Edition) | Strategy & Automation |
| 21 | Post 19: Infrastructure as Code | Strategy & Automation |
| 22 | *Series Conclusion / What's Next* | — |

**Total timeline: 22 weeks** (19 posts + 3 recap/conclusion posts)

---

## Key Messaging Throughout Series

**Primary Message:** Hyper-V with Windows Server 2025 is a mature, enterprise-ready virtualization platform that deserves serious considerationâ€”especially given VMware's pricing changes and Azure Local's subscription requirements.

**Supporting Messages:**
- PowerShell-first automation is powerful and sufficient for most organizations
- Three-tier architecture remains valid and often superior for specific workloads
- You don't need HCI or cloud dependency for excellent virtualization
- Your existing hardware investments can be preserved
- Cost savings are significant and provable
- Honest evaluation beats advocacyâ€”know when alternatives make sense

---

## Technical Verification Checklist

Before publication, verify the following against current Microsoft documentation:

- [ ] Windows Server 2025 GA release status and feature availability
- [ ] Hyper-V scalability maximums (2,048 vCPU, 240TB RAM, etc.)
- [ ] GPU-P live migration and HA support shipping status
- [ ] Current Broadcom/VMware licensing terms and pricing
- [ ] Azure Local pricing model ($/core/month)
- [ ] Terraform provider version and capabilities
- [ ] Tool deprecation status (MVMC, SCVMM features, etc.)

---

## Removed/Consolidated Posts Summary

| Original Post | Disposition |
|---------------|-------------|
| Post 6: NIC and Storage Validation | Merged into Post 5 |
| Post 14: Production-Grade WSFC | Content distributed to Posts 8 and 15 |
| Post 15: CSV Internals | Merged into Post 12 (Storage Deep Dive) |
| Post 17: Hyper-V Security Architecture | Merged into Post 11 |
| Post 19: S2D vs Three-Tier | Merged with Post 20 into Post 16 |
| Post 20: When Azure Local Makes Sense | Merged with Post 19 into Post 16 |

---

*Document Version: 2.1*
*Revised: February 5, 2026*
*Series Author: [Your Name]*