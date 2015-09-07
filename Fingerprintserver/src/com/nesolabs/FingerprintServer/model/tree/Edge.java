package com.nesolabs.FingerprintServer.model.tree;

public class Edge {

	private Object value;
	private String node;
	
	public Edge() {}
	
	public Edge(Object value, String node) {
		this.value = value;
		this.node = node;
	}

	public Object getValue() {
		return value;
	}

	public void setValue(Object value) {
		this.value = value;
	}

	public String getNode() {
		return node;
	}

	public void setNode(String node) {
		this.node = node;
	}
	
	
}
