using Toybox.ActivityRecording;
using Toybox.Application;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.Position;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

var requestUrl = "https://intake.spnfo.com/intake";
//var requestUrl = "http://localhost:8000/intake";
var raceCompletedUrl = "https://intake.spnfo.com/finish";

var requestOptions = {
	:method => Communications.HTTP_REQUEST_METHOD_POST,
	:headers => {
		"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
	},
	:responseType => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
};


class SPNFOApp extends Application.AppBase {
	
	var secondsTimer;
	var postTimer;
	var initialized;
	var session;
			
	var numSeconds = 0;
	var subSeconds = 0;
	var postFreq = 500;
	var reqPerSec = 1000 / postFreq;
	
	var userMetadata;	
	var raceMetadata;
	
	var responseValues = {};
	
	function saveSession() {
		if (self.session != null) {
//			System.println("saving activity...");
			self.session.save();
		}
	}
	
	function discardSession() {
		if (self.session != null) {
//			System.println("discarding activity...");
			self.session.discard();
			self.session = null;
		}
	}
	
	function getResponseValues() {
		return self.responseValues;
	}
	
	function getRaceMetadata() {
		return self.raceMetadata;
	}
	
	function setRaceMetadata(rmd) {
		self.raceMetadata = rmd;
	}
	
	function loadUserMetadata() {
		userMetadata = {
			"uid" => Storage.getValue("uid")
		};
	}
	
	function timeTimerCallback() {
		numSeconds++;
	}
	
	function fakePositionCallback(info) {}
	
	function onReceiveRaceData(responseCode, data) {
//		System.println(responseCode);
//		System.println(data);
	
		if (responseCode == 200) {
			
			responseValues.put("connected", true);
			responseValues.put("inSprintZone", data.get("inSprintZone"));
			responseValues.put("distToNextSprint", data.get("distToNextSprint"));
			responseValues.put("pts", data.get("totalPoints"));
			responseValues.put("leaderboard", data.get("leaderboard"));
			responseValues.put("lastSprintPlace", data.get("last_sprint_place"));
			responseValues.put("place", data.get("place"));
			responseValues.put("uid", data.get("uid"));
			responseValues.put("checkpoint", data.get("checkpoint"));
			
			if (raceMetadata != null && (data.get("checkpoint") > raceMetadata.get("laps") * raceMetadata.get("numChkpts"))) {
				raceCompleted();
			}
			
		} else {
			responseValues.put("connected", false);
		}
		
		Ui.requestUpdate();
	}
	
	function makeRequest() {
		
		var positionInfo = Position.getInfo();

//		System.println(positionInfo.position.toDegrees());
//		System.println(positionInfo.accuracy);
		
		if (positionInfo has :accuracy) {
			responseValues.put("accuracy", positionInfo.accuracy);
		}
		
		if (userMetadata.get("uid") != null && positionInfo has :position && positionInfo.position != null) {
			var body = {
				"user" => userMetadata.get("uid"),
				"event" => raceMetadata.get("rid"),
				"req_id" => userMetadata.get("uid").toString() + "-" + numSeconds.toString() + (subSeconds % reqPerSec).toString(),
				"position" => positionInfo.position.toDegrees()
			};
			
//			System.println(body);
									
			Communications.makeWebRequest(requestUrl, body, requestOptions, method(:onReceiveRaceData));
			
			subSeconds++;
		}
		
	}
	
	function startPostTimer() {
		numSeconds = 0;
		Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:fakePositionCallback));
		
		postTimer.start(method(:makeRequest), postFreq, true);
		secondsTimer.start(method(:timeTimerCallback), 1000, true);
		
//		System.println(raceMetadata.get("name"));
		
		if ((session == null) || (session.isRecording() == false)) {
			System.println("starting to record...");
			session = ActivityRecording.createSession({
				:name => raceMetadata.get("name"),
				:sport => ActivityRecording.SPORT_CYCLING,
				:subSport => ActivityRecording.SUB_SPORT_ROAD
			});
			
			session.start();
		}
	}
	
	function raceCompletedCallback(responseCode, data) {
	
		System.println("stopping session...");
		session.stop();
		raceMetadata = null;
	
		var v = new SPNFORaceCompleted();
		Ui.switchToView(v, new SPNFORaceCompletedDelegate(v), Ui.SWIPE_RIGHT);
	}
	
	function raceCompleted() {
		Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:fakePositionCallback));
		postTimer.stop();
		secondsTimer.stop();
				
//		System.println(userMetadata);
//		System.println(raceMetadata);
		
		var body = {
			"uid" => userMetadata.get("uid"),
			"rid" => raceMetadata.get("rid")
		};
		
		System.println(body);
		
		Communications.makeWebRequest(raceCompletedUrl, body, requestOptions,	method(:raceCompletedCallback));
	}

    function initialize() {
        AppBase.initialize();
       
		postTimer = new Timer.Timer();
		secondsTimer = new Timer.Timer();
		
		if (Storage.getValue("initialized")) {
			userMetadata = {
				"uid" => Storage.getValue("uid")
			};
		}
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	if (Storage.getValue("initialized")) {
    		return [ new SPNFOHomeScreen(), new SPNFOEmptyDelegate() ];
    	} else {
    		return [ new SPNFOInitializeScreen(), new SPNFOEmptyDelegate() ];
    	}
    }

	// for testing only
//	function getInitialView() {
//		Storage.setValue("uid", 10000);
//		var v = new SPNFORaceCompleted();
//		return [ v, new SPNFORaceCompletedDelegate(v) ];
//	}

//	function getInitialView() {
//		return [ new SPNFOTopView(), new SPNFOTopDelegate() ];
//	}
	
}
