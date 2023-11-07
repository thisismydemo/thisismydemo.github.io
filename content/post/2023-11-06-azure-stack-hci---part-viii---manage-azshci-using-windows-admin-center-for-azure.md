---
title: Azure Stack HCI - Part VIII - Manage AzSHCI Using Windows Admin Center for Azure
description: This is a series of blogs about my experiences with Azure Stack HCI
date: 2023-11-07T14:07:49.528Z
preview: /img/azshci-series/part-vi/windows-admin-center.png
draft: false
tags:
    - Azure Stack HCI
    - Windows Admin Center
categories:
    - Azure Stack HCI
lastmod: 2023-11-07T14:08:08.009Z
thumbnail: /img/azshci-series/part-vi/windows-admin-center.png
lead: This is a series of blogs about my experiences with Azure Stack HCI
slug: azure-stack-hci-part-viii-manage-azshci-windows-admin-center-azure
---
In this blog series I plan to blog about everything I know about Azure Stack HCI. So, it should be a very short blog series. Just kidding. Again, I tend to blog about subjects that I am currently working on or will be currently working on. So, Azure Stack HCI is fresh on my mind again these days.

My last blog [Azure Stack HCI - Part VII - Configure Windows Admin Center Access](https://thisismydemo.cloud/post/azure-stack-hci-part-vii-configure-windows-admin-center-access/), was actually all about Windows Admin Center and nothing really about Azure Stack HCI. However, this blog is going to be focused on using Windows Admin Center for Azure (Preview) to manage our Azure Stack HCI clusters from anywhere without a VPN or a direct connection. So go get some coffee so I don't put you to sleep.

## Configuring Windows Admin Center Azure (Preview)

What better way to be able to manage your cluster than from the same portal you manage most your Azure environment from, right? Now, this is still a (Preview) services and things could change or not.  There are some limitations that I will call out later when managing your Azure Stack HCI cluster using Windows Admin Center for Azure vs using Windows Admin Center Gateway. They are small and if all you are looking for is to manage the cluster for day to day activities then this is a good tool.

We start by going to our Azure Arc and going to infrastructure, and Azure Stack HCI.  From there we will click on the cluster we want to enable WAC management on. When we get to the cluster blade, the next step is to click on Windows Admin Center (Preview).

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20164709.png)

Here we will see our option to click on Setup.  So, we click on setup.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20164806.png)

The first thing to happen is to the right a new blade will open for our listening port. I will use the default port of 6516. This will need to be open on your firewalls.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20164909.png)

Next we will see to task running.  This will install the AdminCenter extension and configure connectivity to WAC.  What this is actually doing, by installing the extension, is it is installing a version of WAC on each cluster node.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20164955.png)

Here we can see the status of that extension being installed.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20165120.png)

If we go back to the Windows Admin Center window we will get the message that this is being configured and could take about 5 minutes. Which means coffee time!

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20165237.png)

Once the extension are successfully installed we should be able to verify from the Extension blade on our cluster.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171044.png)

When we go back to our Windows Admin Center blade we will see that now we need to configure who can access this WAC instance. We can click the section that says Click to manage access and it will take us to the Access Control for this resource.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171018.png)

From here we will click add and select role assignment.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171122.png)

This next window we will search for Windows admin and it should filter it down to the exact role that we are looking for. Click on Windows Admin Center Administrator Logon. Then we click on Next.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171243.png)

On the next window we will click on + Select Members to add out members to this role assignment.  The pop up to the right, we will select our users or our groups we want to add.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171351.png)

The next window we can review the users we are adding to the role assignment. We can then click Review and Assign. It should take just a minute or two.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171438.png)

Now if we go back to the Windows Admin Center we will see a connect button. All we need to do is click Connect.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171522.png)

This will take a few minute for it to initialize for the first time.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171608.png)

Once it loads, it should look almost exactly the same as if we where logged on to the Windows Admin Center Gateway.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20171724.png)

As you can see and compare, the options that we have available to manage from Azure are very similar to the options we have locally.

![](/img/azshci-series/part-viii/Screenshot%202023-11-06%20172046.png)

There are a few differences. On the Azure version of WAC we don't have the capabilities to manage Azure Kubernetes Service. We also don't have the ability to configure Storage Replicas and Azure Arc settings.  Those are not the things that you will need to worry about, except maybe the management of AKS. This cluster doesn't have AKS installed yet so it may be available after AKS is installed. I will update this blog if that is the case.
