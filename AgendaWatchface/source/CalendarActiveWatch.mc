using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Time;

// globals:
var code = "";
var calendar_raw = null;
var calendar_dirty = false;
var calendar_updated = "";
var weathermin = "";
var weathermax = "";
var weathernow = "";
var weatherid = 0;
var phoneBattery = -1;

var calendar_agendastyle = false;
var calendar_onelinestyle = false;
var calendar_alignleft = false;
var calendar_updaterate = 5;
var calendar_clockcolor = 0xffffff;
var calendar_infocolor = 0x55aaff;
var watch_leftdatafield = 0;
var watch_rightdatafield = 1;
var calendar_demo = false;
var watch_weekday = false;
var english_month = false;
var liveHR = false;

// properties:
var settings_dirty = false;

class CalendarActiveWatch extends App.AppBase {

    function initialize() {
        AppBase.initialize();
        
        var temp;
        //read last values from the Object Store
        temp=App.Storage.getValue("Code");
        if(temp!=null && temp instanceof String) {code=temp;}
        
        temp=App.Storage.getValue("calendar_updated");
        if(temp!=null && temp instanceof String) {calendar_updated=temp;}

        temp=App.Storage.getValue("calendar_raw");
        if(temp!=null) {
        	if (temp instanceof String || temp instanceof Dictionary) {
        		calendar_raw = temp;
        		calendar_dirty = true;
        	}
        }
        
        temp=App.Storage.getValue("weathermin");
        if(temp!=null && temp instanceof String) {weathermin=temp;}
        temp=App.Storage.getValue("weathermax");
        if(temp!=null && temp instanceof String) {weathermax=temp;}
        temp=App.Storage.getValue("weathernow");
        if(temp!=null && temp instanceof String) {weathernow=temp;}
        temp=App.Storage.getValue("weatherid");
        if(temp!=null && temp instanceof Number) {weatherid=temp;}
        temp=App.Storage.getValue("phoneBattery");
        if(temp!=null && temp instanceof Number) {phoneBattery=temp;}
        
        readSettings();
        
        if (calendar_demo) {
        	calendar_dirty = true;
        }
    }
    
    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	requestImmediateUpdate();
        return [ new CalendarActiveView(me) ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
    	readSettings();
    	requestImmediateUpdate();
    	settings_dirty = true;
        Ui.requestUpdate();
    }
    
    function onBackgroundData(data) {
    	if (data!=null && (data instanceof Dictionary)) 
    	{
    		var t = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
       		var ts = Lang.format( "$3$ $4$ $5$ - $1$:$2$ ", [t.hour,t.min.format("%02d"),t.day,t.month,t.year]) ;
       		var tm = Time.now().value();
			
            if (data.hasKey("code")) {
            	code = data["code"];
            	//Sys.println("onData code=" + code );
            	App.Storage.setValue("Code",code);

				var hasCalendar = false;
				if (data.hasKey("calendar")) {
	            // the calendar data:
	        		var calendar = data["calendar"];
	        		var updated = data["modified"];
		         	
		         	if (!(updated instanceof String) || updated!=calendar_updated)
		        	{
			        	// JSON or CSV feedback:
		        		if (calendar instanceof String) {
			        		hasCalendar = true;
			        			
		        			calendar_raw = calendar;
		        			calendar_updated = updated;
		        			calendar_dirty = true;
		        			App.Storage.setValue("calendar_raw",calendar_raw);
		        			App.Storage.setValue("calendar_updated",calendar_updated);
		        			App.Storage.setValue("LastChanged", ts );
		        			App.Storage.setValue("LastChangedM", tm );
		        		}
	        		}
	            }
	            
	            if (!hasCalendar) {
	            // new code, maybe old code was removed:
	            	calendar_raw = null;
	        		calendar_dirty = true;
	        		App.Storage.setValue("calendar_raw",calendar_raw);
	        		App.Storage.setValue("calendar_updated","");
	            }
	        
	            if (data.hasKey("weathermin")) {
	            	weathermin = data["weathermin"];
	            	App.Storage.setValue("weathermin",weathermin);
	            } else {
	            	weathermin = "";
	            }
	            if (data.hasKey("weathermax")) {
	            	weathermax = data["weathermax"];
	            	App.Storage.setValue("weathermax",weathermax);
	            } else {
	            	weathermax = "";
	            }
	            if (data.hasKey("weathernow")) {
	            	weathernow = data["weathernow"];
	            	App.Storage.setValue("weathernow",weathernow);
	            } else {
	            	weathernow = "";
	            }
	            if (data.hasKey("weatherid")) {
	            	weatherid = data["weatherid"];
	            	App.Storage.setValue("weatherid",weatherid);
	            } else {
	            	weatherid = 0;
	            }
	            if (data.hasKey("phoneBattery")) {
	            	phoneBattery = data["phoneBattery"];
	            	App.Storage.setValue("phoneBattery",phoneBattery);
	            } else {
	            	phoneBattery = -1;
	            }
	            
	            if (data.hasKey("error")) {
	            	ts = ts + " " + data["error"];
	            }
			}    
            App.Storage.setValue("LastRequest", ts );
            App.Storage.setValue("LastRequestM", tm );
            Ui.requestUpdate();
	    }
	    requestNormalUpdate();
    }    

    function getServiceDelegate(){
    	return [new UpdateService()];
    }
    
    function readSettings()  {
    	calendar_agendastyle = false;//App.getApp().getProperty("AgendaStyle");
    	calendar_onelinestyle = true;//App.getApp().getProperty("OneLineStyle");
    	calendar_alignleft = true;//App.getApp().getProperty("AlignLeft");
    	calendar_clockcolor = 0xFFFFFF;//App.AppBase.getProperty("ClockColor");
    	calendar_infocolor = 0x55AAFF;//App.AppBase.getProperty("InfoColor");
    	watch_leftdatafield = 0;//App.AppBase.getProperty("LeftDataField");
    	watch_rightdatafield = 3;//App.AppBase.getProperty("RightDataField");
    	calendar_demo = false; //App.getApp().getProperty("Demo");
    	calendar_updaterate = 5;//App.getApp().getProperty("UpdateRate");
    	watch_weekday = false;//App.AppBase.getProperty("Weekday");    	
    	english_month = false;//App.getApp().getProperty("EnglishMonth"); 
    }
    
    function requestImmediateUpdate() {
    	var lastTime = Background.getLastTemporalEventTime();
		if (lastTime != null) {
		    // Events scheduled for a time in the past trigger immediately
		    var nextTime = lastTime.add(new Time.Duration(5 * 60));
		    Background.deleteTemporalEvent();
        	Background.registerForTemporalEvent(nextTime);
		} else {
		    Background.deleteTemporalEvent();
        	Background.registerForTemporalEvent(Time.now());
		}
    }
    
    function requestFastUpdate() {
		Background.deleteTemporalEvent();
    	Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    }
    
    function requestNormalUpdate() {
    	Background.deleteWakeEvent();
        Background.deleteTemporalEvent();
        if (calendar_updaterate instanceof Number) { 
    		if (calendar_updaterate>=5) {
        		Background.registerForTemporalEvent( new Time.Duration(calendar_updaterate*60) );
        	} else {
    			Background.registerForWakeEvent();
    		}
    	}	
   	}
}

