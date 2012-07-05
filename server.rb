#!/usr/bin/env ruby


require 'digest'
require 'json'
require 'net/http'


def hash_mac_address(salt, mac_address)
  Digest::SHA2.hexdigest(salt + mac_address)
end


def compute_secret_hash(app_secret_key, app_permalink, hashed_mac_address)
  Digest::SHA2.hexdigest(app_secret_key + app_permalink + ',' + 'publisher_device_id' + ',' + hashed_mac_address)
end


def report_install_to_crowdmob(app_permalink, hashed_mac_address, secret_hash)
  post_uri = URI.parse('http://deals.mobstaging.com/loot/verify_install.json')
  post_args = {
    'verify[permalink]' => app_permalink,
    'verify[uuid]' => hashed_mac_address,
    'verify[uuid_type]' => 'publisher_device_id',
    'verify[secret_hash]' => secret_hash
  }
  response, data = Net::HTTP.post_form(post_uri, post_args)
end


if __FILE__ == $0
  hashed_mac_address = hash_mac_address('salt', '11:11:11:11:11:11')
  secret_hash = compute_secret_hash('5bb75e8dd6300cadcdd07fa2c46a3c10', 'lulzio', hashed_mac_address)
  response, data = report_install_to_crowdmob('lulzio', hashed_mac_address, secret_hash)
  json = JSON.parse(response.body)

  puts "HTTP status code: #{response.code}"
  puts "CrowdMob internal status code: #{json['install_status']}"
end
