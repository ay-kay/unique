package com.nesolabs.FingerprintServer.mongo;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.UnknownHostException;
import java.util.Date;
import java.util.HashMap;

import org.apache.log4j.Logger;
import org.apache.log4j.MDC;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.mongojack.JacksonDBCollection;
import org.mongojack.WriteResult;

import com.mongodb.BasicDBList;
import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;
import com.mongodb.MongoException;
import com.mongodb.WriteConcern;
import com.mongodb.util.JSON;
import com.nesolabs.FingerprintServer.model.Fingerprint;
import com.nesolabs.FingerprintServer.model.tree.Node;
import com.nesolabs.FingerprintServer.model.tree.SimilaritySearchTree;

public class MongoConnector {

	private static Logger logger = Logger.getLogger(MongoConnector.class);
	private static MongoConnector connector = null;

	private DB db;
	private MongoClient mongoClient;
	private JacksonDBCollection<Fingerprint, String> collection;
	private JacksonDBCollection<SimilaritySearchTree, String> treeCollection;
	private JacksonDBCollection<Node, String> nodeCollection;
	private DBCollection fingerprintTimestamps;

	private MongoConnector() throws UnknownHostException {
		this.mongoClient = new MongoClient();
		try {
			this.mongoClient.getDB("admin").command("ping");
			this.db = mongoClient.getDB("fingerprinting");
			this.db.authenticate("localuser", "speedmax123".toCharArray());
			DBCollection fingerprintCollection = this.db
					.getCollection("fingerprints");
			fingerprintCollection.setWriteConcern(WriteConcern.SAFE);
			this.collection = JacksonDBCollection.wrap(fingerprintCollection,
					Fingerprint.class, String.class);
			this.collection.setWriteConcern(WriteConcern.SAFE);
			this.treeCollection = JacksonDBCollection.wrap(
					this.db.getCollection("tree"), SimilaritySearchTree.class,
					String.class);
			this.nodeCollection = JacksonDBCollection.wrap(
					this.db.getCollection("nodes"), Node.class, String.class);
			this.fingerprintTimestamps = this.db
					.getCollection("fingerprintTimestamps");
		} catch (Exception e) {
			e.printStackTrace();
			logger.error("No connection to mongoDB", e);
		}
	}

	/**
	 * MongoDB Connector (Singleton)
	 * 
	 * @return MongoConnector (Shared Instance)
	 * @throws UnknownHostException
	 */
	public static MongoConnector sharedInstance() throws UnknownHostException {
		if (connector == null) {
			connector = new MongoConnector();
		}
		return connector;
	}

	/*
	 * Database methods
	 */
	
	/**
	 * Associates the current timestamp with the sent in fingerprint
	 * 
	 * @param id objectID as String 
	 */
	public void recordTimestampForFingerprint(String id) {
		DBObject query = new BasicDBObject("fingerprintID", id);
		DBObject update = new BasicDBObject("$push", new BasicDBObject("timestamps", new Date()));
		this.fingerprintTimestamps.update(query, update, true, false);
	}
	
	/**
	 * Gets the Fingerprint with the given '_id' from mongoDB
	 * 
	 * @param objectIdString
	 * @return
	 */
	public Fingerprint getFingerprint(String objectIdString) {
		try {
			return this.collection.findOneById(objectIdString);
		} catch (MongoException e) {
			MDC.put("fingerprintID", objectIdString);
			logger.error("MongoDB: getFingerprint failed", e);
			MDC.remove("fingerprintID");
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * Searches database for the given input
	 * 
	 * @param JSONInput
	 * @return true, if fingerprint exists in database
	 * @throws IOException
	 * @throws JsonMappingException
	 * @throws JsonParseException
	 */
	public Fingerprint hasFingerprint(String input) throws MongoException {
		ObjectMapper mapper = new ObjectMapper();
		Fingerprint fingerprint = null;
		try {
			fingerprint = mapper.readValue(input, Fingerprint.class);
		} catch (JsonParseException e) {
			MDC.put("input", input);
			logger.error("Json parsing failed", e);
			MDC.remove("input");
			e.printStackTrace();
		} catch (JsonMappingException e) {
			MDC.put("input", input);
			logger.error("Json mapping failed", e);
			MDC.remove("input");
			e.printStackTrace();
		} catch (IOException e) {
			MDC.put("input", input);
			logger.error("Failed reading input", e);
			MDC.remove("input");
			e.printStackTrace();
		}

		DBObject query = fingerprint.bsonFromPojo();

		Fingerprint fp = this.collection.findOne(query);
		return fp;
	}
	
	public int getFingerprintCountFromTimestamps(String objectIDString) {
		DBObject query = new BasicDBObject("fingerprintID", objectIDString);
		DBObject timestamp;
		try {
			timestamp = this.fingerprintTimestamps.findOne(query);
		} catch (MongoException e) {
			return 0;
		}
		
		BasicDBList stamps = (BasicDBList) timestamp.get("timestamps");
		
		if (stamps != null) {
			return stamps.size();
		} else {
			return 0;
		}
	}

	/**
	 * Saves the given Fingerprint (JSON format) into "fingerprints" Collection
	 * and gives back a 'Fingerprint' Object
	 * 
	 * @param JSONInput
	 * @return Fingerprint - the inserted Fingerprint
	 * @throws IOException
	 *             , MongoException
	 * @throws JsonMappingException
	 * @throws JsonParseException
	 */
	public Fingerprint saveFingerprint(String JSONInput)
			throws JsonParseException, JsonMappingException, IOException,
			MongoException {
		ObjectMapper mapper = new ObjectMapper();
		Fingerprint fp = mapper.readValue(JSONInput, Fingerprint.class);

		WriteResult<Fingerprint, String> result = this.collection.save(fp,
				WriteConcern.SAFE);

		Fingerprint savedObject = result.getSavedObject();

		/*
		 * If the fingerprint has not yet a cookie, set its '_id' as its
		 * 'cookie'
		 */
		if (savedObject.getCookie() == null) {
			savedObject.setCookie(result.getSavedId());
			result = this.collection.save(savedObject);
		}
		return result.getSavedObject();
	}

	/**
	 * Saves the searchTree into mongoDB
	 * 
	 * @param tree
	 * @return success
	 */
	public boolean saveTree(SimilaritySearchTree tree) {

		try {
			@SuppressWarnings("unused")
			WriteResult<SimilaritySearchTree, String> result = this.treeCollection
					.save(tree, WriteConcern.SAFE);
		} catch (MongoException e) {
			logger.error("Error saving the tree", e);
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public SimilaritySearchTree loadSearchTree() {
		try {

			if (this.treeCollection.count() == 0) {
				return new SimilaritySearchTree(true);
			}

			return this.treeCollection.findOne();
		} catch (MongoException e) {
			logger.error("Error loading the tree", e);
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Saves the given node into mongoDB
	 * 
	 * @param sender
	 * @return the node's ObjectID
	 */
	public Node saveNode(Node sender) {
		try {
			WriteResult<Node, String> result = this.nodeCollection.save(sender,
					WriteConcern.SAFE);
			return result.getSavedObject();
		} catch (MongoException e) {
			MDC.put("node", sender.get_id());
			logger.error("Error saving a node", e);
			MDC.remove("node");
			e.printStackTrace();
			return null;
		}
	}

	public Node getNode(String objectIDString) {
		try {
			return this.nodeCollection.findOneById(objectIDString);
		} catch (MongoException e) {
			MDC.put("nodeID", objectIDString);
			logger.error("Error loading a node", e);
			MDC.remove("nodeID");
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Saves the given push-token into mongoDB
	 * 
	 * @param token
	 * @return success
	 */
	public boolean saveToken(String token) {
		DBCollection tokenCollection = this.db.getCollection("pushTokens");
		DBObject tokenObject = (DBObject) JSON.parse(token);
		DBObject queryObject = (DBObject) JSON.parse(token);
		queryObject.removeField("language");
		com.mongodb.WriteResult result = tokenCollection.update(queryObject,
				tokenObject, true, false, WriteConcern.SAFE);
		return result.getLastError().ok();
	}
	
	/**
	 * Saves the given errorMessage into mongoDB
	 * 
	 * @param error
	 * @return success
	 */
	public boolean saveErrorMessage(String errorMessage) {
		DBCollection errorCollection = this.db.getCollection("errorMessages");
		DBObject errmsg = (DBObject) JSON.parse(errorMessage);
		com.mongodb.WriteResult result = errorCollection.insert(errmsg);
		return result.getLastError().ok();
	}

	/**
	 * Searches the database for other fingerprints matching the properties of the given one.
	 * Inserts them in a map (Fieldname, matches).
	 * 
	 * @param fp
	 * @param maxCompareLevel
	 * @return map propertyMatches (Fieldname, matches)
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 */
	public HashMap<String, Long> fillPropertyMatchesForFingerprint(
			Fingerprint fp, int maxCompareLevel) throws IllegalArgumentException, IllegalAccessException {
		HashMap<String, Long> propertyMatches = new HashMap<String, Long>();

		Field[] fields = Fingerprint.class.getDeclaredFields();

		for (int i = 2; i <= maxCompareLevel + 2; i++) {
			Field field = fields[i];
			field.setAccessible(true);
			String fieldName = field.getName();
			Object fpValue = (field.get(fp) == null) ? "null" : field.get(fp);
			
			// Get count from database for matching fingerprints
			DBObject query = new BasicDBObject(fieldName, fpValue);
			
			long count = this.collection.count(query);

			propertyMatches.put(fieldName, (count - 1));
		}
		return propertyMatches;
	}
}
