using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

(:foreground)
class CalendarActiveView extends Ui.WatchFace {

	var c = null;
	var drawer = null;
	var a = null;
	var width = 260; 
    var height = 260; 
    var isAwake = false; // New flag to track power state

	var _flashFrame = 0;

	var fontSymbols, fontWeather, fontCalendar;
	
    function initialize(app) {
        WatchFace.initialize();
		fontSymbols = Ui.loadResource(Rez.Fonts.symbols);
        fontWeather = Ui.loadResource(Rez.Fonts.weathericons);
		fontCalendar = Ui.loadResource((Rez.Fonts.CalFontBold));
        a = app;
        c = new Calendar();
    }

    function onLayout(dc) {
		drawer = new CalendarDrawerRound(c,dc,9, fontSymbols, fontWeather, fontCalendar);
		width = dc.getWidth();
        height = dc.getHeight();
    }

    function onShow() {
    	
    }
    
    function onUpdate(dc) {

		/*if (GlobalState.runParseTestInSim) {
            // Data from your JSON payload:
            GlobalState.code = "446-750-516";
            GlobalState.calendar_raw = "29509860;29511000;d;SD  (11:30-19:00);;1;\n29510310;29510370;;UV Creme! ;;1;\n29510290;29510350;;UV Creme! 💦;;1;\n29510700;29510760;;AI / Fluidized bed / Helmholtz I;;1;\n29511300;29512140;d;Leerung Bio-Tonne;;1;\n29512020;29512080;;Bei Ragna und Martin checken;;1;\n29512740;29513580;d;Leerung Restabfall, Blaue Tonne;;1;\n29512740;29513705;d;ZD  (08:35-16:05);;1;\n29513170;29513230;;UV Creme!;;1;\n29514780;29514840;;Besprechung 24/7-WMS;;1;\n29516050;29516110;;UV Creme! 💦;;1;\n";
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

		if (_flashFrame > 0) {
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
            dc.fillRectangle(0, 0, width, height);
            
            // Decrement so it stops after this frame
            _flashFrame--; 
            
            // Force one more update immediately to clear the white screen
            // (This creates a quick blink effect)
            Ui.requestUpdate();
        }
	}
	
    function onHide() {
    	if (drawer!=null){drawer.stopLiveHR();}
    }

    function onExitSleep() {
    	isAwake = true;
        c.updateDateString();
        Ui.requestUpdate();
    }

    function onEnterSleep() {
    	isAwake = false;

		var watchBattery = System.getSystemStats().battery; //
		var phoneBattery = GlobalState.phoneBattery; //

		// Thresholds: Phone < 20% or Watch < 10%
		if (phoneBattery >= 0 && phoneBattery < 20) {
			// Auto-switch to Phone Battery view
			GlobalState.displayPhoneBattery = true; //
		} else if (watchBattery < 10) {
			// Auto-switch to Watch Battery view
			GlobalState.displayPhoneBattery = false; //
		}

        Ui.requestUpdate();
    }

	function triggerFlash() {
        _flashFrame = 1; // Set to 1 to trigger the draw loop
        Ui.requestUpdate(); // Request immediate redraw
    }

}
