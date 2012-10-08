#!/usr/bin/env ruby



# This Ruby script is a working example demonstrating server-to-server installs
# tracking integration with CrowdMob.  Although this example is in Ruby, you
# can implement installs tracking using whatever technology you use on your
# server.

# Run this script with:
#   ruby server.rb



require 'digest'
require 'json'
require 'net/http'



class CrowdMob
  # You can test against CrowdMob's staging server located at:
  BASE_URL = 'http://deals.mobstaging.com'

  # Eventually, you'll want to switch over to CrowdMob's production server
  # located at:
  # BASE_URL = 'https://deals.crowdmob.com/crave/verify_install.json'

  # When you registered your app with CrowdMob, you got a secret key and a
  # permalink:
  APP_SECRET_KEY = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  APP_PERMALINK = 'lulzio'

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
  @@salt = 'salt'

  def self.report_install(mac_address)
    post_url = BASE_URL + '/crave/verify_install.json'
    post_uri = URI.parse(post_url)

    # Hash the MAC address.  If you already store the unique device
    # identifiers hashed, then this step is unnecessary.  If you store the
    # device IDs hashed, you would've worked with CrowdMob's engineers to
    # implement a custom server-to-server installs tracking integration
    # solution.
    hashed_mac_address = Digest::SHA2.hexdigest(@@salt + mac_address)

    # Compute the secret hash.  The security hash is a required POST parameter
    # which prevents forged POST requests.  This secret hash consists of your
    # app's permalink, a comma, the string "publisher_device_id", a comma, and
    # the previously hashed MAC address - salted with your app's secret key,
    # all SHA256 hashed.  (Note that there's no comma between the secret key
    # salt and the permalink.)
    secret_hash = Digest::SHA2.hexdigest(APP_SECRET_KEY + APP_PERMALINK + ',' + 'publisher_device_id' + ',' + hashed_mac_address)

    # The POST parameters must be nested within the "verify" namespace:
    post_params = {
      'verify[permalink]' => APP_PERMALINK,
      'verify[uuid]' => hashed_mac_address,
      'verify[uuid_type]' => 'publisher_device_id',
      'verify[secret_hash]' => secret_hash
    }

    # Finally, issue the POST request to CrowdMob's server:
    response, data = Net::HTTP.post_form(post_uri, post_params)
    json = JSON.parse(response.body)

    # Check for a 200 HTTP status code.  This code denotes successful install
    # tracking.
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
end



# You can run this script from the command line to see a working example of
# server-to-server installs tracking integration.
if __FILE__ == $0
  CrowdMob::BASE_URL = 'http://deals.mobstaging.com'
  CrowdMob::APP_SECRET_KEY = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  CrowdMob::APP_PERMALINK = 'lulzio'

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  CrowdMob.report_install(mac_address)
end
