#!/usr/bin/env ruby



# This Ruby script is a working example demonstrating server-to-server
# integration with CrowdMob.  Although this example is in Ruby, you can
# integrate using whatever technology you use on your server.

# First, install the prerequisite "crowdmob" Ruby gem with:
#   $ gem install crowdmob

# If you use Bundler to manage your application's dependencies, add the
# "crowdmob" gem to your Gemfile with:
#   gem 'crowdmob'

# Then run this script with:
#   $ ruby server.rb



require 'crowdmob'



# You can run this script from the command line to see a working example of
# server-to-server integration.
if __FILE__ == $0

  #---------------------------------------------------------------------------#
  # This is how you report app installs to CrowdMob.                          #
  #---------------------------------------------------------------------------#

  # Your environment.
  CrowdMob.env = :development   # Please use this for development/testing.
  # CrowdMob.env = :production  # Please use this only when you go live.

  # When you registered your app with CrowdMob, you got an app secret key and
  # permalink:
  CrowdMob::Installs.app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10'
  CrowdMob::Installs.app_permalink = 'lulzio'

  # If you didn't record your app's secret key and permalink when you
  # registered your app with CrowdMob, you can find it on your app's page on
  # CrowdMob's server.  In this example, our app is located here on CrowdMob's
  # staging server:
  #   http://deals.mobstaging.com/organizations/crowdmob/apps/lulzio
  #
  # In your case, if you registered your app on CrowdMob's production server,
  # your app's homepage URL would correspond to:
  #   https://deals.crowdmob.com/organizations/[your organization permalink]/apps/[your app permalink]

  # This is an example MAC address, stored in your server's database, used to
  # uniquely identify a device:
  mac_address = '11:11:11:11:11:11'

  # Finally, report the app install to CrowdMob:
  CrowdMob::Installs.report(mac_address)





  #---------------------------------------------------------------------------#
  # This is how you manage app install campaigns through CrowdMob.            #
  #---------------------------------------------------------------------------#

  # Your environment.
  CrowdMob.env = :development   # Please use this for development/testing.
  # CrowdMob.env = :production  # Please use this only when you go live.

  # When you registered your organization with CrowdMob, you got an
  # organization secret key and permalink:
  CrowdMob::Campaigns.organization_secret_key = '9cbfbe10e13f2a30cb6509ef0e09445b'
  CrowdMob::Campaigns.organization_permalink = 'crowdmob'

  # Create an app campaign:
  now = DateTime.now
  one_week_from_now = now + 7
  params = {
    bid_in_cents: 300,              # The bounty in cents that you'll pay CrowdMob for each app install.
    max_total_spend_in_cents: 100,  # The maximum you're willing to spend on app installs, total, for this campaign.
    max_spend_per_day_in_cents: 10, # The maximum you're willing to spend on app installs per day for this campaign.
    starts_at: now,                 # When this campaign begins.
    ends_at: one_week_from_now,     # When this campaign ends.
  }
  live = true                       # Whether or not you're ready to take this campaign live right now.
  campaign = CrowdMob::Campaigns.create(live, params)

  # Edit the campaign:
  params = {
    # The parameters are the same as the parameters above, used to create the
    # campaign.  You need only specify the parameters that you wish to change.
    bid_in_cents: 200,
  }
  live = false
  campaign = CrowdMob::Campaigns.edit(campaign['id'], live, params)

  # Delete the campaign:
  CrowdMob::Campaigns.delete(campaign['id'])

end
