---
title: Applying The Final Firmware Update for the Azure Percept DK
description: ""
date: 2023-03-31T23:15:49.359Z
preview: /img/preceptdkupdate/perceptupdate_005.png
draft: false
tags:
  - Azure IoT
  - Azure Percept
  - Azure Percept Development Kit
  - Microsoft Entra
categories:
  - Azure Percept Development Kit
lastmod: 2023-04-01T02:42:12.001Z
thumbnail: /img/preceptdkupdate/perceptupdate_005.png
lead: Trying to save my Azure Percept DK from becoming yet another Microsoft
  hardware in my rock draw.
---

I guess this will be part II of another blog I wrote called [What! My Azure Percept DK Devices Are Being Retired???](https://www.thisismydemo.cloud/post/what-my-azure-percept-dk-devices-are-being-retired/). In that blog I mentioned how the Percept devices that were not cheap are now going into "retirement." The only way to keep using them for other things is to install the last "Unsupported" firmware update before March 30th.  This is my blog about how to install this update since you can no longer do OTA updates on existing devices at this time.

## Prerequisites

I myself will be walking through the [Unsupported SoM Update for Azure Percept DK’s Camera and Audio SoMs](https://dlcdnets.asus.com/pub/ASUS/mb/Embedded_IPC/DKSC-101/Unsupported_SoM_Update_Azure_Percept_DK_Camera_and_Audio_SoMs.pdf?model=DKSC-101) provided by Microsoft.

    1. Azure Percept DK
    2. I have both the camera and the audio accessory.
    3. I have cables to connect.
    4. I still have my power cables.
    5. A power source, check.
    6. A device used to do the updates.  Check, this laptop.
    7. Yep, internet is connected.

Now tim to follow directions...  :)

## How to apply the firmware

First thing first I have made sure that all my devices are connected.  Next I have downloaded the firmware update tool from here [https://download.microsoft.com/download/7/7/a/77a2f57a-0ede-48be-988c-11796f7948da/Azure%20Percept%20DK%20SoM%20Attestation%20Update%20Tool.zip](https://download.microsoft.com/download/7/7/a/77a2f57a-0ede-48be-988c-11796f7948da/Azure%20Percept%20DK%20SoM%20Attestation%20Update%20Tool.zip)

Next I have unzipped the files to the root of my C drive.

C:\Azure Percept DK SoM Attestation Update Tool

Now it is time to connect to my device via SSH. Simple command:

```Bash
ssh username@192.168.100.136
```
![](/img/preceptdkupdate/perceptupdate_001.png)

I already knew the IP of this device since I had just used it.  If not I would have just used my UniFI network tool to look up the IP.

We will run two commands to check the current firmware version of both the camera and the audio accessory.

Audio Accessory

```Bash
lsusb -d 045e:0673 -v

```

Camera

```Bash
lsusb -d 045e:066f -v

```

What we are looking for is that the bcdDevice is at 1.00.  If it is lower then this update is not supported.  If it is 3.00 then you already have it installed.

![](/img/preceptdkupdate/perceptupdate_002.png)

Next we need to copy the firmware install from our device to the Percept DK.  I used WinSCP but you can just use scp command within PowerShell or something.

We need to apply the firmware to both the camera and the audio accessory.  So we need to navigate to the firmware installer application.  Mine is located at:

/home/kristopherturner/Azure Percept DK SoM Attestation Update tool/input/

The command we will run here is:

```Bash
sudo ./AP_Perpheral_Installer_v0.1
```

So this is where someone with Linux experience would all me out.  :) I forgot to do something, that is also not mentioned in the documentation. If I was a Linux user I would have known that I needed to run the following command on the AP_Perpheral_Intaller_v0.1 file.

I got this error:

sudo: AP_Peripheral_Installer_v0.1: command not found

![](/img/preceptdkupdate/perceptupdate_004.png)

Thanks to SatishBoddu-MSFT I was told to change the executable permissions by running:

```Bash
sudo chmod +x AP_Peripheral_Installer_v0.1
```

Once I ran that command I then continued on to running the firmware update tool.

```Bash
sudo ./AP_Peripheral_Installer_v0.1
```

The firmware tool worked and you can see below that both my "ear" and "eye" have been updated.

![](/img/preceptdkupdate/perceptupdate_005.png)

![](/img/preceptdkupdate/perceptupdate_006.png)

## Updating the Azure Percepts Container for Audio and Vision

There are few ways we can update the software.  We can either use the Portal to deploy an IoT Edge Module or we can use VS Code.  I am going to make this easy and deploy to both devices using the portal.

This process is fairly straight forward and the instructions can be found at the following Microsoft Doc,[ Deploy Azure IoT Edge modules from the Azure portal](https://learn.microsoft.com/en-us/azure/iot-edge/how-to-deploy-modules-portal?view=iotedge-1.4).

First we start in the Azure Portal and go to IoT Hub.  Then look for Devices under the Device Management section.

![](/img/preceptdkupdate/perceptupdate_012.png)

We should see both the PerceptDK kit.  I have named mine PerceptDK.  Pretty original name huh?

![](/img/preceptdkupdate/perceptupdate_012.png)

Once we click on our device we should see a list of modules running.  We are going to update the azureearspeechclient module and the azureeye module. We continue by clicking on the Set Modules link on the top menu bar.

![](/img/preceptdkupdate/perceptupdate_013.png)

Next, we will update the first module by clicking on azureearspeechclient.

![](/img/preceptdkupdate/perceptupdate_014.png)

We need to change the Image URI path from the old link to the new container path.

For **azure speech**
> mcr.microsoft.com/azureedgedevices/azureearspeechclientmodule:1.0.4-noauth

For **azure eye**
> mcr.microsoft.com/azureedgedevices/azureeyemodule:2301-1-noauth


![](/img/preceptdkupdate/perceptupdate_015.png)


![](/img/preceptdkupdate/perceptupdate_016.png)

I am still not happy that these devices where put to pasture so soon.  These devices as well as others are not cheap. At least there is a way around them completely going into my Microsoft brick draw and joining my Azure Sphere and other products like my Microsoft Band and more.

I am also glad I was able to get these updates before the deadline which was tonight. I have been taking a 6 day Craftsmen Style Rocking Chair class and haven't turned my laptop on all week.  I may blog about that class.
