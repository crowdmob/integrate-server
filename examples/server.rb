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
require 'time'



class CrowdMob
  # You can test against CrowdMob's staging server located at:
  BASE_URL = 'http://deals.mobstaging.com'

  # Eventually, you'll want to switch over to CrowdMob's production server
  # located at:
  # BASE_URL = 'https://deals.crowdmob.com'

  # When you registered your organization with CrowdMob, you got a secret key
  # and a permalink:
  ORGANIZATION_SECRET_KEY = '9cbfbe10e13f2a30cb6509ef0e09445b'
  ORGANIZATION_PERMALINK = 'crowdmob'

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
    # app's permalink, a comma, the string "campaign_uuid", a comma, and the
    # previously hashed MAC address - salted with your app's secret key, all
    # SHA256 hashed.  (Note that there's no comma between the secret key salt
    # and the permalink.)
    secret_hash = Digest::SHA2.hexdigest(APP_SECRET_KEY + APP_PERMALINK + ',' + 'campaign_uuid' + ',' + hashed_mac_address)

    # The POST parameters:
    post_params = {
      'permalink' => APP_PERMALINK,
      'uuid' => hashed_mac_address,
      'uuid_type' => 'campaign_uuid',
      'secret_hash' => secret_hash
    }

    # Finally, issue the POST request to CrowdMob's server:
    response, data = Net::HTTP.post_form(post_uri, post_params)
    json = JSON.parse(response.body)

    # Check for a 200 HTTP status code.  This code denotes successful install
    # tracking.
    puts "HTTP status code: #{response.code}"
    puts "CrowdMob internal (action) status code: #{json['action_status']}"

    # This table explains what the different status code combinations denote:
    #   HTTP Status Code    CrowdMob Internal Status Code   Meaning
    #   ----------------    -----------------------------   -------
    #   400                 1001                            You didn't supply your app's permalink as an HTTP POST parameter.
    #   400                 1002                            You didn't specify the unique device identifier type as an HTTP POST parameter.  (In the case of server-to-server installs tracking, this parameter should be the string "campaign_uuid".)
    #   400                 1003                            You didn't specify the unique device identifier as an HTTP POST parameter.  (Typically a salted hashed MAC address, but could be some other unique device identifier that you collect on your server.)
    #   404                 1004                            The app permalink that you specified doesn't correspond to any app registered on CrowdMob's server.
    #   403                 1005                            The secret hash that you computed doesn't correspond to the secret hash that CrowdMob's server computed.  (This could be a forged request?)
    #   200                 Any                             CrowdMob's server successfully tracked the install.
  end



  def self.create_campaign(bid_in_cents, max_total_spend_in_cents, max_spend_per_day_in_cents, starts_at, ends_at, active)
    post_url = BASE_URL + '/organizations/' + ORGANIZATION_PERMALINK + '/sponsored_action_campaigns.json'
    post_uri = URI.parse(post_url)
    now = DateTime.now.iso8601
    secret_hash = self.secret_hash_for_campaign(now)
    post_params = {
      'datetime' => now,
      'secret_hash' => secret_hash,
      'sponsored_action_campaign[bid_in_cents]' => bid_in_cents,
      'sponsored_action_campaign[max_total_spend_in_cents]' => max_total_spend_in_cents,
      'sponsored_action_campaign[max_spend_per_day_in_cents]' => max_spend_per_day_in_cents,
      'sponsored_action_campaign[starts_at]' => starts_at,
      'sponsored_action_campaign[ends_at]' => ends_at,
      'sponsored_action_campaign[kind]' => 'install',
      'active' => active,
    }
    response, data = Net::HTTP.post_form(post_uri, post_params)
    json = JSON.parse(response.body)
    json
  end

  def self.delete_campaign(campaign_id)
    delete_url = BASE_URL + '/organizations/' + ORGANIZATION_PERMALINK + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
    now = DateTime.now.iso8601
    secret_hash = self.secret_hash_for_campaign(now)
    delete_url += '?datetime=' + now + '&secret_hash=' + secret_hash
    delete_uri = URI.parse(delete_url)

    http = Net::HTTP.new(delete_uri.host, delete_uri.port)
    http.use_ssl = delete_uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Delete.new(delete_uri.request_uri)
    response = http.request(request)
  end

  def self.secret_hash_for_campaign(now)
    secret_hash = ORGANIZATION_SECRET_KEY + ORGANIZATION_PERMALINK + ',' + now
    secret_hash = Digest::SHA2.hexdigest(secret_hash)
    secret_hash
  end
end



# You can run this script from the command line to see a working example of
# server-to-server installs tracking integration.
if __FILE__ == $0
  CrowdMob::BASE_URL = 'http://deals.mobstaging.com'
  CrowdMob::ORGANIZATION_SECRET_KEY = '9cbfbe10e13f2a30cb6509ef0e09445b'
  CrowdMob::ORGANIZATION_PERMALINK = 'crowdmob'
  CrowdMob::APP_SECRET_KEY = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  CrowdMob::APP_PERMALINK = 'lulzio'

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  # TODO: Uncomment this line later...  Just commenting it out for now to test creating campaigns.
  # CrowdMob.report_install(mac_address)

  now = DateTime.now
  one_week_from_now = now + 7
  campaign = CrowdMob.create_campaign(1, 100, 10, now, one_week_from_now, true)
  CrowdMob.delete_campaign(campaign['id'])
end
