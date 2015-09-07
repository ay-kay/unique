package com.nesolabs.FingerprintServer;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.UnknownHostException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;

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
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;

import com.mongodb.MongoException;
import com.nesolabs.FingerprintServer.model.Fingerprint;
import com.nesolabs.FingerprintServer.model.Response;
import com.nesolabs.FingerprintServer.model.tree.Node;
import com.nesolabs.FingerprintServer.model.tree.SimilaritySearchTree;
import com.nesolabs.FingerprintServer.mongo.MongoConnector;

@Path("/fingerprint")
public class FingerprintService {

	private static Logger mongoLogger = Logger.getLogger( "MongoLogger" );
	private static Logger fsLogger = Logger.getLogger( FingerprintService.class );
	
	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public Response newFingerprint(@HeaderParam("Authorization") String hmac,
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
			mongoLogger.error("Authorization failed for fingerprint request");
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

		Fingerprint fingerprint = null;
		SimilaritySearchTree tree = null;
		boolean unique = false;

		// Check if fingerprint is already present in database
		boolean fingerprintAlreadyKnown = false;
		try {
			fingerprint = mongoConnector.hasFingerprint(input);
		} catch (MongoException e) {
			MDC.put("input", input);
			mongoLogger.error("MongoDB: Error in finding matching fingerprint", e);
			MDC.remove("input");
			e.printStackTrace();
		}

		if (fingerprint == null) {
			// Fingerprint was not found in database => save and insert into
			// tree
			try {
				fingerprint = mongoConnector.saveFingerprint(input);
				MDC.put("fingerprintID", fingerprint.get_id());
				mongoLogger.info("New fingerprint saved");
				MDC.remove("fingerprintID");
			} catch (JsonParseException e) {
				MDC.put("input", input);
				mongoLogger.error("Json parsing failed", e);
				MDC.remove("input");
				e.printStackTrace();
			} catch (JsonMappingException e) {
				MDC.put("input", input);
				mongoLogger.error("Json mapping failed", e);
				MDC.remove("input");
				e.printStackTrace();
			} catch (MongoException e) {
				MDC.put("input", input);
				mongoLogger.error("Failed saving fingerprint", e);
				MDC.remove("input");
				e.printStackTrace();
			} catch (IOException e) {
				MDC.put("input", input);
				mongoLogger.error("Failed reading input", e);
				MDC.remove("input");
				e.printStackTrace();
			}

			tree = mongoConnector.loadSearchTree();

			if (tree == null) {
				mongoLogger.error("Failed loading searchTree");
				return new Response(true, "could not load SimilaritySearchTree");
			}

			try {
				unique = tree.insertFingerprint(fingerprint);
			} catch (IllegalArgumentException | IllegalAccessException e) {
				MDC.put("fingerprintID", fingerprint.get_id());
				mongoLogger.error("Reflection: Error Accessing Field");
				MDC.remove("fingerprintID");
				e.printStackTrace();
			} catch (UnknownHostException e) {
				fsLogger.error("MongoDB Error: Unknown host", e);
				e.printStackTrace();
			} catch (IOException e) {
				fsLogger.error("MongoDB Error: IOException", e);
				e.printStackTrace();
			}
		} else {
			fingerprintAlreadyKnown = true;
			MDC.put("fingerprintID", fingerprint.get_id());
			mongoLogger.info("Existing fingerprint submitted");
			MDC.remove("fingerprintID");
		}

		// Get fingerprint id
		String id = fingerprint.get_id().toString();

		// First, save timestamp for fingerprint
		mongoConnector.recordTimestampForFingerprint(id);

		// Get tree, if null
		if (tree == null) {
			tree = mongoConnector.loadSearchTree();
		}

		// Get the deepest node, in which the given fingerprint was compared
		Node deepestNodeForThisFingerprint = null;
		try {
			deepestNodeForThisFingerprint = tree
					.getDeepestNodeForFingerprintWithID(id);
		} catch (UnknownHostException e) {
			fsLogger.error("MongoDB Error: Unknown host", e);
			e.printStackTrace();
		} catch (IOException e) {
			fsLogger.error("MongoDB Error: IOException", e);
			e.printStackTrace();
		}

		
		// Get list of compared properties
		Field[] fields = Fingerprint.class.getDeclaredFields();
		ArrayList<String> comparedProperties = new ArrayList<String>();
		for (int i = 2; i < deepestNodeForThisFingerprint.getLevel() + 2; i++) {
			Field field = fields[i];
			comparedProperties.add(field.getName());
		}
		
		int equalFingerprints = deepestNodeForThisFingerprint.getVisitedFingerprints().size() - 1;

		String equalString = Integer.toString(equalFingerprints);
		
		if (fingerprintAlreadyKnown) {
			// uniqueness not set, since fp was not inserted in tree
			// => calculate from propertymatches
			unique = (equalFingerprints == 0);
			int sameCookieCount = mongoConnector.getFingerprintCountFromTimestamps(id);
			
			if (sameCookieCount > 1) {
				unique = false;
				int totalEqual = sameCookieCount + equalFingerprints;
				
				if (fingerprint.getLanguage().equals("de")) {
					equalString = totalEqual + " (davon " + sameCookieCount + " von Ihrem Gerät)";
				} else {
					equalString = totalEqual + " (" + sameCookieCount + " of those were sent by your device)";
				}
			}			
		}

		return new Response(id, unique, tree.getFpCount(), comparedProperties, equalString);
	}
}
