<?php



/*
 | This PHP script is a working example demonstrating server-to-server
 | installs tracking integration with CrowdMob.  Although this example is in
 | PHP, you can implement installs tracking using whatever technology you use
 | on your server.
 */



class AppInstall {
    // You can test against CrowdMob's staging server located at:
    private $server_url = 'http://deals.mobstaging.com/crave/verify_install.json';

    // Eventually, you'll want to switch over to CrowdMob's production server
    // located at:
    // private $server_url = 'https://deals.crowdmob.com/crave/verify_install.json';

    // When you registered your app with CrowdMob, you got a secret key and a
    // permalink:
    private $app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10';
    private $app_permalink = 'lulzio';

    // If you didn't record your app's secret key and permalink when you
    // registered your app with CrowdMob, you can find it on your app's page
    // on CrowdMob's server.  In this example, our app is located here on
    // CrowdMob's staging server:
    //    http://deals.mobstaging.com/organizations/crowdmob/apps/lulzio
    //
    // In your case, if you registered your app on CrowdMob's production
    // server, your app's homepage URL would correspond to:
    //    https://deals.crowdmob.com/organizations/[your organization permalink]/apps/[your app permalink]

    // When you signed up for server-to-server installs tracking with
    // CrowdMob, CrowdMob worked with you to determine a secure hashing
    // algorithm, a salt, and a unique device identifier to meet your
    // requirements.  In this example, we're SHA256 hashing MAC addresses,
    // salted with the string "salt".  We typically recommend using your app's
    // secret key as your salt, but we can use any string that meets your
    // requirements as a salt.
    private $salt = 'salt';

    private function hash_mac_address($mac_address) {
      // Hash the MAC address.  If you already store the unique device
      // identifiers hashed, then this step is unnecessary.  If you store the
      // device IDs hashed, you would've worked with CrowdMob's engineers to
      // implement a custom server-to-server installs tracking integration
      // solution.
      $hashed_mac_address = hash('sha256', $this->salt . $mac_address);
      return $hashed_mac_address;
    }

    private function compute_secret_hash($hashed_mac_address) {
      // Compute the secret hash.  The secret hash is a required POST
      // parameter which prevents forged POST requests.  This secret hash
      // consists of your app's permalink, a comma, the string
      // "publisher_device_id", a comma, and the previously hashed MAC address
      // - salted with your app's secret key, all SHA256 hashed.  (Note that
      // there's no comma between the secret key salt and the permalink.)
      $secret_hash = hash('sha256', $this->app_secret_key . $this->app_permalink . ',' . 'publisher_device_id' . ',' . $hashed_mac_address);
      return $secret_hash;
    }

    private function populate_post_fields($hashed_mac_address, $secret_hash) {
      // Construct the POST parameters.  Note that the POST parameters must be
      // nested within the "verify" namespace:
      $fields = array(
          'verify[permalink]'   => $this->app_permalink,
          'verify[uuid]'        => $hashed_mac_address,
          'verify[uuid_type]'   => 'publisher_device_id',
          'verify[secret_hash]' => $secret_hash
      );
      return $fields;
    }

    private function compute_post_fields_string($fields) {
      // Convert the POST parameters from an array to a string.
      foreach($fields as $key => $value) {
        $fields_string .= $key . '=' . $value . '&';
      }
      rtrim($fields_string, '&');
      return $fields_string;
    }

    public function report_to_crowdmob($mac_address) {
        $hashed_mac_address = $this->hash_mac_address($mac_address);
        $secret_hash = $this->compute_secret_hash($hashed_mac_address);
        $fields = $this->populate_post_fields($hashed_mac_address, $secret_hash);
        $fields_string = $this->compute_post_fields_string($fields);

        // Finally, issue the POST request to CrowdMob's server:
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_URL, $this->server_url);
        curl_setopt($ch, CURLOPT_POST, count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        $response_body = curl_exec($ch);
        $response_body = json_decode($response_body);
        $http_status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        // Check for a 200 HTTP status code.  This code denotes successful
        // install tracking.
        print 'HTTP status code: ' . $http_status . "\n";
        print 'CrowdMob internal status code: ' . $response_body->install_status . "\n";

        // This table explains what the different status code combinations denote:
        //  HTTP Status Code    CrowdMob Internal Status Code   Meaning
        //  ----------------    -----------------------------   -------
        //  400                 1001                            You didn't supply your app's permalink as an HTTP POST parameter.
        //  400                 1002                            You didn't specify the unique device identifier type as an HTTP POST parameter.  (In the case of server-to-server installs tracking, this parameter should be the string "publisher_device_id".)
        //  400                 1003                            You didn't specify the unique device identifier as an HTTP POST parameter.  (Typically a salted hashed MAC address, but could be some other unique device identifier that you collect on your server.)
        //  404                 1004                            The app permalink that you specified doesn't correspond to any app registered on CrowdMob's server.
        //  403                 1005                            The secret hash that you computed doesn't correspond to the secret hash that CrowdMob's server computed.  (This could be a forged request?)
        //  200                 Any                             CrowdMob's server successfully tracked the install.
    }
}



// You can run this script from the command line to see a working example of
// server-to-server installs tracking integration.
$app_install = new AppInstall();

// This is an example MAC address, stored in your server's database, used to
// uniquely identify a device:
$mac_address = '11:11:11:11:11:11';

$app_install->report_to_crowdmob($mac_address);
