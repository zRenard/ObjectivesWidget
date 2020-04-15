using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class ObjectivesWidgetDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onNextPage() {
        cycleObjective(-1);
        return false;
    }

    function onPreviousPage() {
        cycleObjective(1);
        return false;
    }
}
