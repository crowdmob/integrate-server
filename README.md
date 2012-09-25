Server to Server Integration
============================

CrowdMob (http://deals.crowdmob.com/) drives installs of your Android or
iPhone mobile app.  As long as you collect the required information on your
server, you can integrate with CrowdMob to track unique installs of your app
through a pure server-to-server solution, requiring no modification of your
mobile app.  This document details the rationale as well as the integration
steps for this server-to-server solution.

Overview
--------

1. The Lulzio integrator launches an install campaign with CrowdMob.  *(You have to do this.)*
2. A user installs the CrowdMob store app.
3. On first run, the CrowdMob store app registers the user’s device with the CrowdMob server.
4. The user installs the Lulzio app through the CrowdMob store.
5. On first run, the Lulzio app registers the user’s device with the Lulzio server.  *(You have to do this.)*
6. The Lulzio server reports the install to the CrowdMob server.  *(You have to do this.)*
7. The CrowdMob server provides stats to the Lulzio integrator.

Collecting the Required Information on Your Server
--------------------------------------------------

Your server has to report app installs that can be matched against CrowdMob
store installs on CrowdMob’s server.  The CrowdMob store collects all of the
following unique device identifiers for each device, so your server has to
collect one of the following as well:

In order of preference on Android:

1. Android ID (http://developer.android.com/reference/android/provider/Settings.Secure.html#ANDROID_ID)
2. Serial number (http://developer.android.com/reference/android/os/Build.html#SERIAL)
3. MAC address \[hashed, encrypted, or plain-text\] (http://developer.android.com/reference/android/net/wifi/WifiInfo.html#getMacAddress())
4. Telephony ID (http://developer.android.com/reference/android/telephony/TelephonyManager.html#getDeviceId())

On iOS:

1. MAC address \[hashed, encrypted, or plain-text\] (http://stackoverflow.com/questions/677530/how-can-i-programmatically-get-the-mac-address-of-an-iphone)

On both Android and iOS, the CrowdMob server stores encrypted MAC addresses to
avoid a potential security concern regarding storing MAC addresses in plain
text.  CrowdMob uses the secure HTTPS protocol to prevent vulnerabilities in
transmitting MAC addresses unencrypted. CrowdMob also allows for you to
transmit hashed or encrypted MAC addresses if you supply your hash or
encryption scheme to our engineers.

If you collect any of the noted device identifiers on your server, you’ll be
able to integrate using a pure server-to-server solution.  If you don’t
collect any of these device identifiers on your server, you’ll need to
modify your server-side and mobile software to collect at least one of these
identifiers.
