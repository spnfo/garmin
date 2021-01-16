using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class SPNFORaceCompletedDelegate extends Ui.InputDelegate {

	var view;
	var deviceType;
		
	function initialize(view) {
		self.view = view;
		
		deviceType = Ui.loadResource(Rez.Strings.DeviceType);
	}
    
	function onKey(keyEvent) {
		if (keyEvent.getKey() == Ui.KEY_DOWN || keyEvent.getKey() == Ui.KEY_UP) {
			view.swapButtons();
		} else if (keyEvent.getKey() == Ui.KEY_ENTER || keyEvent.getKey() == Ui.KEY_START) {
			view.onEnter();
		}
		
		return true;
	}
	
	function onTap(clickEvent) {
		if (clickEvent.getType() == Ui.CLICK_TYPE_TAP) {
			var coords = clickEvent.getCoordinates();
			
			if (deviceType.equals("edge1030")) {
				if (coords[1] > 295 && coords[1] < 357) {
					view.selectSave();
				} else if (coords[1] >= 357 && coords[1] < 418) {
					view.selectDiscard();
				}
			} else if (deviceType.equals("edgeexplore")) {
				if (coords[1] > 252 && coords[1] < 305) {
					view.selectSave();
				} else if (coords[1] >= 305 && coords[1] < 357) {
					view.selectDiscard();
				}
			}
		}
	}

}