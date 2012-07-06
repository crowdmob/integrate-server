#!/usr/bin/env ruby


# This Ruby script is a working example demonstrating server-to-server installs
# tracking integration with CrowdMob.  Although this example is in Ruby, you
# can implement installs tracking using whatever technology you use on your
# server.


require 'digest'
require 'json'
require 'net/http'


def report_install_to_crowdmob
  # You can test against CrowdMob's staging server located at:
  server_url = 'http://deals.mobstaging.com/loot/verify_install.json'

  # Eventually, you'll want to switch over to CrowdMob's production server
  # located at:
  # server_url = https://deals.crowdmob.com/loot/verify_install.json

  # When you registered your app with CrowdMob, you got a secret key and a
  # permalink:
  app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  app_permalink = 'lulzio'

  # If you didn't record your app's secret key and permalink when you
  # registered your app with CrowdMob, you can find it on your app's page on
  # CrowdMob's server.  In this example, our app is located here on CrowdMob's
  # staging server:
  #   http://deals.mobstaging.com/organizations/crowdmob/apps/lulzio
  #
  # In your case, if you registered your app on CrowdMob's production server,
  # your app's homepage URL would correspond to:
  #   https://deals.crowdmob.com/organizations/[your organization permalink]/apps/[your app permalink]

  # When you signed up for server-to-server installs tracking with CrowdMob,
  # CrowdMob worked with you to determine a secure hashing algorithm, a salt,
  # and a unique device identifier to meet your requirements.  In this example,
  # we're SHA256 hashing MAC addresses, salted with the string "salt".  We
  # typically recommend using your app's secret key as your salt, but we can
  # use any string that meets your requirements as a salt.
  salt = 'salt'

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  # Hash the MAC address:
  hashed_mac_address = hash_mac_address(salt, mac_address)

  # Compute the security hash:
  secret_hash = compute_secret_hash(app_secret_key, app_permalink, hashed_mac_address)

  # Finally, issue the POST request to CrowdMob's server:
  response, data = issue_post_request(server_url, app_permalink, hashed_mac_address, secret_hash)
  json = JSON.parse(response.body)

  # Check for a 200 HTTP status code.  This code denotes successful install tracking.
  puts "HTTP status code: #{response.code}"
  puts "CrowdMob internal status code: #{json['install_status']}"

  # This table explains what the different status code combinations denote:
  #   HTTP Status Code    CrowdMob Internal Status Code   Meaning
  #   ----------------    -----------------------------   -------
  #   400                 1001                            You didn't supply your app's permalink as an HTTP POST parameter.
  #   400                 1002                            You didn't specify the unique device identifier type as an HTTP POST parameter.  (In the case of server-to-server installs tracking, this parameter should be the string "publisher_device_id".)
  #   400                 1003                            You didn't specify the unique device identifier as an HTTP POST parameter.  (Typically a salted hashed MAC address, but could be some other unique device identifier that you collect on your server.)
  #   404                 1004                            The app permalink that you specified doesn't correspond to any app registered on CrowdMob's server.
  #   403                 1005                            The secret hash that you computed doesn't correspond to the secret hash that CrowdMob's server computed.  (This could be a forged request?)
  #   200                 Any                             CrowdMob's server successfully tracked the install.
end


def hash_mac_address(salt, mac_address)
  # If you already store unique device identifiers hashed, this step is
  # unnecessary.  In this case, you would've worked with CrowdMob to implement
  # a custom server-to-server installs tracking integration solution.
  Digest::SHA2.hexdigest(salt + mac_address)
end


def compute_secret_hash(app_secret_key, app_permalink, hashed_mac_address)
  # The security hash is a required POST parameter which prevents forged POST
  # requests.  This security hash consists of your app's permalink, a comma,
  # the string "publisher_device_id", a comma, and the previously hashed MAC
  # address - salted with your app's secret key, all SHA256 hashed:
  Digest::SHA2.hexdigest(app_secret_key + app_permalink + ',' + 'publisher_device_id' + ',' + hashed_mac_address)
end


def issue_post_request(server_url, app_permalink, hashed_mac_address, secret_hash)
  post_uri = URI.parse(server_url)

  # The POST parameters must be nested within the "verify" namespace:
  post_params = {
    'verify[permalink]' => app_permalink,
    'verify[uuid]' => hashed_mac_address,
    'verify[uuid_type]' => 'publisher_device_id',
    'verify[secret_hash]' => secret_hash
  }
  response, data = Net::HTTP.post_form(post_uri, post_params)
end


if __FILE__ == $0
  # You can run this script from the command line to see a working example of
  # server-to-server installs tracking integration.
  report_install_to_crowdmob
end
