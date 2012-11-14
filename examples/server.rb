#!/usr/bin/env ruby



# This Ruby script is a working example demonstrating server-to-server
# integration with CrowdMob.  Although this example is in Ruby, you can
# integrate using whatever technology you use on your server.

# First, install the prerequisite "crowdmob" Ruby gem with:
#   $ gem install crowdmob

# Then run this script with:
#   $ ruby server.rb



require 'crowdmob'



# You can run this script from the command line to see a working example of
# server-to-server integration.
if __FILE__ == $0
  # Installs tracking:
  CrowdMob.base_url = 'http://deals.mobstaging.com'
  CrowdMob::Installs.app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  CrowdMob::Installs.app_permalink = 'lulzio'

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  CrowdMob::Installs.report(mac_address)



  # Install campaign CRUD operations:
  CrowdMob.base_url = 'http://deals.mobstaging.com'
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
