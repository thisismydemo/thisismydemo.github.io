---
title: Enable Windows Terminal on Windows Servers
description: How I was able to install Windows Terminal on Windows Server 2022
date: 2023-01-31T15:04:33.533Z
preview: /img/win-terminal/terminal_blog_14.PNG
draft: false
tags:
  - Windows Terminal
  - Windows Server
categories:
  - Windows Terminal
lastmod: 2023-01-31T17:39:48.118Z
thumbnail: /img/win-terminal/terminal_blog_14.PNG
lead: ""
---
Early this year I had written a blog talking about how to enable Windows Terminal on Windows Server.  However, I deleted that blog and all content and can't find my backups so I am re-writing it once again.  I wanted to share my experience with installing Windows Terminal on Windows Server and what I had to do to get around the blockers I ran into.  As I mentioned in the last blog I had ran into issues that other bloggers never seemed to run into when installing Windows Terminal.

To start I will show the error I was getting when trying to install the Windows Server installation package.

### What? Why the Error? ###

First, I pulled the installation package using PowerShell. The following is the command I used.  First I went to the [GitHub repo](https://github.com/microsoft/terminal/releases/tag/v1.16.10231.0) to get the most recent package version.

```
Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.16.10231.0/Microsoft.WindowsTerminal_Win11_1.16.10232.0_8wekyb3d8bbwe.msixbundle -outfile Microsoft.WindowsTerminal_Win11_1.16.10232.0_8wekyb3d8bbwe.msixbundle
```

![](/img/win-terminal/terminal_blog_01.PNG)

Then I went to install the package as documented using the following PowerShell command.

```
Add-AppxPackage Microsoft.WindowsTerminal_Win11_1.16.10232.0_8wekyb3d8bbwe.msixbundle
```

![](/img/win-terminal/terminal_blog_04.PNG)

But then the dreaded error because of some prerequisites are missing.

![](/img/win-terminal/terminal_blog_05.PNG)


I even tried using Chocolatey to install the package.  I have found there are times that Chocolatey would install dependencies.  However, in this case it failed as well.  However, same results.  However, it did install some of the other prerequisites that I needed.

![](/img/win-terminal/terminal_blog_06-install-chocoloty.PNG)
![](/img/win-terminal/terminal_blog_07-install-chocoloty.PNG)

### So How Did It Work? ###

I stumbled on a blog where someone mentioned another package that might need to be installed.  I wish I could find that blog to give credit but I can't remember the blogger and can't find it.  Anyway, going back to GitHub and looking at all the available packages available there is a 2nd package with a _PreinstallKit.zip available.

![](/img/win-terminal/terminal_blog_08.png)

I downloaded this package and extracted it to my source directory.

![](/img/win-terminal/terminal_blog_09.PNG)

Once I opened the file I noticed the Microsoft.VCLibs.140.00.UWPDesktop_14.0.3074.0_x64_8wekyb3d8bbwe.appx package.  If you look within the first error it doesn't show the name of the missing prerequisite.  However, if you look in the error on the Chocolaty install it does show the missing package which is this one.

![](/img/win-terminal/terminal_blog_10.PNG)


So I installed that package using the following PowerSHell command.

`
Add-AppxPackage Microsoft.VCLibs.140.00.UWPDesktop_14.0.3074.0_x64_8wekyb3d8bbwe
`
![](/img/win-terminal/terminal_blog_12.PNG)

Then I ran the Chocolaty installation again to install Windows Terminal.

![](/img/win-terminal/terminal_blog_13.PNG)

Installation was successful

![](/img/win-terminal/terminal_blog_14.PNG)

-------------
