---
title: Azure Stack HCI - Part VII - Configure Windows Admin Center Access
description: This is a series of blogs about my experiences with Azure Stack HCI
date: 2023-11-06T20:39:04.464Z
preview: /img/azshci-series/part-vi/windows-admin-center.png
draft: false
tags:
    - Azure Stack HCI
    - Windows Admin Center
categories:
    - Azure Stack HCI
lastmod: 2023-11-06T22:28:51.863Z
thumbnail: /img/azshci-series/part-vi/windows-admin-center.png
lead: This is a series of blogs about my experiences with Azure Stack HCI
slug: azure-stack-hci-part-vii-configure-windows-admin-center-access
---
In this blog series I plan to blog about everything I know about Azure Stack HCI. So, it should be a very short blog series. Just kidding. Again, I tend to blog about subjects that I am currently working on or will be currently working on. So, Azure Stack HCI is fresh on my mind again these days.

So this blog, which I hope will be short, will be about how to secure your access to the Windows Admin Center that is being used to manage your Azure Stack HCI cluster.  I will be honest, up until right before I just created this blog, I never really gave any thought to this.  Well, maybe some thought but since I don't really use WAC a lot, I never saw it as a need in my environment. Plus, I am the only one who has access to my lab environment anyway. (That I am aware of!)

So, we have our Windows Admin Center deployed and we have it registered with Azure. That is great, right? Well, not so great if you are just using the default security settings out of the box. In this blog I will walk through two ways to give users access to our Windows Admin Centers, the first is using Active Directory and the second is using RBAC via Azure and Entra ID (Azure Active Directory)

## Default Security Settings

Let's look at what is default out of the box first. As you can see in the image below we are not currently using Azure Active Directory (Entra ID) at this point to manage authentication. Neither are we using Multi-factor authentication. It currently is setup to allow Builtin\users to login and manage devices, and it is configured for all Builtin\Administrators the Gateway administrator role which gives anyone in that group rights to control access as well

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20144644.png)

We want to secure our gateway and control access to Windows Admin Center. This will and should improve the security around management of this environment.

## Using Active Directory

By using Active Directory and/or local machine groups for identity we can secure access locally. This may be all we need depending on the environment. If I stayed with this configuration in a production non lab environment I would add some managed Active Directory groups that would be assigned to one of the two roles.

I have created two new Active Directory security groups:

* WACGatewayUsers
* WACGatewayAdministrators

I will then add these two groups as Allowed groups on our Access settings page.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20154316.png)

As you can now see I have both groups added.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20154747.png)

My next step, i removed the BUILTIN\Users group. It will not let you via Windows Admin Center to remove the BUILTIN\Administrators group.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20154946.png)

So we are now a little more secure at this point and can control which users have access to Windows Admin Center by using Active Directory.

## Using Microsoft Entra ID (Azure Active Directory)

The better of the two options in my opinion will be for me to enable authentication to Windows Admin Center using Entra ID, or what was called Azure Active Directory. From the same Gateway access settings blade, we will flip the switch next to "Use Azure Active Directory to add a layer of security to the gateway" from no to yes.

Doing show will give us some instructions on how we need to configure our Azure AD Application we created earlier to give users access.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20155451.png)

By clicking on the link "Go to your Gateway Azure AD app in the Azure portal, it will open up our Azure AD app for us to configure.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20155635.png)

Here we will change the setting Assignment Required from No to Yes. Then we click save. At this point only users who have been assigned under the Users and Groups section under Manage or our Azure AD Group.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20160333.png)

My demo tenant doesn't have the active directory plan (Entra ID) to add groups to Users and Groups. In most cases you would already have created an Entra ID group for the two roles, one for Gateway Administrators and the other for Gateway Users and manage memberships from Entra ID.  So here, I just had to manually assign users.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20160623.png)

On the next screen I will assign them a role of Gateway Users under select a role. Then click Assign. I will repeat this to add any Gateway Administrators that I may need.

Now we should have all our users assigned either the Gateway User role or the Gateway Administrators role.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20160836.png)

We should now be able to log on to Windows Admin Center using our Entra ID credentials. So let's try it for Hagrid?

Let's go to our account settings screen and make sure we are signed out.  Then I will click on Sign In.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20161735.png)

Here I will put Hagrid's login information and click sign Next.

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20161622.png)

Within a few seconds and after verify via our Microsoft Authenticator app, Hagrid is now signed on. Your A Wizard Harry!

![](/img/azshci-series/part-vii/Screenshot%202023-11-06%20161536.png)

## Final Thoughts

Well, I really have none.  Just use Azure Active Directory or I mean Entra ID from now on. It makes RBAC so much simpler!