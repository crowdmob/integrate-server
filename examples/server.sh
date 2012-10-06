#!/bin/bash


# This Bash shell script is a working example demonstrating server-to-server
# installs tracking integration with CrowdMob.  Although this example is in
# Bash script, you can implement installs tracking using whatever technology
# you use on your server.


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
secret_hash="b53cd8652cb1feb3b10a087a6ed97566c3c50544607c9c086d7fbbb3d13f8c00"


# Finally, issue the POST request, passing in the required parameters.  Note
# that the parameters are nested within the "verify" namespace.
curl --data "verify[permalink]=$app_permalink&verify[uuid]=$uuid&verify[uuid_type]=publisher_device_id&verify[secret_hash]=$secret_hash" $server_url
echo
