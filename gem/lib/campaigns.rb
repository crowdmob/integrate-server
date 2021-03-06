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

  def self.create(params, active)
    url = CrowdMob.base_url + '/api/organizations/' + @organization_permalink + '/sponsored_action_campaigns.json'
    uri = URI.parse(url)
    now, secret_hash = self.compute_secret_hash

    form = {
      'ios_url' => params[:ios_url],
      'android_url' => params[:android_url],
      'datetime' => now,
      'secret_hash' => secret_hash,
      'active' => active,
      'campaign[max_total_spend_in_dollars]' => params[:max_total_spend_in_dollars],
      'campaign[max_spend_per_day_in_dollars]' => params[:max_spend_per_day_in_dollars],
      'campaign[starts_at]' => params[:starts_at],
      'campaign[ends_at]' => params[:ends_at],
    }
    form['campaign[android]'] = '1' if params[:android_bid]
    form['campaign[android_bid]'] = params[:android_bid] if params[:android_bid]
    form['campaign[ipad]'] = '1' if params[:ipad_bid]
    form['campaign[ipad_bid]'] = params[:ipad_bid] if params[:ipad_bid]
    form['campaign[iphone]'] = '1' if params[:iphone_bid]
    form['campaign[iphone_bid]'] = params[:iphone_bid] if params[:iphone_bid]
    form['campaign[ipod]'] = '1' if params[:ipod_bid]
    form['campaign[ipod_bid]'] = params[:ipod_bid] if params[:ipod_bid]

    response, data = Net::HTTP.post_form(uri, form)
    json = JSON.parse(response.body)
    json
  end

  def self.query(campaign_id)
    url = CrowdMob.base_url + '/api/organizations/' + @organization_permalink + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
    now, secret_hash = self.compute_secret_hash
    url += '?datetime=' + now + '&secret_hash=' + secret_hash
    uri = URI.parse(url)
    response = self.issue_http_request(uri, 'Get')
  end

  def self.edit(campaign_id, active, params)
    url = CrowdMob.base_url + '/api/organizations/' + @organization_permalink + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
    now, secret_hash = self.compute_secret_hash
    url += '?datetime=' + now + '&secret_hash=' + secret_hash + '&active=' + active.to_s
    params.each { |key, value| url += '&campaign[' + key.to_s + ']=' + value.to_s }
    uri = URI.parse(url)
    response = self.issue_http_request(uri, 'Put')
    json = JSON.parse(response.body)
    json
  end

  def self.delete(campaign_id)
    url = CrowdMob.base_url + '/api/organizations/' + @organization_permalink + '/sponsored_action_campaigns/' + campaign_id.to_s + '.json'
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
  puts "creating campaign"
  now = DateTime.now
  one_week_from_now = now + 7
  params = {
    ios_url: 'https://itunes.apple.com/us/app/angry-birds-free/id409807569?mt=8',
    max_total_spend_in_dollars: 100.00,
    max_spend_per_day_in_dollars: 10.00,
    starts_at: now,
    ends_at: one_week_from_now,
    # android_bid: 2.00,
    # ipad_bid: 2.50,
    iphone_bid: 3.00,
    ipod_bid: 2.00,
  }
  campaign = CrowdMob::Campaigns.create(params, true)
  puts "created campaign: #{campaign}"

  # Edit the campaign:
  puts "editing campaign"
  params = { iphone_bid: 3.50 }
  campaign = CrowdMob::Campaigns.edit(campaign['id'], false, params)
  puts "edited campaign: #{campaign}"

  # Delete the campaign:
  puts "deleting campaign"
  CrowdMob::Campaigns.delete(campaign['id'])
  puts "deleted campaign"
end
