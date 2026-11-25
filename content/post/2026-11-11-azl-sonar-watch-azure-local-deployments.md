---
title: "AzL Sonar: Watch an Azure Local Deployment While It Runs"
description: An open-source, read-only monitor that shows every machine, every step and the live node logs of an Azure Local deployment in one local web page.
date: 2026-11-11T00:00:00.000Z
author: Kristopher Turner (Country Cloud Boy)
draft: true
preview: /img/azurelocal-sonar/banner.svg
fmContentType: post
slug: azl-sonar-watch-azure-local-deployments
lead: Every step, every machine, every log line, in one local page
thumbnail: /img/azurelocal-sonar/banner.svg
categories:
    - Azure
    - Azure Local
tags:
    - Azure Local
    - Azure Arc
    - PowerShell
    - Monitoring
    - Automation
lastmod: 2026-11-11T00:00:00.000Z
---

An Azure Local deployment runs for hours, and for most of that time the honest answer to "how is it going?" is "let me check". You refresh the portal. You open a remote session to the seed node and go looking through log folders. You compare what Azure says with what the node is actually doing, and sometimes they do not agree.

**AzL Sonar** puts all of that in one page. It follows a deployment while it runs: how each machine gets ready, how its operating system is configured, every validation and deployment step with its status and duration, and the live deployment logs from the seed node.

<!--more-->

> **Repository:** [github.com/AzureLocal/azurelocal-sonar](https://github.com/AzureLocal/azurelocal-sonar) (MIT license)

All the screenshots in this post are Sonar's built-in demo data, with example names only.

---

## What You See

![The Sonar page during a provisioning run: the modes, a card per machine, the steps and the live logs](/img/azurelocal-sonar/sonar-main.png)

The page reads top to bottom:

- **The top bar:** the cluster, the run status, the elapsed time, and when Azure last answered.
- **The modes:** one tile per stage of the deployment, Discovery, Provisioning, OS configuration, Validate, Deployment and Update. The tile of the stage that is happening now is selected. Click another to look back.
- **The summary:** one card per machine, with what it is doing now and what comes next.
- **The steps:** the step tree with live timers. A failed step shows its error text inline.
- **The live logs:** every line with its time, level and file, with filters by level, text, file and step.

## It Follows the Whole Route

Sonar is not only for the cluster deployment. It follows each stage that leads to it.

**Discovery.** Before anything is installed, the toolkit's hardware discovery reads each machine over its BMC. Sonar shows a card per machine with its service tag, ports and MAC addresses, the suggested management port, and anything to check first.

![The Discovery stage: a card per machine, one of them flagged for a check before provisioning](/img/azurelocal-sonar/sonar-discovery.png)

**Provisioning.** With [Azure Local ZTP](https://thisismydemo.cloud/post/azure-local-ztp-zero-touch-provisioning/) or Microsoft's simplified machine provisioning, Sonar shows each machine's lifecycle and the steps of its OS install. On the OEM image route it shows the Arc registration instead.

**OS configuration.** Each machine's method, steps, retries, the guarded network change and the domain join. A machine that fails says exactly which step failed and why.

![OS configuration: one machine converged, one failed on a driver step, one still applying](/img/azurelocal-sonar/sonar-osconfig.png)

**Validate.** The validation step tree, with the cluster card above it. The failure is at the top, in words.

![Validate failed: the cluster card names the failing check and the error](/img/azurelocal-sonar/sonar-cluster-validate.png)

**Deployment.** The nested deployment steps with live timers, next to the logs from the seed node as they are written.

![Deployment running: step 5 of 7, with the seed node's deployment log beside it](/img/azurelocal-sonar/sonar-cluster-deploy.png)

To watch one stage on its own, start Sonar with `-Monitor`, for example `-Monitor Validate`. It then shows only that tile and reads only what that stage needs.

## Read-Only, by Design

A monitor you run during a deployment must not be able to break the deployment. Sonar is built around that.

- **It never writes to Azure.** Every Azure call is a `GET`. Reader on the resource group is enough.
- **It never writes to a node.** It lists and reads log files with shared read access, so the deployment and log rotation are never blocked. It keeps no state on the node.
- **It never changes your workstation.** If a WinRM setting is missing, it tells you. It does not set it.
- **The page answers this machine only.** It listens on `localhost`, accepts only `GET`, and needs a per-start access token.
- **No secrets in the config file.** A password in the config is rejected. Log text is masked for common secret formats before it is stored, shown or exported.

Without access to the node logs Sonar still runs. The steps and machine status come from Azure, and the log pane tells you which account and folders to use.

![The Log access window: which account reads which log folders in each phase](/img/azurelocal-sonar/sonar-log-access.png)

## Nothing to Install

Sonar is a PowerShell 7 module that serves a local web page. There is no service, no database and no build step.

```powershell
git clone https://github.com/AzureLocal/azurelocal-sonar.git
cd azurelocal-sonar

Connect-AzAccount
./Start-AzlSonar.ps1 -InfrastructureFile ./infrastructure.yml
```

It reads the same master `infrastructure.yml` the [Azure Local toolkit](https://github.com/AzureLocal/azurelocal-toolkit) and ZTP use, so there is nothing else to write. If you do not use that file, a guided setup writes a small config file for you, or you can write one by hand.

Sonar starts the back end, asks once for the account that reads the logs, and opens the browser. Ctrl+C stops it. Nothing changes in Azure or on the machines.

**No cluster to watch yet?** Add `?demo=1` to the page URL and Sonar shows a running deployment from built-in sample data. It is the fastest way to see what the page does.

## Record a Run and Replay It

A deployment that failed at two in the morning is easier to understand the next day if you can watch it again.

```powershell
# Record while you watch
./Start-AzlSonar.ps1 -ConfigPath ./config/clus01.json -Record ./recordings/clus01.jsonl

# Replay later: no Azure sign-in, no node access
./Start-AzlSonar.ps1 -Replay ./recordings/clus01.jsonl -Speed 240 -StartAt deployment
```

A replay plays back through the same page. You can scrub to any moment of the run, and the step tree, timers, machine status and logs rebuild exactly as they were. Markers on the scrubber take you straight to Validate, Deploy, each main step, or a failure.

A normal recording keeps identifiers such as GUIDs, IP addresses and host names, so treat it like a log export. To share one, record with `-Publishable`: every identifier is replaced by a stable pseudonym, the file is checked afterwards, and it replays the same.

## Details Worth Knowing

![The Details pop-down: what Sonar is working from, and where each value came from](/img/azurelocal-sonar/sonar-details.png)

- **Details** shows what Sonar is working from: the target, the route, the nodes, the sources and how old each one is.
- **Export** downloads the whole run as one JSON bundle, without secrets.
- **A local HTTP API** serves the same data, so a pipeline step or a script can read the state of a run.
- **A dark theme**, because deployments finish at night.

![The dark theme](/img/azurelocal-sonar/sonar-dark.png)

## What to Know Before You Rely on It

- **Sonar is new.** The log folders and accounts are confirmed on a real two-node Azure Local deployment with Local Identity. The Active Directory entries come from Microsoft's documentation and are marked that way on the page.
- **Update, add node and repair are unverified against a live run.** They are built from Microsoft's reference and labelled as such.
- **It is a monitor, not a fixer.** Sonar never runs a check and never retries a step. It tells you what happened and, where it knows, what to do next.

## Try It

- **Code and docs:** [github.com/AzureLocal/azurelocal-sonar](https://github.com/AzureLocal/azurelocal-sonar)
- **Requirements:** PowerShell 7.4 or later, the `Az.Accounts` module, and read access to the resource group
- **First look:** start it and add `?demo=1` to the URL

If the page gets something wrong for your version or identity model, open an issue. That is how the "not yet confirmed" badges turn into "confirmed".
