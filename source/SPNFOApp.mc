using Toybox.Application;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.Position;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

var requestUrl = "https://intake.spnfo.com/intake";
//var requestUrl = "http://localhost:8000/intake";
var raceCompletedUrl = "https://intake.spnfo.com/finished";

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
			
	var numSeconds = 0;
	var subSeconds = 0;
	var postFreq = 500;
	var reqPerSec = 1000 / postFreq;
	
	var userMetadata;	
	var raceMetadata;
	
	var responseValues = {};
	
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
	
	function startRace() {
        self.secondsTimer = new Timer.Timer();
        secondsTimer.start(method(:timeTimerCallback), 1000, true);
        
        self.postTimer = new Timer.Timer();
        postTimer.start(method(:makeRequest), 500, true);
	}
	
	function onReceiveRaceData(responseCode, data) {
		System.println(responseCode);
		System.println(data);
	
		if (responseCode == 200) {
			
			responseValues.put("connected", true);
			responseValues.put("inSprintZone", data.get("inSprintZone"));
			responseValues.put("distToNextSprint", data.get("distToNextSprint"));
			responseValues.put("pts", data.get("totalPoints"));
			responseValues.put("leaderboard", data.get("leaderboard"));
			responseValues.put("lastSprintPlace", data.get("last_sprint_place"));
			responseValues.put("place", data.get("place"));
			responseValues.put("uid", data.get("uid"));
			
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

		System.println(positionInfo.position.toDegrees());
		System.println(positionInfo.accuracy);
		
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
									
			Communications.makeWebRequest(requestUrl, body, requestOptions, method(:onReceiveRaceData));
			
			subSeconds++;
		}
		
	}
	
	function startPostTimer() {
		numSeconds = 0;
		Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:fakePositionCallback));
		postTimer.start(method(:makeRequest), postFreq, true);
		secondsTimer.start(method(:timeTimerCallback), 1000, true);
	}
	
	function raceCompletedCallback(responseCode, data) {
		Ui.switchToView(new SPNFORaceCompleted(), new SPNFOEmptyDelegate(), Ui.SWIPE_RIGHT);
	}
	
	function raceCompleted() {
		Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:fakePositionCallback));
		postTimer.stop();
		secondsTimer.stop();
		
		raceMetadata = null;
		
		Communications.makeWebRequest(
			raceCompletedUrl, 
			{"uid" => userMetadata.get("uid")}, 
			requestOptions, 
			method(:raceCompletedCallback)
		);
	}

	function stopPostTimer() {
		postTimer.stop();
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

}
