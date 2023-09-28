---
title: MicroK8S and WSL Managed by Azure Arc
description: A blog series about my experiences with MicroK8S, WSL, and Azure Arc
date: 2023-09-27T16:00:00.000Z
preview: /img/microk8s_arc/wsl2.png
draft: false
tags:
  - Azure Arc
  - Kubernetes
  - MicrosK8S
categories:
  - Azure Arc-Enabled Kubernetes
  - Azure Arc-Enabled Servers
  - MicroK8S
lastmod: 2023-09-28T16:45:13.622Z
thumbnail: /img/microk8s_arc/wsl2.png
lead: A blog series about my experiences with MicroK8S, WSL, and Azure Arc
slug: microk8s-wsl-managed-azure-arc
keywords:
  - Azure Arc
  - MicroK8s
  - Windows Subsystem For Linux
  - WSL
---
I recently started a new job with a company that isn't a 100% Microsoft shop. It has been many years since I have worked in a environment that everyone wasn't drinking the Microsoft Kool-Aid. Not a bad thing if you do, I did and I loved that flavor. However, new job means new challenges and new way of doing things.

In this blog series I am going to discuss my experiences with MicroK8S.  Since that is a solution that seems to be one of the favorites in a lot of meetings I am in. So,sit right back and hear my tail, a tail of a fateful experience, that started from my lack of experience, aboard this MicroK8s ship!  The blogger a bearded and burly man, a learning, eager and pure.  Many people will try to read this blog, for a 3 hour technical deep dive for sure.  (Thanks Gilligan! I am guessing just my older readers will understand this one?)

The blog will be broken up into the following three sections:

1. [Installing MicroK8s on Windows Subsystem for Linux (WSL)](https://www.thisismydemo.cloud/post/microk8s-wsl-managed-azure-arc-part-ii-installing-microk8s-wsl/)
2. Azure Arc-enabled servers:  Installing Azure Connected Machine Agent
3. Azure Arc-enabled Kubernetes:  Connecting my MicroK8S cluster to Azure

Who knows?  I may extend this blog series to much more. Right now, I feel those are the 3 areas I am going to focus on.

