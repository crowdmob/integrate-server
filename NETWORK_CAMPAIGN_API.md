Campaign API for Approved Display Networks
==========================================

CrowdMob (http://deals.crowdmob.com/) displays its current inventory of advertising to approved networks for syndication.  This document explains how to retrieve this inventory.


Short Version
-------------
Make a get request to `GET http://deals.crowdmob.com/api/networks/{YOUR_CROWDMOB_PERMALINK}/ads.json` and the responding json will be in the following format.  Replace `{YOUR_CROWDMOB_PERMALINK}` with the value provided by your CrowdMob Account Manager.


<pre class="json">
{"campaigns": [
  {
     "id": 76, // CrowdMob's campaign ID that is unique to these bid amounts
     "network_max_total_spend": 100.0, // Total spend, in USD that can be spent by the network
     "network_max_spend_per_day": 20.0, // Total spend per day, in USD that can be spent by the network
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
     "click_through_url": "http://crave.crowdmob.com/incoming?campaign_id=76&device_type=DEVICE_TYPE&device_uuid=DEVICE_UUID&device_uuid_type=DEVICE_UUID_TYPE&location=USER_LOCATION&source_name={YOUR_CROWDMOB_PERMALINK}&source_uuid=SOURCE_CLICK_UUID", // Click through URL with macros to be replaced when shown in the ad for the particular device / impression
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
   },
   // ... more campaigns
]};
</pre>


Campaign API in Detail
======================

We provide a JSON API that describes details on the campaigns that can be run on your network.  

Simply issue a get request to our server endpoint: `GET http://deals.crowdmob.com/api/networks/{YOUR_CROWDMOB_PERMALINK}/ads.json` and the responding json will be in the following format.  Replace `{YOUR_CROWDMOB_PERMALINK}` with the value provided by your CrowdMob Account Manager.

We will return a JSON object with an array of `campaigns`, e.g. `{"campaigns": [ { /* campaign 1 */ }, { /* campaign 2 */ }, ... ]}`.  Each campaign object contains the necessary information to render an ad for the campaign on your own network.  Let's examine them in more detail.

The Campaign JSON Object
------------------------

Each campaign object returned contains three important sections: date, totals, and click-thru information, `app` information (the app being advertised), and `bids` information that describes pricing in each region that's enabled.  

Here's a collapsed version:
<pre class="json">
  {
    // campaign date, totals, and click-thru information...
     "app": {
       // information about the app being advertised...
     },
     "bids": { 
       // CPC Bid amounts for different platforms for devices based in different locales...
     }
  }
</pre> 

A Little More About `Bids`
--------------------------

Bids is the most complex object, and the most important to get correct, so let's look at it first.  

Generically, the bids object will have the following format:

<pre class="json">
"bids": {
  "{DEVICE_TYPE}": {
    "{COUNTRY_CODE}": {
      "enabled": true|false,
      "network_cpc_bid": {USD_BID_AMOUNT}
    },
    // ... more country codes...
  }
  // ... more device types
}
</pre>

The most important thing to note, is that there might be differing bids for different device types, in different countries.  The campaign may pay $2 for an iPhone click in the US, but only pay $0.75 for an Android user in Singapore.  Additionally, not all regions may be enabled to begin with, so an ad in that region for that campaign will not generate any revenue.

Currently, `{DEVICE_TYPE}` can have values of one of the following:
`ipod` - any version of iPod touch
`iphone` - any version of iPhone
`ipad` - any version of iPad
`ipad_retina` - only iPad models 3 & 4
`android` - any version of Android

The `{COUNTRY_CODE}` is the ISO 3166 2 letter code of any country, in all lowercase.  These are provided at http://www.iso.org/iso/home/standards/country_codes/country_names_and_code_elements.htm

Here's an example to cement the concept:

<pre>
  "bids": {
     "iphone": {
       "us": {
         "enabled": true,
         "network_cpc_bid": 1.0
       }
     },
     "ipad": {
       "us": {
         "enabled": true,
         "network_cpc_bid": 1.5
       }
     },
     "android": {
       "us": {
         "enabled": true,
         "network_cpc_bid": 0.99
       },
       "au": {
         "enabled": true,
         "network_cpc_bid": 0.38
       },
       "uk": {
         "enabled": true,
         "network_cpc_bid": 0.38
       },
       "ca": {
         "enabled": true,
         "network_cpc_bid": 0.38
       }
     }
   }
</pre>

In this example, the campaign only wants to buy clicks in the United States for iPhones & iPads, but is willing to pay different rates for Android devices in the United States, Australia, the United Kingdom, and Canada.


The `click_through_url` and its Macros
--------------------------------------

One other important factor is knowing the macros used in our click-through URLs.  In order to generate any revenue for click throughs, we need to be able to correctly populate the url we provide.  The click through URL is in the `"click_through_url"` JSON element of each campaign.  It will look something like this: `http://crave.crowdmob.com/incoming?campaign_id=1111111&device_type=DEVICE_TYPE&device_uuid=DEVICE_UUID&device_uuid_type=DEVICE_UUID_TYPE&location=USER_LOCATION&source_name=acme-network&source_uuid=SOURCE_CLICK_UUID`

There are several macros we need to be replaced in this URL format:

* `DEVICE_TYPE` - This must be replaced with one of the following: `ipod` - any version of iPod touch; `iphone` - any version of iPhone; `ipad` - any version of iPad; `ipad_retina` - only iPad models 3 & 4; or `android` - any version of Android
* `DEVICE_UUID_TYPE` - This must be replaced with the string `mac_address`, `udid`, `android_id`, `idfa`, depending on what your network can give us.
* `DEVICE_UUID` - This must be replaced with the corresponding, identifyier value of the user's device.  For example, if you supply "mac_address" in DEVICE_UUID_TYPE, your DEVICE_UUID must be the device's MAC Address.
* `SOURCE_CLICK_UUID` (optional) - The unique click id the network has assigned to this click, for reconciliation
* `USER_LOCATION` (optional) - This should optionally be replaced by latitude & longitude (separated by comma), of the user if known



Assembling an Advertisement
---------------------------

In order to assemble ads to be displayed in HTML, we can simply iterate through the campaigns and find the highest value campaign that matches the current user's device and location.  Here's a javascript (jQuery) snippet that will do the job:

<pre>
  &lt;script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"&gt;&lt;/script&gt;&lt;!-- required to getJSON from our server --&gt;
  &lt;script src="https://datejs.googlecode.com/files/date.js">&lt;/script&gt;&lt;!-- required to parse dates in ISO format --&gt;
  &lt;script&gt;
    var device_tracking_type = "mac_address";
    var current_user_device_type = "android";
    var current_user_country_code = "ca";
    var current_user_mac_address = "11:11:11:11";
    var current_user_location = "37.8188,-122.4784";
    var current_impression_uuid = "mynetworkimpression-iowd23e823jsd094";
    var current_time = new Date();
    
    $.getJSON('http://deals.crowdmob.com/api/networks/{YOUR_CROWDMOB_PERMALINK}/ads.json', function(data) {
      console.log("Returning the markup for the highest bid:", highestCpcCampaignMarkup(data));
    });
    
    // Returns the ad markup for the campaign that has the highest bid matching the current_user_device_type, in the country defined by current_user_country_code, at the current time, or null if there isn't a matching campaign.
    function highestCpcCampaignMarkup(data) {
      var campaigns = data.campaigns;
      var lastHighestCampaign = null;
      for (var i = 0; i < campaigns.length; ++i) {
        var campaign = campaigns[i];
        
        // First, make sure we are between the right dates, right now (or the campaign doesn't end at a specific date), that isn't paused
        if (Date.parse(campaign.starts_at) <= current_time && (campaign.ends_at == null || Date.parse(campaign.ends_at) > current_time) && campaign.paused_at == null) {
          
          // Second, make sure that this campaign has a bid for the device type, in the region, and that that region is enabled
          if (campaign.bids[current_user_device_type] && campaign.bids[current_user_device_type][current_user_country_code] && campaign.bids[current_user_device_type][current_user_country_code].enabled) {
            
            // Finally, if the matching campaign has a higher bid than the last one found, mark it as found
            if (lastHighestCampaign == null || lastHighestCampaign[current_user_device_type][current_user_country_code].network_cpi_bid < campaign.bids[current_user_device_type][current_user_country_code].network_cpi_bid) {
              lastHighestCampaign = campaign;
            }
            
          }
          
        }
      }
      
      if (lastHighestCampaign) {
        var CAMPAIGN_TEMPLATE = "&lt;a href='{{CLICKTHRU_URL}}'&gt;&lt;img src='{{APPICON}}'/&gt;{{APPTITLE}}&lt;br/&gt;{{APPDESCRIPTION}}&lt;/a&gt;";
      
        // First replace the Click-Thru URL Parameters
        var finalizedClickThruUrl = lastHighestCampaign.click_through_url.replace(
            'DEVICE_TYPE', current_user_device_type
          ).replace(
            'DEVICE_UUID_TYPE', device_tracking_type
          ).replace(
            'DEVICE_UUID', current_user_mac_address
          ).replace(
            'SOURCE_CLICK_UUID', current_impression_uuid
          ).replace(
            'USER_LOCATION', current_user_location
          );
        
        return CAMPAIGN_TEMPLATE.replace(
          "{{CLICKTHRU_URL}}", finalizedClickThruUrl
        ).replace(
          "{{APPICON}}", lastHighestCampaign.app.icon_url
        ).replace(
          "{{APPTITLE}}", lastHighestCampaign.app.name
        ).replace(
          "{{APPDESCRIPTION}}", lastHighestCampaign.app.description
        );
      }
      else {
        return null;
      }
    }
  &lt;/script&gt;
</pre>

This is also available as a gist, at https://gist.github.com/mattcrowdmob/5166634
