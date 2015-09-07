package com.nesolabs.FingerprintServer.model.tree;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.UnknownHostException;
import java.util.ArrayList;

import org.mongojack.ObjectId;

import com.nesolabs.FingerprintServer.model.Fingerprint;
import com.nesolabs.FingerprintServer.mongo.MongoConnector;

public class Node {

	private String _id;
	private int level;
	private boolean isLeaf = true;
	private Field field;
	private Object fieldValue;
	private String fingerprint = null;
	private Fingerprint oldFP;
	private ArrayList<Edge> edges;
	private ArrayList<String> visitedFingerprints;

	private final String VALUE_NOT_SET = "null";

	public Node() {
	}

	public Node(int level) {
		this.level = level;
		this.edges = new ArrayList<Edge>();
		this.visitedFingerprints = new ArrayList<String>();
	}

	/**
	 * Fügt den Fingerprint 'fp' in den Knoten / Baum ein. Speichert den
	 * aufrufenden Knoten
	 * 
	 * @param fp
	 *            - einzufügender Fingerprint
	 * @param sender
	 *            - zu speichernder Knoten
	 * @return uniqueness - true, wenn unique
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws IOException
	 */
	public boolean insertFingerprint(Fingerprint fp, Node sender)
			throws IllegalArgumentException, IllegalAccessException,
			IOException {

		MongoConnector mongoConnector = MongoConnector.sharedInstance();
		
		/*
		 * Speichere den Knoten, der diese Funktion aufgerufen hat, in mongoDB.
		 * Hier zu speichern ist wesentlich weniger Code, als würde man an jedem
		 * möglichen Ende dieser Funktion speichern.
		 */
		if (sender != null) {
			mongoConnector.saveNode(sender);
		}

		/*
		 * Behalte die '_id' aller Fingerabdrücke, die in diesem Knoten
		 * angekommen sind. (Sie haben alle die Eigenschaft zu diesem Level
		 * gleich)
		 */
		this.visitedFingerprints.add(fp.get_id().toString());

		/*
		 * Rekursionsende erreicht, wenn Baum so tief, dass alle Eigenschaften
		 * betrachtet wurden.
		 */
		if (this.level == Fingerprint.class.getDeclaredFields().length - 2) {
			mongoConnector.saveNode(this);
			return false;
		}

		/*
		 * Hole das für diesen Level zu überprüfende Feld via Reflection. Kann
		 * leider nicht im Konstruktor gemacht werden, da es nicht möglich ist,
		 * den Typ 'java.lang.reflect.Field' mit MongoJack zu serialisieren.
		 * Hier werden 2 übersprungen, weil sie nicht verglichen werden sollen
		 * ('_id' und 'cookie')
		 */
		this.field = Fingerprint.class.getDeclaredFields()[level + 2];
		this.field.setAccessible(true);

		/*
		 * Hole den Wert der Eigenschaft für diesen Level. Behandle außerdem den
		 * Fall, dass in 'fp' der Wert für diesen Node / level nicht gesetzt
		 * ist.
		 */
		this.fieldValue = this.field.get(fp);
		if (this.fieldValue == null) {
			this.fieldValue = VALUE_NOT_SET;
		}

		/*
		 * Behandle den Fall, dass dieser Knoten ein Blatt ist
		 */
		if (this.isLeaf) {

			/*
			 * Sonderbehandlung:
			 * 
			 * Dieser Knoten enthält noch keinen Fingerabdruck (er wurde also
			 * gerade erst erzeugt. Daher übernehme 'fp' und gebe true zurück.
			 * (Dieser Knoten ist immernoch ein Blatt)
			 */
			if (this.fingerprint == null) {
				this.fingerprint = fp.get_id().toString();
				mongoConnector.saveNode(this);
				return true;
			}

			/*
			 * Dieser Knoten wird ab jetzt kein Blatt mehr sein, da mindestens
			 * ein Kindknoten entsteht
			 */
			this.isLeaf = false;

			// Hole den aktuellen Fingerabdruck dieses Knotens aus der
			// Datenbank.
			this.oldFP = mongoConnector.getFingerprint(this.fingerprint);

			// Id des Fingerabdrucks wird in diesem Knoten nicht mehr benötigt
			this.fingerprint = null;

			/*
			 * Hole die beiden zu vergleichenden Werte. Auch hier wieder den
			 * Sonderfall behandeln, dass der Wert für diesen Level nicht
			 * gesetzt ist.
			 */
			Object oldValue = this.field.get(this.oldFP);
			Object newValue = this.fieldValue;
			if (oldValue == null) {
				oldValue = VALUE_NOT_SET;
			}

			if (newValue.equals(oldValue)) {
				// Beide gleich => Beide in den gleichen neuen Kindknoten
				// => Lege einen neuen Knoten und neue Kante an
				Node child = new Node(this.level + 1);
				
				child = mongoConnector.saveNode(child);
				
				Edge edge = new Edge(oldValue, child.get_id());

				// Füge Kante hinzu
				this.edges.add(edge);

				// Füge beide Fingerabdrücke ein
				child.insertFingerprint(this.oldFP, this);

				// Gib Wert zu aktuellem Fingerabdruck zurück
				return child.insertFingerprint(fp, this);
			} else {
				// Zwei verschiedene Werte
				// => Lege zwei neue Knoten an
				Node leftChild = new Node(this.level + 1);
				Node rightChild = new Node(this.level + 1);
				
				leftChild = mongoConnector.saveNode(leftChild);
				rightChild = mongoConnector.saveNode(rightChild);

				Edge edge1 = new Edge(oldValue, leftChild.get_id());
				Edge edge2 = new Edge(newValue, rightChild.get_id());

				this.edges.add(edge1);
				this.edges.add(edge2);

				// Zurückgegeben werden muss nur der Wert für den neuen
				// Fingerabdruck
				leftChild.insertFingerprint(this.oldFP, this);
				return rightChild.insertFingerprint(fp, this);
			}

		} else {
			/*
			 * Dieser Knoten ist kein Blatt
			 * 
			 * => Finde richtigen Kindknoten für den neuen Fingerprint
			 */
			for (Edge edge : this.edges) {
				if (this.fieldValue.equals(edge.getValue())) {
					
					Node child = mongoConnector.getNode(edge.getNode());
					
					return child.insertFingerprint(fp, this);
				}
			}
			// Kein passender Knoten gefunden => Lege neuen an
			Node newChild = new Node(this.level + 1);
			
			newChild = mongoConnector.saveNode(newChild);
			
			Edge edge = new Edge(this.fieldValue, newChild.get_id());
			this.edges.add(edge);
			return newChild.insertFingerprint(fp, this);
		}
	}
	
	public Node getDeepestNodeForFingerprintWithID(String id) throws UnknownHostException, IOException {
		Node deepestNode = null;
		if (this.visitedFingerprints.contains(id)) {
			deepestNode = this;
			for (Edge edge : this.edges) {
				Node child = MongoConnector.sharedInstance().getNode(edge.getNode());
				Node temp = child.getDeepestNodeForFingerprintWithID(id);
				if (temp != null) {
					deepestNode = temp;
				}
			}
		}
		return deepestNode;
	}

	// ####################
	// Getters & Setters
	// ####################

	@ObjectId
	public String get_id() {
		return _id;
	}

	@ObjectId
	public void set_id(String _id) {
		this._id = _id;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public String getFingerprint() {
		return fingerprint;
	}

	public void setFingerprint(String fingerprint) {
		this.fingerprint = fingerprint;
	}

	public ArrayList<Edge> getEdges() {
		return edges;
	}

	public void setEdges(ArrayList<Edge> edges) {
		this.edges = edges;
	}

	public ArrayList<String> getVisitedFingerprints() {
		return visitedFingerprints;
	}

	public void setVisitedFingerprints(ArrayList<String> visitedFingerprints) {
		this.visitedFingerprints = visitedFingerprints;
	}
}
