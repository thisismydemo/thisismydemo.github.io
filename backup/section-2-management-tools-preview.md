# Section 2: Management Tools and Interfaces - Streamlined Preview

## 2 Management Tools and Interfaces

Your centralized vCenter management transitions to a cloud-first approach with a clear management hierarchy that prioritizes Azure integration while maintaining local tools for specific scenarios.

**Primary: Azure Portal (Azure Arc Control Plane)** - Microsoft's official recommendation for Azure Local VM management. Once your clusters are registered with Azure Arc, the **Azure Portal** becomes your primary management interface. VMs created through the Azure Portal are "Arc VMs" with full Azure integration: RBAC permissions, Azure Hybrid Benefits, cloud monitoring, and unified management alongside Azure resources. Each Azure Local cluster appears as an Azure resource, enabling consistent governance across your hybrid estate. This replaces vCenter's centralized approach with cloud-native management that scales globally. In the Azure Portal, each Azure Local cluster appears as an Azure resource, and VMs are represented as "Arc VMs" resources. You can create, start/stop, delete VMs, configure virtual networks, and monitor resources all from the portal. Azure applies Role-Based Access Control (RBAC) for these resources, allowing you to assign granular permissions. For your enterprise environment, you might give development teams access to manage their own VMs (self-service) in specific clusters without exposing the entire 6-cluster infrastructure – something vCenter also allowed with custom roles, now achieved via Azure RBAC on Arc-enabled VMs.

**Secondary: Azure CLI and PowerShell** - For automation and advanced operations. **Az PowerShell** and **Azure CLI** manage Arc-enabled resources and provide Infrastructure-as-Code capabilities through ARM templates and Bicep. Traditional **PowerShell modules** (Hyper-V, Failover Clustering) handle underlying platform operations. This combination replaces PowerCLI for scripting and automation scenarios.

**Third: Windows Admin Center (WAC)** - Microsoft's direction is to manage Azure Local through the Azure Portal but it can be used for managing existing Azure Local clusters when cloud connectivity is unavailable (not in a fully disconnected scenario), managing traditional Hyper-V VMs, VM console access, and troubleshooting. WAC provides local cluster management with features like live migration, VM console access, performance charts, and cluster administration. Creates "unmanaged VMs" that cannot be managed through Azure Portal. Use primarily for troubleshooting and when disconnected from Azure. WAC provides local cluster management similar to vCenter's interface, but creates "unmanaged VMs" that lack Azure Arc benefits and cannot be managed through Azure Portal. Microsoft's direction is to manage Azure Local through the Azure Portal, but WAC is still an important tool for cluster administration **when cloud connectivity is unavailable or for some advanced settings**. WAC provides a UI to manage Hyper-V hosts and clusters (much like vCenter) and includes features like live migration, VM console access, performance charts, etc. You'll likely use WAC during for troubleshooting scenarios. Over time, expect more functionality to shift to Azure Portal, but WAC remains available (just as vSphere has both new HTML5 client and legacy vSphere client – WAC is analogous to a local client, while Azure Portal is the cloud-based UI).

**Last Resort: Traditional Tools for Troubleshooting** - **Failover Cluster Manager** and **Hyper-V Manager** are the "old way" of managing Windows clusters. Use these only for deep troubleshooting, diagnostics, or when you need to "dig into the clusters" for low-level investigation. These tools help with cluster status, shared volumes, VM console access, and host-specific configurations when other tools don't provide the needed visibility. In day-to-day operations, you won't use them often (WAC and Azure Portal cover most needs), but they are handy for low-level troubleshooting. **Failover Cluster Manager** lets you see cluster status, cluster shared volumes, and can be used to move roles (VMs) between hosts, configure cluster settings, etc., much like vCenter's cluster view. **Hyper-V Manager** allows direct management of VMs on a single host (e.g. to adjust VM settings or connect to a VM console). For your team, using these will feel different from vCenter, but they are occasionally useful for diagnostics or if GUI access is needed in a pinch on a specific host. Most routine tasks, however, will be done in the Azure Portal or WAC.

**Automation Tools (PowerShell/CLI):** VMware admins transition from PowerCLI to PowerShell for Azure Local management. Hyper-V and Failover Clustering operations use PowerShell modules, while Azure Arc resources utilize **Az PowerShell** and **Azure CLI**. Infrastructure-as-Code approaches include ARM templates and Bicep files for VM deployment.

**Note on System Center Virtual Machine Manager (SCVMM):** While SCVMM provided centralized management for earlier Azure Stack HCI deployments, this comparison focuses on Azure Local's native management tools and Azure integration. SCVMM remains valid for organizations with existing System Center investments, but the Azure-native approach represents the strategic direction.

### Tool Usage Decision Matrix

**When to Use Each Management Interface:**

| Operation Type | Azure Portal | Windows Admin Center | PowerShell | Best Use Case |
|---------------|--------------|---------------------|------------|---------------|
| **VM Creation** | Arc VM creation | Create VM wizard | `New-VM` | Portal: Standard ops, WAC: Local/emergency |
| **Performance Monitoring** | Azure Monitor | WAC performance tab | `Get-Counter` | Portal: Analytics, WAC: Real-time troubleshooting |
| **Live Migration** | Not available | Move VM wizard | `Move-ClusterVirtualMachineRole` | WAC: Interactive, PS: Automation |
| **Security Management** | Azure Policy/Defender | Local security settings | Security cmdlets | Portal: Policy, WAC: Local config |
| **Network Configuration** | Azure networking | WAC network settings | Network cmdlets | Portal: SDN, WAC: Traditional networking |

### Automation Transition Guide

**Scripting Framework Changes:**

| Automation Task | PowerCLI Approach | PowerShell/Azure CLI Approach |
|-----------------|------------------|------------------------------|
| **Bulk VM Operations** | `Get-VM \| ForEach-Object` | `Get-AzConnectedMachine \| ForEach-Object` |
| **Host Configuration** | `Get-VMHost \| Set-VMHostAdvancedConfiguration` | `Invoke-Command -ComputerName $Hosts` |
| **Resource Monitoring** | `Get-Stat -Entity $VM` | `Get-AzMetric -ResourceId $VM` |
| **Network Management** | `Get-VirtualSwitch \| New-VirtualPortGroup` | `New-NetAdapter \| Add-VMNetworkAdapter` |

### Critical Management Method Considerations

**Management Method Lock-in:** You cannot mix VM management approaches without losing functionality:

- **Azure Local Arc VMs** (created via Azure Portal): Managed through Azure Portal, CLI, PowerShell. **Cannot** be managed through Windows Admin Center.
- **Traditional Hyper-V VMs** (created via WAC/PowerShell): Managed through Windows Admin Center, Hyper-V Manager, PowerShell. **Cannot** be managed through Azure Portal.
- **Microsoft's recommendation:** "The recommended way to create and manage VMs on Azure Local is using the Azure Arc control plane."

**VM Restoration Limitations:** VMs restored from backup or Azure Site Recovery **lose their Azure Arc identity** and revert to traditional Hyper-V VMs:
- Restored VMs can only be managed through Windows Admin Center, Hyper-V Manager, or PowerShell
- Loss of Azure Portal management, RBAC permissions, and Azure Hybrid Benefits  
- Plan backup/DR procedures accounting for potential loss of Azure management capabilities

**Feature Gaps:** Arc VMs have limited Windows Admin Center support (marked with ❌ in Microsoft comparison tables), while WAC-created VMs have "limited manageability from the Azure Arc control plane, and fewer Azure Hybrid Benefits."

 > **Key Takeaway:** Azure Portal first, Azure CLI/PowerShell for automation, Windows Admin Center when cloud unavailable, traditional tools for troubleshooting only. Choose your VM management method carefully—it affects long-term manageability and disaster recovery.

**Bottom Line:** Azure Local's management hierarchy prioritizes cloud integration over local control. While this requires learning new Azure-native workflows instead of vCenter's unified approach, the result is enhanced RBAC, global scalability, and seamless hybrid cloud operations. Success depends on understanding when to use each tool and the irreversible consequences of management method choices.

---

*This section covers the management tool hierarchy and critical considerations for Azure Local administration.*
