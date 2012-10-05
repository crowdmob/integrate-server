#!/usr/bin/env python



# This Python script is a working example demonstrating server-to-server
# installs tracking integration with CrowdMob.  Although this example is in
# Python, you can implement installs tracking using whatever technology you
# use on your server.



def report_install_to_crowdmob(server_url, app_secret_key, app_permalink, salt, mac_address):
    import hashlib
    import httplib
    import json
    import urllib
    import urlparse

    # Hash the MAC address.  If you already store the unique device
    # identifiers hashed, then this step is unnecessary.  If you store the
    # device IDs hashed, you would've worked with CrowdMob's engineers to
    # implement a custom server-to-server installs tracking integration
    # solution.
    hashed_mac_address = hashlib.sha256(salt + mac_address).hexdigest()

    # Compute the security hash.  The security hash is a required POST
    # parameter which prevents forged POST requests.  This security hash
    # consists of your app's permalink, a comma, the string
    # "publisher_device_id", a comma, and the previously hashed MAC address -
    # salted with your app's secret key, all SHA256 hashed.  (Note that
    # there's no comma between the secret key salt and the permalink.)
    secret_hash = app_secret_key + app_permalink + ',' + 'publisher_device_id' + ',' + hashed_mac_address
    secret_hash = hashlib.sha256(secret_hash).hexdigest()

    server_url = urlparse.urlparse(server_url)
    params = urllib.urlencode({
        'verify[permalink]': app_permalink,
        'verify[uuid]': hashed_mac_address,
        'verify[uuid_type]': 'publisher_device_id',
        'verify[secret_hash]': secret_hash,
    })
    headers = {
        'Content-type': 'application/x-www-form-urlencoded',
        'Accept': 'text/json',
    }
    conn = httplib.HTTPConnection(server_url.hostname)
    conn.request('POST', server_url.path, params, headers)
    response = conn.getresponse()
    data = response.read()
    conn.close()

    data = json.loads(data)
    print response.status, response.reason, data



# You can run this script from the command line to see a working example of
# server-to-server installs tracking integration.
if __name__ == '__main__':
    # You can test against CrowdMob's staging server located at:
    server_url = 'http://deals.mobstaging.com/crave/verify_install.json'

    # Eventually, you'll want to switch over to CrowdMob's production server
    # located at:
    # server_url = https://deals.crowdmob.com/crave/verify_install.json

    # When you registered your app with CrowdMob, you got a secret key and a
    # permalink:
    app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10'
    app_permalink = 'lulzio'

    # If you didn't record your app's secret key and permalink when you
    # registered your app with CrowdMob, you can find it on your app's page on
    # CrowdMob's server.  In this example, our app is located here on
    # CrowdMob's staging server:
    #   http://deals.mobstaging.com/organizations/crowdmob/apps/lulzio
    #
    # In your case, if you registered your app on CrowdMob's production
    # server, your app's homepage URL would correspond to:
    #   https://deals.crowdmob.com/organizations/[your organization permalink]/apps/[your app permalink]

    # When you signed up for server-to-server installs tracking with CrowdMob,
    # CrowdMob worked with you to determine a secure hashing algorithm, a
    # salt, and a unique device identifier to meet your requirements.  In this
    # example, we're SHA256 hashing MAC addresses, salted with the string
    # "salt".  We typically recommend using your app's secret key as your
    # salt, but we can use any string that meets your requirements as a salt.
    salt = 'salt'

    # This is an example MAC address, stored in your server's database, used to
    # uniquely identify a device:
    mac_address = '11:11:11:11:11:11'

    report_install_to_crowdmob(server_url, app_secret_key, app_permalink, salt, mac_address)
