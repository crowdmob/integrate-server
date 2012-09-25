#!/bin/bash


# This Bash shell script is a working example demonstrating server-to-server
# installs tracking integration with CrowdMob.  Although this example is in
# Bash script, you can implement installs tracking using whatever technology
# you use on your server.


# You can test against CrowdMob's staging server located at:
server_url="http://deals.mobstaging.com/loot/verify_install.json"

# Eventually, you'll want to switch over to CrowdMob's production server
# located at:
# server_url="https://deals.crowdmob.com/loot/verify_install.json"

# When you registered your app with CrowdMob, you got a secret key and a
# permalink.  We'll pass the permalink in as part of our POST request, and
# we'll use the secret key in order to generate the secret hash.
app_permalink="lulzio"

uuid="6751f06f9f9b83b9c1e80936ffe59bc536700b2"
secret_hash="b53cd8652cb1feb3b10a087a6ed97566c3c50544607c9c086d7fbbb3d13f8c00"


curl --data "verify[permalink]=$app_permalink&verify[uuid]=$uuid&verify[uuid_type]=publisher_device_id&verify[secret_hash]=$secret_hash" $server_url
echo
