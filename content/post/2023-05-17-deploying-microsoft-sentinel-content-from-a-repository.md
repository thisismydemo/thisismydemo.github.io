---
title: Deploying Microsoft Sentinel Content From A Repository - Introduction
description: ""
date: 2023-05-17T15:11:44.578Z
preview: /img/sentinel_repository_into/Screenshot 2023-05-17 103948.png
draft: false
tags:
  - Azure DevOps
  - Microsoft Sentinel
  - GitHub
categories:
  - Microsoft Sentinel
lastmod: 2023-05-17T15:42:49.510Z
thumbnail: /img/sentinel_repository_into/Screenshot 2023-05-17 103948.png
lead: Digging deeper into my curiosity on how to deploy Sentinel using ADO or GitHub
slug: deploying-microsoft-sentinel-content-repository-introduction
---
So recently I have been dragged kicking and screaming into the security world.  Well, not really dragged, if you know me I am a large guy and it would be more like fork lifting me kicking and screaming?  Anyway, I actually love working with security products like Microsoft Sentinel, Defender for Cloud and the many other Defender for.. Products Microsoft offers, along with Identify solutions like Entra Permissions Management and more.

Recently I have been getting assigned a lot of Microsoft Sentinel projects at work.  Ranging from simple workshops all the way to full out enablement deployments of the solution.  Each has it's own differences as well as each project has something very in common, the content that gets deployed.  I have a few more of these projects lined up in my pipeline so wanted a way to automate as much as I could to save my time as well as my customers time. If you have had to onboard Sentinel via the Portal, there is a lot of click click click click click click that takes place.

I have found some cool solutions that have helped get me to a point with automation. One such solution is the [Sentinel-All-In-ONe](https://github.com/Azure/Azure-Sentinel/tree/master/Tools/Sentinel-All-In-One) which is now at version 2.  Over all this is a great way to get started when you need to onboard Sentinel. I highly recommend it if you are just needing to spin up a lab, a POC, or even a simple workshop for your customers or for yourself.

The solution that really caught my however is [deploying content from an Azure DevOps Repository or a GitHub Repository](https://learn.microsoft.com/en-us/azure/sentinel/ci-cd?tabs=github).

In my next few blogs I will discuss how my first attempt at learning about deploying content from a repository. As well as future blogs on how to customize the repositories if you have many customers you may be managing or even if you are just needing to customer it for your organizations onboarding of Sentinel. I really feel this is a solution that will be very beneficial to not just me but my customers as well.

Just like my blog series on Cross-Tenant Synchronization, you the reader will either learn from my mistakes or successes. I am looking forward to these blogs coming very soon!
