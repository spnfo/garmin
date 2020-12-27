using Toybox.WatchUi as Ui;
using Toybox.Graphics;

class SPNFORaceCompleted extends Ui.View {
	
	var saveSelected = false;
	
	function initialize() {
		View.initialize();
	}
	
	function onLayout(dc) {
		setLayout(Rez.Layouts.RaceCompletedLayout(dc));
	}
	
	function swapButtons() {
		var saveButton = View.findDrawableById("save_button");
		var discardButton = View.findDrawableById("discard_button");
		var saveLabel = View.findDrawableById("saveLabel");
		var discardLabel = View.findDrawableById("discardLabel");
		
		if (saveSelected) {
			saveButton.setBackgroundColor(0x000000);
			discardButton.setBackgroundColor(0xECC0FD);
			saveLabel.setColor(Graphics.COLOR_WHITE);
			discardLabel.setColor(Graphics.COLOR_BLACK);
		} else {
			saveButton.setBackgroundColor(0xECC0FD);
			discardButton.setBackgroundColor(0x000000);
			saveLabel.setColor(Graphics.COLOR_BLACK);
			discardLabel.setColor(Graphics.COLOR_WHITE);
		}
		
		saveSelected = !saveSelected;
		Ui.requestUpdate();
	}
	
	function onEnter() {
		
		if (saveSelected) {
			// save activity
		}
	}
	
	function onUpdate(dc) {
		View.onUpdate(dc);
	}
	
	function onHide() {}
	
}