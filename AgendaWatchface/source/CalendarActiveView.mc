using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

class CalendarActiveView extends Ui.WatchFace {

	var c = null;
	var drawer = null;
	var a = null;
	
    function initialize(app) {
        WatchFace.initialize();
        a = app;
        c = new Calendar();
    }

    function onLayout(dc) {
        var partNumber = Sys.getDeviceSettings().partNumber;
        var id = Sys.getDeviceSettings().uniqueIdentifier;
		
		drawer = new CalendarDrawerRound(c,dc,9);
        
    }

    function onShow() {
    	
    }
    
    function onUpdate(dc) {
    	if (settings_dirty) {
    		drawer.updateSettings();
    		settings_dirty = false;
    	}
    
    	if (calendar_dirty)	{
	    	calendar_dirty = false;
	    	if (calendar_demo) {
	    	// clear calendar and add demo events:
	    		c.demo();
	    	} else
	    	if (calendar_raw instanceof String)	{
	    	// update CSV calendar
	    		c.decodeFromCSV(calendar_raw);
	    	} else 
	    	{
	    	// clear calendar and add demo events:
	    		c.demo();
	    	}
	    	calendar_raw = null; // release resources
	    } else {
	    	c.checkForNewDay();
	    }
    	
    	if (drawer!=null) {
    		drawer.draw(dc);
    	}
	}
	
    function onHide() {
    	if (drawer!=null){drawer.stopLiveHR();}
    }

    function onExitSleep() {
    	if (drawer!=null){drawer.startLiveHR();}
    	c.updateDateString();
    	a.requestImmediateUpdate();
    }

    function onEnterSleep() {
    	if (drawer!=null){drawer.stopLiveHR();}
    }

}
