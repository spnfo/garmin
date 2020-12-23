using Toybox.WatchUi as Ui;
using Toybox.Communications;
using Toybox.Timer;
using Toybox.Application;
using Toybox.Application.Storage;
using Toybox.System;

var deviceUrl = "https://api.spnfo.com/device";
//var deviceUrl = "http://localhost:8000/device";
var deviceRequestOptions = {
	:method => Communications.HTTP_REQUEST_METHOD_GET,
	:responseType => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
};

class SPNFOInitializeScreen extends Ui.View {
	
	var refreshTimer;
	var statusTimer;
	var settings;
	var code;
	
	function refreshCallback(responseCode, data) {
		if (responseCode == 200) {
			self.code = data.get("code");
		} else {
			self.code = null;
		}
		
		Ui.requestUpdate();
	}
	
	function onRefresh() {
		var urlWithParams = deviceUrl + "?deviceId=" + settings.uniqueIdentifier;
		Communications.makeWebRequest(urlWithParams, null, deviceRequestOptions, method(:refreshCallback));
	}
	
	function statusCallback(responseCode, data) {

		if (responseCode == 200) {
			if (data.get("uid") != null) {
				// we are initialized -- store the uid
				
				Storage.setValue("uid", data.get("uid"));
				Storage.setValue("initialized", true);
				Application.getApp().loadUserMetadata();
				
				// navigate to home screen
				Ui.switchToView(new SPNFOHomeScreen(), new SPNFOEmptyDelegate(), Ui.SLIDE_LEFT);
			}
		}
	}
	
	function onStatus() {
		var urlWithParams = deviceUrl + "?deviceId=" + settings.uniqueIdentifier + "&status=true";
		Communications.makeWebRequest(urlWithParams, null, deviceRequestOptions, method(:statusCallback));
	}
	
	function initialize() {
		View.initialize();
	}
	
	function onLayout(dc) {
		setLayout(Rez.Layouts.InitializeLayout(dc));
		
		refreshTimer = new Timer.Timer();
		refreshTimer.start(method(:onRefresh), 1000 * 60 * 5, true);
		
		statusTimer = new Timer.Timer();
		statusTimer.start(method(:onStatus), 1000 * 10, true);
		
		settings = System.getDeviceSettings();
		
		onRefresh();

	}
	
	
	function onUpdate(dc) {
			
		if (code != null) {
			View.findDrawableById("codeLabel").setText(self.code.toString());
		} else {
			View.findDrawableById("codeLabel").setText(Ui.loadResource(Rez.Strings.initializeCodeLabel));
		}
		
	
		View.onUpdate(dc);
	}
	
	function onHide() {
		refreshTimer.stop();
		statusTimer.stop();
	}
}