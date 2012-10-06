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

    private static String serverUrl = "http://deals.mobstaging.com/crave/verify_install.json";
    // private static String serverUrl = "https://deals.crowdmob.com/crave/verify_install.json";
    private static String appSecretKey = "5bb75e8dd6300cadcdd07fa2c46a3c10";
    private static String appPermalink = "lulzio";
    private static String salt = "salt";

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

    private static void reportToCrowdmob(String macAddress) throws Exception {
        String hashedMacAddress = Hash.hash("SHA-256", salt, macAddress);
        String secretHash = Hash.hash("SHA-256", appSecretKey, appPermalink + "," + "publisher_device_id" + "," + hashedMacAddress);

        URL url = new URL(serverUrl);
        String params = "verify[permalink]=" + appPermalink;
        params += "&verify[uuid]=" + hashedMacAddress;
        params += "&verify[uuid_type]=" + "publisher_device_id";
        params += "&verify[secret_hash]=" + secretHash;

        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setDoOutput(true);
        conn.setDoInput(true);
        conn.setInstanceFollowRedirects(false);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("charset", "utf-8");
        conn.setRequestProperty("Content-Length", "" + Integer.toString(params.getBytes().length));
        conn.setUseCaches(false);

        DataOutputStream outputStream = new DataOutputStream(conn.getOutputStream());
        outputStream.writeBytes(params);
        outputStream.flush();
        outputStream.close();
        Integer httpResponseCode = conn.getResponseCode();
        DataInputStream inputStream = new DataInputStream(conn.getInputStream());
        String httpResponseBody = streamToString(inputStream);
        conn.disconnect();

        System.out.println(httpResponseCode);
        System.out.println(httpResponseBody);
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
