# Section 10: Disconnected/Connectivity Operations

Understanding how VMware vSphere's offline capabilities compare to Azure Local's disconnected operations helps you plan for edge scenarios, intermittent connectivity, and air-gapped deployments while maintaining operational continuity.

## Connectivity Requirements Comparison

### VMware vSphere Offline Operations
VMware vSphere operates independently of cloud connectivity with these characteristics:
- **Indefinite offline operation** - No cloud dependency for basic operations
- **vCenter management** - Full management capabilities through vCenter Server
- **Host-level access** - Direct ESXi host management when vCenter unavailable
- **No licensing dependencies** - Perpetual licenses don't require cloud check-ins

### Azure Local Connectivity Models
Azure Local supports multiple connectivity scenarios with varying capabilities:

| Connectivity Mode | Description | Duration Limit | Management Capabilities |
|-------------------|-------------|----------------|------------------------|
| **Fully Connected** | Continuous Azure connectivity | Unlimited | Full Azure portal + local tools |
| **Semi-Connected** | Intermittent connectivity | 30 days maximum | Local tools + periodic Azure sync |
| **Fully Disconnected (Preview)** | Complete air-gap deployment | No Azure dependency | Local control plane + portal |
| **Traditional Offline** | Basic disconnected operations | 30 days licensing limit | Windows Admin Center + PowerShell |

## New Fully Disconnected Operations (Preview)

Microsoft has introduced comprehensive disconnected operations for Azure Local, enabling complete air-gapped deployments:

### Fully Disconnected Capabilities
**Local Control Plane Services:**
- **Local Azure Portal** - Full portal experience without internet connectivity
- **Azure Resource Manager (ARM)** - Complete ARM template and CLI support
- **Role-Based Access Control** - Full RBAC for subscriptions and resource groups
- **Managed Identity** - System-assigned managed identity support
- **Azure Container Registry** - Local container image and artifact storage
- **Azure Key Vault** - Local secrets and key management

**Supported Workload Types:**
- Azure Local VMs (Windows Server 2025/2022, Windows 10 Enterprise, Ubuntu LTS)
- Arc-enabled Kubernetes clusters and AKS enabled by Arc
- Arc-enabled servers for VM guest management
- Containerized applications with local registry support

### Deployment Requirements for Air-Gapped Operations
**Infrastructure Prerequisites:**
- Higher hardware requirements for local control plane hosting
- PKI infrastructure integration for secure endpoint management
- Domain controller integration for time synchronization and identity
- Network isolation with proper security controls

**Preparation Steps:**
```powershell
# Time server configuration for disconnected operations
w32tm /config /manualpeerlist:"dc.contoso.com" /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time

# Environment variable for disconnected operations support
[Environment]::SetEnvironmentVariable("DISCONNECTED_OPS_SUPPORT", $true, [System.EnvironmentVariableTarget]::Machine)
```

## Traditional Disconnected Operations (30-Day Model)

### Operational Capabilities During Disconnection
**Local Management Tools:**
- **Windows Admin Center** - Available offline for cluster management
- **PowerShell** - Full local cluster management capabilities  
- **Failover Cluster Manager** - Traditional Windows clustering tools
- **Hyper-V Manager** - Direct host management interface

**30-Day Grace Period Behavior:**
- ✅ Existing VMs continue running normally
- ✅ VM live migration between cluster nodes
- ✅ Virtual network and storage configuration changes
- ✅ Performance monitoring and troubleshooting
- ❌ New VM creation after 30-day licensing expiration
- ❌ Azure portal management and monitoring
- ❌ Azure Arc services and cloud extensions

## Use Case Scenarios

### When to Choose Each Model

**Fully Disconnected Operations (Preview):**
- Government and defense deployments requiring complete air-gap
- Remote locations with no internet infrastructure (oil rigs, manufacturing sites)
- Healthcare and finance with strict data sovereignty requirements
- High-security environments minimizing attack surfaces

**Semi-Connected Operations (30-Day):**
- Edge locations with intermittent connectivity
- Cost-conscious deployments with minimal cloud integration
- Temporary disconnection scenarios during maintenance
- Remote offices with periodic satellite/cellular connectivity

**Fully Connected Operations:**
- Primary datacenter deployments with reliable internet
- Maximum Azure service integration requirements
- Development and testing environments
- Scenarios requiring real-time cloud services

## Migration Strategy Comparison

### From VMware Indefinite Offline to Azure Local

**Planning Considerations:**

| VMware Approach | Azure Local Traditional | Azure Local Disconnected (Preview) |
|-----------------|------------------------|-----------------------------------|
| No connectivity planning | Arrange 30-day periodic connections | Complete air-gap deployment |
| vCenter-only management | WAC + PowerShell local skills | Local portal + ARM template skills |
| Perpetual licensing | Cloud licensing check-ins | Local control plane licensing |
| Host-level fallback | Cluster management focus | Comprehensive local Azure services |

**Team Skill Development Requirements:**

**For Traditional Disconnected (30-Day):**
- Windows Admin Center proficiency for offline management
- PowerShell cluster management capabilities
- Understanding local vs cloud feature boundaries
- Incident response for extended disconnections

**For Fully Disconnected (Preview):**
- Local control plane architecture understanding
- PKI and certificate management expertise
- Air-gapped deployment and security procedures
- Local Azure portal and ARM template skills

## Operational Resilience Comparison

**VMware vSphere Resilience Model:**
- vCenter as primary control plane with ESXi host fallback
- No external dependencies for basic VM operations
- Unlimited offline operation duration
- Manual processes for extended outages

**Azure Local Resilience Model:**
- Choice between cloud-hybrid and fully disconnected architectures
- Local control plane capabilities matching cloud services
- Planned connectivity windows vs continuous operation options
- Consistent management experience across connectivity states

The evolution to fully disconnected operations (preview) bridges the gap between VMware's indefinite offline capabilities and Azure Local's cloud-integrated approach, providing flexibility to match your organization's connectivity requirements and security posture.

---

*This section covers all connectivity models from traditional 30-day disconnected operations to new fully air-gapped deployments, helping you choose the appropriate model for your migration scenario.*
