import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

var maxEvents=9;
var nbEvents;
var events as Array<Array> = [] as Array<Array>;
var todayM;    
var today;
// Event selected
var eventDateMoment;
var eventName;
var eventGoal;
var eventType;
var eventDiff;
var selection;
var nextEvent; // The immediate next event closer to today
var durationUnits as Array<Integer> =[Gregorian.SECONDS_PER_DAY,7*Gregorian.SECONDS_PER_DAY,Gregorian.SECONDS_PER_HOUR] as Array<Integer>;
var durationUnitsLabel as Array<String> =["days","weeks","hours"] as Array<String>;
var durationSelected=0;

function changeDuration() {
	durationSelected=((durationSelected+1)+3)%3;
	WatchUi.requestUpdate();
}

function cycleObjective(direction) {
	var nbEvents=events.size();
	if (nbEvents>0) {
		selection = ((selection+direction)+nbEvents)%nbEvents;
		eventName=events[selection][0];
		eventGoal=events[selection][1];
		eventDateMoment = events[selection][2];
		eventType = events[selection][3];
		eventDiff = events[selection][4];
	}
	WatchUi.requestUpdate();
}

class ObjectivesWidgetView extends WatchUi.View {
	var triEventBitmap;
	var swimEventBitmap;
	var bikeEventBitmap;
	var runEventBitmap;
	var otherEventBitmap;

    function initialize() {
        View.initialize();
		WatchUi.requestUpdate();
        triEventBitmap = WatchUi.loadResource(Rez.Drawables.id_tri);
        swimEventBitmap = WatchUi.loadResource(Rez.Drawables.id_swim);
        bikeEventBitmap = WatchUi.loadResource(Rez.Drawables.id_bike);
        runEventBitmap = WatchUi.loadResource(Rez.Drawables.id_run);
        otherEventBitmap = WatchUi.loadResource(Rez.Drawables.id_other);
        durationSelected = Application.Properties.getValue("DefaultUnit");
        if (Toybox.Application has :Resource) {
        	durationUnitsLabel[0] = Application.loadResource(Rez.Strings.days);
        	durationUnitsLabel[1] = Application.loadResource(Rez.Strings.weeks);
        	durationUnitsLabel[2] = Application.loadResource(Rez.Strings.hours);
        }
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
		var hasRsc = (Toybox.Application has :Resource);
    	dc.setColor(Graphics.COLOR_TRANSPARENT,Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);

		if (dc has :setAntiAlias ) { dc.setAntiAlias(true); }
		
		if (eventName.length()==0) {
			dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_MEDIUM), Graphics.FONT_MEDIUM , (hasRsc?Application.loadResource(Rez.Strings.NoObjective):"No objectives"), Graphics.TEXT_JUSTIFY_CENTER);
		} else {
		    todayM = new Time.Moment(Time.today().value());    
			today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
	    	dc.setPenWidth(5);
	    	var icoType="";
	    	var showIcons=Application.Properties.getValue("ShowIcons");
	    	var icons=otherEventBitmap;
	    	switch ( eventType ) {
				case 0:
					icoType = hasRsc?Application.loadResource(Rez.Strings.swim):"Swim";
					icons=swimEventBitmap;
				break;
				case 1:
					icoType= hasRsc?Application.loadResource(Rez.Strings.bike):"Bike";
					icons=bikeEventBitmap;
				break;
				case 2:
					icoType=hasRsc?Application.loadResource(Rez.Strings.run):"Run";
					icons=runEventBitmap;
				break;
				case 3:
					icoType=hasRsc?Application.loadResource(Rez.Strings.tri):"Triathlon";
					icons=triEventBitmap;
				break;
				default:
					icoType=hasRsc?Application.loadResource(Rez.Strings.other):"Other";
					icons=otherEventBitmap;
				break;
			}
			if (eventName.length()>17) {
				dc.drawText(width/2,(height/3)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY ), Graphics.FONT_SYSTEM_XTINY , eventName, Graphics.TEXT_JUSTIFY_CENTER);
			} else {
				dc.drawText(width/2,(height/3)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_TINY ), Graphics.FONT_SYSTEM_TINY , eventName, Graphics.TEXT_JUSTIFY_CENTER);
			}
		    var eventDate = Gregorian.utcInfo(eventDateMoment, Time.FORMAT_MEDIUM);
			var dateString = Lang.format(
			    "$1$ $2$/$3$/$4$",
			    [
			        eventDate.day_of_week,
			        eventDate.day,
			        eventDate.month,
			        eventDate.year
			    ]
			);			
			var hourString =  Lang.format(
			    "$1$:$2$",
			    [
			        eventDate.hour.format("%02u"),
			        eventDate.min.format("%02u")
			    ]
			);
			var firstDayOfYear = Gregorian.moment({:day => 1, :month =>1}); // 0
			var lastDayOfYear =  Gregorian.moment({:day => 31, :month =>12}); // 365
			var durationYear = lastDayOfYear.subtract(firstDayOfYear);
			var nbDays = Math.floor(durationYear.value()/Gregorian.SECONDS_PER_DAY);
			var dayOfYearToday = Math.floor(firstDayOfYear.subtract(todayM).value()/Gregorian.SECONDS_PER_DAY);
			var arcP = Math.floor((dayOfYearToday*360)/nbDays);
			var eventDiffDay=eventDiff/Gregorian.SECONDS_PER_DAY;	
	
			var radius=(width>height)?height:width; // compute radius for non-round device and non square
			var diffRx = Math.ceil((width>height)?(width-height)/2.0:0); // compute x offset due to non square device
			var diffRy = Math.ceil((height>width)?(height-width)/2.0:0); // compute y offset due to non square device
	        dc.drawArc(width/2, height/2, (radius/2)-5,Graphics.ARC_CLOCKWISE, 90,90-arcP);
	    	drawTicks(dc,Graphics.COLOR_LT_GRAY,3,(radius / 2),10,30.0,0,diffRx,diffRy);
	    	dc.setColor(Graphics.COLOR_WHITE ,Graphics.COLOR_TRANSPARENT);
	    	dc.drawText(width/2,(height/4)*3-Graphics.getFontHeight(Graphics.FONT_SYSTEM_TINY ), Graphics.FONT_SYSTEM_TINY ,dateString, Graphics.TEXT_JUSTIFY_CENTER);
	    	dc.drawText(width/2,(height/4)*3-Graphics.getFontHeight(Graphics.FONT_SYSTEM_TINY )/2+4, Graphics.FONT_SYSTEM_TINY ,eventGoal, Graphics.TEXT_JUSTIFY_CENTER);
			
			if (eventDiffDay>0) {
				if (height<=220) {
	    			dc.drawText(width/2,(height/2)-8+Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY ), Graphics.FONT_SYSTEM_XTINY , durationUnitsLabel[durationSelected], Graphics.TEXT_JUSTIFY_CENTER);
    			} else {
	    			dc.drawText(width/2,(height/2)+3+Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY ), Graphics.FONT_SYSTEM_XTINY , durationUnitsLabel[durationSelected], Graphics.TEXT_JUSTIFY_CENTER);
    			}
			}
			if (!hourString.equals("00:00")) {
				if (height<=220) {
	   				dc.drawText(width/2,(height/2)+4+Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY )*2, Graphics.FONT_SYSTEM_XTINY, hourString, Graphics.TEXT_JUSTIFY_CENTER);
	   			} else {
	   				dc.drawText(width/2,(height/2)+Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY )*3, Graphics.FONT_SYSTEM_XTINY, hourString, Graphics.TEXT_JUSTIFY_CENTER);
	   			}
			}
			if (events.size()>1) {
	    		dc.drawText(width/2,(height/5)*4, Graphics.FONT_SYSTEM_XTINY ,(selection+1)+"/"+events.size(), Graphics.TEXT_JUSTIFY_CENTER);
			}
			
			// All Events Tick
			for( var i = 0; i < events.size(); i += 1 ) {
				var dateDiff = events[i][4]/Gregorian.SECONDS_PER_DAY;
				var dayOfYearEvent = Math.floor(firstDayOfYear.subtract(events[i][2]).value()/Gregorian.SECONDS_PER_DAY);
				var arcE = Math.floor((dayOfYearEvent*360.0)/nbDays);
				var angleE = Math.toRadians(arcE-90.0);
			    var outerRad = (radius / 2.0);
			    var innerRad = outerRad - 20;
				var sX, sY;
			    var eX, eY;
			    sY =  outerRad + innerRad * Math.sin(angleE);
			    eY =  outerRad + outerRad * Math.sin(angleE);
			    sX =  outerRad + innerRad * Math.cos(angleE);
			    eX =  outerRad + outerRad * Math.cos(angleE);
		
		    	if (dateDiff==0) {
		    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
		    	} else if (dateDiff>0) {
		    		if (i==nextEvent) {
		    			dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
		    		} else {
		    			dc.setColor(Graphics.COLOR_RED ,Graphics.COLOR_TRANSPARENT);
		    		}
		    	} else if (dateDiff<0) {
		    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
		    	}
				if (i==selection) {
			    	dc.setPenWidth(6);
	    			dc.setColor(Graphics.COLOR_BLUE ,Graphics.COLOR_TRANSPARENT);
			    } else {
			    	dc.setPenWidth(3);
			    }
			    if (Gregorian.info(events[i][2], Time.FORMAT_MEDIUM).year == today.year) {		    	
			    	dc.drawLine(sX+diffRx, sY+diffRy, eX+diffRx, eY+diffRy);
			    }
			}
	
			if (eventDiffDay==0) {
	    		dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_LARGE)/2, Graphics.FONT_SYSTEM_LARGE ,"Race Day", Graphics.TEXT_JUSTIFY_CENTER);
	    		dc.drawText(width/2,(height/2)+Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY ), Graphics.FONT_SYSTEM_XTINY , "Good Luck !", Graphics.TEXT_JUSTIFY_CENTER);
	    	} else if (eventDiffDay>0) {
	    		if (selection==nextEvent) {
	    			dc.setColor(Graphics.COLOR_ORANGE ,Graphics.COLOR_TRANSPARENT);
	    		} else {
	    			dc.setColor(Graphics.COLOR_RED ,Graphics.COLOR_TRANSPARENT);
	    		}
	    		if (height<=205) {
	    			dc.drawText(width/2,(height/2)-12-Graphics.getFontHeight(Graphics.FONT_NUMBER_HOT )/2, Graphics.FONT_NUMBER_HOT  ,Math.round(eventDiff/durationUnits[durationSelected]).toString(), Graphics.TEXT_JUSTIFY_CENTER);
	    		} else {
	    			dc.drawText(width/2,(height/2)-12-Graphics.getFontHeight(Graphics.FONT_SYSTEM_NUMBER_THAI_HOT)/2, Graphics.FONT_SYSTEM_NUMBER_THAI_HOT ,Math.round(eventDiff/durationUnits[durationSelected]).toString(), Graphics.TEXT_JUSTIFY_CENTER);
	    		}    	
	    	} else if (eventDiffDay<0) {
	    		dc.setColor(Graphics.COLOR_DK_GREEN ,Graphics.COLOR_TRANSPARENT);
	    		dc.drawText(width/2,(height/2)-Graphics.getFontHeight(Graphics.FONT_SYSTEM_LARGE), Graphics.FONT_SYSTEM_LARGE ,"Done", Graphics.TEXT_JUSTIFY_CENTER);    		
	    		dc.drawText(width/2,(height/2)+2, Graphics.FONT_SYSTEM_LARGE ,"since "+(-eventDiffDay)+ " day(s)", Graphics.TEXT_JUSTIFY_CENTER);    		
	    	}
	    	if (!showIcons) {
	    		dc.drawText(width/2,(height/5)-Graphics.getFontHeight(Graphics.FONT_XTINY ), Graphics.FONT_XTINY , icoType, Graphics.TEXT_JUSTIFY_CENTER);
	    	} else {
				if (height<=205) { 
					dc.drawBitmap((width/2)-12, height/5-20, icons);
				} else {
					dc.drawBitmap((width/2)-25, height/5-40, icons);
				}	    	
	    	}
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function drawTicks(dc,color,size,out,innerOffset,angle,offset,rx,ry) {
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
            dc.drawLine(sX+rx, sY+ry, eX+rx, eY+ry);
        }
	}


}
