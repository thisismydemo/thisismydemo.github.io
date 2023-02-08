---
title: How To Grant Users Access To Entra Permissions Management Portal
description: ""
date: 2023-02-08T20:34:11.929Z
preview: /img/entra_user_management/epm_user_03.png
draft: false
tags:
  - Entra Permissions Management
categories:
  - Entra Permissions Management
lastmod: 2023-02-08T20:34:40.516Z
thumbnail: img/entra_user_management/epm_user_03.png
lead: ""
slug: grant-users-access-entra-permissions-management-portal
---
This is going to be one of those blogs that I write based off of things I didn't know but learned in the heat of the moment.

I want to be able to have a normal user get on to the Entra Permissions Management portal to request the needed permissions they need.  (This in itself is can be a blog and how to videos) So turned to Bing/Google/Chat GPT/My Dog... nothing. They all linked to how to manage users and groups within the Portal but only at an administrative level.

The Microsoft Documentation shows how to add users/groups to the Entra Management Portal at the Administrative level using the [management dashboard](https://learn.microsoft.com/en-us/azure/active-directory/cloud-infrastructure-entitlement-management/ui-user-management#manage-groups). In short, the documentation shows how to manage at a user level to see what permissions they are assigned.  It then discusses how to add groups to manage those permissions to the portal. Basically with three levels of permissions to Authorization systems:  Admin for all Authorization System Types, Admin for selected Authorization System Types, or Custom.

This is great for managing administrative task and controlling the level of permissions your administrations have within Entra Permissions Management.

However, the questions came up one day, How does a normal user access the portal to make a  request for more permissions?  In theory, this can be done using existing ITSM tools that may already be in place in your environment. These can easier be integrated with workflows for users to request permissions, admins to approve and deny, etc.

However, I knew that it could be done via the Entra Permissions Management portal without giving users anymore permissions to it then needed.  This was the part that isn't documented anywhere that I can find.  I reached out to a co-worker, sort of embarrassed that I didn't know this, for some help.  The good thing is, he had ran in this himself, and also found out how to assign the right permissions himself by accident.

So we don't want our users to see this error:

![](/img/entra_user_management/epm_user_03.png)

But we also don't want to give them permissions to see more than they need like this:

![](/img/entra_user_management/epm_user_04.png)

We just want them to be able to request more permissions and only see this:

![](/img/entra_user_management/epm_user_11.png)


### How Is It Done? ###

First we need to create an Azure AD Group. I have crated a few default groups to use for various levels of permissions to the portal. The group I will be using will be **EPM - User Portal Access**.  I also made this a dynamic user membership type and placed all active users in this group.

![](/img/entra_user_management/epm_user_01.png)

Now we need to login to the Entra Permissions Management portal. Once logged in click on the profile picture in the upper right hand.  Then select User management from the drop down menu.

![](/img/entra_user_management/epm_user_05.png)

We are going to create Permissions by clicking on Create Permissions.

![](/img/entra_user_management/epm_user_06.png)

On the Set Group permissions window, enter the newly created AAD Group, then select Admin for select Authorization Systems Types. Then click Next.

![](/img/entra_user_management/epm_user_07.png)

On the next screen leave everything blank and click Next.

![](/img/entra_user_management/epm_user_08.png)

On the next screen click Save.

![](/img/entra_user_management/epm_user_09.png)


Now our newly created AAD Group has been assigned permissions but no viewer, controller or approver permissions, to the portal.

![](/img/entra_user_management/epm_user_10.png)

At this point we will test one of users that do not have any special permissions to the portal.  Earlier the user would have gotten this when he tried to log on.

![](/img/entra_user_management/epm_user_03.png)

But now when he logs on he will see the following screen:

![](/img/entra_user_management/epm_user_11.png)

Now this is exactly what we wanted to see when a user that needs to request more permissions can see when they log on to the Entra Permissions Management portal.

I just wanted to note, this isn't how it is documented with Microsoft. In fact, as I mentioned above it isn't documented anywhere.  There may be a better way to manage this but this is how my co-worker discovered how to do it and how I will be doing it moving forward.

I can see another blog coming with even more information on how to manage users and permissions using Entra Permissions Management.

-------------------------