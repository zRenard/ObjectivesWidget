using Toybox.WatchUi;
using Toybox.System;

class ObjectivesWidgetDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        changeDuration();
        return true;
    }

    function onBack() {
    	return false;
	}

    function onNextPage() {
        cycleObjective(-1);
        return true;
    }

    function onPreviousPage() {
        cycleObjective(1);
        return true;
    }
}