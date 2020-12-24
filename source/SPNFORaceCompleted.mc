using Toybox.WatchUi as Ui;

class SPNFORaceCompleted extends Ui.View {
	
	function initialize() {
		View.initialize();
	}
	
	function onLayout(dc) {
		setLayout(Rez.Layouts.RaceCompletedLayout(dc));
	}
	
	
	function onUpdate(dc) {
		View.onUpdate(dc);
	}
	
	function onHide() {}
	
}