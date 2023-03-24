---
title: What! My Azure Percept DK Devices Are Being Retired???
description: ""
date: 2023-03-23T22:58:14.214Z
preview: /img/perceptdkreset/Screenshot 2023-03-24 090855.png
draft: false
tags:
  - Azure Percept Development Kit
  - Azure IoT
categories:
  - Azure Percept Development Kit
lastmod: 2023-03-24T14:14:23.153Z
thumbnail: /img/perceptdkreset/Screenshot 2023-03-24 090855.png
lead: ""
---

So recently I started working on another IoT project which lead me to breaking out all my old development kits.  I previously wrote a blog called  [My Azure Sphere Needs Reset](https://www.thisismydemo.cloud/post/my-azure-sphere-needs-reset/) where I walked through recovering an old Azure Sphere Development Kit I had. So I decided to write another few blogs following how I had to do the same with all my devices since I couldn't really remember any of the configurations and some of these devices had been configured for long gone IoT Hubs and tenants that don't exist anymore.

https://azure.microsoft.com/en-us/updates/azure-percept-dk-retirement-announcement/

I needed to figure out how to reset my devices in order to get this last update so I could keep using my devices for now. I didn't want to add my Percept devices to my Microsoft hardware rock draw like my Windows Phones, Microsoft Band 1 and 2, and my Azure Sphere among many other devices sit.

This time it was fairly simple. I was able to connect to the WiFi AP running on my Percept DK still since I never changed the default password.  Which allowed me to run through the setup again and reconnect the device to my new IoT Hub.  If I hadn't done that, I would have needed to connect my device via USB which meant taking it apart and changing some DIP switches and other things that are a pain including flashing the device with some firmware.

Once I got connected to the AP on the device it will redirect me to your.new.device/ which starts the process to configure the device.

The first step is to configure the wireless network the device will connect to:

![](/img/perceptdkreset/Screenshot%202023-03-24%20080957.png)

Once connected, the next step is to select the IoT Hub that this device will communicate to.  I will choose to setup as a new device.

![](/img/perceptdkreset/Screenshot%202023-03-24%20081302.png)

Next we will need to log on to our Azure environment.

![](/img/perceptdkreset/Screenshot%202023-03-24%20081350.png)

![](/img/perceptdkreset/Screenshot%202023-03-24%20081858.png)

Here I will select my existing IoT Hub.  Although we could create a new IoT Hub if needed.

![](/img/perceptdkreset/Screenshot%202023-03-24%20081536.png)

Then we name the device.

![](/img/perceptdkreset/Screenshot%202023-03-24%20081610.png)

The device is now configured and we are ready to open the Azure Percept Studio.


![](/img/perceptdkreset/Screenshot%202023-03-24%20081736.png)

Open up the Azure Percept Studio.

![](/img/perceptdkreset/perceptstudio001.png)

Now if we click on Devices we should see our newly configured Percept DK.

![](/img/perceptdkreset/Screenshot%202023-03-24%20090337.png)

Now that my Percept is reset I am ready to move forward with the update to allow me to use this device past March 30th.