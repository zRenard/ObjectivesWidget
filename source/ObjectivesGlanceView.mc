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
		todayM = new Time.Moment(Time.today().value());    
		today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
        GlanceView.initialize();
        ObjectivesWidgetApp.settingUpdate();
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
	    	    
    	dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
	    //dc.drawRectangle(0, 0, width, height);

		if (eventName.length()==0) {
	    	dc.drawText(0,(height/2)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY)/2, Graphics.FONT_SYSTEM_XTINY, "No objective", Graphics.TEXT_JUSTIFY_LEFT);
		} else {	    
		    todayM = new Time.Moment(Time.today().value());    
		    today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
		    var eventDate = Gregorian.info(eventDateMoment, Time.FORMAT_MEDIUM);
			var dateString = Lang.format(
			    "$1$ $2$/$3$/$4$",
			    [
			        eventDate.day_of_week,
			        eventDate.day,
			        eventDate.month,
			        eventDate.year
			    ]
			);
			var duration1 = eventDateMoment.compare(todayM);
			var dateDiff = duration1/Gregorian.SECONDS_PER_DAY;
			var baroffset = 0;
			var bar = width; // 365
			var tick = bar/12;
			var firstDayOfYear = Gregorian.moment({:day => 1, :month =>1}); // 0
			var lastDayOfYear =  Gregorian.moment({:day => 31, :month =>12}); // 365
			var durationYear = lastDayOfYear.subtract(firstDayOfYear);
			var nbDays = Math.floor(durationYear.value()/Gregorian.SECONDS_PER_DAY);
			var dayOfYearEvent = Math.floor(firstDayOfYear.subtract(eventDateMoment).value()/Gregorian.SECONDS_PER_DAY);
			var dayOfYearToday = Math.floor(firstDayOfYear.subtract(todayM).value()/Gregorian.SECONDS_PER_DAY);
			var tickEvent = Math.floor((dayOfYearEvent*bar)/nbDays);
			var barP = Math.floor((dayOfYearToday*bar)/nbDays);
	    	dc.setPenWidth(1);		
	    	dc.setColor(Graphics.COLOR_LT_GRAY ,Graphics.COLOR_TRANSPARENT);
	    	dc.fillRoundedRectangle(baroffset,(height/2)-5, barP, 10, 3);
	    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
			for (var i=1;i<=11;i++) {
				dc.drawLine(baroffset+tick*i, (height/2)-5, baroffset+tick*i, (height/2)+5);
			}
	    	dc.drawRoundedRectangle(baroffset,(height/2)-5, bar-baroffset, 10, 3);
	    	dc.drawText(0,0, Graphics.FONT_SYSTEM_XTINY, eventName, Graphics.TEXT_JUSTIFY_LEFT);
	    	if (dateDiff==0) {
	    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, "Race Day", Graphics.TEXT_JUSTIFY_LEFT);
	    	} else if (dateDiff>0) {
	    		dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, dateString + " - " + dateDiff +"d", Graphics.TEXT_JUSTIFY_LEFT);
	    	} else if (dateDiff<0) {
	    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, dateString + " - Done", Graphics.TEXT_JUSTIFY_LEFT);    		
	    	}
//	    	dc.setPenWidth(3);
//			dc.drawLine(baroffset+tickEvent, (height/2)-8, baroffset+tickEvent, (height/2)+8);
			// All Events Tick
//	    	dc.setPenWidth(2);
			for( var i = 0; i < events.size(); i += 1 ) {
				if (i==selection) {
			    	dc.setPenWidth(4);
			    } else {
	    			dc.setPenWidth(2);
			    }
				var dateDiff = events[i][3];			    
		    	if (dateDiff==0) {
		    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
		    	} else if (dateDiff>0) {
		    		dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
		    	} else if (dateDiff<0) {
		    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
		    	}
				var dayOfYearEvent = Math.floor(firstDayOfYear.subtract(events[i][1]).value()/Gregorian.SECONDS_PER_DAY);
				var tickEvent = Math.floor((dayOfYearEvent*bar)/nbDays);
				dc.drawLine(baroffset+tickEvent, (height/2)-6, baroffset+tickEvent, (height/2)+6);
			}   	
	    }
	} 
}