---
title: "Customize My WIndows Terminal Please? "
description: ""
date: 2023-02-01T14:59:27.749Z
preview: /img/wsterm_customize/wsterm_02.png
draft: false
tags:
  - Windows Terminal
categories:
  - Windows Terminal
lastmod: 2023-02-01T16:08:38.716Z
thumbnail: img/wsterm_customize/wsterm_02.png
lead: My favorite Windows Terminal customizations
---
Since I recently re-did a blog about how to install Windows Terminal I wanted to write a quick blog on some of my favorite customizations that I do for my Windows Terminal.

The three areas I always change are:

1. Open As Admin
2. Always on Top
3. Backgrounds for each profile. (ie, PowerShell, Azure Cloud, Ubuntu, etc).


So how exciting is it to look at this all day?

![](/img/wsterm_customize/wsterm_01.PNG)

Well, a few clicks here and a few clicks there can have your Windows Terminal looking a little more like yourself or at least a little like your own taste?

![](/img/wsterm_customize/wsterm_02.png)

Now, images are nice but when you are working a lot in Windows Terminal it is nice that it sits on top of other windows (if you have the screen space that is).  Also, most of use are running scripts and things that need elevated privileges to run.  It is always a pain to right click and open as Administrator all the time.  So why not setup Windows Terminal to always open as administrator, or at least Windows Powershell or Ubuntu.  You are not limited to just the entire application, you can specify which shell you want to open with elevated permissions as well.

So let's get started?

### Always On Top ###

For all three areas I will discuss in this blog we will be working out of settings from within Windows Terminal. To get to settings click on the down arrow to the right of the last tab and then click settings.

![](/img/wsterm_customize/wsterm_06.png)

The Startup screen has some very nice options. For instance, what profile do you want to luanch at default?  I always keep Windows PowerShell but here you can change it to CMD, Ubuntu, PowerShell Core, etc.  Also when Terminal Starts, do you want to start the default tab or restart on the tab you left off?  The one option that I never looked at but is really interesting is the New instance behavior.  This allows Windows terminal to open in the most used window or the most recently used window.

![](/img/wsterm_customize/wsterm_07.png)

Anyway, let's get back to what I am blogging about here.  How do I set Windows Terminal to stay always on top?

In settings just click on Appearance and Always On Top is located half way down.  Just flip it over to On.

![](/img/wsterm_customize/wsterm_08.png)

That was pretty simple and fast.

### Open As Admin ###

Now let's look how to set Windows Terminal to open as Administrator.

Open settings and look for Defaults under Profiles.  Halfway down you will see the setting that needs to be turned on. This will launch Windows Terminal as administrator for all profiles.

![](/img/wsterm_customize/wsterm_09.png)

If you wanted to just launch Windows PowerShell as Administrator just go to that profile and change it there and not in the Defaults profile.

![](/img/wsterm_customize/wsterm_10.png)

### Make My Terminal Pretty? ###

Now lets go over how to change your Windows Terminal backgrounds from boring to fun?

Open up settings, click on Appearance, then click on the profile you want to edit.  For this example I will use the Windows PowerShell profile.  Click on Appearance under Additional settings.

![](/img/wsterm_customize/wsterm_11.png)

Scroll down to Background Image, click browse and search for your image you want to use. Click Save once you have changes this setting.

![](/img/wsterm_customize/wsterm_12.png)

Next we want to look at a few things.  First I always set my images at 60% transparency. Scroll down and toward the bottom you should find the Transparency settings

![](/img/wsterm_customize/wsterm_14.png)

Then scroll up and we need to adjust the color scheme of the font.  For me and most my backgrounds the Ubuntu-ColorScheme works well.

![](/img/wsterm_customize/wsterm_13.png)

For each change you should be able to see what the shell should look like at the top of the screen.

Now you have pretty little Windows terminal backgrounds to look at while you work.  Here are some of mine:


![](/img/wsterm_customize/wsterm_15.png)

![](/img/wsterm_customize/wsterm_02.png)

![](/img/wsterm_customize/wsterm_03.png)

![](/img/wsterm_customize/wsterm_04.png)

![](/img/wsterm_customize/wsterm_05.png)


Feel free to play around and customize your own Windows Terminal experience.