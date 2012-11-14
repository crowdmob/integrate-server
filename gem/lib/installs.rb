#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'net/http'

load 'base.rb'



module CrowdMob::Installs
  class << self
    attr_accessor :app_secret_key
    attr_accessor :app_permalink
  end

  # When you registered your app with CrowdMob, you got an app secret key and
  # a permalink:
  @app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  @app_permalink = 'lulzio'

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
  # and a unique device identifier to meet your requirements.  In this
  # example, we're SHA256 hashing MAC addresses, salted with the string
  # "salt".  We typically recommend using your app's secret key as your salt,
  # but we can use any string that meets your requirements as a salt.
  @@salt = 'salt'

  def self.report(mac_address)
    url = CrowdMob.base_url + '/crave/verify_install.json'
    uri = URI.parse(url)

    # Hash the MAC address.  If you already store the unique device
    # identifiers hashed, then this step is unnecessary.  If you store the
    # device IDs hashed, you would've worked with CrowdMob's engineers to
    # implement a custom server-to-server installs tracking integration
    # solution.
    hashed_mac_address = Digest::SHA2.hexdigest(@@salt + mac_address)

    # Compute the secret hash.  The secret hash is a required POST parameter
    # which prevents forged POST requests.  This secret hash consists of your
    # app's permalink, a comma, the string "campaign_uuid", a comma, and the
    # previously hashed MAC address - salted with your app's secret key, all
    # SHA256 hashed.  (Note that there's no comma between the secret key salt
    # and the permalink.)
    secret_hash = Digest::SHA2.hexdigest(@app_secret_key + @app_permalink + ',' + 'campaign_uuid' + ',' + hashed_mac_address)

    # The POST parameters:
    params = {
      'permalink' => @app_permalink,
      'uuid' => hashed_mac_address,
      'uuid_type' => 'campaign_uuid',
      'secret_hash' => secret_hash
    }

    # Finally, issue the POST request to CrowdMob's server:
    response, data = Net::HTTP.post_form(uri, params)
    json = JSON.parse(response.body)

    # Check for a 200 HTTP status code.  This code denotes successful install
    # tracking.
    # puts "HTTP status code: #{response.code}"
    # puts "CrowdMob internal (action) status code: #{json['action_status']}"

    # This table explains what the different status code combinations
    # denote:
    #   HTTP Status Code    CrowdMob Internal Status Code   Meaning
    #   ----------------    -----------------------------   -------
    #   400                 1001                            You didn't supply your app's permalink as an HTTP POST parameter.
    #   400                 1002                            You didn't specify the unique device identifier type as an HTTP POST parameter.  (In the case of server-to-server installs tracking, this parameter should be the string "campaign_uuid".)
    #   400                 1003                            You didn't specify the unique device identifier as an HTTP POST parameter.  (Typically a salted hashed MAC address, but could be some other unique device identifier that you collect on your server.)
    #   404                 1004                            The app permalink that you specified doesn't correspond to any app registered on CrowdMob's server.
    #   403                 1005                            The secret hash that you computed doesn't correspond to the secret hash that CrowdMob's server computed.  (This could be a forged request?)
    #   200                 Any                             CrowdMob's server successfully tracked the install.
  end
end



# You can run this script from the command line to see a working example of
# server-to-server integration.
if __FILE__ == $0
  CrowdMob.base_url = 'http://deals.mobstaging.com'
  CrowdMob::Installs.app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  CrowdMob::Installs.app_permalink = 'lulzio'

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  CrowdMob::Installs.report(mac_address)
end
