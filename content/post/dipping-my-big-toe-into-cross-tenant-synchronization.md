---
title: Dipping My Big Toe Into Cross-Tenant Synchronization Part I
description: ""
date: 2023-04-04T15:04:07.465Z
preview: /img/crosstenantsync/my-topo.png
draft: true
tags: ""
categories: ""
lastmod: 2023-04-08T16:51:35.478Z
thumbnail: /img/crosstenantsync/my-topo.png
lead: Part I - I have a very big Big Toe!!!
slug: dipping-big-toe-cross-tenant-synchronization-part-I
---

So, I am very interested in What cross-tenant synchronization is and what it could do for me and maybe for customers?  Since I have a number of tenants I thought it would be good to at least try this preview feature and blog about my experience.

Also, this blog originally started out as a single blog but as I started to write it it grew and grew and grew.  I wanted to refocus myself and break it up into smaller parts.  The first part will focus on a single source to a single target topology.  That is all explained below.

So let me dive into my experience, good or bad?

Topics Covered in this blog:

1. What is Cross-Tenant Synchronization?
2. What are the prerequisites
3. Topology Planning
4. My Environment
5. Deployment
6. Defining User Scope for Provisioning


## What is Cross-Tenant Synchronization?

According to the [Microsoft Learn documentation](https://learn.microsoft.com/en-us/azure/active-directory/multi-tenant-organizations/cross-tenant-synchronization-overview):

Cross-tenant synchronization automates creating, updating, and deleting Azure AD B2B collaboration users across tenants in an organization. It enables users to access applications and collaborate across tenants, while still allowing the organization to evolve.

Here are the primary goals of cross-tenant synchronization:

* Seamless collaboration for a multi-tenant organization
* Automate lifecycle management of B2B collaboration users in a multi-tenant organization
* Automatically remove B2B accounts when a user leaves the organization

## Prerequisites

So I found that there are of course some perquisites required.  The biggest one is that all tenants will been to be licensed for Azure AD Premium P1 or P2. So on a few of my tenants I had to enable the trial of Azure AD Premium P2.

The following roles will be needed for the Source tenant:

* Security Administrator Role
* Hybrid Identity Administrator Role
* Cloud Application Administrator or Application Administrator Role

The following roles will be needed for the Target tenant:

* Security Administrator Role* Security Administrator Role

There is of course some planning that is needed.  However, I like to jump in and drive first, when it comes to learning new technologies.

1. I need to define our topology/structure of our tenants.
2. The Microsoft documentation says I need to learn how provisioning service works. I think I will do that as I keep moving forward and then go back and read about it?
3. I will need to determine which of my users will be in scope for provisioning.
4. Then I need to figure out what data I need to map between tenants.

All this is available to read more about on the Microsoft Learn Documentation for [Planning Your Provisioning Deployment](https://learn.microsoft.com/en-us/azure/active-directory/multi-tenant-organizations/cross-tenant-synchronization-configure#step-1-plan-your-provisioning-deployment).

## Topologies Planning

### Topology

My environment for testing will consist of a few tenants. So I have a few choices on how I can configure the my topology.  For example:

* Single Source with a single target
* Single Source with multiple targets
* Multiple sources with a single target
* Mesh peer-to-peer

For testing I wanted to see what I could do.  Single source with a single target seemed easier but I was curious.  I also needed to educate myself for future customer engagements so I wanted to try a more advanced topology.

The Mesh peer-to-peer really had my attention.  This topology would work great for organizations that need to have users flow across all tenants and enable people to access applications and resources in both directions.

![](/img/crosstenantsync/mesh-top.png)

The other three are pretty much one way synchronization. Which means users in Tenant A will have access to resource in Tenant B but not the other way around.

So Single source with a single target would be great for customers who want to have or manage all their users in Tenant A but have access to resources in Tenant B.

![](/img/crosstenantsync/singletosingletop.png)

The same with single source with multiple targets.  An organization may have multiple tenants but they just want to manage identities from Tenant A and have users sync to Tenant B, Tenant C, and Tenant D, etc. so they would have the same access to services in those tenants.

![](/img/crosstenantsync/single-multi-top.png)

The last, multiple sources with a single target would work the opposite in some sense.  An example here would be that users in tenants B, Tenant C, and Tenant D would need access to the parent Tenant A.

![](/img/crosstenantsync/multi-single-top.png)

Now, at least up until this point this is what my understanding of all these topologies are.  As I document this and actually configure this solution I may learn that my assumptions are wrong.

So, I will try and deploy a Mesh peer-to-peer topology however, I have decided to split up my blogs into various parts. So Part I will be about configuring two tenants as a single source and single target. From there I will continue to grow this experiment and convert that single source and single target into a mini Mesh deployment.  I will also try and blog about using the Portal and also using Graph API to accomplish all this.

### My Environment

I happen to have 4 tenants that I can use:

* Sheep and Cows (this is a good story.  Ask me about it.)
* Country Cloud Boy  (May explain a little bit about Sheep and Cows?)
* Living On The Edge
* This Is My Demo

Below is what my topology should look like when I am done.

![](/img/crosstenantsync/my-topo.png)

For Part I the topology will look like this:

![](/img/crosstenantsync/single-target-parti.png)

## The Deployment

So I am going to jump in and start driving...  I am hoping things go well? After all, this is a learning experience so I won't make stupid mistakes later.

So we start in the target tenant. I am going to start with one of my tenants I really don't use a lot and move forward with the rest later in other parts of this blog.

There are two ways that we can configure cross-tenant synchronization. Either from the Azure portal or from Graph API. I am planning to do the first target and source with the portal then maybe doing the rest or at least one tenant source and target using Graph API.

### Sheep and Cows / Country Cloud Boy Tenants using the Portal

As mentioned before, I will be doing this first set of tenants using the portal.  My target will be my sheepandcows.onmicrosoft.com tenant and my source tenant will be my countrcloudboy.onmicrosoft.com tenant.

#### Target Tenant Configuration - User Synchronization Enablement

To enable user synchronization on my target tenant, sheepandcows.onmicrosoft.com, I did the following:

1. From the portal, I logged in as an account that meets all the prerequisites mentioned above.
2. I then selected Azure Active Directory and then External Identities.
3. On the blade to the left I selected Cross-tenant access settings.
4. I then selected add organization and then typed in my source tenant which right now is going to be **countrycloudboy.onmicrosoft.com** and clicked Add.

![](/img/crosstenantsync/crosssync-001.png)

5. My source tenant now shows in the list under organizations found.  Here I clicked on Inherited from default under Inbound access.
6. On the page that popped up I selected Cross-tenant sync (Preview) on the menu at the top. Then I put a check in the **Allow users sync into this tenant** check box. Then of course I hit save at the bottom.

![](/img/crosstenantsync/crosssync-002.png)

#### Target Tenant Configuration - Configure automatic redeem Invitations

I am still in some ways following the Microsoft Learn documentation at this point. This step is allow the automatically redeem invitations so users from the source tenant don't have to accept the prompt. This will be configured on both the source and the target.

This was really easy, to accomplish this I did the following:

1. On my target tenant, **sheepandcows.onmicrosoft.com**, on thee same Inbound access settings page I was already on, I clicked the Trust settings tab.
2. Here I placed a check next to **Suppress consent prompts for users from the other tenant when they access apps and resources in my tenant** check box. Then I clicked Save.

![](/img/crosstenantsync/crosssync-003.png)

#### Source Tenant Configuration - Automatically redeem invitations

The following are the steps I followed for this step:

1. I signed on to the countrycloudboy.onmicrosoft.com tenant as a user with the proper rights as mentioned above.
2. I went back to Active Directory and External Identities.
3. Then selected Cross-tenant access settings.
4. Again, like the target tenant, I selected Organization settings and then I clicked on Add organization.
5. For the target I added **sheepandcows.onmicrosoft.com** then I clicked Add.

![](/img/crosstenantsync/crosssync-004.png)

6. Here instead of clicking on Inherited from default under Inbound access, I needed to click on inherited from default under Outbound access.
7. Then click Trust settings, and placed a check in the **Suppress consent prompts for users from my tenant when they access apps and resources in the other tenant** check box. Then click Save.

![](/img/crosstenantsync/crosssync-005.png)

#### Source Tenant Configuration - Create a configuration

In my source tenant, countrycloudboy.onmicrosoft.com, the following steps I took:

1. From Azure Active Directory, I clicked on Cross-tenant synchronization (Preview). Then clicked Configurations.
2. Here it asked me to provide a name for my configuration. I hadn't really thought of one so I decided to use **This Is My Demo Production**. Then I clicked Create.

![](/img/crosstenantsync/crosssync-006.png)

The documentation said it should take about 15 seconds for the configuration to show but mine took about a minute.

#### Source Tenant Configuration - Testing Connection to Target Tenant.

Again from my source Tenant, countrycloudboy.onmicrosoft.com I did the following steps:

1. From Active Directory clicked on Cross-tenant synchronization, then selected Configurations.
2. From the **This Is My Demo Production** configuration, I selected Provisioning under the Manage menu.
3. Here I changed Provisioning Mode from Manual to Automatic. Under Admin Credentials, Authentication Method needed to be set at Cross Tenant Synchronization Policy. Then I needed to add my target tenant, sheepandcows.onmicrosoft.com, tenant id.

![](/img/crosstenantsync/crosssync-007.png)

4. Here I needed to click **Test Connection**.

Oh what the flying cows????  I got the following error:

![](/img/crosstenantsync/crosssync-008.png)

Fortunately the [troubleshooting section](https://learn.microsoft.com/en-us/azure/active-directory/multi-tenant-organizations/cross-tenant-synchronization-configure#symptom---test-connection-fails-with-azuredirectoryb2bmanagementpolicycheckfailure) had the error and had a solution?

However, I wasn't too sure. It says the cause of the error indicates that the policy to automatically redeem invitations in both the source and target tenants wasn't setup.  However, I am pretty sure I did.

The solution is  te repeat the steps**Automatically redeem invitations in both the target and source**.

The first thing I did was look in the target tenant settings:

1. sheepandcows.onmicrosoft.com Active Directory, then External Identities, then Cross-tenant access settings.
2. Here I clicked on Inherited from default under Inbound access and then I selected Trust settings.

I was a little shocked to see that there was no check in the check box next to **Suppress consent prompts for users from the other tenant when they access apps and resources in my tenant**. I had sworn I had did this.  I must not have hist save?  So I checked it again and hit save.

This time, I noticed that it went from inherited from default to Configured under Inbound Access.

Here is a hint at least I think it may be a hint.  Since I am doing a Mess topology, I am going to assume that I will be doing the same under Outbound Access as well.  But we will wait until I get there before I find out if my assumptions are correct. You do know what assume means?  :)

Just to double check, I went back to the other settings to make sure it said configured as well.  This one said Configured so I think I just forgot to hit save on the inbound access.

Now back to our test......

After hitting Test Connection we have a successful test.

![](/img/crosstenantsync/crosssync-009.png)

At this point I clicked Save and made sure I clicked Save. This started the process for Updating user provisioning settings.

![](/img/crosstenantsync/crosssync-010.png)

Once this was successful, I saw two more sections pop up called Mappings and Settings. At this time I just closed this window to move on the the next steps.

### Defining User Scope for Provisioning

For this section everything is configured from the Source tenant which is countrycloudboy.onmicrosoft.com.  We are going to define who will be provisioned.  This will be done either by attributes of the user or assignment to the configuration.

The documentation says to start small.  However, if you don't go big then you shouldn't show up or something like that? Kidding, this is a non-production environment anyway.  I also only have about 2 users in each of these tenants anyway. So I will go big and include everyone.
