import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance)
class ObjectivesGlanceView extends WatchUi.GlanceView {

    function initialize() {
		todayM = new Time.Moment(Time.today().value());    
		today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
        GlanceView.initialize();
		WatchUi.requestUpdate();
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
			var baroffsetX = 0;
			var baroffsetY = 5;
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
	    	dc.fillRoundedRectangle(baroffsetX,baroffsetY+(height/2)-7, barP, 14, 3);
	    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
			for (var i=1;i<=11;i++) {
				dc.drawLine(baroffsetX+tick*i, baroffsetY+(height/2)-7, baroffsetX+tick*i, baroffsetY+(height/2)+7);
			}
	    	dc.drawRoundedRectangle(baroffsetX,baroffsetY+(height/2)-7, bar-baroffsetX, 14, 3);
	    	if (nbEvents>1) {
	    	 var pageEvent="("+ nbEvents + ")";
	    	 dc.drawText(width-dc.getTextWidthInPixels(pageEvent,Graphics.FONT_SYSTEM_XTINY),0, Graphics.FONT_SYSTEM_XTINY, pageEvent, Graphics.TEXT_JUSTIFY_LEFT);
	    	}
	    	if (eventName.length()<=14) {
	    		dc.drawText(0,0, Graphics.FONT_SYSTEM_TINY,eventName, Graphics.TEXT_JUSTIFY_LEFT);
	    	} else {
	    		dc.drawText(0,0, Graphics.FONT_SYSTEM_XTINY,eventName.substring(0,19), Graphics.TEXT_JUSTIFY_LEFT);
	    	}
	    	if (dateDiff==0) {
	    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY), Graphics.FONT_SYSTEM_XTINY, "Race Day - Good Luck !", Graphics.TEXT_JUSTIFY_LEFT);
	    	} else if (dateDiff>0) {
	    		dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, dateString + " - " + dateDiff +"d", Graphics.TEXT_JUSTIFY_LEFT);
	    	} else if (dateDiff<0) {
	    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(0,height-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_SYSTEM_XTINY, dateString + " - Done", Graphics.TEXT_JUSTIFY_LEFT);    		
	    	}
			// All Events Tick
			for( var i = 0; i < events.size(); i += 1 ) {
				if (i==selection) {
			    	dc.setPenWidth(6);
			    } else {
	    			dc.setPenWidth(4);
			    }
				dateDiff = events[i][4];			    
		    	if (dateDiff==0) {
		    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
		    	} else if (dateDiff>0) {
		    		if (i==selection) {
		    			dc.setColor(Graphics.COLOR_BLUE ,Graphics.COLOR_TRANSPARENT);
		    		} else {
		    			dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
		    		}
		    	} else if (dateDiff<0) {
		    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
		    	}
				dayOfYearEvent = Math.floor(firstDayOfYear.subtract(events[i][2]).value()/Gregorian.SECONDS_PER_DAY);
				tickEvent = Math.floor((dayOfYearEvent*bar)/nbDays);
				if (Gregorian.info(events[i][2], Time.FORMAT_MEDIUM).year == today.year) {
				 dc.drawLine(baroffsetX+tickEvent, baroffsetY+(height/2)-8, baroffsetX+tickEvent, baroffsetY+(height/2)+8);
				}
			}   	
	    }
	} 
}