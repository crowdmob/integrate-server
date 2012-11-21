#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'net/http'
require 'time'

load 'base.rb'



module CrowdMob::Campaigns
  class << self
    attr_accessor :organization_secret_key
    attr_accessor :organization_permalink
  end

  # When you registered your organization with CrowdMob, you got an
  # organization secret key and permalink:
  @organization_secret_key = '9cbfbe10e13f2a30cb6509ef0e09445b'
  @organization_permalink = 'crowdmob'

  def self.create(app_store_url, active, params)
    url = CrowdMob.base_url + '/organizations/' + @organization_permalink + '/sponsored_action_campaigns.json'
    uri = URI.parse(url)
    now, secret_hash = self.compute_secret_hash
    params = {
      'app_store_url' => app_store_url,
      'datetime' => now,
      'secret_hash' => secret_hash,
      'active' => active,
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
    url = CrowdMob.base_url + '/organizations/' + @organization_permalink + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
    now, secret_hash = self.compute_secret_hash
    url += '?datetime=' + now + '&secret_hash=' + secret_hash + '&active=' + active.to_s
    params.each { |key, value| url += '&sponsored_action_campaign[' + key.to_s + ']=' + value.to_s }
    uri = URI.parse(url)
    response = self.issue_http_request(uri, 'Put')
    json = JSON.parse(response.body)
    json
  end

  def self.delete(campaign_id)
    url = CrowdMob.base_url + '/organizations/' + @organization_permalink + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
    now, secret_hash = self.compute_secret_hash
    url += '?datetime=' + now + '&secret_hash=' + secret_hash
    uri = URI.parse(url)
    response = self.issue_http_request(uri, 'Delete')
  end

  def self.compute_secret_hash
    now = DateTime.now.iso8601
    secret_hash = @organization_secret_key + @organization_permalink + ',' + now
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



# You can run this script from the command line to see a working example of
# server-to-server integration.
if __FILE__ == $0
  CrowdMob.env = :development
  CrowdMob::Campaigns.organization_secret_key = '9cbfbe10e13f2a30cb6509ef0e09445b'
  CrowdMob::Campaigns.organization_permalink = 'crowdmob'

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
