# Section 3: VM Lifecycle Operations - Streamlined Preview

## 3 Virtual Machine Lifecycle Operations

Daily VM management remains familiar with equivalent capabilities for provisioning, migration, and maintenance operations.

Daily VM operations in Azure Local will feel familiar, with analogous features to vSphere for creating, running, and modifying virtual machines:

**VM Provisioning & Templates:** In vSphere, you might clone from templates. Azure Local doesn't use vCenter templates in the same way, but you have a few options:

- Through Azure Portal, you can create a new VM (Arc VM) and specify an image or existing VHD. Azure Local can integrate with Azure's image gallery, or you can keep a library of golden VHD(X) images (similar to templates) on a file share. While not as GUI-integrated as vCenter templates, using scripting or WAC's "Create VM from existing disk" achieves a similar result. Additionally, Azure Resource Manager templates can define a VM shape (vCPU, memory, OS image, etc.) for consistent deployment across clusters.
- **Sysprep and clone:** You can sysprep a VM, shut it down, and copy its VHDX to use as a master image. This is analogous to how many admins create VMware templates (which are essentially VMs marked as template).
- Azure Local also supports **Cloud-Init** for Linux and **VM customization** tasks via Azure Arc, which can inject configuration into new VMs similar to VMware guest customization.

**Live Migration (vMotion):** VMware's vMotion allows moving running VMs between hosts with no downtime. Hyper-V's equivalent is **Live Migration**, and it's a core feature of Azure Local clusters. You can initiate a live migration through WAC or Failover Cluster Manager (by moving the VM role to another node) – the VM continues running during the move, just like vMotion. Live Migration performance and limits are comparable to vMotion; it uses a dedicated network (or networks) to transfer memory and state. In practice, you'll put a host into "**pause/drain roles**" mode (maintenance mode) which automatically live-migrates its VMs to other hosts, allowing patching or hardware maintenance – similar to vSphere's maintenance mode + DRS.

**VM Snapshots (Checkpoints):** VMware "snapshots" have a parallel in Hyper-V called **checkpoints**. You can take a checkpoint of a VM's state, do changes or backups, and later apply or discard it. Standard checkpoints save the VM's disk and memory state. Azure Local supports both standard and "production" checkpoints (production checkpoints use VSS in the guest to create a disk-consistent point-in-time without saving memory, ideal for backups). The experience is similar: you can create a checkpoint in WAC or PowerShell, and if needed, revert (apply) that checkpoint to roll back a VM.

**Cloning and VM Copies:** If you need to duplicate a VM, the process isn't one-click clone as in vCenter, but it's straightforward: you can export a VM (which copies its VHDX and config) and import it as a new VM. WAC has an **"Export VM"** action, or you can use PowerShell cmdlets to accomplish a clone. Alternatively, as mentioned, keep a library of prepared images for quick deployment.

**VM Tools and Integration Services:** In vSphere, VMs run VMware Tools for optimized drivers and guest OS integration. Azure Local uses **Hyper-V Integration Services** – analogous tools providing driver optimization (for storage, network, etc.) and guest integration (for time sync, shutdown, heartbeat, VSS, etc.). The good news is that modern Windows and Linux OSs include Hyper-V integration components by default (Windows has them built-in, Linux distributions have Hyper-V drivers in the kernel).

**Console Access:** vSphere offers a web console or remote console to VMs. With Azure Local, if you're using the Azure Portal, there isn't a built-in VM console viewer for Arc VMs at this time – you would typically connect via RDP or SSH as you would for any server. However, using Windows Admin Center, you *do* have an HTML5 VM console for each VM (it uses VMConnect behind the scenes).

**Resource Allocation & Performance Settings:** All the VM hardware settings you're used to in VMware exist in Hyper-V, though sometimes under different names. For CPU and memory: you can set vCPUs, reserve or limit CPU capacity (via Hyper-V "virtual machine reserve" or setting processor weight, analogous to VMware shares/reservations). Memory can be fixed or "Dynamic Memory" – Hyper-V's form of memory overcommitment. Dynamic Memory can automatically adjust a VM's memory between a minimum and maximum, based on demand, which is somewhat comparable to VMware's ballooning/overcommit.

**Bottom Line:** Azure Local VM lifecycle operations provide equivalent functionality to vSphere with different management interfaces. While VMware consolidates most operations in vCenter, Azure Local splits between cloud-based Azure Portal for Arc VMs and local Windows Admin Center for direct management. Your team will need to adapt to PowerShell-centric automation and distributed management tools, but core VM operations remain familiar with similar performance settings and resource allocation options.

---

*This streamlined section covers VM lifecycle operations while eliminating overlap with management tools and storage content.*
