---
title: My Azure Sphere Needs Reset?
description: How do you recover an Azure Sphere Development kit?
date: 2023-03-23T19:51:12.724Z
preview: /img/azspherereset/Screenshot 2023-03-23 150752.png
draft: false
tags:
  - Azure Sphere
  - Azure Sphere Development Kit
  - Azure IoT
categories:
  - Azure Sphere Development Kit
lastmod: 2023-03-23T20:16:21.344Z
thumbnail: /img/azspherereset/Screenshot 2023-03-23 150752.png
lead: How do you recover an Azure Sphere Development kit?
---

So I needed to break out my Azure SPhere Development kit again that I haven't touched in a very long time.  Since then, the tenant my Azure Sphere was registered to has changed, and along with other things like my memory in my aging head, I couldn't remember for the life of me how to access the kit.

So this blog is mainly for me so in 6 months when I need to use my Azure Sphere development kit again I will have a quick and easy reminder.

## How did I reset it

The first step was to get all the needed tools installed that I hadn't installed on my new work laptop.  There are a few ways to manage an Azure Sphere.

1. Via Windows CLI
2. Via Visual Studio Code
3. Via VIsual Studio
4. Via Linux CLI

I went the route of the WIndows CLI and Visual Studio Code installation.

## Visual Studio Code

For Visual Studio Code you will need to install the following two extensions:

1. Azure SPhere
2. Azure Sphere UI

However, if you install one, the other will automatically install.

There are a few more things that need to be installed on your Windows device but these items are needed as well with the WIndows CLI installation.

## Windows CLI Installation

For the installation for Windows CLI you will need to install the Azure SPhere SDK.  You can download this at [Azure Sphere SDK Download](https://aka.ms/AzureSphereSDKDownload/Windows).  Once downloaded just run the installation.

As with the Visual Studio Code installation there are some more installations that are needed.

## CMake and Ninja for Windows

For both VS Code and the WIndows CLi you will need to install CMake and Ninja for Windows.  I did this using the Chocolaty installation.

1. choco install ninja
2. choco install cmake

I rebooted my machine after but not sure if that was needed.  In doubt, reboot!  :)

## Recovering the Azure Sphere Development Kit

I called it resetting the device, however Microsoft calls it recovering the device.  This was farley easy once I had the tools installed.

Open your Windows Terminal and simply type the following command:

```powershell
az device recover
```

![](/img/azspherereset/Screenshot%202023-03-23%20150752.png)

The  Azure Sphere development kit was recovered successfully and now I can move on to the next steps of claiming my device.
