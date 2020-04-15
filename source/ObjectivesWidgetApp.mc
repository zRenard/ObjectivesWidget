using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ObjectivesWidgetApp extends Application.AppBase {

	function settingUpdate() {
        selection=0;
        nbEvents=0;
        
		events = [];
        for( var i = 0; i < maxEvents; i += 1 ) {
        	var ename = Application.getApp().getProperty("Objective"+(i+1)+"-Name");
        	var edate = Application.getApp().getProperty("Objective"+(i+1)+"-Date");
        	var etype = Application.getApp().getProperty("Objective"+(i+1)+"-Type");        	
		    var moment = Gregorian.moment({
				:year => edate.substring( 0, 4).toNumber(),
				:month => edate.substring( 5, 7).toNumber(),
				:day => edate.substring( 8, 10).toNumber(),
			});    	
        	var ediff = moment.compare(todayM)/Gregorian.SECONDS_PER_DAY;
        	if (ename.length()>0) {
        		events.add([ename, moment ,etype, ediff]);
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
		        if (events[i][3]>=0 && eventDiff>=events[i][3]) {
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
	}

    function initialize() {
		todayM = new Time.Moment(Time.today().value());    
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