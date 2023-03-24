---
title: Is my Azure Sphere a rock now?
description: ""
date: 2023-03-24T01:06:44.470Z
preview: /img/azsphereregister/register_004.png
draft: false
tags:
  - Azure Sphere
  - Azure IoT
categories:
  - Azure Sphere Development Kit
lastmod: 2023-03-24T01:19:29.368Z
thumbnail: /img/azsphereregister/register_004.png
lead: Yet another piece of Microsoft Hardware that is going into the rock draw
---

In a previous blog I wrote about having to recover my Azure Sphere Development Kit. So I decided to right one on what to do with it once I have recovered it. So this blog continues from [My Azure Sphere Needs Reset?](https://www.thisismydemo.cloud/post/my-azure-sphere-needs-reset/)

However..........

According to [Microsoft's documentation](https://learn.microsoft.com/en-us/azure-sphere/install/claim-device?tabs=cliv2beta#choose-a-tenant) on how to claim the device there is a call out:

> Claiming a device is a one-time operation that you cannot undo even if the device is sold or transferred to another person or organization. A device can be claimed only once. Once claimed, the device is permanently associated with the Azure Sphere tenant.

This I was not aware of nor could I do anything about since I last used this device when I worked for Microsoft for some demos on a tenant I no longer have access to.

First I wanted to see if the tenant it was claimed by showed up.  So I ran the following command:

```PowerShell
azsphere tenant list
```

It did not show any tenants so I thought I might get lucky.  So I went to create a tenant.....

So when I went to create a new tenant for this device I ran into a small problem:

```PowerShell
azsphere tenant create --name <tenant-name or tenant-ID>
```

![](/img/azsphereregister/register_004.png)

So I am thinking this device is now a rock?  I am stuck here until I can hopefully find answers on Twitter or LinkedIn.  Since I don't have support associated with any of my demo subscriptions I am at the mercy of the community.

I hope I can blog a more happier ending sooner than later.  However, until then I feel like this is just become another rock in my Microsoft hardware rock draw.  It will have to join my Azure Percept devices soon.