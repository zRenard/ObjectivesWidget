using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ObjectivesWidgetApp extends Application.AppBase {

	function settingUpdate() {
	    durationSelected = Application.getApp().getProperty("DefaultUnit");
		todayM = new Time.Moment(Time.now().value());    
		today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
	
        selection=0;
        nextEvent=0;
        nbEvents=0;
        
		events = [];
		//System.println(today);
        for( var i = 0; i < maxEvents; i += 1 ) {
        	var ename = Application.getApp().getProperty("Objective"+(i+1)+"-Name");
        	var edate = Application.getApp().getProperty("Objective"+(i+1)+"-Date"); // 2020-05-11 07:00 or 2020-05-11
        	var etype = Application.getApp().getProperty("Objective"+(i+1)+"-Type");
        	var eventM = new Time.Moment(edate);    
        	if (ename.length()>0) {
        		events.add([ename, eventM ,etype, eventM.compare(todayM)]);
        		nbEvents=nbEvents+1;
	    	}
	    }
	    
	    if (nbEvents==0) {
	    	eventName = "";
	    } else {			    
	        for (var i = 0; i < nbEvents-1; i++) { 
	        	for (var j = 0; j < nbEvents-i-1; j++) {
	        		var d1=events[j][3];
	        		var d2=events[j+1][3];
	        		if (d1 > d2)  { 
		                var temp = events[j]; 
		                events[j] = events[j+1]; 
		                events[j+1] = temp;
	                }
				}
			}
//		    System.print("sorted");
//		    System.println(events);

		    selection=nbEvents-1;
		    eventName = events[selection][0];
			eventDateMoment = events[selection][1];
			eventType = events[selection][2];
			eventDiff = events[selection][3];

//			System.print(selection + " ");
//			System.print(eventName + " ");
//			System.print(eventDiff + " ");
//			System.println(eventDateMoment);
	
	        for (var i = 0; i < nbEvents-1; i++) {
//	        	System.println("Event to sort : " + events[i][3]/Gregorian.SECONDS_PER_DAY);
		        if (events[i][3]/Gregorian.SECONDS_PER_DAY>=0 && eventDiff/Gregorian.SECONDS_PER_DAY>=events[i][3]/Gregorian.SECONDS_PER_DAY) {
		        	selection=i;
		            eventName = events[selection][0];
					eventDateMoment = events[selection][1];
					eventType = events[selection][2];
					eventDiff = events[selection][3];
				}
			}
//			System.print(selection + " ");
//			System.print(eventName + " ");
//			System.print(eventDiff + " ");
//			System.println(eventDateMoment);
		}
		nextEvent=selection;
	}

    function initialize() {
		todayM = new Time.Moment(Time.now().value());    
		today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new ObjectivesWidgetView(), new ObjectivesWidgetDelegate() ];
    }
    
 	function onSettingsChanged(){
    	settingUpdate();
        WatchUi.requestUpdate();
    }
    
    (:glance)    
	function getGlanceView() {
        return [ new ObjectivesGlanceView() ];
    } 
 

}