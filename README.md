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

1. The Lulzio integrator launches an install campaign with CrowdMob.
2. A user installs the CrowdMob store app.
3. On first run, the CrowdMob store registers the user’s device with the CrowdMob server.
4. The user installs your app through the CrowdMob store.
5. On first run, your app registers the user’s device with your server.
6. Your server reports the install to the CrowdMob server.
7. The CrowdMob server provides stats to the Lulzio integrator.
