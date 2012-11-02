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

Assuming that your company is called Lulzio...

![Server to Server Integration Overview](https://lh3.googleusercontent.com/QZJcEpEqWbE8w3Lo5zwR4O0zcTcpxzTn5NlDQjxWyt6sB4h_sFoYrrBuBQFrfsOJS6l9QJTuONtCOTHGRqamiHh6NH-lcKTuAZE7bTTs6K44wlypPZg "Server to Server Integration Overview")

1. The Lulzio integrator launches an install campaign with CrowdMob.  *(Done by Lulzio integrator.)*
2. A user installs the CrowdMob store app.
3. On first run, the CrowdMob store app registers the user’s device with the CrowdMob server.
4. The user installs the Lulzio app through the CrowdMob store.
5. On first run, the Lulzio app registers the user’s device with the Lulzio server.  *(Implemented by Lulzio integrator.)*
6. The Lulzio server reports the install to the CrowdMob server.  *(Implemented by Lulzio integrator.)*
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

For both Android and iOS, the CrowdMob server stores encrypted MAC addresses
to avoid a potential security concern regarding storing MAC addresses in plain
text.  CrowdMob uses the secure HTTPS protocol to prevent vulnerabilities in
transmitting MAC addresses in plain text. CrowdMob also allows for you to
transmit hashed or encrypted MAC addresses if you supply your hash or
encryption scheme to our engineers.

If you collect any of the noted device identifiers on your server, you’ll be
able to integrate using a pure server-to-server solution.  If you don’t
collect any of these device identifiers on your server, you’ll need to
modify your server-side and mobile software to collect at least one of these
identifiers.



Reporting an Install from Your Server to CrowdMob’s Server
----------------------------------------------------------

Now that you’re collecting the required information, your server can report
an install to CrowdMob’s server.  In order to report an install, your server
must issue an HTTP POST request to https://deals.crowdmob.com/crave/verify_install.json.
The POST request parameters must be as follows:

1. `permalink`:  The permalink generated for your app when you registered your app with CrowdMob.
2. `uuid_type`:  Either `android_id`, `android_serial_number`, `mac_address`, or `android_telephony_id`, depending on which of these device identifiers your server collects.
3. `uuid`:  The device identifier, either the Android ID, the Android serial number, the Android telephony ID, or the MAC address.
4. `secret_hash`:  A SHA-256 hash of the following string: `<secret_key> + <permalink> + ‘,’ + <udid_type> + ‘,’ + <udid>`.  (Note that there is no comma between the secret key and the permalink.)

You get your app’s secret key and permalink when you register your app with CrowdMob, and your mobile app and/or server must compute the user’s device’s UDID.

The following JSON expression represents the parameters that you should send to CrowdMob's server:

`{ permalink: <your permalink>, uuid_type: <your uuid type>, uuid: <your uuid>, secret_hash: <your secret hash> }`

Your final url should look like the following:
https://deals.crowdmob.com/crave/verify_install.json?permalink=<your permalink>&uuid_type=<your uuid type>&uuid=<your uuid>&secret_hash=<your secret hash>

Interpreting the Response from CrowdMob’s Server
------------------------------------------------

Once your server has issued the POST request, CrowdMob’s server returns an
HTTP status code.  The HTTP status codes mean:

* `400`:  At least one HTTP POST parameter was not supplied.
* `403`:  Your security hash doesn’t match the expected value.
* `404`:  Your specified app permalink doesn’t correspond to an app registered with CrowdMob.
* `200`:  Your request was well formed and was properly processed by CrowdMob’s server.



Example Source Code
-------------------

Look at some example source code in:

* [Java](https://github.com/crowdmob/integrate-server/blob/master/examples/ServerToServer.java)
* [PHP](https://github.com/crowdmob/integrate-server/blob/master/examples/server.php)
* [Python](https://github.com/crowdmob/integrate-server/blob/master/examples/server.py)
* [Ruby](https://github.com/crowdmob/integrate-server/blob/master/examples/server.rb)
* [Bash (shell) script / curl](https://github.com/crowdmob/integrate-server/blob/master/examples/server.sh)
