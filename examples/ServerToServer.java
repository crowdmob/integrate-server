// This Java program is a working example demonstrating server-to-server
// installs tracking integration with CrowdMob.  Although this example is in
// Java, you can implement installs tracking using whatever technology you use
// on your server.

// Compile this program with the command:
//    $ javac ServerToServer.java
//
// Then run this program with the command:
//    $ java ServerToServer



import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;



public class ServerToServer {

    // You can test against CrowdMob's staging server located at:
    private static String serverUrl = "http://deals.mobstaging.com/crave/verify_install.json";

    // Eventually, you'll want to switch over to CrowdMob's production server
    // located at:
    // private static String serverUrl = "https://deals.crowdmob.com/crave/verify_install.json";

    // When you registered your app with CrowdMob, you got a secret key and a
    // permalink:
    private static String appSecretKey = "5bb75e8dd6300cadcdd07fa2c46a3c10";
    private static String appPermalink = "lulzio";

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
    private static String salt = "salt";

    private static void reportToCrowdmob(String macAddress) throws Exception {
        // Hash the MAC address.  If you already store the unique device
        // identifiers hashed, then this step is unnecessary.  If you store
        // the device IDs hashed, you would've worked with CrowdMob's
        // engineers to implement a custom server-to-server installs tracking
        // integration solution.
        String hashedMacAddress = Hash.hash("SHA-256", salt, macAddress);

        // Compute the secret hash.  The secret hash is a required POST
        // parameter which prevents forged POST requests.  This secret hash
        // consists of your app's permalink, a comma, the string
        // "publisher_device_id", a comma, and the previously hashed MAC
        // address - salted with your app's secret key, all SHA256 hashed.
        // (Note that there's no comma between the secret key salt and the
        // permalink.)
        String secretHash = Hash.hash("SHA-256", appSecretKey, appPermalink + "," + "publisher_device_id" + "," + hashedMacAddress);

        URL url = new URL(serverUrl);
        // Construct the POST parameters.  Note that the POST parameters must
        // be nested within the "verify" namespace:
        String params = "verify[permalink]=" + appPermalink;
        params += "&verify[uuid]=" + hashedMacAddress;
        params += "&verify[uuid_type]=" + "publisher_device_id";
        params += "&verify[secret_hash]=" + secretHash;

        // Finally, issue the POST request to CrowdMob's server:
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");

        DataOutputStream outputStream = new DataOutputStream(conn.getOutputStream());
        outputStream.writeBytes(params);
        outputStream.flush();
        outputStream.close();
        Integer httpStatusCode = conn.getResponseCode();
        DataInputStream inputStream = new DataInputStream(conn.getInputStream());
        String httpResponseBody = streamToString(inputStream);
        conn.disconnect();

        // Check for a 200 HTTP status code.  This code denotes successful
        // install tracking.
        System.out.println("HTTP status code: " + httpStatusCode);
        System.out.println("HTTP response body: " + httpResponseBody);

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

    private static String streamToString(DataInputStream stream) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
        String line;
        StringBuilder builder = new StringBuilder();
        try {
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return builder.toString();
    }

    public static void main(String[] args) throws Exception {
        String macAddress = "11:11:11:11:11:11";
        reportToCrowdmob(macAddress);
    }

}



// This class only contains static methods.  So we don't incur any penalty for
// instantiating a new object.  It's just a way to organize all of the methods
// to do with generating cryptographic hashes.
class Hash {

    static String hash(String algorithm, String salt, String message) {
        MessageDigest digest = null;
        try {
            digest = MessageDigest.getInstance(algorithm);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        digest.reset();
        if (salt.length() > 0) {
            digest.update(salt.getBytes());
        }
        byte[] messageDigest = digest.digest(message.getBytes());

        // Convert the message digest to hex.  For more info, see: http://stackoverflow.com/a/332101
        StringBuffer hexBuffer = new StringBuffer();
        for (int j = 0; j < messageDigest.length; j++) {
            String hexByte = Integer.toHexString(0xFF & messageDigest[j]);
            if (hexByte.length() == 1) {
                hexBuffer.append("0");
            }
            hexBuffer.append(hexByte);
        }
        String hexString = hexBuffer.toString();
        return hexString;
      }

}
