#!/usr/bin/env ruby



# This Ruby script is a working example demonstrating server-to-server
# integration with CrowdMob.  Although this example is in Ruby, you can
# integrate using whatever technology you use on your server.

# Run this script with:
#   ruby server.rb



require 'digest'
require 'json'
require 'net/http'
require 'time'



module CrowdMob
  # You can test against CrowdMob's staging server located at:
  BASE_URL = 'http://deals.mobstaging.com'

  # Eventually, you'll want to switch over to CrowdMob's production server
  # located at:
  # BASE_URL = 'https://deals.crowdmob.com'



  module Installs
    # When you registered your app with CrowdMob, you got an app secret key
    # and a permalink:
    APP_SECRET_KEY = '5bb75e8dd6300cadcdd07fa2c46a3c10'
    APP_PERMALINK = 'lulzio'

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
    @@salt = 'salt'

    def self.report(mac_address)
      url = BASE_URL + '/crave/verify_install.json'
      uri = URI.parse(url)

      # Hash the MAC address.  If you already store the unique device
      # identifiers hashed, then this step is unnecessary.  If you store the
      # device IDs hashed, you would've worked with CrowdMob's engineers to
      # implement a custom server-to-server installs tracking integration
      # solution.
      hashed_mac_address = Digest::SHA2.hexdigest(@@salt + mac_address)

      # Compute the secret hash.  The secret hash is a required POST parameter
      # which prevents forged POST requests.  This secret hash consists of
      # your app's permalink, a comma, the string "campaign_uuid", a comma,
      # and the previously hashed MAC address - salted with your app's secret
      # key, all SHA256 hashed.  (Note that there's no comma between the
      # secret key salt and the permalink.)
      secret_hash = Digest::SHA2.hexdigest(APP_SECRET_KEY + APP_PERMALINK + ',' + 'campaign_uuid' + ',' + hashed_mac_address)

      # The POST parameters:
      params = {
        'permalink' => APP_PERMALINK,
        'uuid' => hashed_mac_address,
        'uuid_type' => 'campaign_uuid',
        'secret_hash' => secret_hash
      }

      # Finally, issue the POST request to CrowdMob's server:
      response, data = Net::HTTP.post_form(uri, params)
      json = JSON.parse(response.body)

      # Check for a 200 HTTP status code.  This code denotes successful
      # install tracking.
      puts "HTTP status code: #{response.code}"
      puts "CrowdMob internal (action) status code: #{json['action_status']}"

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



  module Campaigns
    # When you registered your organization with CrowdMob, you got an
    # organization secret key and permalink:
    ORGANIZATION_SECRET_KEY = '9cbfbe10e13f2a30cb6509ef0e09445b'
    ORGANIZATION_PERMALINK = 'crowdmob'

    def self.create(active, params)
      url = BASE_URL + '/organizations/' + ORGANIZATION_PERMALINK + '/sponsored_action_campaigns.json'
      uri = URI.parse(url)
      now, secret_hash = self.compute_secret_hash
      params = {
        'datetime' => now,
        'secret_hash' => secret_hash,
        'active' => params[:active],
        'sponsored_action_campaign[bid_in_cents]' => params[:bid_in_cents],
        'sponsored_action_campaign[max_total_spend_in_cents]' => params[:max_total_spend_in_cents],
        'sponsored_action_campaign[max_spend_per_day_in_cents]' => params[:max_spend_per_day_in_cents],
        'sponsored_action_campaign[starts_at]' => params[:starts_at],
        'sponsored_action_campaign[ends_at]' => params[:ends_at],
        'sponsored_action_campaign[kind]' => 'install',
      }
      response, data = Net::HTTP.post_form(uri, params)
      json = JSON.parse(response.body)
      json
    end

    def self.edit(campaign_id, active, params)
      url = BASE_URL + '/organizations/' + ORGANIZATION_PERMALINK + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
      now, secret_hash = self.compute_secret_hash
      url += '?datetime=' + now + '&secret_hash=' + secret_hash + '&active=' + active.to_s
      params.each { |key, value| url += '&sponsored_action_campaign[' + key.to_s + ']=' + value.to_s }
      uri = URI.parse(url)
      response = self.issue_http_request(uri, 'Put')
      json = JSON.parse(response.body)
      json
    end

    def self.delete(campaign_id)
      url = BASE_URL + '/organizations/' + ORGANIZATION_PERMALINK + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
      now, secret_hash = self.compute_secret_hash
      url += '?datetime=' + now + '&secret_hash=' + secret_hash
      uri = URI.parse(url)
      response = self.issue_http_request(uri, 'Delete')
    end

    def self.compute_secret_hash
      now = DateTime.now.iso8601
      secret_hash = ORGANIZATION_SECRET_KEY + ORGANIZATION_PERMALINK + ',' + now
      secret_hash = Digest::SHA2.hexdigest(secret_hash)
      [now, secret_hash]
    end

    def self.issue_http_request(uri, http_method)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP.const_get(http_method).new(uri.request_uri)
      response = http.request(request)
      response
    end
  end
end



# You can run this script from the command line to see a working example of
# server-to-server integration.
if __FILE__ == $0
  # Installs tracking:
  CrowdMob::BASE_URL = 'http://deals.mobstaging.com'
  CrowdMob::Installs::APP_SECRET_KEY = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  CrowdMob::Installs::APP_PERMALINK = 'lulzio'

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  CrowdMob::Installs.report(mac_address)



  # Install campaign CRUD operations:
  CrowdMob::BASE_URL = 'http://deals.mobstaging.com'
  CrowdMob::Campaigns::ORGANIZATION_SECRET_KEY = '9cbfbe10e13f2a30cb6509ef0e09445b'
  CrowdMob::Campaigns::ORGANIZATION_PERMALINK = 'crowdmob'

  # Create a campaign:
  now = DateTime.now
  one_week_from_now = now + 7
  params = {
    bid_in_cents: 1,
    max_total_spend_in_cents: 100,
    max_spend_per_day_in_cents: 10,
    starts_at: now,
    ends_at: one_week_from_now,
  }
  campaign = CrowdMob::Campaigns.create(true, params)

  # Edit the campaign:
  params = { bid_in_cents: 2 }
  campaign = CrowdMob::Campaigns.edit(campaign['id'], false, params)

  # Delete the campaign:
  CrowdMob::Campaigns.delete(campaign['id'])
end
