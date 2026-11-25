---
title: "Azure Local ZTP: Bare Metal to Arc in One Command"
description: An open-source tool that automates Microsoft's simplified machine provisioning for Azure Local end to end, with no USB stick and no one in the rack.
date: 2026-11-11T00:00:00.000Z
author: Kristopher Turner (Country Cloud Boy)
draft: true
preview: /img/azurelocal-ztp/banner.svg
fmContentType: post
slug: azure-local-ztp-bare-metal-arc-command
lead: One file, one command, no USB stick, no one in the rack
thumbnail: /img/azurelocal-ztp/banner.svg
categories:
    - Azure
    - Azure Local
tags:
    - Azure Local
    - Azure Arc
    - PowerShell
    - Automation
    - Zero Touch Provisioning
lastmod: 2026-11-11T00:00:00.000Z
---

Getting the operating system onto an Azure Local machine has always been the part of a deployment that needs a person. Someone builds a USB stick, someone walks to the rack, someone watches a console. Multiply that by the number of nodes and the number of sites, and the "cloud" part of the project starts a long time after the hardware arrives.

Microsoft's [simplified machine provisioning (preview)](https://learn.microsoft.com/azure/azure-local/deploy/simplified-machine-provisioning) changes the model: you boot a small maintenance environment, the machine produces an ownership voucher, you claim the machine in Azure, and Azure installs the OS and connects it to Azure Arc. It is a big step forward. It still starts with a USB stick per machine and a list of manual steps in the portal.

<!--more-->

**Azure Local ZTP** removes those too. It is an open-source PowerShell tool that runs the whole flow from a management host, over the BMC, for every node in parallel.

> **Repository:** [github.com/AzureLocal/azurelocal-ztp](https://github.com/AzureLocal/azurelocal-ztp) (MIT license)

---

## What Microsoft Gives You, and What Is Still Manual

![The Machine provisioning (preview) page in the Azure portal](/img/azurelocal-ztp/portal-machine-provisioning.png)

The portal lays the feature out as three steps: download and install the maintenance environment, provision the machines, deploy the cluster. Step one is where the hands are. For each machine you prepare boot media, boot from it, wait, and collect the voucher. Only then can Azure take over.

ZTP automates step one and step two. Step three, the cluster, is deliberately left to the tools that already do it.

## What ZTP Does

You fill in one file, `infrastructure.yml`: the machines (name, serial, BMC, the MAC of the management port), the network, the BIOS values you want, and the Azure subscription, resource group and site. Secrets are never in the file. It holds Key Vault references only.

Then one command does this:

1. Downloads and checks the maintenance ISO, and builds one virtual USB image per node.
2. Sets the BIOS values the file names, and boots each node from its image over the BMC (Redfish virtual media), all nodes in parallel.
3. Reads each node's ownership voucher back from its image.
4. Sets each static management address on the port with the node's management MAC, in the maintenance environment, before the claim.
5. Claims the machines in Azure with a Bicep template, waits for "Ready to cluster", and resubmits a failed OS install once.
6. Checks each management address on the management port through Azure.
7. Sets back any BIOS value that was changed for the install only, and waits until each machine is Connected again.
8. Writes a handoff file with each machine's Arc machine name and resource ID.

![The ZTP flow from infrastructure.yml to the handoff, across the operator, the management host, Azure and the machine](/img/azurelocal-ztp/ztp-flow-to-handoff.png)

Each stage starts only when the gate before it passes. A gate that fails stops the run and says why. Run the same command again and it resumes where it stopped, skipping the stages that are done.

## Running It

On a Windows management host that reaches the BMCs, in an elevated PowerShell 7 session:

```powershell
git clone https://github.com/AzureLocal/azurelocal-ztp.git
cd azurelocal-ztp

# Plan: changes nothing in Azure, on the BMCs or on the nodes
Connect-AzAccount -Tenant <tenant-id>
./scripts/simplified-provisioning/Invoke-ZtpEnvironment.ps1 -InfrastructureFile D:\ztp\infrastructure.yml

# Execute: REINSTALLS the nodes. Run the same command again to resume
./scripts/simplified-provisioning/Invoke-ZtpEnvironment.ps1 -InfrastructureFile D:\ztp\infrastructure.yml -Execute
```

The plan run is the part I would not skip. It validates the file and tells you what the run will do before anything is touched. The execute run reinstalls the nodes, so treat it with the respect that deserves.

The file is the same master `infrastructure.yml` (schema 5) that the [Azure Local toolkit](https://github.com/AzureLocal/azurelocal-toolkit) reads for OS configuration and cluster deployment. Fill it in once, and every tool after ZTP reads the same values. A ZTP-only template is there if that is all you need.

## Watching a Run

A run takes a while, and most of that time is Azure installing the OS. ZTP writes every state change to an event file, and [AzL Sonar](https://github.com/AzureLocal/azurelocal-sonar) reads that file next to what Azure reports, so you can follow each machine through each stage in a browser.

![AzL Sonar following a ZTP run of three machines: two complete, one installing the OS (demo data)](/img/azurelocal-ztp/sonar-ztp-run.png)

Sonar is read-only and has its own post: [AzL Sonar: Watch an Azure Local Deployment While It Runs](https://thisismydemo.cloud/post/azl-sonar-watch-azure-local-deployments/).

## What You Have at the End

Each machine is **Provisioned** in Azure and **Arc-connected**, and the handoff file says, per node and per port, whether the management port has the address your file gives it.

That last part depends on how the management address is assigned:

| Mode | The management port after ZTP |
| --- | --- |
| A: DHCP with a reservation (recommended) | Its reserved address. Nothing more to do |
| B: Static, with DHCP on the network | A DHCP address. The OS install resets the static address ZTP set |
| C: Static, no DHCP on the management network | No address. Arc reaches the node over the provisioning port |

Modes B and C are supported, but the static address is not in place when ZTP finishes, because Microsoft's OS install resets every port. OS configuration sets it afterwards, by MAC.

## What It Does Not Do

I would rather you hear this from me than find it out in the rack.

- **The Microsoft feature is in preview.** Provisioning resources are in East US only, and Arc gateway is not supported.
- **It is proven on one platform.** The end-to-end flow has run on Dell AX-760 with iDRAC, two nodes. BMC handling is proven on Dell iDRAC only. The AX-760 is also not on Microsoft's validated hardware list for this feature: it works, but Microsoft does not support it.
- **It stops at the handoff.** ZTP does not install OEM drivers, stage the Solution Builder Extension, turn DHCP off on the other ports, set DNS or time, or create the deployment admin. That is OS configuration, and it comes next. The nodes are ready for OS configuration, not yet for Validate.
- **Find network ports by MAC.** Machines built this way name their ports `Port0` to `Port6`. Any script that runs afterwards must find a port by its MAC, not its name.

## What Comes Next

The handoff file and the same `infrastructure.yml` feed the next phase: [Phase 03, OS Configuration](https://azurelocal.cloud/docs/implementation/04-cluster-deployment/phase-03-os-configuration/) on azurelocal.cloud, then Active Directory preparation, Validate and Deploy.

## Try It

- **Code and docs:** [github.com/AzureLocal/azurelocal-ztp](https://github.com/AzureLocal/azurelocal-ztp)
- **Start with:** the Prerequisites page, then the Operator guide
- **Pipelines:** examples for Azure DevOps, GitHub Actions and GitLab CI are in the repository
- **Tests:** `Invoke-Pester ./tests/simplified-provisioning` runs against recorded fixtures, with no hardware and no Azure

If you run it on hardware other than Dell, I would like to hear how it goes. Open an issue with what you saw.
