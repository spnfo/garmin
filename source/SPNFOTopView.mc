using Toybox.Application;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

class SPNFOTopView extends Ui.View {

//	var sensorTimer;
//	var postTimer;
	
	var dispObj = {};
	var defaultStrings = {};
	var raceMetadata;

    function initialize() {
        View.initialize();
    }
    
//    function sensorCallback() {
//    	Ui.requestUpdate();
//    }
    
    function secondsToTimeString(s) {
    	s %= (24 * 3600);
    	var hour = s / 3600;
    	s %= 3600;
    	var min = s / 60;
    	var sec = s % 60;
    	
    	var hourString = (hour < 10) ? "0" + hour.toString() : hour.toString();
    	var minString = (min < 10) ? "0" + min.toString() : min.toString();
    	var secString = (sec < 10) ? "0" + sec.toString() : sec.toString();
    	
    	return hourString + "." + minString + "." + secString;
    }
    
    // Load your resources here
    function onLayout(dc) {
    	
        setLayout(Rez.Layouts.TopLayout(dc));
        
        raceMetadata = Application.getApp().getRaceMetadata();
        
//        sensorTimer = new Timer.Timer();
//        sensorTimer.start(method(:sensorCallback), 1000, true);
        
        // this is messy but the next 2 blocks should save some battery life
        dispObj.put("connectedBox", View.findDrawableById("connected_box"));
        dispObj.put("powerBox", View.findDrawableById("power_box"));
        dispObj.put("timeBox", View.findDrawableById("time_box"));
        dispObj.put("speedBox", View.findDrawableById("speed_box"));
        dispObj.put("hrBox", View.findDrawableById("hr_box"));
        dispObj.put("cadenceBox", View.findDrawableById("cadence_box"));
        dispObj.put("positionBox", View.findDrawableById("position_box"));
        dispObj.put("elevationBox", View.findDrawableById("elevation_box"));
        
        defaultStrings.put("powerText", Ui.loadResource(Rez.Strings.initialPowerText));
        defaultStrings.put("speedText", Ui.loadResource(Rez.Strings.initialSpeedText));
        defaultStrings.put("hrText", Ui.loadResource(Rez.Strings.initialHrText));
        defaultStrings.put("cadenceText", Ui.loadResource(Rez.Strings.initialCadenceText));
        defaultStrings.put("positionText", Ui.loadResource(Rez.Strings.initialPositionText));
        defaultStrings.put("elevationText", Ui.loadResource(Rez.Strings.initialElevationText));
        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        
        var info = Sensor.getInfo();
        var appValues = Application.getApp().getResponseValues();
               
        if (appValues.get("connected") && appValues.hasKey("accuracy") && appValues.get("accuracy") > 2) {
        	dispObj.get("connectedBox").setBackgroundColor(0x32A852);
        } else if (appValues.get("connected") && appValues.hasKey("accuracy") && appValues.get("accuracy") <= 2) {
        	dispObj.get("connectedBox").setBackgroundColor(0xFFD726);
        } else {
        	dispObj.get("connectedBox").setBackgroundColor(0xFF0000);
        }
        
        if (appValues.hasKey("place")) {
            dispObj.get("positionBox").setText(appValues.get("place").format("%02d") + "/" + raceMetadata.get("numRacers").format("%02d"));
        }
        
        dispObj.get("timeBox").setText(secondsToTimeString(Application.getApp().numSeconds));
        
        if (info[:power] != null) {
        	dispObj.get("powerBox").setText(info.power.toString());
        } else {
        	dispObj.get("powerBox").setText(defaultStrings.get("powerText"));
        }
                
        if (info[:speed] != null) {
        	dispObj.get("speedBox").setText((info.speed * 2.23694).format("%.1f"));
        } else {
        	dispObj.get("speedBox").setText(defaultStrings.get("speedText"));
        }
        
        if (info[:heartRate] != null) {
        	dispObj.get("hrBox").setText(info.heartRate.toString());
        } else {
        	dispObj.get("hrBox").setText(defaultStrings.get("hrText"));
        }
        
        if (info[:cadence] != null) {
        	dispObj.get("cadenceBox").setText(info.cadence.toString());
        } else {
        	dispObj.get("cadenceBox").setText(defaultStrings.get("cadenceText"));
        }
        
        if (info[:altitude] != null) {
        	dispObj.get("elevationBox").setText(info.altitude.format("%.0f"));
        } else {
        	dispObj.get("elevationBox").setText(defaultStrings.get("elevationText"));
        }
        
        View.onUpdate(dc);
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
//    	sensorTimer.stop();
    }

}
