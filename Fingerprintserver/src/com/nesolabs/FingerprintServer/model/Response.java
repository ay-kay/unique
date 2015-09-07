package com.nesolabs.FingerprintServer.model;

import java.util.ArrayList;

public class Response {

	private String id;
	private boolean unique;
	private boolean requestFailed;
	private String errorDescription;
	private int fingerprintCount;
	private ArrayList<String> propertyMatches;
	private String equalFingerprints;
	
	public Response() {};
	
	public Response(String id, boolean unique, int fingerprintCount, ArrayList<String> propertyMatches, String equalFingerprints) {
		this.id = id;
		this.unique = unique;
		this.fingerprintCount = fingerprintCount;
		this.propertyMatches = propertyMatches;
		this.equalFingerprints = equalFingerprints;
		this.requestFailed = false;
	}
	
	public Response(boolean requestFailed, String error) {
		this.requestFailed = requestFailed;
		this.errorDescription = error;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public boolean isUnique() {
		return unique;
	}

	public void setUnique(boolean unique) {
		this.unique = unique;
	}

	public boolean isRequestFailed() {
		return requestFailed;
	}

	public void setRequestFailed(boolean requestFailed) {
		this.requestFailed = requestFailed;
	}
	
	public String getErrorDescription() {
		return errorDescription;
	}

	public void setErrorDescription(String errorDescription) {
		this.errorDescription = errorDescription;
	}

	public int getFingerprintCount() {
		return fingerprintCount;
	}

	public void setFingerprintCount(int fingerprintCount) {
		this.fingerprintCount = fingerprintCount;
	}

	public ArrayList<String> getPropertyMatches() {
		return propertyMatches;
	}

	public void setPropertyMatches(ArrayList<String> propertyMatches) {
		this.propertyMatches = propertyMatches;
	}

	public String getEqualFingerprints() {
		return equalFingerprints;
	}

	public void setEqualFingerprints(String equalFingerprints) {
		this.equalFingerprints = equalFingerprints;
	}
}
