using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

var maxEvents=3;
var nbEvents;
var events = [];
var todayM;    
var today;
// Event selected
var eventDateMoment;
var eventName;
var eventType;
var eventDiff;
var selection;

function cycleObjective(direction) {
	var nbEvents=events.size();
	if (nbEvents>0) {
		selection = ((selection+direction)+nbEvents)%nbEvents;
		eventName=events[selection][0];
		eventDateMoment = events[selection][1];
		eventType = events[selection][2];
		eventDiff = events[selection][3];
	}
	WatchUi.requestUpdate();
}

class ObjectivesWidgetView extends WatchUi.View {

    function initialize() {
		todayM = new Time.Moment(Time.today().value());    
		today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
        View.initialize();
        ObjectivesWidgetApp.settingUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
//        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
		var width = dc.getWidth();
		var height = dc.getHeight();
			    
    	dc.setColor(Graphics.COLOR_TRANSPARENT,Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);

		if (eventName.length()==0) {
			dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_MEDIUM), Graphics.FONT_MEDIUM , Application.loadResource(Rez.Strings.NoObjective), Graphics.TEXT_JUSTIFY_CENTER);
		} else {
		    todayM = new Time.Moment(Time.today().value());    
			today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
	    	dc.setPenWidth(5);
	    	var icoType;
	
			switch ( eventType ) {
				case 0:
					icoType = Application.loadResource(Rez.Strings.swim);
				break;
				case 1:
					icoType = Application.loadResource(Rez.Strings.bike);
				break;
				case 2:
				  	icoType = Application.loadResource(Rez.Strings.run);
				break;
				case 3:
	    			icoType = Application.loadResource(Rez.Strings.tri);
				break;
				default:
	    			icoType = Application.loadResource(Rez.Strings.other);
				break;
			}
	    	dc.drawText(width/2,(height/5)-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_XTINY , icoType, Graphics.TEXT_JUSTIFY_CENTER);
	
	    	dc.drawText(width/2,(height/3)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_TINY ), Graphics.FONT_SYSTEM_TINY , eventName, Graphics.TEXT_JUSTIFY_CENTER);
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
			var firstDayOfYear = Gregorian.moment({:day => 1, :month =>1}); // 0
			var lastDayOfYear =  Gregorian.moment({:day => 31, :month =>12}); // 365
			var durationYear = lastDayOfYear.subtract(firstDayOfYear);
			var nbDays = Math.floor(durationYear.value()/Gregorian.SECONDS_PER_DAY);
			var dayOfYearToday = Math.floor(firstDayOfYear.subtract(todayM).value()/Gregorian.SECONDS_PER_DAY);
			var arcP = Math.floor((dayOfYearToday*360)/nbDays);
	
	        dc.drawArc(width/2, height/2, (width/2)-5,Graphics.ARC_CLOCKWISE, 90,90-arcP);
	    	drawTicks(dc,Graphics.COLOR_LT_GRAY,3,(width / 2),10,30.0,0);
	    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
	    	dc.drawText(width/2,(height/4)*3-Graphics.getFontHeight(Graphics.FONT_SYSTEM_TINY ), Graphics.FONT_SYSTEM_TINY ,dateString, Graphics.TEXT_JUSTIFY_CENTER);
			
			if (events.size()>1) {
	    		dc.drawText(width/2,(height/5)*4, Graphics.FONT_SYSTEM_XTINY ,(selection+1)+"/"+events.size(), Graphics.TEXT_JUSTIFY_CENTER);
			}
			
	    	var dateDiffString=eventDiff;
	    	if (eventDiff==0) {
	    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_LARGE)/2, Graphics.FONT_SYSTEM_LARGE ,"Race Day", Graphics.TEXT_JUSTIFY_CENTER);    		
	    	} else if (eventDiff>0) {
	    		dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_NUMBER_THAI_HOT)/2, Graphics.FONT_SYSTEM_NUMBER_THAI_HOT ,eventDiff, Graphics.TEXT_JUSTIFY_CENTER);    	
	    	} else if (eventDiff<0) {
	    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_LARGE), Graphics.FONT_SYSTEM_LARGE ,"Done", Graphics.TEXT_JUSTIFY_CENTER);    		
	    		dc.drawText(width/2,(height/2)+2, Graphics.FONT_SYSTEM_LARGE ,"since "+(-eventDiff)+ " day(s)", Graphics.TEXT_JUSTIFY_CENTER);    		
	    	}
	
			// All Events Tick
			for( var i = 0; i < events.size(); i += 1 ) {
				var dateDiff = events[i][3];
				var dayOfYearEvent = Math.floor(firstDayOfYear.subtract(events[i][1]).value()/Gregorian.SECONDS_PER_DAY);
				var arcE = Math.floor((dayOfYearEvent*360)/nbDays);
				var angleE = Math.toRadians(arcE-90);
			    var outerRad = (width / 2);
			    var innerRad = outerRad - 20;
				var sX, sY;
			    var eX, eY;        
			    sY =  outerRad + innerRad * Math.sin(angleE);
			    eY =  outerRad + outerRad * Math.sin(angleE);
			    sX =  outerRad + innerRad * Math.cos(angleE);
			    eX =  outerRad + outerRad * Math.cos(angleE);
		
				if (i==selection) {
			    	dc.setPenWidth(6);
			    } else {
			    	dc.setPenWidth(3);
			    }
		    	if (dateDiff==0) {
		    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
		    	} else if (dateDiff>0) {
		    		dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
		    	} else if (dateDiff<0) {
		    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
		    	}
			    dc.drawLine(sX, sY, eX, eY);
			}
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function drawTicks(dc,color,size,out,innerOffset,angle,offset) {
    	dc.setPenWidth(size);
    	dc.setColor(color,Graphics.COLOR_TRANSPARENT);    	

		var sX, sY;
        var eX, eY;
        var outerRad = out - offset;
        var innerRad = outerRad - innerOffset;
                
        for (var i = 0; i < Math.toRadians(360); i += Math.toRadians(angle)) {
            sY = offset + outerRad + innerRad * Math.sin(i);
            eY = offset + outerRad + outerRad * Math.sin(i);
            sX = offset + outerRad + innerRad * Math.cos(i);
            eX = offset + outerRad + outerRad * Math.cos(i);
            dc.drawLine(sX, sY, eX, eY);
        }
	}


}
