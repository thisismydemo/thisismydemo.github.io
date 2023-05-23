---
title: How to Integrate Microsoft Sentinel and Freshservice
description: ""
date: 2023-05-22T23:13:05.049Z
preview: /img/sentinel-freshservice/freshservice-025.png
draft: false
tags:
  - Microsoft Sentinel
  - FreshService
categories:
  - Microsoft Sentinel
lastmod: 2023-05-23T21:13:20.898Z
thumbnail: /img/sentinel-freshservice/freshservice-025.png
lead: Sometimes your customers can teach you a thing or two.
slug: integrate-microsoft-sentinel-freshservice
---
There are times even your customers can teach you something.  Recently while onboarding [Microsoft Sentinel](https://www.microsoft.com/en-us/security/business/siem-and-xdr/microsoft-sentinel) for a customer I ran into one of those times.  I had been asked by the customer to integrate Microsoft Sentinel with [Freshservice](https://www.freshworks.com/freshservice/).  Fresh service is one of many cloud based ITSM that I have run along my fun career.  I personally don't know much about Freshservice out side of the fact that my customer used it and had a use case where they wanted Sentinel to open a ticket in their system. Just like with all or most of my blogs, I write these in hopes that others can find a solution they are looking for but also, as I get older I forget a lot more than I remember.  This way I can search Bing once again in 6 months or a year and find my blog I wrote on this subject.

So this blog is about my experience integrating Microsoft Sentinel with Freshservice. So the three main areas I am going to write about are:

* Was there a playbook created already for Freshservice?
* Created A Freshservice account for testing.
* Created a playbook and logic app.

## Is there a playbook for Freshservice?

So when I started I did what we all do. I immediately went into the Content Hub to search for Freshservice. However, there isn't any Freshservice content available.  I couldn't find anything in any of the community repos I know about as well. Don't worry, there is hope.  I can dust off my logic app skills (the little I had) and try to create one.  Instead of creating one from scratch let's not re-invite the wheel.  From all the content solutions I have already installed I had two playbooks that I could use to copy. The first was the Create and Update Service Now Record provided and supported by the community.

![](/img/sentinel-freshservice/freshservice-001.png)

Then I also found a playbook from ZenDesk, [Create Zendesk Ticket](https://github.com/Azure/Azure-Sentinel/tree/master/Playbooks/Create-Zendesk-Ticket).  This was in the Content Hub and was created by Brian Delaney.

![](/img/sentinel-freshservice/freshservice-002.png)

Out of the two, the ZenDesk Logic App looked like the easiest for me to edit and use.  So  I went with the Create Zendesk Ticket playbook. More information below on how I created and configured the playbook for Freshservice.

## Freshservice Account
So, how do I even test this playbook to make sure it works. I never used [freshservice](https://www.freshworks.com/freshservice/), and I wasn't going to ask the customer for access to Freshservice. So I went to their website, and clicked Free Trial.  Why not?  Make sure when you click Free Trial that you select the correct product.  You will need to scroll down  to their IT Services PRoducts and click on Free Trial under Freshservice.

![](/img/sentinel-freshservice/freshservice-003.png)

It took maybe 5 minutes at the most before I had my account setup.

![](/img/sentinel-freshservice/freshservice-004.png)

![](/img/sentinel-freshservice/freshservice-005.png)

So now I have my account.  The next thing was to do some research on how to continue. I knew there was a logic app connector in preview for Freshservice. So the next step was to create the playbook.

## Create Playbook and Logic App
So at this point, I now have a Freshservice account that I can test with. I know the plan that I have, which is to create a playbook from the Create Zendesk Ticket template.

So step one was to go to my Microsoft Sentinel workspace.  From there I went to Automation under Configuration.  Under the Playbook Templates (Preview) I searched for Zendesk and then clicked on Create Playbook.

![](/img/sentinel-freshservice/freshservice-006.png)

The following steps I took to create the playbook:

1. On Create Playbook, on the Basics blade, I renamed the default playbook from Create-ZenDesk-Ticket to Create-FreshServiceITSM-Ticket.
2. On the Parameters blade I just ignored that. Since I would be deleting the ZenDesk connector anyway.
3. The next two blades, Connections and Review & Create I just left defaults.
4. Last I clicked, Create and continue to designer.

![](/img/sentinel-freshservice/freshservice-007.png)

Here I edited the Connections step:

![](/img/sentinel-freshservice/freshservice-008.png)

For this demo I just used my account to connect the logic apps to the proper Tenant.  However, you should really connect with a managed identity or at least a service principal account.  So don't do as I do, but do as I say?

The next step was to remove the Zendesk Connector and then add the Freshservice Connector. This part is fairly straight forward.  You click on the three dots to the right on the Zendesk connector then click Delete. To add the Freshservice connector, just click on the + New Step button.

![](/img/sentinel-freshservice/freshservice-009.png)

When you first click on the connector to add it, the next screen will prompt you to select an action.  Here I picked Create a Ticket (Preview). The other options is to update a ticket or and a note to a ticket.

Now it is time to edit the Freshservice connector. This is where things got really interesting.  Doing a Bing search, there is limited to no information out there on how to configure the Freshservice logic app connector.  I played with it for a while and found a few links that took me to the Freshservice community site.  There was a post that was over a year old with someone asking about authenticating and no one had responded.  Playing around more I did find a link that directed me to Freshservice and and article on how to create an API Key. However, still no clear documentation on how to actually configure the fields needed.

![](/img/sentinel-freshservice/freshservice-010.png)

I tried my username but then I was like, I never got a password. How do I log on to Freshservice anyway?  That is when I went back to the dashboard and saw I never verified my email account.  For some reason, all my Freshservice email went directly to spam. I found the email to verify my account, and verified it.  From there it ask me to create a password which I did. So my account is verified.

So from this point I was on my own.  So I tried just my username and password for the user name and password field. The one thing I need to call out, when you put your Site URL, don't add the / at the end. It doesn't like that.

At this point I clicked Create.

![](/img/sentinel-freshservice/freshservice-013.png)

So it looked like it worked!!!  (Hint, this is sarcasm)

![](/img/sentinel-freshservice/freshservice-014.png)

So once again, I am at a section that I can't find any documentation for. What is the Requester ID?  It is asking for an integer and an email address that I tried associated with my account wouldn't work. I tried a few different combos.

I did what anyone would do. I just started filling out stuff. I assumed I could find that ID in the Freshservice dashboard for my user profile. I couldn't find anything. So i made up a number and put it there.  The rest was pretty simple to follow.  The rest is just like any other logic app in Sentinel. I went simple for this one.  For subject, I selected some dynamic content for a Microsoft Sentinel incident.

![](/img/sentinel-freshservice/freshservice-015.png)

I clicked Save. The logic app save was completed and I thought, hey, this was easy.  Let's test!

Note, I did find that if I selected any Dynamic content based off "alerts" that it would change the logic app and this step to For Each.  Maybe someone with more Logic App experience can explain that to me. I am assuming something because it was an Alert and not an Incident but you know what assume means?

The easiest way to test a playbook is to go back to Microsoft Sentinel, click on incidents, select an incident. Then in then in the Incident information blade to the right, at the bottom there is a dropdown called Actions.  Select Actions and then select Run Playbook (Preview).

![](/img/sentinel-freshservice/freshservice-016.png)

At the Run Playbook on incident blade, click on Run next to the playbook that was just created.

![](/img/sentinel-freshservice/freshservice-017.png)

Now, again. Great, the playbook ran and looked to be successful. But was it????  Let's go back to the playbook and open it to see what the logic apps status is.  I still haven't received a ticket yet in Freshservice so something didn't work. To get back to the logic apps, click on automation under configuration. Click on active playbooks at the top, and then select the playbook just created which my case is the Create-FreshServiceITSM-Ticket. To my surprise, the logic app ran successful.  Yet still no ticket???

![](/img/sentinel-freshservice/freshservice-018.png)

So something is wrong. Going back to the Logic App Designer I was interested in what my Requester Id was? How do I get that from Freshservice and did I really connect successfully to the Freshservice API? I didn't even enter an API key or username for that API key. I went back to the community forums and posted a question.  I wasn't expecting an answer right away. Which I don't think I even have one now. I sent a message via chat on the Freshservice support page but sat there for a long time with no response.  I was stuck and now I had to get back on a call with my customer to do more work on this project.

Luckily, the customer actually had experience the logic app connector for Freshservice in the past.  Which, now I was about to learn something from my customer instead of the other way around.  He explained how to get the Freshservice connector first connected and authenticated. Again, there is no documentation out there that I could find so I went with what the customer said.

So let's go back to the connector and change the connection. To do so, from the designer, just click on the Change connection on the Create Ticket step. For this purpose, I created a new connection.  Named it FreshServiceAPIConnection.  Now get this, the password is just any character. My customer told me to just put an X or something in that field. The site URL is the same I used before, https://thisismydemo.freshservice.com without a / at the end. The user name is the API Key.

The API key can be generated from the profile screen.  Now the question is, and I don't know, can you create a service account or some kind of managed identity in FreshService for this? Using an API key from a standard user account seems a bit unsecure and questionable for this?

![](/img/sentinel-freshservice/freshservice-012.png)


So now I have my information on the Connection screen for the Freshservice connector.

![](/img/sentinel-freshservice/freshservice-019.png)

Just like before the connection was made. However, now when I go to Requester ID, if I click the dropdown I do get user accounts.  The problem is, these are user accounts.  These are not service accounts, or even my admin account.

![](/img/sentinel-freshservice/freshservice-020.png)

So my customer once again gave me some knowledge. He showed me how to get the Requester Id from my account.  The easiest way was to go to your profile and within the URL the number show is the requester id.

![](/img/sentinel-freshservice/freshservice-021.png)

So now I have my requester Id correctly.  Let's see what happens when I click save and try to run the playbook again?

![](/img/sentinel-freshservice/freshservice-022.png)

The playbook saved just fine. Now let's go test the playbook again. To do this, we go back to Sentinel, under Threat Management click on Incidents.  Select an incident, then on the incident information blade to the right, click on the Actions drop down menu at the bottom, then click on Run Playbook (Preview). Then on the Run playbook on incident blade, select the playbook we want to run and click run.

Again, the playbook ran successfully. However, within seconds I got an notification in my Freshservice dashboard that a new ticket was created.

![](/img/sentinel-freshservice/freshservice-023.png)

Now it is time to go back to the Logic App and start to customize the information that will be sent with the ticket.  We also want to crate an automation rule that will run this playbook automatically based off specific criteria.

The one thing I did notice is on the ticket in Freshservice it came in as a low priority. However, that incident in Sentinel was a Medium incident.  I will need to dig deeper in how to map the severity in Freshservice.

![](/img/sentinel-freshservice/freshservice-024.png)

However, over all it was a success.  I was able to create a ticket in Freshservice from incidents triggered in Microsoft Sentinel.  There are things I would like to find out and maybe Freshservice can email me some things like documentation and explain some of my issues above? But overall, the job is done and what the customer needed and expected has been accomplished. I will keep playing and seeing what else can be done. There doesn't look to be away to have two way communication, so closing a ticket in Freshservice doesn't trigger a playbook in Sentinel to close the incident. I will be interested in seeing how a ticket can be updated from other playbooks that I will create. However, I don't think I will spend too much more time on this.
