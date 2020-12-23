using Toybox.WatchUi as Ui;
using Toybox.Sensor;
using Toybox.Timer;

class SPNFOBottomView extends Ui.View {

	var dispObj = {
		"positionBox" => [],
		"tagBox" => [],
		"timeBox" => []
	};
	var defaultStrings = {};
	var raceMetadata;
//	var updateTimer;

	function Initialize() {
		View.Initialize();
	}
	
//	function onTimer() {
//		Ui.requestUpdate();
//	}
	
	function onLayout(dc) {
		setLayout(Rez.Layouts.BottomLayout(dc));
		
//		updateTimer = new Timer.Timer();
//		updateTimer.start(method(:onTimer), 500, true);
		raceMetadata = Application.getApp().getRaceMetadata();
		
		// this is messy but the next 2 blocks should save some battery life
        dispObj.put("connectedBox", View.findDrawableById("connected_box"));
        
        dispObj.get("positionBox").add(View.findDrawableById("place1_position_box"));
        dispObj.get("positionBox").add(View.findDrawableById("place2_position_box"));
        dispObj.get("positionBox").add(View.findDrawableById("place3_position_box"));
        dispObj.get("positionBox").add(View.findDrawableById("place4_position_box"));
        dispObj.get("positionBox").add(View.findDrawableById("place5_position_box"));
        dispObj.get("tagBox").add(View.findDrawableById("place1_tag_box"));
        dispObj.get("tagBox").add(View.findDrawableById("place2_tag_box"));
        dispObj.get("tagBox").add(View.findDrawableById("place3_tag_box"));
        dispObj.get("tagBox").add(View.findDrawableById("place4_tag_box"));
        dispObj.get("tagBox").add(View.findDrawableById("place5_tag_box"));
		dispObj.get("timeBox").add(View.findDrawableById("place1_time_box"));
		dispObj.get("timeBox").add(View.findDrawableById("place2_time_box"));
		dispObj.get("timeBox").add(View.findDrawableById("place3_time_box"));
		dispObj.get("timeBox").add(View.findDrawableById("place4_time_box"));
		dispObj.get("timeBox").add(View.findDrawableById("place5_time_box"));
		
        dispObj.put("ptsBox", View.findDrawableById("pts_box"));
        dispObj.put("prevSprintPlaceBox", View.findDrawableById("prev_sprint_place_box"));
        dispObj.put("dtnsBox", View.findDrawableById("dtns_box"));
        
        defaultStrings.put("placeText", Ui.loadResource(Rez.Strings.initialPlaceText));
        defaultStrings.put("tagText", Ui.loadResource(Rez.Strings.initialPlaceText));
        defaultStrings.put("timeText", Ui.loadResource(Rez.Strings.initialTimeText));
        defaultStrings.put("pointsText", Ui.loadResource(Rez.Strings.initialPointsText));
        defaultStrings.put("prevPlaceText", Ui.loadResource(Rez.Strings.initialPrevPlaceText));
        defaultStrings.put("dtnsText", Ui.loadResource(Rez.Strings.initialDTNSText));

	}
	
	function onShow() {}
	
	function onUpdate(dc) {
		View.onUpdate(dc);
		
		var sensorInfo = Sensor.getInfo();
		var appValues = Application.getApp().getResponseValues();
		
		if (appValues.get("connected")) {
        	dispObj.get("connectedBox").setBackgroundColor(0x32A852);
        } else {
        	dispObj.get("connectedBox").setBackgroundColor(0xFF0000);
        }
		
		if (appValues.get("distToNextSprint") != null && appValues.get("distToNextSprint") > 0) {
			dispObj.get("dtnsBox").setText(appValues.get("distToNextSprint").format("%.1f"));
		} else {
			dispObj.get("dtnsBox").setText(defaultStrings.get("dtnsText"));
		}
		
		if (appValues.get("pts") != null) {
			dispObj.get("ptsBox").setText(appValues.get("pts").toString());
		}
		
		if (appValues.get("lastSprintPlace") != null) {
			dispObj.get("prevSprintPlaceBox").setText(appValues.get("lastSprintPlace").get("place").toString());
		}
		
		var myIndex = -1;
		
		if (appValues.get("leaderboard") != null) {
			for (var i = 0; i < appValues.get("leaderboard").size(); i++) {
				if (appValues.get("uid").equals(appValues.get("leaderboard")[i].get("uid"))) {
					myIndex = i;
					break;
				}
			}
		
			for (var i = 0; i < appValues.get("leaderboard").size(); i++) {
				dispObj.get("tagBox")[i].setText(appValues.get("leaderboard")[i].get("tag"));
				dispObj.get("positionBox")[i].setText(appValues.get("leaderboard")[i].get("place").toString());
				
				if (i != myIndex) {
					if (sensorInfo has :speed && sensorInfo.speed != 0) {
						var timeDiff = (raceMetadata.get("avgChkptDist") * (appValues.get("leaderboard")[i].get("chkpt")-appValues.get("leaderboard")[myIndex].get("chkpt"))) / sensorInfo.speed;
						dispObj.get("timeBox")[i].setText(timeDiff.format("%+.2f"));
					} else {
						dispObj.get("timeBox")[i].setText(defaultStrings.get("timeText"));
					}
					dispObj.get("positionBox")[i].setDefaultBackgroundColor();
					dispObj.get("tagBox")[i].setDefaultBackgroundColor();
					dispObj.get("timeBox")[i].setDefaultBackgroundColor();
				} else {
					dispObj.get("timeBox")[i].setText(defaultStrings.get("timeText"));
					
					dispObj.get("positionBox")[i].setBackgroundColor(0xAAAAAA);
					dispObj.get("tagBox")[i].setBackgroundColor(0xAAAAAA);
					dispObj.get("timeBox")[i].setBackgroundColor(0xAAAAAA);
				}
			}
		}
	}
	
	function onHide() {}
}