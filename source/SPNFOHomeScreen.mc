using Toybox.WatchUi as Ui;
using Toybox.Communications;
using Toybox.Timer;
using Toybox.Time;
using Toybox.Application;
using Toybox.Attention;
using Toybox.Application.Storage;
using Toybox.System;

var statusUrl = "https://api.spnfo.com/gpsStatus";
//var statusUrl = "http://localhost:8000/status";
var statusRequestOptions = {
	:method => Communications.HTTP_REQUEST_METHOD_GET,
	:responseType => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
};

class SPNFOHomeScreen extends Ui.View {

	var countdownTimer;
	var statusTimer;
	var uid;
	
	var countdownNum;
	
	function countdown() {
		var topLabel = View.findDrawableById("topLabel");
		var centerLabel = View.findDrawableById("centerLabel");
		var bottomLabel = View.findDrawableById("bottomLabel");
		topLabel.setText("");
		centerLabel.setText(countdownNum.toString());
		bottomLabel.setText("");
		
		Ui.requestUpdate();
		
		countdownNum--;
		
		if (countdownNum < 0) {
			Application.getApp().startPostTimer();
			
			if (Attention has :ToneProfile) {
				var toneProfile = [ new Attention.ToneProfile(250, 880) ];
				Attention.playTone({:toneProfile => toneProfile});
			}
			
			Ui.switchToView(new SPNFOTopView(), new SPNFOTopDelegate(), Ui.SLIDE_RIGHT);
		} else {
			if (Attention has :ToneProfile) {
				var toneProfile = [ new Attention.ToneProfile(500, 440) ];
				Attention.playTone({:toneProfile => toneProfile});
			}
		}
	}
	
	function startRace() {
		countdownTimer = new Timer.Timer();
		countdownTimer.start(method(:countdown), 1000, true);
	}
	
	function statusCallback(responseCode, data) {

		if (responseCode == 200) {
			var raceMetadata = {
				"rid" => data.get("rid"),
				"name" => data.get("name"),
				"numRacers" => data.get("numRacers"),
				"avgChkptDist" => data.get("avgChkptDist"),
				"laps" => data.get("laps"),
				"numChkpts" => data.get("numChkpts")
			};
			
			Application.getApp().setRaceMetadata(raceMetadata);
			
			if (data.get("startTime") instanceof Number) {
				// Race has already started
				Application.getApp().startPostTimer();
				Ui.switchToView(new SPNFOTopView(), new SPNFOTopDelegate(), Ui.SLIDE_RIGHT);
			} else {
				// set race timer for countdown
				statusTimer.stop();
				var startTime = data.get("startTime");	
				var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
				
				var startMomentOptions = {
					:year => now.year,
					:month => now.month,
					:day => now.day,
					:hour => startTime.substring(0,2).toNumber(),
					:minute => startTime.substring(3,5).toNumber(),
					:second => startTime.substring(6,8).toNumber()
				};
				
				var startMoment = Time.Gregorian.moment(startMomentOptions);
				var startMomentInfo = Time.Gregorian.info(startMoment, Time.FORMAT_SHORT);
				
				var tts = startMoment.subtract(Time.now());
				countdownNum = tts.value();
				
				if (countdownNum > 30) {
					// I think this  means race is starting right on the hour ????
					Application.getApp().startPostTimer();
					Ui.switchToView(new SPNFOTopView(), new SPNFOTopDelegate(), Ui.SLIDE_RIGHT);
				} else {
					countdownTimer = new Timer.Timer();
					countdownTimer.start(method(:countdown), 1000, true); 
				}
			}
		}
	}
	
	function onStatus() {
		var urlWithParams = statusUrl + "?uid=" + uid.toString();
		Communications.makeWebRequest(urlWithParams, null, statusRequestOptions, method(:statusCallback));
	}
	
	function initialize() {
		View.initialize();
	}
	
	function onLayout(dc) {
		setLayout(Rez.Layouts.HomeScreenLayout(dc));
		
		uid = Storage.getValue("uid");
		
		statusTimer = new Timer.Timer();
		statusTimer.start(method(:onStatus), 1000 * 10, true);		

		onStatus();
	}
	
	
	function onUpdate(dc) {
	
		View.onUpdate(dc);
	}
	
	function onHide() {
	
		if (statusTimer != null) {
			statusTimer.stop();
		}
		
		if (countdownTimer != null) {
			countdownTimer.stop();
		}
		
	}
}