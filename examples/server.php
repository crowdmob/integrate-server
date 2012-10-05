<?php



class AppInstall {
    private $server_url = 'http://deals.mobstaging.com/loot/verify_install.json';
    private $app_secret_key = '5bb75e8dd6300cadcdd07fa2c46a3c10';
    private $app_permalink = 'lulzio';
    private $salt = 'salt';

    private function hash_mac_address($mac_address) {
      $hashed_mac_address = hash('sha256', $this->salt . $mac_address);
      return $hashed_mac_address;
    }

    private function compute_secret_hash($hashed_mac_address) {
      $secret_hash = hash('sha256', $this->app_secret_key . $this->app_permalink . ',' . 'publisher_device_id' . ',' . $hashed_mac_address);
      return $secret_hash;
    }

    private function populate_post_fields($hashed_mac_address, $secret_hash) {
      $fields = array(
          'verify[permalink]'   => $this->app_permalink,
          'verify[uuid]'        => $hashed_mac_address,
          'verify[uuid_type]'   => 'publisher_device_id',
          'verify[secret_hash]' => $secret_hash
      );
      return $fields;
    }

    private function compute_post_fields_string($fields) {
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

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_URL, $this->server_url);
        curl_setopt($ch, CURLOPT_POST, count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        $response_body = curl_exec($ch);
        $response_body = json_decode($response_body);
        $http_status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        print 'HTTP status code: ' . $http_status . "\n";
        print 'CrowdMob internal status code: ' . $response_body->install_status . "\n";
    }
}



$app_install = new AppInstall();
$mac_address = '11:11:11:11:11:11';
$app_install->report_to_crowdmob($mac_address);
