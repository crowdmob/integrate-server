Campaign API for Approved Display Networks
==========================================

CrowdMob (http://deals.crowdmob.com/) displays its current inventory of advertising to approved networks for syndication.  This document explains how to retrieve this inventory.


Short Version
-------------
Make a get request to `GET http://deals.crowdmob.com/api/networks/{YOUR_CROWDMOB_PERMALINK}/ads.json` and the responding json will be in the following format.  Replace `{YOUR_CROWDMOB_PERMALINK}` with the value provided by your CrowdMob Account Manager.

<pre class="json">
{
     "id": 76, // CrowdMob's campaign ID that is unique to these bid amounts
     "network_max_total_spend": 100.0, // Total spend, in USD that can be spent by the network (e.g. AirPush)
     "network_max_spend_per_day": 20.0, // Total spend per day, in USD that can be spent by the network (e.g. AirPush)
     "starts_at": "1970-01-01T00:00:00+00:00", // Earliest date that the ads can be shown for this campaign ID
     "ends_at": null, // Last date that the ads can be shown for this campaign ID (or null for "forever")
     "app": {
       "id": 14398, // CrowdMob's app id for the app being advertised in this campaign
       "name": "Tiny Castle", // Display name of the application
       "permalink": "comtinycorealms", // CrowdMob's app permalink identifier for the app being advertised in this campaign
       "icon_url": "http://d7z71ba2y7s7x.cloudfront.net/apps/icons/14398-icon.:format?1361413867",  // URL of app icon
       "purchasable_cost_in_cents": 0,  // How much it costs the user to get this app on their device
       "description": "Join millions of players in Tiny Castle and save your family's ancient castle from the Evil Queen!",  // CrowdMob's app single-sentence description for the app being advertised in this campaign
       "ios_url": "", // Apple App Store link for this app
       "android_url": "https://play.google.com/store/apps/details?id=com.tinyco.realms", // Google Play Store link for this app
       "publisher": {
         "id": 7752, // CrowdMob's id for the publisher of the app being advertised in this campaign
         "name": "TinyCo", // Name of the publisher of the app being advertised in this campaign
         "permalink": "tinyco", // CrowdMob's permalink identifier for the publisher of the app being advertised in this campaign
         "website_url": "http://www.tinyco.com" // Website for the publisher of the app being advertised in this campaign
       }
     },
     "click_through_url": "http://crave.crowdmob.com/incoming?campaign_id=76&device_type=DEVICE_TYPE&device_uuid=DEVICE_UUID&device_uuid_type=DEVICE_UUID_TYPE&location=USER_LOCATION&source_name=airpush&source_uuid=SOURCE_CLICK_UUID", // Click through URL with macros to be replaced when shown in the ad for the particular device / impression
     "paused_at": null, // null if the campaign is not currently paused.  A datetime if the campaign is currently paused
     "bids": { // CPC Bid amounts for different platforms for devices based in different locales
       "android": { // Bids for android devices
         "us": { // USA bids
           "enabled": true, // Boolean on whether or not this locale is enabled in for this campaign
           "network_cpc_bid": 0.01 // Bid, in USD, that the campaign is willing to pay per click for devices in this locale
         },
         "au": { // Australian bids
           "enabled": true, // Boolean on whether or not this locale is enabled in for this campaign
           "network_cpc_bid": 0.01 // Bid, in USD, that the campaign is willing to pay per click for devices in this locale
         },
         "uk": { // United Kingdom bids
           "enabled": true, // Boolean on whether or not this locale is enabled in for this campaign
           "network_cpc_bid": 0.01 // Bid, in USD, that the campaign is willing to pay per click for devices in this locale
         },
         "ca": { // Canada bids
           "enabled": true, // Boolean on whether or not this locale is enabled in for this campaign
           "network_cpc_bid": 0.01 // Bid, in USD, that the campaign is willing to pay per click for devices in this locale
         }
       }
     }
   }
</pre>


In Detail
---------

IN PROGRESS