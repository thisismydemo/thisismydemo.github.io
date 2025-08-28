# Section 1: Core Virtualization Platform - Streamlined Preview

## 1 Core Virtualization Platform (Hypervisor & Infrastructure)

The foundation of your virtualization environment changes from ESXi to Azure Local (Hyper-V), maintaining enterprise-grade capabilities while integrating cloud services.

**Hypervisor:** VMware ESXi will be replaced by the **Azure Local operating system** (a specialized Hyper-V based OS). Both are bare-metal hypervisors with comparable performance and enterprise features. Hyper-V supports modern capabilities like virtual NUMA, nested virtualization, GPU acceleration, and memory management. For example, Azure Local supports GPU partitioning/pooling and even live migration of GPU-enabled VMs (similar to vMotion for VMs with GPUs). In practice, you should expect similar VM performance and stability from Hyper-V as with ESXi, as both are mature type-1 hypervisors.

**Clusters and Hosts:** In Azure Local, Hyper-V hosts are joined in a **Windows Failover Cluster** (managed by Azure Arc). This provides high availability akin to vSphere clusters. An Azure Local cluster can have 2–16 nodes; with 90 hosts, you would deploy multiple clusters (each cluster managed as a unit in Azure). Hosts in an Azure Local cluster use **Storage Spaces Direct (S2D)** for storage pooling – functionally similar to VMware vSAN in that each node's local disks form a shared, resilient storage pool across the cluster. If your VMware setup uses a SAN or NAS, Azure Local can accommodate that too (CSV volumes on external LUNs), but most deployments use S2D hyperconverged storage for best integration. Networking is provided by Hyper-V Virtual Switches; for advanced software-defined networking (comparable to NSX), Azure Local can integrate an **SDN layer** using VXLAN (optional), although many organizations simply use VLANs and the Hyper-V virtual switch.

**Licensing Note:** Azure Local uses a subscription-based licensing model (billed per physical core per month), unlike VMware's host licensing. Windows Server guest VMs still require licensing unless you use Azure Hybrid Benefits. It's important to factor this into planning, though the focus here is on technical features.

[Back to Table of Contents](#table-of-contents)

---

*This streamlined section covers the core hypervisor and infrastructure foundation, eliminating overlap with detailed storage (Section 5) and management tools (Section 2) content.*
