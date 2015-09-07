package com.nesolabs.FingerprintServer.model.tree;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Queue;

import org.apache.log4j.Logger;
import org.apache.log4j.MDC;
import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.mongojack.ObjectId;

import com.nesolabs.FingerprintServer.FingerprintService;
import com.nesolabs.FingerprintServer.model.Fingerprint;
import com.nesolabs.FingerprintServer.mongo.MongoConnector;

@JsonIgnoreProperties(ignoreUnknown = true)
public class SimilaritySearchTree {
	
	private static Logger mongoLogger = Logger.getLogger( "MongoLogger" );
	private static Logger fsLogger = Logger.getLogger( FingerprintService.class );

	private String _id;
	private Node root;
	private int fpCount = 0;

	public SimilaritySearchTree() {
	}
	
	public SimilaritySearchTree(boolean first) {
		try {
			this.root = MongoConnector.sharedInstance().saveNode(new Node(0));
		} catch (IOException e) {
			fsLogger.error("MongoDB Error: IOException", e);
			e.printStackTrace();
		}
	}

	/**
	 * Fügt den gegebenen Fingerabdruck in den Suchbaum ein.
	 * 
	 * @param fingerprint
	 * @return uniqueness - true, wenn Fingerabdruck (unter den bisherigen)
	 *         eindeutig
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws IOException
	 */
	public boolean insertFingerprint(Fingerprint fingerprint)
			throws IllegalArgumentException, IllegalAccessException,
			IOException {
		fpCount++;

		boolean uniqueness = false;
		try {
			uniqueness = this.root.insertFingerprint(fingerprint, null);
		} catch (Exception e) {
			MDC.put("fingerprintID", fingerprint.get_id());
			mongoLogger.error("Exception while inserting fingerprint in tree", e);
			MDC.remove("fingerprintID");
			e.printStackTrace();
		}

		MongoConnector.sharedInstance().saveTree(this);

		return uniqueness;
	}

	/**
	 * Untersucht, wie viele bereits vorhandene Fingerabdrücke die gleiche
	 * Ausprägung für die unterschiedlichen Eigenschaften trägt
	 * 
	 * @param fp
	 * @return HashMap (String, Integer) - Zuordnung von Eigenschaft (Name) zu
	 *         Vorkommen im Baum
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws IOException 
	 * @throws UnknownHostException 
	 */
	public HashMap<String, Integer> getPropertyUniquessForFingerprint(
			Fingerprint fp) throws IllegalArgumentException,
			IllegalAccessException, UnknownHostException, IOException {

		HashMap<String, Integer> propertyMatches = new HashMap<String, Integer>();

		Field[] fields = Fingerprint.class.getDeclaredFields();

		// Lege queue an und füge Wurzel ein
		Queue<Node> queue = new LinkedList<Node>();
		queue.add(this.root);
		
		MongoConnector mongoConnector = MongoConnector.sharedInstance();

		// Leere die Queue
		while (!queue.isEmpty()) {
			// Nimm ersten Knoten aus Queue
			Node node = queue.remove();

			if (node.getLevel() == fields.length - 2) {
				break;
			}

			// Füge seine Kindknoten zu Queue hinzu und
			// Werte Edges aus
			Field field = fields[node.getLevel() + 2];
			field.setAccessible(true);
			Object fpValue = (field.get(fp) == null) ? "null" : field.get(fp);

			// Zähle alle Aufkommen der gleichen Ausprägungen der Eigenschaften
			Integer matches = 0;
			if (propertyMatches.containsKey(field.getName())) {
				matches = propertyMatches.get(field.getName());
			}

			for (Edge edge : node.getEdges()) {
				
				Node n = mongoConnector.getNode(edge.getNode());
				
				queue.add(n);
				// Prüfe, ob eine Kante den gleichen Wert trägt, wie 'fp'
				if (edge.getValue().equals(fpValue)) {
					matches += n.getVisitedFingerprints().size();
				}
			}
			
			propertyMatches.put(field.getName(), matches);
		}
		HashMap<String, Integer> correctValues = new HashMap<String, Integer>();
		
		// Ziehe eins ab (für den Fingerabdruck, der gerade überprüft wird)
		for (String key : propertyMatches.keySet()) {
			Integer value = propertyMatches.get(key) - 1;
			correctValues.put(key, Math.max(0, value));
			
		}
		
		return correctValues;
	}
	
	public Node getDeepestNodeForFingerprintWithID(String id) throws UnknownHostException, IOException {
		return this.root.getDeepestNodeForFingerprintWithID(id);
	}

	// ####################
	// Getters & Setters
	// ####################

	@ObjectId
	public String get_id() {
		return _id;
	}

	@ObjectId
	public void set_id(String id) {
		this._id = id;
	}

	public Node getRoot() {
		return root;
	}

	public void setRoot(Node root) {
		this.root = root;
	}

	public int getFpCount() {
		return fpCount;
	}

	public void setFpCount(int fpCount) {
		this.fpCount = fpCount;
	}
}
