using Toybox.WatchUi as Ui;

class SPNFOBottomDelegate extends Ui.InputDelegate {
    
    function pushTopScreen() {
    	Ui.popView(Ui.SLIDE_DOWN);
//    	Ui.pushView(new SPNFOTopView(), new SPNFOTopDelegate(), Ui.SWIPE_DOWN);
    }
    
    function onSwipe(swipeEvent) {
    	if (swipeEvent.getDirection() == Ui.SWIPE_DOWN) {
    		pushTopScreen();
    	}
    	
    	return true;
    }

}