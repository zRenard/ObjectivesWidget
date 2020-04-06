using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance)
class ObjectivesGlanceView extends WatchUi.GlanceView {
	
    function initialize() {
        GlanceView.initialize();    	         
    }
    
    function onShow() {
    }

	function timerCallback() {
    	WatchUi.requestUpdate();
	}

    function onHide() {
    }
    
    function onLayout(dc) {
    }
    
    function onUpdate(dc) {
    	var width = dc.getWidth();
	    var height = dc.getHeight();
	    var todayM = new Time.Moment(Time.today().value());    
	    var today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
	    var eventM = new Time.Moment(Application.getApp().getProperty("MainObjective-Date"));
	    var eventDate = Gregorian.info(eventM, Time.FORMAT_MEDIUM);
		var dateString = Lang.format(
		    "$1$ $2$/$3$/$4$",
		    [
		        eventDate.day_of_week,
		        eventDate.day,
		        eventDate.month,
		        eventDate.year
		    ]
		);
		var duration1 = eventM.compare(todayM);
		var dateDiff = duration1/Gregorian.SECONDS_PER_DAY;
    	dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
//    	dc.drawRectangle(0, 0, width, height);
		var baroffset = 5;
		var bar = width-baroffset*2; // 365
		var tick = Math.floor(bar/12);
		var firstDayOfYear = Gregorian.moment({:day => 1, :month =>1}); // 0
		var lastDayOfYear =  Gregorian.moment({:day => 31, :month =>12}); // 365
		var durationYear = lastDayOfYear.subtract(firstDayOfYear);
		var nbDays = Math.floor(durationYear.value()/Gregorian.SECONDS_PER_DAY);
		var dayOfYearEvent = Math.floor(firstDayOfYear.subtract(eventM).value()/Gregorian.SECONDS_PER_DAY);
		var dayOfYearToday = Math.floor(firstDayOfYear.subtract(todayM).value()/Gregorian.SECONDS_PER_DAY);
		var tickEvent = Math.floor((dayOfYearEvent*bar)/nbDays);
		var barP = Math.floor((dayOfYearToday*bar)/nbDays);
		
    	dc.setColor(Graphics.COLOR_LT_GRAY ,Graphics.COLOR_TRANSPARENT);
    	dc.fillRoundedRectangle(baroffset,(height/2)-5, barP, 10, 3);
    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
		for (var i=1;i<=11;i++) {
			dc.drawLine(baroffset+tick*i, (height/2)-5, baroffset+tick*i, (height/2)+5);
		}
    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
    	dc.drawRoundedRectangle(baroffset,(height/2)-5, bar, 10, 3);
    	dc.drawText(0,0, Graphics.FONT_SYSTEM_XTINY, Application.getApp().getProperty("MainObjective-Name"), Graphics.TEXT_JUSTIFY_LEFT);
    	if (dateDiff==0) {
    		dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, "Race Day", Graphics.TEXT_JUSTIFY_LEFT);
    	} else if (dateDiff>0) {
    		dc.setColor(Graphics.COLOR_RED ,Graphics.COLOR_TRANSPARENT);
    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, dateString + " - " + dateDiff +"d", Graphics.TEXT_JUSTIFY_LEFT);
    	} else if (dateDiff<0) {
    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, dateString + " - Done", Graphics.TEXT_JUSTIFY_LEFT);    		
    	}
    	dc.setPenWidth(2);
		dc.drawLine(baroffset+tickEvent, (height/2)-5, baroffset+tickEvent, (height/2)+5);    	
    } 
}