# Section 5: Storage Architecture Deep Dive - Streamlined Preview

## 5 Storage Architecture Deep Dive

Your VMware storage architecture—whether external SAN, vSAN, or hybrid—transitions to Storage Spaces Direct with fundamental changes in storage presentation, management, and operational workflows.

Understanding how traditional storage concepts translate to Azure Local helps you plan storage performance, capacity, and infrastructure changes regardless of your current VMware storage approach.

### Storage Architecture Migration Paths

**Core Storage Philosophy Evolution:** Azure Local standardizes on Storage Spaces Direct (S2D) as the primary storage approach, representing a shift from diverse VMware storage options to a unified software-defined storage model.

Your current VMware storage architecture maps to Azure Local as follows:

| Current VMware Storage | Azure Local Approach | Migration Complexity | Operational Impact |
|------------------------|----------------------|---------------------|-------------------|
| **External FC/iSCSI SAN** | Storage Spaces Direct (S2D) | High - Architecture change | Complete storage workflow transformation |
| **vSAN HCI** | Storage Spaces Direct (S2D) | Medium - Concept translation | Management tool and policy changes |
| **Hybrid (SAN + vSAN)** | Storage Spaces Direct (S2D) | High - Consolidation required | Unified storage management approach |
| **NFS/NAS** | Storage Spaces Direct (S2D) | High - Protocol change | File service architecture redesign |

### External SAN → Storage Spaces Direct Transformation

**Traditional SAN Architecture Changes:** Most VMware customers using external SAN arrays face the most significant storage architecture changes when moving to Azure Local.

**Storage Infrastructure Transformation:**

| Traditional SAN Approach | Azure Local S2D Approach | Infrastructure Change |
|---------------------------|---------------------------|---------------------|
| **Storage Array** | Server-based storage pool | Hardware procurement shifts from arrays to servers |
| **FC/iSCSI Network** | Ethernet-based storage network | Network infrastructure simplification |
| **LUN Presentation** | Cluster Shared Volumes (CSV) | Storage presentation method changes |
| **Array Management** | PowerShell/WAC storage management | Management tool and skillset evolution |
| **RAID Controllers** | Software-defined resilience | Hardware dependency reduction |

**Operational Workflow Changes:**
- **LUN Creation:** Array-based LUN carving → S2D volume creation via PowerShell/WAC
- **Storage Monitoring:** Array management consoles → Windows Storage Health Service
- **Performance Tuning:** Array cache/tier policies → S2D cache and resiliency policies
- **Capacity Planning:** Array expansion → Node addition for capacity/performance scaling

**Converged Mode Option:** Azure Local supports converged mode where you can continue using existing SAN arrays as Cluster Shared Volumes, but you lose cloud integration benefits and most customers migrate to S2D for operational simplification.

### vSAN → Storage Spaces Direct Architectural Translation

**For customers currently using vSAN:** The transition involves conceptual translation rather than fundamental architecture change, as both are software-defined storage approaches.

| Storage Component | vSAN | Storage Spaces Direct | Architecture Impact |
|-------------------|------|----------------------|-------------------|
| **Storage Pooling** | vSAN cluster-wide storage pool | S2D cluster-shared volumes | Similar abstraction layer |
| **Data Placement** | vSAN object placement | S2D mirror/parity placement | Different algorithms, same resilience |
| **Cache Tier** | vSAN read/write cache | S2D cache with NVMe/SSD | Equivalent performance acceleration |
| **Capacity Tier** | vSAN capacity drives | S2D capacity drives | Standard HDD/SSD support |
| **Resiliency** | FTT policies (RAID-1/5/6) | Mirror/parity configurations | Different terminology, same protection |

**vSAN Policy Translation:** Your existing vSAN storage policies map to S2D resiliency settings:

| Workload Type | vSAN Policy | S2D Configuration | Capacity Efficiency |
|---------------|-------------|-------------------|-------------------|
| **High Performance** | FTT=1, RAID-1 + All-Flash | Two-way mirror + NVMe cache | 50% usable capacity |
| **Balanced** | FTT=1, RAID-5 + Hybrid | Mirror-accelerated parity | 66% usable capacity |
| **Capacity Optimized** | FTT=2, RAID-6 + Archive | Dual parity + compression | 75% usable capacity |

### Storage Presentation and Management Changes

**VMFS vs CSV Architecture:** The fundamental change from VMware's VMFS datastore model to Windows Cluster Shared Volumes affects how storage is presented and managed.

**Storage Presentation Comparison:**

| Storage Concept | VMware Approach | Azure Local Approach | Operational Difference |
|-----------------|-----------------|---------------------|----------------------|
| **Storage Abstraction** | VMFS datastores | Cluster Shared Volumes (CSV) | Different file system and presentation |
| **VM Storage Files** | .vmdk on VMFS | .vhdx on NTFS/ReFS | Different file formats and management |
| **Storage Policies** | vSphere storage policies | S2D resiliency settings | Different terminology, similar concepts |
| **Thin Provisioning** | VMFS thin disks | VHDX dynamically expanding | Equivalent functionality, different implementation |
| **Storage vMotion** | Cross-datastore migration | CSV live migration | Similar capability, different underlying mechanism |

### Performance Characteristics and Planning

**Storage Performance Translation:** Understanding performance differences helps with capacity planning and architecture decisions.

| Performance Metric | External SAN | vSAN All-Flash | S2D All-Flash | Planning Consideration |
|--------------------|---------------|----------------|---------------|----------------------|
| **IOPS Capability** | Array-dependent | 100K+ per host | 150K+ per host | S2D often provides superior per-host performance |
| **Latency** | Network + array latency | Sub-millisecond | Sub-millisecond | Network latency elimination with S2D |
| **Throughput** | FC/iSCSI limited | 2GB/s+ per host | 3GB/s+ per host | Higher bandwidth potential with S2D |
| **Scalability** | Array capacity limits | 64 hosts max | 16 hosts per cluster | Different scale-out approaches |

### Storage Management Tool Evolution

**Management Workflow Changes:** Storage administration transitions from array-specific tools to Windows-native management interfaces.

| Task | Traditional SAN | vSAN Management | S2D Management | Skill Set Impact |
|------|-----------------|-----------------|----------------|------------------|
| **Volume Creation** | Array management console | vSphere Client | WAC/PowerShell | PowerShell scripting skills required |
| **Health Monitoring** | Array monitoring tools | vSAN health service | Storage Health Service | Windows event log integration |
| **Performance Analytics** | Array performance tools | vSAN performance | Storage Performance Monitor | Native Windows performance counters |
| **Policy Configuration** | Array policy/tier settings | vSphere Client | WAC/PowerShell | Policy-based management evolution |
| **Capacity Planning** | Array capacity planning | vSAN capacity planner | S2D sizing tools | Microsoft sizing methodologies |

### Storage Transition Planning and Strategy

**Migration Planning Approach:** Different VMware storage architectures require different transition strategies and timelines.

**External SAN Migration Strategy:**
1. **Infrastructure Assessment:** Evaluate existing SAN capacity, performance, and lifecycle status
2. **S2D Sizing:** Plan server hardware to meet current storage performance and capacity requirements  
3. **Network Planning:** Design Ethernet-based storage network to replace FC/iSCSI infrastructure
4. **Skills Development:** Train storage teams on PowerShell and Windows storage management
5. **Phased Migration:** Plan data migration from SAN to S2D during maintenance windows

**vSAN Migration Strategy:**
1. **Policy Mapping:** Document existing vSAN storage policies and map to S2D resiliency settings
2. **Performance Validation:** Ensure S2D configuration meets or exceeds current vSAN performance
3. **Management Training:** Transition from vSphere Client to Windows Admin Center/PowerShell workflows
4. **Tool Integration:** Reconfigure monitoring and automation tools for S2D management

### Storage Networking and Infrastructure Changes

**Network Architecture Evolution:** Storage networking requirements change significantly, especially for external SAN customers.

| Network Aspect | Traditional SAN | vSAN | Azure Local S2D |
|-----------------|-----------------|------|-----------------|
| **Storage Protocol** | FC/iSCSI | vSAN network | Ethernet SMB3 |
| **Network Isolation** | FC fabric or iSCSI VLAN | vSAN traffic isolation | Storage intent networks |
| **Redundancy** | Dual FC paths or iSCSI multipath | vSAN network redundancy | NIC teaming or SR-IOV |
| **Bandwidth Planning** | FC/iSCSI link speeds | 10GbE+ for vSAN | 25GbE+ recommended for S2D |

### Bottom Line

Storage Spaces Direct represents a fundamental shift from diverse VMware storage approaches to a unified software-defined storage model. External SAN customers face the most significant architectural changes, while vSAN customers experience more of a management and tooling transition. Both paths lead to simplified storage management with Windows-native tools and often superior performance characteristics.

> **Key Takeaway:** Whether coming from external SAN or vSAN, Azure Local consolidates storage management into a single S2D approach that eliminates storage array dependencies while providing equivalent or better performance through software-defined storage.

---

*This section focuses purely on storage architecture fundamentals, leaving backup integration details for Section 6 and disaster recovery storage topics for Section 7.*
