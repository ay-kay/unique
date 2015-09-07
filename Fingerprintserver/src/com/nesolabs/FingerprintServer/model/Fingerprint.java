package com.nesolabs.FingerprintServer.model;

import java.util.ArrayList;
import java.util.HashMap;

import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.mongojack.ObjectId;

import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Fingerprint {

	@ObjectId
	public String get_id() {
		return _id;
	}

	@ObjectId
	public void set_id(String _id) {
		this._id = _id;
	}

	private String _id;
	private String cookie;

	// ###########
	// unprotected
	// ###########

	private Boolean jailbreak;
	private String iosVersion;
	private Boolean voipAllowed;
	private String carrierName;
	private Boolean monoAudio;
	private String name;
	private Boolean canSendTweet;
	private Boolean canMakePayments;
	private Boolean invertedColors;
	private Boolean voiceOver;
	private Boolean guidedAccess;
	private Boolean closedCaptioning;
	private Boolean trackingEnabled;
	private String model;
	private String country;
	private String language;
	private Boolean diff;
	private String identifierForVendor;
	private String reachability;
	private String wifiSSID;
	private String isp;
	private String publicIP;

	private ArrayList<String> keyboards;
	private ArrayList<String> apps;
	private ArrayList<HashMap<String, String>> top50Songs;

	// ###########
	// protected
	// ###########

	private ArrayList<String> assets;
	private ArrayList<String> twitter;
	private ArrayList<HashMap<String, Object>> contacts;
	private ArrayList<String> reminders;
	private ArrayList<String> calendars;

	// ###########
	// plists
	// ###########

	private Boolean plist_battery;
	private String plist_disksize;
	private String plist_appleID;
	private String plist_playerID;
	private String plist_ringtone;
	private String plist_smstone;
	private String plist_callVibration;
	private String plist_smsVibration;
	private ArrayList<HashMap<String, String>> plist_itunesHosts;
	private ArrayList<String> plist_apps;
	private ArrayList<String> plist_codeSigningIdentities;

	public Fingerprint() {
	}

	public DBObject bsonFromPojo() {

		BasicDBObject document = new BasicDBObject();

		document.put("cookie", this.cookie);
		document.put("jailbreak", this.jailbreak);
		document.put("iosVersion", this.iosVersion);
		document.put("voipAllowed", this.voipAllowed);
		document.put("carrierName", this.carrierName);
		document.put("monoAudio", this.monoAudio);
		document.put("name", this.name);
		document.put("canSendTweet", this.canSendTweet);
		document.put("canMakePayments", this.canMakePayments);
		document.put("invertedColors", this.invertedColors);
		document.put("voiceOver", this.voiceOver);
		document.put("guidedAccess", this.guidedAccess);
		document.put("closedCaptioning", this.closedCaptioning);
		document.put("trackingEnabled", this.trackingEnabled);
		document.put("model", this.model);
		document.put("country", this.country);
		document.put("language", this.language);
		document.put("diff", this.diff);
		document.put("identifierForVendor", this.identifierForVendor);
		document.put("reachability", this.reachability);
		document.put("wifiSSID", this.wifiSSID);
		document.put("isp", this.isp);
		document.put("publicIP", this.publicIP);
		document.put("keyboards", this.keyboards);
		document.put("apps", this.apps);
		document.put("top50Songs", this.top50Songs);
		document.put("assets", this.assets);
		document.put("twitter", this.twitter);
		document.put("contacts", this.contacts);
		document.put("reminders", this.reminders);
		document.put("calendars", this.calendars);
		document.put("plist_battery", this.plist_battery);
		document.put("plist_disksize", this.plist_disksize);
		document.put("plist_appleID", this.plist_appleID);
		document.put("plist_playerID", this.plist_playerID);
		document.put("plist_ringtone", this.plist_ringtone);
		document.put("plist_smstone", this.plist_smstone);
		document.put("plist_callVibration", this.plist_callVibration);
		document.put("plist_smsVibration", this.plist_smsVibration);
		document.put("plist_itunesHosts", this.plist_itunesHosts);
		document.put("plist_apps", this.plist_apps);
		document.put("plist_codeSigningIdentities", this.plist_codeSigningIdentities);

		return document;
	}

	// ####################
	// Getters & Setters
	// ###################

	public String getCookie() {
		return cookie;
	}

	public void setCookie(String cookie) {
		this.cookie = cookie;
	}

	public Boolean isJailbreak() {
		return jailbreak;
	}

	public void setJailbreak(Boolean jailbreak) {
		this.jailbreak = jailbreak;
	}

	public String getIosVersion() {
		return iosVersion;
	}

	public void setIosVersion(String iosVersion) {
		this.iosVersion = iosVersion;
	}

	public Boolean isVoipAllowed() {
		return voipAllowed;
	}

	public void setVoipAllowed(Boolean voipAllowed) {
		this.voipAllowed = voipAllowed;
	}

	public String getCarrierName() {
		return carrierName;
	}

	public void setCarrierName(String carrierName) {
		this.carrierName = carrierName;
	}

	public Boolean isMonoAudio() {
		return monoAudio;
	}

	public void setMonoAudio(Boolean monoAudio) {
		this.monoAudio = monoAudio;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Boolean isCanSendTweet() {
		return canSendTweet;
	}

	public void setCanSendTweet(Boolean canSendTweet) {
		this.canSendTweet = canSendTweet;
	}

	public Boolean isCanMakePayments() {
		return canMakePayments;
	}

	public void setCanMakePayments(Boolean canMakePayments) {
		this.canMakePayments = canMakePayments;
	}

	public Boolean isInvertedColors() {
		return invertedColors;
	}

	public void setInvertedColors(Boolean invertedColors) {
		this.invertedColors = invertedColors;
	}

	public Boolean isVoiceOver() {
		return voiceOver;
	}

	public void setVoiceOver(Boolean voiceOver) {
		this.voiceOver = voiceOver;
	}

	public Boolean isGuidedAccess() {
		return guidedAccess;
	}

	public void setGuidedAccess(Boolean guidedAccess) {
		this.guidedAccess = guidedAccess;
	}

	public Boolean isClosedCaptioning() {
		return closedCaptioning;
	}

	public void setClosedCaptioning(Boolean closedCaptioning) {
		this.closedCaptioning = closedCaptioning;
	}

	public Boolean isTrackingEnabled() {
		return trackingEnabled;
	}

	public void setTrackingEnabled(Boolean trackingEnabled) {
		this.trackingEnabled = trackingEnabled;
	}

	public String getModel() {
		return model;
	}

	public void setModel(String model) {
		this.model = model;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getLanguage() {
		return language;
	}

	public void setLanguage(String language) {
		this.language = language;
	}

	public Boolean isDiff() {
		return diff;
	}

	public void setDiff(Boolean diff) {
		this.diff = diff;
	}

	public String getIdentifierForVendor() {
		return identifierForVendor;
	}

	public void setIdentifierForVendor(String identifierForVendor) {
		this.identifierForVendor = identifierForVendor;
	}

	public String getReachability() {
		return reachability;
	}

	public void setReachability(String reachability) {
		this.reachability = reachability;
	}

	public String getWifiSSID() {
		return wifiSSID;
	}

	public void setWifiSSID(String wifiSSID) {
		this.wifiSSID = wifiSSID;
	}

	public String getIsp() {
		return isp;
	}

	public void setIsp(String isp) {
		this.isp = isp;
	}

	public String getPublicIP() {
		return publicIP;
	}

	public void setPublicIP(String publicIP) {
		this.publicIP = publicIP;
	}

	public ArrayList<String> getKeyboards() {
		return keyboards;
	}

	public void setKeyboards(ArrayList<String> keyboards) {
		this.keyboards = keyboards;
	}

	public ArrayList<String> getApps() {
		return apps;
	}

	public void setApps(ArrayList<String> apps) {
		this.apps = apps;
	}

	public ArrayList<HashMap<String, String>> getTop50Songs() {
		return top50Songs;
	}

	public void setTop50Songs(ArrayList<HashMap<String, String>> top50Songs) {
		this.top50Songs = top50Songs;
	}

	public ArrayList<String> getAssets() {
		return assets;
	}

	public void setAssets(ArrayList<String> assets) {
		this.assets = assets;
	}

	public ArrayList<String> getTwitter() {
		return twitter;
	}

	public void setTwitter(ArrayList<String> twitter) {
		this.twitter = twitter;
	}

	public ArrayList<HashMap<String, Object>> getContacts() {
		return contacts;
	}

	public void setContacts(ArrayList<HashMap<String, Object>> contacts) {
		this.contacts = contacts;
	}

	public ArrayList<String> getReminders() {
		return reminders;
	}

	public void setReminders(ArrayList<String> reminders) {
		this.reminders = reminders;
	}

	public ArrayList<String> getCalendars() {
		return calendars;
	}

	public void setCalendars(ArrayList<String> calendars) {
		this.calendars = calendars;
	}

	public Boolean getPlist_battery() {
		return plist_battery;
	}

	public void setPlist_battery(Boolean plist_battery) {
		this.plist_battery = plist_battery;
	}

	public String getPlist_disksize() {
		return plist_disksize;
	}

	public void setPlist_disksize(String plist_disksize) {
		this.plist_disksize = plist_disksize;
	}

	public String getPlist_appleID() {
		return plist_appleID;
	}

	public void setPlist_appleID(String plist_appleID) {
		this.plist_appleID = plist_appleID;
	}

	public String getPlist_playerID() {
		return plist_playerID;
	}

	public void setPlist_playerID(String plist_playerID) {
		this.plist_playerID = plist_playerID;
	}

	public String getPlist_ringtone() {
		return plist_ringtone;
	}

	public void setPlist_ringtone(String plist_ringtone) {
		this.plist_ringtone = plist_ringtone;
	}

	public String getPlist_smstone() {
		return plist_smstone;
	}

	public void setPlist_smstone(String plist_smstone) {
		this.plist_smstone = plist_smstone;
	}

	public String getPlist_callVibration() {
		return plist_callVibration;
	}

	public void setPlist_callVibration(String plist_callVibration) {
		this.plist_callVibration = plist_callVibration;
	}

	public String getPlist_smsVibration() {
		return plist_smsVibration;
	}

	public void setPlist_smsVibration(String plist_smsVibration) {
		this.plist_smsVibration = plist_smsVibration;
	}

	public ArrayList<HashMap<String, String>> getPlist_itunesHosts() {
		return plist_itunesHosts;
	}

	public void setPlist_itunesHosts(
			ArrayList<HashMap<String, String>> plist_itunesHosts) {
		this.plist_itunesHosts = plist_itunesHosts;
	}

	public ArrayList<String> getPlist_apps() {
		return plist_apps;
	}

	public void setPlist_apps(ArrayList<String> plist_apps) {
		this.plist_apps = plist_apps;
	}

	public ArrayList<String> getPlist_codeSigningIdentities() {
		return plist_codeSigningIdentities;
	}

	public void setPlist_codeSigningIdentities(
			ArrayList<String> plist_codeSigningIdentities) {
		this.plist_codeSigningIdentities = plist_codeSigningIdentities;
	}
}
