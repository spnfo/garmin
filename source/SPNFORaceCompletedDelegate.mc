using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class SPNFORaceCompletedDelegate extends Ui.InputDelegate {

	var view;
	var saveSelected = true;
	
	function initialize(view) {
		self.view = view;
	}
    
	function onKey(keyEvent) {
		System.println(keyEvent.getKey());
		if (keyEvent.getKey() == Ui.KEY_DOWN || keyEvent.getKey() == Ui.KEY_UP) {
			view.swapButtons();
		} else if (keyEvent.getKey() == Ui.KEY_ENTER) {
			
		}
	}

}