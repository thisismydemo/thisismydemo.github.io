---
title: Intune Proactive Remediation - Check if KB5007253 is installed.
description: This is my experience using Proactive Remediation and how to install a KB if
  not isntalled.
date: 2023-01-31T15:53:58.920Z
preview: ""
draft: false
tags:
  - Intune
  - Proactive Remediation
categories:
  - Intune Proactive Remediation
lastmod: 2023-01-31T19:33:52.216Z
thumbnail: ""
lead: ""
---
I want to start this blog out by saying I am not an Intune expert.  In fact I don't really spend much time with Intune.  However, once in a while there are projects that require certain tools like InTune so once in a while I do get my hands on Intune. So I want to share what I have learned about Intune Proactive Remediation and how to create and apply them in your Endpoint environment.

### So What is Intune Proactive Remediation ###

At a high level Intune Proactive Remediation is a Microsoft Intune feature that enables administrators to automatically resolve common device issues such as outdated software versions, missing security updates, and incorrectly configured settings. The goal is to reduce the need for manual intervention by proactively maintaining the health and compliance of devices managed by Intune.

Proactive remediation packages consist of a detect and remediate script. These packages run on the client machine and according to Microsoft can detect and fix common support issues before they even realize there’s a problem. For this case, I am going to use proactive remediation script to detect if a if an required Windows Update has been applied and if it hasn't will install that Update.

### The Package ###

For more details on proactive remediation packages you can check out the following Microsoft Learn site, [Tutorial - Proactive remediation - Microsoft Endpoint Manager | Microsoft Learn](https://learn.microsoft.com/en-us/mem/analytics/proactive-remediations)

Let’s talk about the Detect and Remediate PowerShell scripts we will use for this proactive remediation package.

#### Detection Script ####

The detection script looks to see if a specific cumulative update is installed.  For this scenario, we have some requirements that KB5007253 needs to be installed in order for the Azure AD Kerberos functionality for hybrid identities to work on Windows 10 machines and mapping Azure Files.  Here the detection script checks that the update is installed.  If the update is not installed it will mark the system as non-compliant and then the remediation script will start.  If the update is installed, it will mark the system as compliant and exit.

```
<#
.DESCRIPTION
    Detects if the cumulative update KB5007253 - 2021-11 Cumulative Update Preview for Windows 10 is installed.
    If the installed it will marked as compliant.  If it isn't installed it will be marked as non-compliant then remediated.

.NOTES
    Author and Edited: Kristopher Turner (InvokeLLC)
#>

$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Detect-" + "WindowsUpdate-KB5007253-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

$update = Get-Hotfix -Id KB5007253
try {
    if ($update -eq $null) {
        # Install the update
        Write-Host "KB5007253 Needed"
        Exit 1
    }
    else {
        # Update is already installed
        Write-Host "KB5007253 update is already installed"
        Exit 0
    };
}
catch {
    $errMsg = $_.Exception.Message
    Write-Host $errMsg
    exit 1
}

Stop-Transcript
```

#### Remediation Script ####

The remediation script will only run if the machine was non-compliant.  Here is my remediation script. It is fairly simple, it just installed the KB that is needed.

```
<#
.DESCRIPTION
    Installs cumulative update KB5007253 - 2021-11 Cumulative Update Preview for Windows 10.

.NOTES
    Author and Edited: Kristopher Turner (InvokeLLC)
#>

$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Remediate" + "WindowsUpdate-KB5007253-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

# Install Update
Start-Process -FilePath "wusa.exe" -ArgumentList "/quiet /norestart /install /KB4565503" -Wait

Stop-Transcript

```
---------------------------