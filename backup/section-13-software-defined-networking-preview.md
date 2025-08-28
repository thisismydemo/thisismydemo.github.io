## 13 Software-Defined Networking

### Your NSX Networking Operations Translation

Your NSX-powered network virtualization translates to Azure Local's cloud-managed approach with significant architectural changes. This isn't a feature-equivalent migration—it's a shift from comprehensive on-premises SDN to essential networking with cloud service integration.

> **Critical Decision Alert:** SDN enabled by Azure Arc requires Azure Local 2506 (OS version 26100.xxxx+) and is a permanent, irreversible choice that eliminates on-premises load balancing, VPN gateways, and advanced overlay networking capabilities you currently rely on with NSX. Once enabled, it cannot be disabled, and Network Controller runs as a Failover Cluster service instead of traditional VMs.

> **Alternative SDN Approach Note:** Azure Local also supports traditional on-premises SDN deployment using Windows Admin Center, documented in Microsoft's [Azure Local 23H2 SDN concepts](https://learn.microsoft.com/en-us/azure/azure-local/concepts/software-defined-networking-23h2?view=azloc-2507). This approach provides more comprehensive on-premises networking capabilities but contradicts the cloud-first architectural direction of this comparison. **Important:** These two SDN approaches are mutually exclusive—you must choose either Arc-enabled SDN or traditional on-premises SDN during initial deployment. This analysis focuses exclusively on SDN enabled by Azure Arc as Microsoft's strategic direction.

### SDN Architecture Philosophy Shift

**VMware NSX Comprehensive Platform vs Azure Arc Cloud-Native Approach:**

The fundamental difference between VMware NSX and Azure Local's SDN enabled by Azure Arc reflects contrasting architectural philosophies. VMware NSX provides a complete network virtualization platform with distributed routing, advanced load balancing, VPN gateways, and comprehensive security services managed through on-premises NSX Manager. Azure Local's SDN enabled by Azure Arc takes a cloud-first approach, providing core micro-segmentation through Network Controller while integrating with Azure cloud services for advanced networking capabilities.

This architectural shift represents Microsoft's strategic direction: instead of replicating every NSX capability locally, Azure Local provides essential network security through Azure Arc integration while leveraging Azure's native cloud services for advanced networking requirements that exceed basic micro-segmentation and load balancing.

Your network operations evolve from NSX Manager's centralized on-premises control to Azure Portal's cloud-managed approach, requiring internet connectivity for network policy changes but providing global consistency and Azure service integration that on-premises NSX cannot match.

### Feature Capability Direct Comparison

**SDN Components Mapping - NSX-T vs Azure Arc SDN:**

| SDN Capability | VMware NSX-T 4.1+ | Azure Local SDN (Arc-enabled) | Operational Impact |
|----------------|-------------------|-------------------------------|-------------------|
| **Network Segmentation** | NSX Segments with Distributed Firewall | Logical Networks with Network Security Groups | Similar micro-segmentation capability |
| **Micro-segmentation Rules** | Distributed Firewall with application-layer inspection | NSGs with stateful Layer 4 inspection | Reduced application awareness, vSwitch port-level enforcement |
| **Load Balancing** | NSX Advanced Load Balancer (L4/L7) | Software Load Balancer (L4 only) | **No Layer 7 features, no SSL termination** |
| **VPN Gateway Services** | NSX Edge VPN (L2VPN, IPSec, SSL-VPN) | RAS Gateway (IPSec, GRE) with BGP | **Reduced VPN types, BGP routing support** |
| **Distributed Routing** | NSX Distributed Logical Router with ECMP | ❌ **Not Supported** | **Basic routing only** |
| **Virtual Network Overlays** | NVGRE, VXLAN, STT | NVGRE, VXLAN support | **Similar overlay support** |
| **Dynamic Security Groups** | Security groups with VM attribute-based membership | ❌ **Not Supported** | **Static NSG assignments only** |
| **Management Interface** | NSX Manager (on-premises GUI/API) | Azure Portal, CLI, ARM templates | **Cloud-managed approach** |
| **Network Monitoring** | NSX Intelligence with flow analytics | Azure Monitor and Log Analytics | **Cloud-integrated monitoring** |
| **Virtual Appliance Chaining** | Service insertion on Tier-0/Tier-1 | Network Controller-based chaining | **Different implementation model** |

### Core Networking Architecture Changes

**What Changes in Your Daily Operations:**

| Your Current NSX Workflow | Azure Local Equivalent | Key Operational Change |
|---------------------------|------------------------|----------------------|
| **NSX Manager GUI/API** → Network policy management | **Azure Portal/CLI** → Cloud-based policy management | Requires internet connectivity for changes |
| **Dynamic Security Groups** → VM tags automatically assign policies | **Network Security Groups** → Manual assignment to VMs | More manual security policy management |
| **NSX Advanced Load Balancer** → On-premises L4/L7 load balancing | **Software Load Balancer** → L4 load balancing only | No SSL termination, health monitoring differences |
| **NSX Edge VPN** → Multiple VPN types and SSL VPN | **RAS Gateway** → IPSec and GRE with BGP | Fewer VPN options, no SSL VPN |
| **NSX Intelligence** → Local network analytics | **Azure Monitor** → Cloud-based monitoring | Different troubleshooting workflow |

### Micro-Segmentation Translation

Your NSX distributed firewall rules translate to Azure Local Network Security Groups (NSGs) with different enforcement model:

**NSX Distributed Firewall (Current):**
- Hypervisor-level stateful inspection
- Web-Tier-SG: VMs tagged "web-tier" automatically included
- Rules apply based on VM attributes and discovered services
- Zero-downtime policy updates

**Azure Local NSGs (New Model):**
- vSwitch port-level rule enforcement
- Web-VMs-NSG: Manually assigned to specific VM network interfaces  
- Rules based on IP addresses and port ranges only
- Rules move with workloads across the datacenter

**Operational Impact:** You'll manage security group membership manually rather than through dynamic VM tagging, but rules are still distributed across your workloads and move with VMs during migration.

### Critical Capabilities Changes

**NSX Advanced Features You'll Lose:**
- **Layer 7 Load Balancing:** No SSL termination, advanced health checks, or application delivery features
- **Dynamic Security Groups:** No automatic membership based on VM attributes or application discovery  
- **Advanced Overlay Networking:** Reduced to basic NVGRE/VXLAN support
- **Identity Firewall:** No Active Directory user-based network policies
- **NSX Federation:** No multi-site SDN management

**Azure Local SDN Provides Instead:**
- Software Load Balancer with Layer 4 NAT and high availability
- RAS Gateway with BGP routing for site-to-site connectivity
- Network Controller REST API for automation
- Virtual network appliance chaining support for third-party solutions

### Management Workflow Changes

**Current NSX Workflow:**
1. Connect to NSX Manager locally
2. Create dynamic security groups with VM queries
3. Apply policies immediately to ESXi hosts
4. Monitor with NSX Intelligence locally

**New Azure Local Workflow:**
1. Access Azure Portal (internet required)
2. Create NSGs through Network Controller API  
3. Policies sync through Azure Arc to local Hyper-V hosts
4. Monitor through Azure Monitor and Log Analytics

### Architecture Deployment Considerations

**Network Controller Architecture (Azure Local SDN):**
- Runs as Failover Cluster service (minimum 3 nodes for HA)
- REST API Northbound interface for management
- Service Fabric-based distributed application platform
- Cannot be deployed on physical hosts (dedicated VMs required)

**NSX-T Architecture (Current):**
- VM-based NSX Manager cluster
- Multiple management components (Manager, Controller, Edge)
- Local administrative control and offline capabilities
- Reversible configuration changes

### Planning Your Transition

**Architecture Decisions to Make:**
1. **Cloud Dependency:** Accept internet connectivity requirement for network policy changes
2. **Load Balancing Strategy:** Plan for Layer 4-only capabilities or third-party solutions
3. **Security Group Management:** Develop processes for manual NSG assignment
4. **VPN Services:** Migrate to IPSec/GRE with BGP or use Azure VPN Gateway
5. **Third-Party Integration:** Evaluate virtual appliance chaining for advanced features

**What Continues Working Offline:**
- Existing network policies remain active through Network Controller
- VM-to-VM traffic continues normally with distributed enforcement
- Current security rules stay enforced at vSwitch ports
- Local troubleshooting of running workloads

**What Requires Cloud Connectivity:**
- Creating or modifying network security policies through Azure Portal
- Adding new logical networks or NSG configurations
- Monitoring and analytics access through Azure services
- Network Controller management operations

### Bottom Line for Your Team

Azure Local SDN enabled by Arc represents Microsoft's cloud-first approach to networking with essential features rather than comprehensive platform replacement. You gain Azure integration and simplified management model but lose advanced NSX capabilities like Layer 7 load balancing, dynamic security groups, and comprehensive on-premises networking services.

**This is a permanent, irreversible architectural decision requiring OS version 26100+.** Ensure your organization is prepared for cloud-managed networking and potential third-party solutions for advanced requirements before enabling SDN by Azure Arc.

Your NSX distributed firewall rules translate to Azure Local Network Security Groups (NSGs) with simplified capabilities:

**NSX Security Groups (Dynamic):**
- Web-Tier-SG: VMs tagged "web-tier" automatically included
- Rules apply based on VM attributes and discovered services

**Azure Local NSGs (Static):**
- Web-VMs-NSG: Manually assigned to specific VM network interfaces  
- Rules based on IP addresses and port ranges only

**Operational Impact:** You'll manage security group membership manually rather than through dynamic VM tagging. Use PowerShell scripts to automate NSG assignments for consistency.

### Critical Capabilities Not Available

**NSX Features You'll Lose:**
- **Software Load Balancing:** No on-premises load balancing services
- **VPN Gateway Services:** No local VPN or remote access capabilities  
- **Advanced Overlay Networking:** Basic logical networks only
- **Dynamic Security Groups:** No automatic membership based on VM attributes

**Required Azure Cloud Services:**
- Azure Load Balancer for application load balancing
- Azure VPN Gateway for site-to-site connectivity
- Manual scripting for security group management

### Management Workflow Changes

**Current NSX Workflow:**
1. Connect to NSX Manager locally
2. Create dynamic security groups with VM queries
3. Apply policies immediately to ESXi hosts
4. Monitor with NSX Intelligence locally

**New Azure Local Workflow:**
1. Access Azure Portal (internet required)
2. Create NSGs and assign to specific VMs  
3. Policies sync through Azure Arc to local hosts
4. Monitor through Azure Monitor and Log Analytics

### Planning Your Transition

**Architecture Decisions to Make:**
1. **Cloud Dependency:** Accept internet connectivity requirement for network changes
2. **Load Balancing Strategy:** Plan application architecture around Azure Load Balancer
3. **Site Connectivity:** Migrate VPN services to Azure VPN Gateway or ExpressRoute
4. **Security Management:** Develop processes for manual NSG assignment and maintenance

**What Continues Working Offline:**
- Existing network policies remain active
- VM-to-VM traffic continues normally
- Current security rules stay enforced
- Local troubleshooting of running workloads

**What Requires Cloud Connectivity:**
- Creating or modifying network security rules
- Adding new logical networks
- Monitoring and analytics access
- Troubleshooting through Azure tools

### Bottom Line for Your Team

Azure Local SDN represents Microsoft's cloud-first approach to networking. You gain Azure integration and simplified management, but lose comprehensive on-premises networking services. Success requires accepting that advanced networking capabilities move to Azure cloud services rather than remaining local like NSX.

**This is a permanent, irreversible architectural decision.** Ensure your organization is prepared for cloud-managed networking before enabling SDN by Azure Arc.

[Back to Table of Contents](#table-of-contents)
