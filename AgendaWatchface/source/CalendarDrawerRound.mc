using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class CalendarDrawerRound {

	var w, h; // size
	var t = 0; // 0 = unknown, 1 = 218, 2 = FR 735xt, 3 = VA3, 2 = 240, 4 = Fenix 5
	var c; // calendar
	var fontClock;
	var fontDeltaX = 0;
	var fontDeltaXam = 0;
	var fontDeltaY = 0;
	var dataDrawer;
	var liveHR = 0;
	
	function resetLiveHR() {
		liveHR = 0;
	}
	
    function initialize( calendar, dc, type ) {
        w = dc.getWidth();
        h = dc.getHeight();
        c = calendar;
        t = type;
        dataDrawer = new DataDrawer();
        
        updateSettings();
    }
    
    function updateSettings() {
     	// System Font:
		fontClock = Gfx.FONT_NUMBER_HOT;
   		
		fontDeltaX = 15;
		fontDeltaXam = 10;
		fontDeltaY = -5;
    }
     
    function draw(dc) {
    	
	// Get and show the current time
        var now = Sys.getClockTime();
        var timeString = null;
        var timeAdd = null;
		
		// Clock Formatting:
	    timeString = Lang.format("$1$:$2$", [now.hour.format("%02d"), now.min.format("%02d")]);
	
        
	// Get system stats like battery, memory ...
		var battery = System.getSystemStats().battery;
	// -----------------------------------------------------------------------------------------------------------------	
		
		// clear dc:
		dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
	
	// TEST:			
		//timeString = "20:37";
		
		var xClock12;
		var xClock24;
		var xBattery;
		var yDate = 0;
		var yClock;
		var yClockSmall;
		var yDataField;
		var yHR;
		var yDay;
		var yCalendar;
		var dySymbols, dyDataField, dyHR; 
		
		xClock12 = w - 68 + fontDeltaX + fontDeltaXam;
		xClock24 = w/2 + fontDeltaX/2;
		xBattery = 46;
		yDate = 10;
		yClock = 23 + fontDeltaY;
		yClockSmall = 68;
		yDataField = 92;
		if (t==6 || t==9) {
			yHR = 76; 
		} else {
			yHR = 73;
		}
		yDay = 87;
		yCalendar = 120; 
		dySymbols = 2;
		dyDataField = 8;
		dyHR = 22; 
		
		// draw clock:
		dc.setColor(calendar_clockcolor,Gfx.COLOR_TRANSPARENT);
		dc.drawText(xClock24, yClock, fontClock, timeString, Gfx.TEXT_JUSTIFY_CENTER);
		
		// above clock: system
		dc.setColor(calendar_infocolor,Gfx.COLOR_TRANSPARENT);
		dataDrawer.drawInfoLeft(dc, w/2-38, yDate+dySymbols);
		dataDrawer.drawInfoRight(dc, w/2+30, yDate+dySymbols);
		
		dc.drawText( w/2, yDate, Gfx.FONT_XTINY, c.dateShortString, Gfx.TEXT_JUSTIFY_CENTER);
		if (liveHR < 4) {
			if (phoneBattery >= 0) {
				if (phoneBattery >= 30) { 
					dc.setColor(0x00AA00,Gfx.COLOR_TRANSPARENT);
				} else if (phoneBattery >= 10) {
					dc.setColor(0xFF5500,Gfx.COLOR_TRANSPARENT);
				} else {
					dc.setColor(0xFF0000,Gfx.COLOR_TRANSPARENT);
				}
				dc.drawText( w/2, 234, Gfx.FONT_XTINY, "P:" + phoneBattery.format("%.0f")+"%", Gfx.TEXT_JUSTIFY_CENTER);
				dc.setColor(calendar_infocolor,Gfx.COLOR_TRANSPARENT);
			} else {
				dc.drawText( w/2, 234, Gfx.FONT_XTINY, "???%", Gfx.TEXT_JUSTIFY_CENTER);
			}
		}
		else if (battery < 20) {
			dc.setColor(0xFF0000,Gfx.COLOR_TRANSPARENT);
			dc.drawText( w/2, 234, Gfx.FONT_XTINY, battery.format("%.0f")+"%", Gfx.TEXT_JUSTIFY_CENTER);
			dc.setColor(calendar_infocolor,Gfx.COLOR_TRANSPARENT);
		} else {
			dc.drawText( w/2, 234, Gfx.FONT_XTINY, battery.format("%.0f")+"%", Gfx.TEXT_JUSTIFY_CENTER);
		}
		
		
		// below clock: fitness
		dc.setColor(calendar_infocolor,Gfx.COLOR_TRANSPARENT);
		dataDrawer.drawLeft(dc, 10, yDataField, watch_leftdatafield, dyDataField, weathernow, weatherid);
		dataDrawer.drawRight(dc, w-11, yDataField, weatherid, dyDataField, weathermin, weathermax);
		
		if (liveHR < 5)
		{
			liveHR++;
		}
		dataDrawer.drawHR(dc, w/2, yHR, dyHR, liveHR );
	
			
		// the calendar:
		dc.setColor(0x555555,Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawLine(0,yCalendar,w,yCalendar);

	// TEST:			
		//drawWaitInfo(dc,yCalendar);
		
		if ((c.valid || calendar_demo) && c.events.size()>0 ) {
			drawCalendar(dc,yCalendar);
		} else {
			drawWaitInfo(dc,yCalendar);
		}
	}
	
	// state: New - no code
	// draws the hint to wait for the code
	function drawWaitInfo(dc,y) {
	// _done
		var dy, fontWait, x=w/2;

		dy = [ 0, 25, 45, 65 ];
		fontWait = Gfx.FONT_TINY;

		dc.setColor(0xffaa00, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x, y+dy[0], fontWait, Ui.loadResource(Rez.Strings.WaitInfo_01), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(x, y+dy[1], Gfx.FONT_XTINY, Ui.loadResource(Rez.Strings.WaitInfo_02), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(x, y+dy[2], Gfx.FONT_XTINY, Ui.loadResource(Rez.Strings.WaitInfo_03), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(x, y+dy[3], Gfx.FONT_XTINY, Ui.loadResource(Rez.Strings.WaitInfo_04), Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	// state: has Calendar data
	// draws the calendar
	function drawCalendar(dc,y) {

	// _done
		var ev = null;
		var now = Time.now().value();
		var col1,col2,col3; // colors 
		var midx = 0;
		var i, maxitems = 6;
		
		var xDelta; // delta for every line -> to show on round
		var dyDate; // dy after the date line
		var dyLine; // dy after each event

		// max seconds since last update before showing a warning		
		var lastUpdt = App.Storage.getValue("LastChangedM");
		var lastReq = App.Storage.getValue("LastRequestM");
		var maxUpdateDelay = 300; 
		var lastUpdtTime = lastUpdt != null ? lastUpdt : 0;
	    var lastReqTime = lastReq != null ? lastReq : maxUpdateDelay + 1;
		var noConnection = ( (lastReqTime - lastUpdtTime) > maxUpdateDelay);
		
		xDelta = [10,12,16,25,38,62];
		dyDate = 16;
		dyLine = 16;

		// we need a few events to set placeholders and draw section dividers:
		var lastEvTodayAlldayIdx = c.getLastTodayAllday();
		var lastEvTodayTimedIdx = c.getLastTodayTimed();
		var lastEvTomorrowIdx = c.getLastEvTomorrow();
		var lastEvTodayIdx;
		
		var noEventsToday = (lastEvTodayAlldayIdx == null && lastEvTodayAlldayIdx == null);
		var noEventsTomorrow = (lastEvTomorrowIdx == null);
		
		if (noEventsToday) {
			lastEvTodayIdx = 0;
		} else if (lastEvTodayAlldayIdx == null) {
			lastEvTodayIdx = lastEvTodayTimedIdx;
		} else if (lastEvTodayTimedIdx == null) {
			lastEvTodayIdx = lastEvTodayAlldayIdx;
		} else {
			lastEvTodayIdx = lastEvTodayAlldayIdx > lastEvTodayTimedIdx ? lastEvTodayAlldayIdx : lastEvTodayTimedIdx;
		}
				
		// draw:
		var lineOffset = 0;
		var timeEndOfToday = Time.today().value() + 24*60*60;
		var timeEndOfTomorrow = Time.today().value() + 48*60*60; 
    	for ( i=0; i < c.getNumEvents(); i++ ) {
    	
    		if (i == 0 && noConnection) {
    			dc.setColor(0xff0000, Gfx.COLOR_TRANSPARENT);
				dc.drawText(w/2, y, Gfx.FONT_XTINY, "Keine Verbindung!", Gfx.TEXT_JUSTIFY_CENTER);
				y += dyLine;
				lineOffset++;
    		}
    		
    		if (i == 0 && noEventsToday) {
				dc.setColor(0xffffff, Gfx.COLOR_TRANSPARENT);
				dc.drawText(w/2, y, Gfx.FONT_XTINY, "Heute keine Termine mehr", Gfx.TEXT_JUSTIFY_CENTER);
				y += dyLine;
				lineOffset++;
			}
			
			if (i > 0 && lastEvTodayAlldayIdx == i) {
				// draw a horizontal line after last allday event of today						
				y+= 3;
				dc.setColor(0x555555,Gfx.COLOR_TRANSPARENT);
				dc.setPenWidth(1);
				dc.drawLine(0,y,w,y);
			}
			
			if (i == lastEvTodayIdx) {
				y+= 4;
				dc.setColor(0x555555,Gfx.COLOR_TRANSPARENT);
				dc.setPenWidth(2);
				dc.drawLine(0,y,w,y);
				
				if (noEventsTomorrow) {
					dc.setColor(0xaaaaaa, Gfx.COLOR_TRANSPARENT);
					dc.drawText(w/2, y, Gfx.FONT_XTINY, "Morgen keine Termine", Gfx.TEXT_JUSTIFY_CENTER);
					y += dyLine;
					lineOffset++;
				}
				
			}
    	
    		ev = c.getEventIfNotPastAlready(i, now);
    		if (ev!=null && i+lineOffset < maxitems)
    		{
    			// colors:
    			var isTodayEvent = false, isTomorrowEvent = false;
    			if (ev.tStart < timeEndOfToday) {
    				//todays events (color depending on allday or timed event)
    				col1 = ev.allday ? 0xaaaaaa : 0xffffff;
    				col2 = ev.allday ? 0xaaaaaa : 0xffffff;    
    			} else if (ev.tStart < timeEndOfTomorrow) {
    				//tomorrows events
    				col1 = 0xaaaaaa; col2 = 0xaaaaaa; 
    			} else {
					col1 = 0x555555; col2 = 0x555555; //anything after tomorrow
				}
    			
    			// paint event texts:
    			if (!ev.allday){
    				midx = dc.getTextWidthInPixels(ev.time,Gfx.FONT_XTINY);
    				dc.setColor(col1, Gfx.COLOR_TRANSPARENT);
					dc.drawText(midx+xDelta[i+lineOffset], y, Gfx.FONT_XTINY, ev.time, Gfx.TEXT_JUSTIFY_RIGHT);
					
	    			dc.setColor(col2, Gfx.COLOR_TRANSPARENT);
					dc.drawText(midx+xDelta[i+lineOffset]+5, y, Gfx.FONT_XTINY, ev.desc, Gfx.TEXT_JUSTIFY_LEFT);
				} else if (ev.allday) {
					// center todays allday events
					dc.setColor(col1, Gfx.COLOR_TRANSPARENT);
					dc.drawText(w/2, y, Gfx.FONT_XTINY, ev.desc, Gfx.TEXT_JUSTIFY_CENTER);
				}
				
				y+=dyLine;
				
    		}
    	}
	}

}
