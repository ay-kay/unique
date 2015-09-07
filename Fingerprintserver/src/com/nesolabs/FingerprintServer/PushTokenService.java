package com.nesolabs.FingerprintServer;

import java.net.UnknownHostException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.ws.rs.Consumes;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.Logger;
import org.apache.log4j.MDC;

import com.nesolabs.FingerprintServer.model.Response;
import com.nesolabs.FingerprintServer.mongo.MongoConnector;

@Path("/pushToken")
public class PushTokenService {

	private static Logger mongoLogger = Logger.getLogger("MongoLogger");
	private static Logger fsLogger = Logger.getLogger(PushTokenService.class);

	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public Response storeToken(@HeaderParam("Authorization") String hmac,
			String input) {

		// HMAC
		SecretKeySpec keySpec = new SecretKeySpec("inputSharpness".getBytes(),
				"HmacSHA1");

		Mac mac;
		byte[] result = null;
		try {
			mac = Mac.getInstance("HmacSHA1");
			mac.init(keySpec);
			result = mac.doFinal(input.getBytes());
		} catch (NoSuchAlgorithmException e) {
			mongoLogger.error("Calculating HMAC: Did not find algorithm", e);
			e.printStackTrace();
		} catch (InvalidKeyException e) {
			mongoLogger.error("Calculating HMAC: Key invalid", e);
			e.printStackTrace();
		}

		String myHMAC = Hex.encodeHexString(result);

		String defaultHMAC = "eed0e215ab631e05bc28968c6b837607a7318558";

		// Test if hmac is correct (in 'Authorization' header)
		if (!myHMAC.equals(hmac) && !myHMAC.equals(defaultHMAC)) {
			MDC.put("input", input);
			mongoLogger.error("Authorization failed for token request");
			MDC.remove("input");
			return new Response(true, "AUTHORIZATION ERROR - NOT ALLOWED");
		}
		
		if (myHMAC.equals(defaultHMAC)) {
			MDC.put("input", input);
			MDC.put("myHMAC", myHMAC);
			mongoLogger.error("Default HMAC used");
			MDC.remove("input");
			MDC.remove("myHMAC");
		}

		// Map JSON-String to Fingerprint.class
		MongoConnector mongoConnector = null;
		try {
			mongoConnector = MongoConnector.sharedInstance();
		} catch (UnknownHostException e) {
			fsLogger.error("MongoDB Error: Unknown host", e);
			e.printStackTrace();
		}

		if (mongoConnector == null) {
			fsLogger.error("Unable to connect to mongoDB");
			return new Response(true, "MongoDB not reachable");
		}

		mongoConnector.saveToken(input);

		return new Response(false, "");
	}
}
