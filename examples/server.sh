#!/bin/bash



# This Bash shell script is a working example demonstrating server-to-server
# installs tracking integration with CrowdMob.  Although this example is in
# Bash script, you can implement installs tracking using whatever technology
# you use on your server.

# Run this script with:
#   $ sh server.sh



# You can test against CrowdMob's staging server located at:
server_url="http://deals.mobstaging.com/crave/verify_install.json"

# Eventually, you'll want to switch over to CrowdMob's production server
# located at:
# server_url="https://deals.crowdmob.com/crave/verify_install.json"



# When you registered your app with CrowdMob, you got a secret key and a
# permalink.  We'll pass the permalink in as part of our POST request, and
# we'll use the secret key in order to generate the secret hash.
app_permalink="lulzio"



# You can store/transmit unique device identifiers hashed, encrypted, or in
# plain text.  This is an example hashed device identifier:
uuid="6751f06f9f9b83b9c1e80936ffe59bc536700b2"



# The secret hash is a SHA-256 hash of the following string:
#   <secret_key> + <permalink> + ‘,’ + <udid_type> + ‘,’ + <udid>`
# Note that there's no comma between the secret key and the permalink.
secret_hash="9c52fc3c8dc4e640b6112ef27fb3c5245f63537558d725fbafd6797f4b2a88c6"



# Finally, issue the POST request, passing in the required parameters:
curl --data "permalink=$app_permalink&uuid=$uuid&uuid_type=campaign_uuid&secret_hash=$secret_hash" $server_url
echo
