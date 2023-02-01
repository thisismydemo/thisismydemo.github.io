---
title: My Intune Proactive Remediation Scripts
description: ""
date: 2023-02-01T14:59:02.573Z
preview: ""
draft: false
tags:
  - PowerShell
  - Proactive Remediation
  - Intune
categories:
  - Intune Proactive Remediation
lastmod: 2023-02-01T17:34:46.490Z
thumbnail: ""
lead: ""
slug: intune-proactive-remediation-scripts
---
I have been working with Intune Proactive Remediation scripts I wanted to share a few that I am working on.If you want to know more about Intune Proactive Remediation you can check on past blogs of mine.

[Using Intune's Proactive Remediation Script Packages to configure clients to retrieve Kerberos tickets for Azure Files.](https://www.thisismydemo.cloud/post/2023-01-20-using-intunes-proactive-remediation-script-packages-to-configure-clients-to-retrieve-kerberos-tickets-for-azure-files/)

[Intune Proactive Remediation - Check if KB5007253 is installed.](https://www.thisismydemo.cloud/post/2023-01-31-intunes-proactive-remediations/)

The following scripts are currently in my GitHub repo called [ProactiveRemediations](https://github.com/kristopherjturner/ProactiveRemediations).

As of the time of this blog I have created 5 Proactive Remediation Scripts.

1. CloudKerberosTicketRetrievalEnabled
2. DriveMappingDetection
3. EnableLinkedConnections
4. InstallWIndowsUpdate
5. RemoveScheduledTask


### CloudKerberosTicketRetrievalEnabled ###
This was created to enable client machines for Azure AD Kerberos authentication on the Azure file shares.  It was a simple Registry entry that needed a value added or changed.

***Detection Script***
```
<#
.DESCRIPTION
	Detects if the registry key CloudKerberosTicketRetrievalEnabled exist and it is enabled.
	If the value set on it is correct and be marked as compiant.  If it is it doesn't exist  or the value is incorrect
	it will be markd as non-compliant then remediated.

.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
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

Stop-Transcript
```


***Remediation Script***

```
<#
.DESCRIPTION
		Remediates and createsthe registry key CloudKerberosTicketRetrievalEnabled and
		assigns the correct value to enable it.


.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
#>

$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Remediate-" + "CloudKerberosTicketRetrievalEnabled-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)


#># Reg2CI (c) 2022 by Roger Zander
if ((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters") -ne $true) { New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name 'CloudKerberosTicketRetrievalEnabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;


Stop-Transcript
```
----------------------
### DriveMappingDetection ###
This was a script I used to map an Azure Files drive using Intune.  We needed to do some detection if the drive already existed and if the user could connect to port 445 before the drive could be mapped.

***Detection Script***

```
<#
.DESCRIPTION
	Detects if user already has Azure File Share mapped.  If detected it will exit script and not run remediation script.
	If not detected it will then detected if user can connect to Azure File Share via port 445. If user can connect via port 445 the remediation
	script will run. If user can't connect it will exit.


.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
	Make sure to change change variables!!!

#>

$ShareName = "" # - Azure File Share
$StorageAccount = "" # - Storage Account


$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "DriveMapping-" + "Detect-" + $ShareName + "-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

$connectTestResult = Test-NetConnection -ComputerName "$storageaccount.file.core.windows.net" -Port 445
$Path = "\\$StorageAccount.file.core.windows.net\$ShareName"


try {
	if ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -ea SilentlyContinue) -eq 1) {
	}
	else { 
		Write-Host "EnableLinkedConnection Registry Key Doesn't Exist."
		exit 1 
 };
	if (Get-PSDrive | Where-Object { $_.DisplayRoot -eq $path }) { 
		Write-Host "Drive is Mapped"
		exit 0
	}
 else { 
		Write-Host "Drive needs to be mapped"
		exit 1 
 };
	if ($connectTestResult.TcpTestSucceeded) { 
		Write-Host "Connection to storage account via 443 succesful. Script will continue." 
	} 
	else {
		Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
		exit 1
	}
}
catch {
	$errMsg = $_.Exception.Message
	Write-Host $errMsg
	exit 1
}

Stop-Transcript
```

***Remediation Script***
```
<#
.DESCRIPTION
    Remediate script will run if detect script passed.  The script will then find the next available drive letter and map the Azur File share.  
    After which the script will configure a scheduled task to make rue the mapped drive stays mapped.

.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
	Make sure to change change variables!!!

#>

$ShareName = "" # - Azure File Name
$DriveLabel = "" # - Drive Label
$StorageAccount = "" # - Storage Account

$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "DriveMapping-" + "Remediate-" + $ShareName + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

function Test-RunningAsSystem {
    [CmdletBinding()]
    param()
    process {
        return [bool]($(whoami -user) -match "S-1-5-18")
    }
}

$Path = "\\$StorageAccount.file.core.windows.net\$ShareName"
$ProviderName = Get-WmiObject win32_logicaldisk | select-object ProviderName | where-object { $_.ProviderName -eq "$Path" }
$DriveLetter = (68..90 | ForEach-Object { $L = [char]$_; if ((Get-PSDrive).Name -notContains $L) { $L } })[0]
Write-Host ("$DriveLetter is next available.")

if ($ProviderName) {
    Write-Host $Path ("already exist.")
    Write-Host ("Exiting Script")
    Exit
}
else {
    Write-Host ("Mapped drive will continue.")
}


$connectTestResult = Test-NetConnection -ComputerName "$storageaccount.file.core.windows.net" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    Write-Host ("Connection to storage account via 443 succesful. Script will continue.")
}
else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    Write-Host ("Skipping drive creation due to connectivity.")
    Exit
}



if (-not (Test-RunningAsSystem)) {

    $psDrives = Get-PSDrive | Where-Object { $_.Provider.Name -eq "FileSystem" -and $_.Root -notin @("$env:SystemDrive\", "D:\") } `
    | Select-Object @{N = "DriveLetter"; E = { $_.Name } }, @{N = "Path"; E = { $_.DisplayRoot } }

    try {
        #check if variable in unc path exists, e.g. for $env:USERNAME -> resolving
        if ($Path -match '\$env:') {
            $Path = $ExecutionContext.InvokeCommand.ExpandString($Path)
        }

        #if label is null we need to set it to empty in order to avoid error
        if ($null -eq $DriveLabel) {
            $DriveLabel = ""
        }

        $exists = $psDrives | Where-Object { $_.Path -eq $Path -or $_.DriveLetter -eq $DriveLetter }
        $process = $true

        if ($null -ne $exists -and $($exists.Path -eq $Path -and $exists.DriveLetter -eq $DriveLetter )) {
            Write-Output "Drive '$($DriveLetter):\' '$($Path)' already exists with correct Drive Letter and Path"
            $process = $false

        }
        else {
            # Mapped with wrong config -> Delete it
            Get-PSDrive | Where-Object { $_.DisplayRoot -eq $Path -or $_.Name -eq $DriveLetter } | Remove-PSDrive -EA SilentlyContinue
        }

        if ($process) {
            Write-Output "Mapping network drive $($Path)"
            $null = New-PSDrive -PSProvider FileSystem -Name $DriveLetter -Root $Path -Description $DriveLabel -Persist -Scope global -EA SilentlyContinue
				(New-Object -ComObject Shell.Application).NameSpace("$($DriveLetter):").Self.Name = $DriveLabel
        }
    }
    catch {
        $available = Test-Path $($Path)
        if (-not $available) {
            Write-Error "Unable to access path '$($Path)' verify permissions and authentication!"
        }
        else {
            Write-Error $_.Exception.Message
            Exit 1
        }
    }


    # Remove unassigned drives
    if ($removeStaleDrives -and $null -ne $psDrives) {
        $diff = Compare-Object -ReferenceObject $driveMappingConfig -DifferenceObject $psDrives -Property "DriveLetter" -PassThru | Where-Object { $_.SideIndicator -eq "=>" }
        foreach ($unassignedDrive in $diff) {
            Write-Warning "Drive '$($unassignedDrive.DriveLetter)' has not been assigned - removing it..."
            Remove-SmbMapping -LocalPath "$($unassignedDrive.DriveLetter):" -Force -UpdateProfile
        }
    }

    # Fix to ensure drives are mapped as persistent!
    $null = Get-ChildItem -Path HKCU:\Network -ErrorAction SilentlyContinue | ForEach-Object { New-ItemProperty -Name ConnectionType -Value 1 -Path $_.PSPath -Force -ErrorAction SilentlyContinue }
}
Stop-Transcript
```
---------------------------

### EnableLinkedConnections ###
This was created because even though the scripts run as logged in user, Intune still runs the script in an elevated mode.  So mapping drives in an elevated mode won't show up.

***Detection Script***
```
<#
.DESCRIPTION
	Detects if Registry Key and Value exist.  If True then script will end and compliant.  If false it will end with Not compliant and trigger the remediation script.


.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
#>


$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Detect-" + "EnableLinkedConnections-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)

try {
	if (-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
		# Remediate on exit code 1
		Write-Host "Registry Key Doesn't Exist."
		exit 1
	};
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -ea SilentlyContinue) -eq 1) {
		Write-Host "EnableLinkedConnection exist and is enabled"
		exit 0
	} else { 
		Write-Host "EnableLinkedConnection doesn't exist"
		exit 1 };
}
catch {
	$errMsg = $_.Exception.Message
	Write-Host $errMsg
	exit 1
}

Stop-Transcript
```
***Remediation Script***
```
<#
.DESCRIPTION
	Remediates EnableLinkedConnection Registry Value from 0 to 1.


.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
#>


$Date = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogFileName = "Remediate-" + "EnableLinkedConnections-" + $date + ".log"
Start-Transcript -Path $(Join-Path $env:temp $LogFileName)


if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;


Stop-Transcript
```
---------------------------

### InstallWIndowsUpdate ###
This was created to check if a certain cumulative update was installed.  If not, it would install it. This specific one you can just run the detection script for your reports if needed.

***Detection Script***
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
***Remediation Script***
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

### RemoveScheduledTask ###
My first mapped drive script included a scheduled task that would always check if the drive was mapped. This caused some issues with the same drive being mapped over and over.  So I needed a way to remove these task by checking if it existed then removing it.

***Detection Script***

```
<#
.DESCRIPTION
	Detects if user a scheduled task is installed.  If not, machine is compliant.


.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
	Make sure to change everything in []

#>

$LogFileName = "Detect-IntuneDriveMappingScheduledTask-[taskname]" + $date + ".log"
Start-Transcript -Path $(Join-Path -Path $env:temp -ChildPath "$LogFileName")
Write-Output "Running as System --> removing scheduled task which will ran on user logon"

try {
    if (Get-ScheduledTask -TaskName 'IntuneDriveMapping-[Task Name]'){
        # Remediate on exit code 1
        Write-Host "[Enter Task Name] Task Exist"
        exit 1
    } else {
        Write-Host "[Enter Task Name] does not exits"
        exit 0
    }
}
catch {
	$errMsg = $_.Exception.Message
	Write-Host $errMsg
	exit 1
}

Stop-Transcript
```

***Remediation Script***
```
<#
.DESCRIPTION
	Remediates a machine by removing the detected scheduled task that is installed.


.NOTES
	Author and Edited: Kristopher Turner (InvokeLLC)
	Make sure to change everything in []

#>


$LogFileName = "Remediate-IntuneDriveMappingScheduledTask-[add task name]-" + $date + ".log"
Start-Transcript -Path $(Join-Path -Path $env:temp -ChildPath "$LogFileName")
Write-Output "Running as System --> removing scheduled task which will ran on user logon"

Write-Host "Removing [ add task name ] Scheduled Task."
Unregister-ScheduledTask -TaskName 'IntuneDriveMapping-[and task name]' -Confirm:$false


Stop-Transcript

```
----------------------------------
