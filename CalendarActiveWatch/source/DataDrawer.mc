using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DataDrawer {

	var fontSymbols;
	var fontWeather;
	
	/*
		enum:
		0 = steps
		1 = calories
    	2 = activeMinutesDay 
    	3 = floorsClimbed
    	4 = distance
    	5 = metersClimbed	
    	6 = free memory
	*/

	function initialize() {
        fontSymbols = Ui.loadResource(Rez.Fonts.symbols);
        fontWeather = Ui.loadResource(Rez.Fonts.weathericons);
    }
    
    function getSymbol( what ) {
    	var rc = ""; 
    	if (what==0) { rc = "F"; } else
    	if (what==1) { rc = "D"; } else
    	if (what==2) { rc = "H"; } else
    	if (what==3) { rc = "I"; } else
    	if (what==4) { rc = "K"; } else
    	if (what==5) { rc = "J"; }
    	return rc;
    }
    
    function getWeatherSymbol( weatherid ) {
    	var rc = "-";
    	if (weatherid instanceof Number) {
    	if (weatherid >= 803) {rc = "A";} else //clouds
    	if (weatherid >= 801) {rc = 'F';} else //cloudy
    	if (weatherid == 800) {rc = 'J';} else //sunny
    	if (weatherid >= 700) {rc = "C";} else //mist/fog
    	if (weatherid >= 600) {rc = "H";} else //snow
    	if (weatherid >= 500) {rc = "B";} else //rain
    	if (weatherid >= 300) {rc = "G";} else //drizzle
    	if (weatherid >= 200) {rc = "I";} }    //thunderstorm
    	var hour = Sys.getClockTime().hour;
    	if (hour < 6 || hour > 17) { //night time symbols
    		if (rc == 'F') {rc = 'E';}
    		if (rc == 'J') {rc = 'D';}
    	} 
    	return rc;
    }

	// draw BT only:
    function drawInfoLeft( dc, x, y ) {
    	if (System.getDeviceSettings().phoneConnected) {
			dc.drawText(x,  y, fontSymbols, "A", Gfx.TEXT_JUSTIFY_LEFT); 
		}
	}
	
	// draw importantst info right:
	function drawInfoRight( dc, x, y) {
		if (System.getDeviceSettings().notificationCount>0) {
			dc.drawText(x,  y, fontSymbols, "G", Gfx.TEXT_JUSTIFY_LEFT);
			x+=12; 
		}
    	if (System.getDeviceSettings().doNotDisturb) {
			dc.drawText(x,  y, fontSymbols, "B", Gfx.TEXT_JUSTIFY_LEFT);
			x+=11; 
		} 
		if (System.getDeviceSettings().alarmCount>0) {
			dc.drawText(x,  y, fontSymbols, "C", Gfx.TEXT_JUSTIFY_LEFT); 
			x+=12;			
		} 
    }
     
    function drawLeft( dc, x, y, what, dySym, weathernow, weatherid ) {
		if (weatherid != 0) {
		dc.drawText(x, y-8, fontWeather, getWeatherSymbol(weatherid), Gfx.TEXT_JUSTIFY_LEFT);
		dc.drawText(x+64, y-5, Gfx.FONT_SMALL, weathernow, Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(x+64, y-2, Gfx.FONT_XTINY, "°C", Gfx.TEXT_JUSTIFY_LEFT); }
	}
	
	function drawRight( dc, x, y, what, dySym, wmin, wmax) {
		if (what != 0) { //draw only if we got some weather data indicated by having an id != 0
		dc.drawText(x-25, y+8,Gfx.FONT_XTINY, wmin, Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(x-25, y-5   ,Gfx.FONT_XTINY, wmax, Gfx.TEXT_JUSTIFY_RIGHT);
		dc.drawText(x, y-5,Gfx.FONT_SMALL, "°C", Gfx.TEXT_JUSTIFY_RIGHT); }
	}
	
	function drawHR( dc, x, y, dySym, liveHR ) {
		// Get HR:
		var hr = "--";
		
		if (liveHR < 5)
		{
			var sample = Activity.getActivityInfo().currentHeartRate;
			if (null != sample) 
			{
				hr = "" + sample;
			}
		}
		else
		{
			if (ActivityMonitor has :getHeartRateHistory) 
			{
				var hrIterator = ActivityMonitor.getHeartRateHistory(1, true);
				var sample = hrIterator.next();
				if (null != sample && sample has :heartRate) {	   // null check
			        if (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {    // check for invalid samples
			        	hr = ""+ sample.heartRate;
			        }
			    }
		    }
	    }
	
		x += -(dc.getTextWidthInPixels(hr,Gfx.FONT_NUMBER_MILD) + 11)/2 + 11; // 11=size of icon
		if (liveHR%2 == 0)
		{	// blink when live
			dc.drawText(x, y+dySym, fontSymbols, "E", Gfx.TEXT_JUSTIFY_RIGHT);
		}
		dc.drawText(x, y, Gfx.FONT_NUMBER_MILD, hr, Gfx.TEXT_JUSTIFY_LEFT);
	}

	function drawDay( dc, x, y ) {
		// Get Weekday:
		var ti = Gregorian.info( Time.today(), Time.FORMAT_MEDIUM ); 
		dc.drawText(x, y, Gfx.FONT_MEDIUM, ti.day_of_week, Gfx.TEXT_JUSTIFY_CENTER);
	}
}
