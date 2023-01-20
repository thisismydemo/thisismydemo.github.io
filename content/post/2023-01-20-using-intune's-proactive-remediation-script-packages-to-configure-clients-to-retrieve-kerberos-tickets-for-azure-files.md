---
title: Using Intune's Proactive Remediation Script Packages to configure clients to
  retrieve Kerberos tickets for Azure Files.
description: ""
date: 2023-01-20T16:33:32.103Z
preview: ""
draft: true
tags:
  - Azure Files
  - Intune
  - PowerShell
  - Poractive Remediation
categories:
  - Azure Files
  - Intune
lastmod: 2023-01-20T17:34:03.379Z
thumbnail: img/intune_header.png
lead: ""
---
In order to map an Azure File share with Azure AD Kerberos authentication for hybrid user accounts enabled you need to make sure that you configure the clients to retrieve Kerberos tickets.

There are three methods that can accomplish this on your client computers.

1. Configure an Intune Policy and apply it to the clients.
2. Configure Group Policy on the clients
3. Apply a registry value on the client.

I am going to use the registry method, but I will also be using Microsoft's Intune Proactive remediation. Proactive remediation is part of Endpoint Analytics. The devices must be enrolled into Endpoint analytics in order for this to work.

[Quickstart - Enroll Intune devices - Microsoft Endpoint Manager](https://learn.microsoft.com/en-us/mem/analytics/enroll-intune)

Proactive remediations are package that consist of a detect and remediate script. These packages run on the client machine and according to Microsoft can detect and fix common support issues before they even realize there's a problem. For this case, I am going to use proactive remediations to detect if a registry key exists and has a certain value and remediate it if it doesn't exist or the wrong value is configured.

* * * * *

The Proactive Remediation Package
---------------------------------

For more details on proactive remediation packages you can check out the following Microsoft Learn site, [Tutorial - Proactive remediations - Microsoft Endpoint Manager | Microsoft Learn](https://learn.microsoft.com/en-us/mem/analytics/proactive-remediations)

Let's talk about the Detect and Remediate PowerShell scripts we will use for this proactive remediation package.

### Detect Script

The detection script will look to see first if the path for the registry value exists. If it doesn't it will exit with a code 1 and write an error "Registry key doesn't exist" If the path does exist, it will check to see if the registry key exists and if the value of that key is 1. If it isn't a value of 1 the script will exit with a code 1. If any code 1's is returned, the script will exit, and the client machine will be marked as noncompliant within Intune's Proactive Remediation package section. The proactive remediation package will then run the remediate script. If it returns a code of 0, Intune will show that it is compliant and do nothing else.

```
<
.DESCRIPTION
    Detects if the registry key CloudKerberosTicketRetrievalEnabled exist and it is enabled.
    If the value set on it is correct and be marked as compliant.  If it is it doesn't exist  or the value is incorrect
    it will be marked as non-compliant then remediated.

.NOTES
    Author and Edited: Kristopher Turner (InvokeLLC)
    Make sure to change change variables!!!
#>

$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Detect-" + "CloudKerberosTicketRetrievalEnabled-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

try {
    if (-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters")) {
        # Remediate on ext code 1
        Write-Host "Registry key doesn't exist"
        exit 1
    };
    if ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name 'CloudKerberosTicketRetrievalEnabled' -ea SilentlyContinue) -eq 1) {
        Write-Host "CloudKerberosTicketRetrievalEnabled exist and is enabled"
        exit 0
    }
 else {
        Write-Host "CloudKerberosTicketRetrievalEnabled doesn't exist or is not enabled"
        exit 1
    };
}
catch {
    $errMsg = $_.Exception.Message
    Write-Host $errMsg
    exit 1
}

Stop-Transcript#
```

### Remediate Script

If the machine is noncompliant the remediate script will run within seconds. The script below will then add the registry path and registry key as well as assign the correct value to that key. One the script is done; Intune will now show that the machine has been remediated.

```
<
.DESCRIPTION
        Remediates and createsthe registry key CloudKerberosTicketRetrievalEnabled and
        assigns the correct value to enable it.

.NOTES
    Author and Edited: Kristopher Turner (InvokeLLC)
    Make sure to change change variables!!!

#>

$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Remediate-" + "CloudKerberosTicketRetrievalEnabled-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

#># Reg2CI (c) 2022 by Roger Zander
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name 'CloudKerberosTicketRetrievalEnabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

Stop-Transcript#
```

### The Proactive Remediation Package

To create a proactive remediation script package:

1. Go to the Endpoint Manager Admin center.

2. Click on Reports then on Endpoint analytics.

3. Click on Proactive remediation

![image](img/intune_header.png)

3. From the Proactive remediations blade, click on + Create script package.

4. Under the basic tab on the Create custom script enter the desired information for:

- **Name**
- **Description**
- **Publisher**

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQFwDJuj0wCYeg/article-inline_image-shrink_1500_2232/0/1673471441568?e=1679529600&v=beta&t=g1E9sTg2GkXZGvr_xEwXKFmUC0KL0nkoYSpxdwExIl4)</figure>

5\. Click Next

6\. Under the settings tab on the Create custom script page add the detect and remediate scripts.

7\. For ***Run this script using the logged-on credentials*** we will leave that as No. We want the system account which will have the permissions to add the registry key to run this script.

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQGPM9HXMm-26A/article-inline_image-shrink_1500_2232/0/1673471707209?e=1679529600&v=beta&t=L6HJqWwYRSLrfovs4JgQiDXUk1L60TKRuv7V4GyGrEc)</figure>

8\. Click on Next.

9\. Click Next on the Scope Tags tab.

10\. On the assignment tab, we will assign this package to **All Devices**.

11\. Edit the schedule for All Devices. I will edit this schedule to run every morning at 9:00 AM. If a computer is offline at that time, the next time that computer comes back online even if it is after 9:00 AM the script will run and report back.

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQEUdeQsDe3V5w/article-inline_image-shrink_1500_2232/0/1673471882456?e=1679529600&v=beta&t=H4Zb_Md0oFB7NgEUtE_1H_i_xL9kt7HIBmCFwO9gCbU)</figure>

12\. Click Apply to save the schedule. Then click Next.

13\. Review the configuration and if everything is correct click Create.

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQHosIFfDMhRvQ/article-inline_image-shrink_1000_1488/0/1673471985809?e=1679529600&v=beta&t=5NEjhisyfQDat5Pp9fII6b7O5JC4z1fJBVdCOw-t9TQ)</figure>

Now that the package has been created, we will want to monitor that it was actually successfully deployed to our devices. We can view the status by returning to the proactive remediations blade. You will see the newly created proactive remediation script package exist and is Active. It will take some time for this package to be applied across your environment.

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQHFGih-X9jklA/article-inline_image-shrink_1500_2232/0/1673472348863?e=1679529600&v=beta&t=6BCCASM-HdN-w7CADaT68RoSHd9gNZ6XSS2YqtJCQBE)</figure>

### Monitoring the Proactive Remediation Package

From the proactive remediation screen, you can see the overview, the current properties, and the device status.

The **overview**blade will give you a dashboard with a nice overview of the status of your proactive remediation package

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQE2GGd0m-ggsw/article-inline_image-shrink_1000_1488/0/1673472901465?e=1679529600&v=beta&t=wTQdXryeyG8A9TvtaRUnr2fXuxyWSwigy5wyyq13XRQ)</figure>

From the **Properties** page you can see what configurations are set for the specific proactive remediation package.

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQGhF0TTTFLOGA/article-inline_image-shrink_1000_1488/0/1673472941079?e=1679529600&v=beta&t=BlG-ApXap6_0mWxcpOVks4sp798HSjbDsJn1zYJLz3I)</figure>

From the **Device Status** page, you can see the status of each device. Here you should see each device, the username assigned to that device. The detection status will either show a green Without Issues or an orange With Issues. Under Remediation status, if the detection status was without issues, this will show a dark blue Not Run. If if the detection status was orange and the remediation script ran successful it will be light blue and say issue fixed. If the remediation status showed Failed than the remediation didn't succeed, and it will try again on the next scheduled time.

<figure class="reader-image-block__figure" style="box-sizing: inherit; margin: var(--artdeco-reset-base-margin-zero); padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); display: var(--artdeco-reset-base-display-block);">![No alt text provided for this image](https://media.licdn.com/dms/image/D5612AQGVMFooM2uFtA/article-inline_image-shrink_1500_2232/0/1673472975951?e=1679529600&v=beta&t=gBbCC1OMJ_r2S8XUPKZLYDadU2v-S5mWbwS1uBeDaT4)</figure>

Once the Regkey for the CloudKerberosTicketRetrivalEnbaled has been set, you should now be set to continue the configuration of Azure Kerberos authentication for hybrid accounts on in order to create mapped drives from your clients to your Azure Files.

Final Thoughts
--------------

I really like the idea of Proactive Remediation scripts in Intune. The only negative thing is how long these scripts can take to run on a client and how long it takes for that data to report back to Intune. There are a lot of good resources out there from others who have created many more script packages. I plan to blog a little more about this if I have time in the future.
