## 4 High Availability, Clustering & Application Protection

VM uptime protection evolves from ESXi HA/DRS to Windows Failover Clustering with integrated Azure services for health monitoring.

Maintaining VM uptime during host failures or maintenance is just as crucial in Azure Local as in vSphere, and similar mechanisms exist:

**High Availability Architecture:** In Azure Local, Hyper-V hosts are joined in a **Windows Failover Cluster** (managed by Azure Arc). This provides high availability akin to vSphere clusters. When a host fails, the cluster automatically restarts VMs on surviving hosts - similar to VMware HA. The main difference is that Azure Local doesn't have DRS (Distributed Resource Scheduler) for automatic load balancing. Instead, you manually live-migrate VMs or create PowerShell scripts to balance load across hosts.

**Cluster Features Comparison:**
- **VMware HA:** Automatically restarts VMs after host failure with admission control
- **Azure Local Clustering:** Failover Clustering automatically restarts VMs with quorum-based protection
- **VMware DRS:** Automatically balances VMs across hosts based on resource utilization
- **Azure Local:** Manual live migration or PowerShell-based load balancing required

**Application-Level Protection:** Just like vSphere, you can implement application clustering (SQL Server Availability Groups, Windows Failover Clustering for applications) on top of the VM infrastructure. Azure Local supports guest clustering scenarios with shared storage via CSV volumes.

**Maintenance Procedures:** Similar to vSphere maintenance mode, you can put Azure Local hosts into "pause/drain" mode, which automatically live-migrates VMs to other hosts before maintenance. This is done through Windows Admin Center or PowerShell commands. Volume management (creating volumes, resizing, etc.) is handled separately via WAC or PowerShell for operational workflows.

**Recovery Time Differences:** Azure Local cluster failover typically takes 15-25 seconds to restart VMs after host failure, compared to VMware HA's similar timeframe. For zero-downtime scenarios, VMware's Fault Tolerance (FT) capability doesn't have an Azure Local equivalent - you rely on application-level HA instead.

**Fault Tolerance vs High Availability Reality:** Understanding the difference between VMware's protection options and Azure Local's approach is crucial for setting proper expectations:

| Protection Method | VMware Implementation | Azure Local Implementation | Business Impact |
|-------------------|----------------------|---------------------------|-----------------|
| **VM Restart (Most Common)** | vSphere HA (15-30 seconds) | Cluster Failover (15-25 seconds) | Equivalent brief outage |
| **Zero Downtime (Niche)** | Fault Tolerance (0 seconds) | Not available - use application clustering | FT users lose zero-downtime capability |
| **Live Migration** | vMotion (0 seconds) | Live Migration (0 seconds) | Equivalent planned maintenance capability |

**Resource Consumption Impact:** If you used VMware FT, you consumed 200% CPU and memory resources for zero-downtime protection. Azure Local cluster failover uses only ~10% cluster overhead, allowing higher VM consolidation ratios but with brief restart windows instead of zero-downtime protection.

**Application Protection Strategy Evolution:** VMware Application HA and monitoring translates to Windows Server Failover Clustering with different operational approaches:

**Application Monitoring Translation:**
- **VMware App HA:** Integrated vCenter monitoring with automatic service restart
- **Azure Local WSFC:** Generic Application cluster roles with PowerShell health check scripts
- **SQL Server Protection:** Shifts from vSphere HA VM restart to SQL Always On Availability Groups for database-level failover

**Multi-Tier Application Dependencies:** Application startup sequencing and VM placement change significantly:
- **VMware Approach:** DRS anti-affinity rules ensure VMs run on different hosts, Application HA groups manage startup ordering
- **Azure Local Approach:** Manual VM placement policies or PowerShell automation, WSFC resource dependencies manage application sequencing

**Operational Learning Curve:** The team should be prepared for a shift from vCenter's unified interface to PowerShell-based cluster management for advanced scenarios. This includes monitoring new cluster metrics which Azure Monitor Insights will help with, replacing vSphere's centralized monitoring approach.

**Bottom Line:** Azure Local provides equivalent VM-level high availability through Windows Failover Clustering for the majority of VMware customers who used vSphere HA. However, customers who relied on VMware Fault Tolerance lose zero-downtime protection and must implement application-level clustering instead. Live migration capabilities remain equivalent for planned maintenance scenarios, while DRS automatic load balancing requires manual management or PowerShell automation in Azure Local.

---

*This streamlined section covers HA fundamentals while eliminating overlap with storage architecture and VM lifecycle content.*
