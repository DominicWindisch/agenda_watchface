using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

(:foreground)
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
		drawer = new CalendarDrawerRound(c,dc,9);
    }

    function onShow() {
    	
    }
    
    function onUpdate(dc) {

		/*if (GlobalState.runParseTestInSim) {
            // Data from your JSON payload:
            GlobalState.code = "446-750-516";
            GlobalState.calendar_raw = "29279400;29280240;d;Leerung Gelbe Tonne, Bio-Tonne;;1;\n29280210;29280300;;Arbeitsberatung // techn. dep. m;;1;\n29282895;29282955;;Betriebsausweis tauschen;;1;\n29285760;29286180;;Zugfahrt;;1;\n29285850;29285910;;Mittagessen;;1;\n29286600;29288040;d;Ponylino;;1;\n29289480;29290320;d;Leerung Bio-Tonne;;1;\n29290920;29291760;d;Leerung Restabfall, Blaue Tonne;;1;\n29290920;29292060;d;SD  (11:30-19:00);;1;\n29292360;29293380;d;ZD  (09:30-17:00);;1;\n";
            GlobalState.calendar_updated = "2025-09-02 09:45:00";
            GlobalState.weathermin = "16.1";
            GlobalState.weathermax = "20.5";
            GlobalState.weathernow = "17";
            GlobalState.weatherid = 502;
            GlobalState.phoneBattery = 96;

            GlobalState.calendar_dirty = true;
            GlobalState.runParseTestInSim = false; // Unset flag so it only runs once
        }*/

    	if (GlobalState.settings_dirty) {
    		drawer.updateSettings();
    		GlobalState.settings_dirty = false;
    	}
    
    	if (GlobalState.calendar_dirty)	{
	    	GlobalState.calendar_dirty = false;
	    	if (GlobalState.calendar_demo) {
	    		c.demo();
	    	} else if (GlobalState.calendar_raw instanceof String)	{
	    		c.decodeFromCSV(GlobalState.calendar_raw);
	    	} else {
	    		c.demo();
	    	}
	    	GlobalState.calendar_raw = null; // release resources
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
