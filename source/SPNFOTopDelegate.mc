using Toybox.WatchUi as Ui;

class SPNFOTopDelegate extends Ui.InputDelegate {
    
    function pushBottomScreen() {
    	Ui.pushView(new SPNFOBottomView(), new SPNFOBottomDelegate(), Ui.SWIPE_UP);
    }
    
    function onSwipe(swipeEvent) {
    	if (swipeEvent.getDirection() == Ui.SWIPE_UP) {
    		pushBottomScreen();
    	}
    	
    	return true;
    }

}