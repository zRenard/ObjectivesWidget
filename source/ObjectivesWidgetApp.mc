using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ObjectivesWidgetApp extends Application.AppBase {

	function settingUpdate() {
	    durationSelected = Application.getApp().getProperty("DefaultUnit");
		todayM = new Time.Moment(Time.today().value());    
		today = Gregorian.info(todayM, Time.FORMAT_MEDIUM);
	
        selection=0;
        nextEvent=0;
        nbEvents=0;
        
		events = [];
        for( var i = 0; i < maxEvents; i += 1 ) {
        	var ename = Application.getApp().getProperty("Objective"+(i+1)+"-Name");
        	var egoal = Application.getApp().getProperty("Objective"+(i+1)+"-Goal");
        	var edate = Application.getApp().getProperty("Objective"+(i+1)+"-Date"); // 2020-05-11 07:00 or 2020-05-11
        	var etype = Application.getApp().getProperty("Objective"+(i+1)+"-Type");
        	 
        	var eventM = new Time.Moment(edate);
        	var eventDiff = eventM.compare(todayM);
        	var forSorting = (eventDiff<0 ? 0 : eventDiff);    
        	if (ename.length()>0) {
        		events.add([ename, egoal, eventM ,etype, eventDiff, forSorting]);
        		nbEvents=nbEvents+1;
	    	} else {
	    	 Application.getApp().setProperty("Objective"+(i+1)+"-Date", todayM.value());
	    	}
	    }
	    
	    if (nbEvents==0) {
	    	eventName = "";
	    } else {
	        for (var i = 0; i < nbEvents-1; i++) {
	        	for (var j = 0; j < nbEvents-i-1; j++) {
	        		var d1=events[j][4];
	        		var d2=events[j+1][4];
	        		if (d1 > d2)  { 
		                var temp = events[j]; 
		                events[j] = events[j+1]; 
		                events[j+1] = temp;
	                }
				}
			}
			for (var i = 0; i < nbEvents; i++) {
				if (events[i][4]>=0) { selection = i; break; }
			}			
		    eventName = events[selection][0];
		    eventGoal = events[selection][1];
			eventDateMoment = events[selection][2];
			eventType = events[selection][3];
			eventDiff = events[selection][4];
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