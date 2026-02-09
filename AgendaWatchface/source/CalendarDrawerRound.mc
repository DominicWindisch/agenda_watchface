using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Math;

(:foreground)
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

    var fontBold;
	
	function startLiveHR() {
		liveHR = 0;
	}
	function stopLiveHR() {
		liveHR = 999;
	}
	
    function initialize( calendar, dc, type, symbols, weather, customFont ) {
        w = dc.getWidth();
        h = dc.getHeight();
        c = calendar;
        t = type;
        dataDrawer = new DataDrawer(symbols, weather);
        fontBold = customFont;
        updateSettings();
    }
    
    function updateSettings() {
		fontClock = Gfx.FONT_NUMBER_HOT;
		fontDeltaX = 15;
		fontDeltaXam = 10;
		fontDeltaY = -5;
    }
     
    function draw(dc) {
        var now = Sys.getClockTime();
        var timeString = Lang.format("$1$:$2$", [now.hour.format("%02d"), now.min.format("%02d")]);
		var battery = System.getSystemStats().battery;
		
		dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		
		var xClock24 = w/2 + fontDeltaX/2;
		var yDate = 10;
		var yClock = 21 + fontDeltaY;
		var yDataField = 92;
        var yHR = 86;
		var yCalendar = 120; 
		var dySymbols = 2;
		var dyDataField = 8;
		var dyHR = 11; 
		
		dc.setColor(GlobalState.calendar_clockcolor,Gfx.COLOR_TRANSPARENT);
		dc.drawText(xClock24, yClock, fontClock, timeString, Gfx.TEXT_JUSTIFY_CENTER);
		
		dc.setColor(GlobalState.calendar_infocolor,Gfx.COLOR_TRANSPARENT);
		dataDrawer.drawInfoLeft(dc, w/2-38, yDate+dySymbols);
		dataDrawer.drawInfoRight(dc, w/2+30, yDate+dySymbols);
		
		dc.drawText( w/2, yDate, fontBold, c.dateShortString, Gfx.TEXT_JUSTIFY_CENTER);
		// --- DRAW BATTERY ---
        if (GlobalState.displayPhoneBattery) {
            // SHOW PHONE BATTERY
            if (GlobalState.phoneBattery >= 0) {
                if (GlobalState.phoneBattery >= 30) { 
                    dc.setColor(0x00AA00, Gfx.COLOR_TRANSPARENT);
                } else if (GlobalState.phoneBattery >= 10) {
                    dc.setColor(0xFF5500, Gfx.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(0xFF0000, Gfx.COLOR_TRANSPARENT);
                }
                dc.drawText( w/2, 234, fontBold, "P:" + GlobalState.phoneBattery.format("%.0f")+"%", Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                // Phone battery unknown
                dc.setColor(GlobalState.calendar_infocolor, Gfx.COLOR_TRANSPARENT);
                dc.drawText( w/2, 234, fontBold, "P:?", Gfx.TEXT_JUSTIFY_CENTER);
            }
        } else {
            // SHOW WATCH BATTERY
            if (battery < 20) {
                dc.setColor(0xFF0000, Gfx.COLOR_TRANSPARENT);
            } else {
                dc.setColor(GlobalState.calendar_infocolor, Gfx.COLOR_TRANSPARENT);
            }
            dc.drawText( w/2, 234, fontBold, "W:" + battery.format("%.0f")+"%", Gfx.TEXT_JUSTIFY_CENTER);
        }
		
		dc.setColor(GlobalState.calendar_infocolor,Gfx.COLOR_TRANSPARENT);
		dataDrawer.drawLeft(dc, 10, yDataField, GlobalState.watch_leftdatafield, dyDataField, GlobalState.weathernow, GlobalState.weatherid);
		dataDrawer.drawRight(dc, w-11, yDataField, GlobalState.weatherid, dyDataField, GlobalState.weathermin, GlobalState.weathermax);
		
        dataDrawer.drawBodyBattery(dc, w/2, yHR, dyHR);	

		dc.setColor(0xaaaaaa,Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawLine(0,yCalendar,w,yCalendar);

		if ((c.valid || GlobalState.calendar_demo) && c.events.size()>0 ) {
			drawCalendar(dc,yCalendar);
		} else {
			drawWaitInfo(dc,yCalendar);
		}
	}
	
	function drawWaitInfo(dc,y) {
		var dy, fontWait, x=w/2;
		dy = [ 0, 25, 45, 65 ];
		fontWait = Gfx.FONT_TINY;
		dc.setColor(0xffaa00, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x, y+dy[0], fontWait, Ui.loadResource(Rez.Strings.WaitInfo_01), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(x, y+dy[1], fontBold, Ui.loadResource(Rez.Strings.WaitInfo_02), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(x, y+dy[2], fontBold, Ui.loadResource(Rez.Strings.WaitInfo_03), Gfx.TEXT_JUSTIFY_CENTER);
		dc.drawText(x, y+dy[3], fontBold, Ui.loadResource(Rez.Strings.WaitInfo_04), Gfx.TEXT_JUSTIFY_CENTER);
	}

    // Helper function to convert a Y-coordinate to an angle on the left side of the screen
    function yToAngle(y as Lang.Number) as Lang.Double {
        var cy = h / 2;
        var radius = w / 2;
        
        // Calculate y relative to the center of the screen
        var y_rel = y - cy;

        // Clamp the value to prevent math errors if y is outside the circle
        if (y_rel > radius) { y_rel = radius; }
        if (y_rel < -radius) { y_rel = -radius; }

        // Calculate the corresponding x-coordinate on the left side of the circle
        var x_rel_sq = radius * radius - y_rel * y_rel;
        var x_rel = -Math.sqrt(x_rel_sq);

        // Calculate the angle using atan2. Invert y for graphics coordinate system.
        var angleRad = Math.atan2(-y_rel, x_rel);
        var angleDeg = Math.toDegrees(angleRad);
        
        // Convert from -180 to 180 range to Garmin's 0 to 360 range
        if (angleDeg < 0) {
            angleDeg += 360;
        }
        return angleDeg;
    }

    // NEW: Helper function to convert a Y-coordinate to an angle on the RIGHT side of the screen
    function yToAngleRight(y as Lang.Number) as Lang.Double {
        var cy = h / 2;
        var radius = w / 2;
        var y_rel = y - cy;

        if (y_rel > radius) { y_rel = radius; }
        if (y_rel < -radius) { y_rel = -radius; }

        // Use positive X for the right side of the circle
        var x_rel_sq = radius * radius - y_rel * y_rel;
        var x_rel = Math.sqrt(x_rel_sq);

        var angleRad = Math.atan2(-y_rel, x_rel);
        var angleDeg = Math.toDegrees(angleRad) + 1; // there's an ever so slight gap
        
        if (angleDeg < 0) {
            angleDeg += 360;
        }

        return angleDeg; 
    }


    function drawEvent(dc, ev, y, xLineStart, color) {
                
        // --- Draw Event Prefix (Day and Time) ---
        var prefix = ev.day;
        if (ev.time.length() > 0) {
            prefix += " " + ev.time;
        }
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(xLineStart, y, fontBold, prefix, Gfx.TEXT_JUSTIFY_LEFT);
        
        // --- Draw Event Description ---
        // Calculate the starting X based on the prefix width for a fluid layout
        var prefixWidth = dc.getTextWidthInPixels(prefix, fontBold);
        var descriptionStartX = xLineStart + prefixWidth + 5; // 5px gap
        dc.drawText(descriptionStartX, y, fontBold, ev.desc, Gfx.TEXT_JUSTIFY_LEFT);
    }

	function getDxFromY(y as Lang.Number) {
		// radius = 130
		var dy = (y + 16) - 130; // subtract the line height
		return Math.ceil(130 - Math.sqrt(16900 - (dy*dy))); // inherent small offset to get out of the arc
	}

	function drawDottedArcs(dc, cx, cy, radius, ystart, ystop) {
		//dc.drawArc(cx, cy, radius, arcDir, start, stop);
		// start with a gap, then draw, until end
		/*var gap = 3; // smallest possible gap
		for (var drawStartY = ystart + gap; drawStartY < ystop; drawStartY += 2*gap) {
			var start = yToAngle(drawStartY);
			var stop = yToAngle(drawStartY + gap);
			dc.drawArc(cx, cy, radius, Gfx.ARC_COUNTER_CLOCKWISE, start, stop);
		}

		for (var drawStartY = ystart + gap; drawStartY < ystop; drawStartY += 2*gap) {
			var startR = yToAngleRight(drawStartY);
			var stopR = yToAngleRight(drawStartY + gap);
			dc.drawArc(cx, cy, radius, Gfx.ARC_CLOCKWISE, startR, stopR);
		}*/
		
		// draw points by hand:
		var gap = 2;
		for (var y = ystart + 2 * gap; y < ystop; y+= 2 * gap){
			var dy = y - cy;
			var dx = Math.sqrt(cx * cx - (dy*dy));
			var xLeft = Math.ceil(cx - dx);
			dc.drawPoint(xLeft + 1, y);
			dc.drawPoint(xLeft, y);
			dc.drawPoint(xLeft + 1, y);
			var xRight = Math.floor(cx + dx);
			dc.drawPoint(xRight, y);
			dc.drawPoint(xRight - 1, y);
		}
		
	}

	function drawCalendar(dc,y) {
		var now = Time.now().value();
		var maxitems = 6;
		var itemsDrawn = 0;
		var dyLine = 16;

        var textOffset = -2; // depending on the font, text may need to be vertically offset with respect to the arcs and lines
        y = y + textOffset;

        //var xDelta = [15, 18, 22, 31, 44, 68];

        var yCalendarStart = y-textOffset;
        //var yAfterToday = 0.0;
        var yAfterTomorrow = 0.0;
        //var yAfterFuture = 0.0;
        var separatorY = 0.0;
        var hasFutureEvents = false;

		// 1. Check for connection error
		var lastUpdt = App.Storage.getValue("LastChangedM");
		var lastReq = Time.now().value(); //App.Storage.getValue("LastRequestM");
		var maxUpdateDelay = 900; 
		var lastUpdtTime = (lastUpdt != null) ? lastUpdt : 0;
	    var lastReqTime = (lastReq != null) ? lastReq : maxUpdateDelay + 1;
		var noConnection = ( (lastReqTime - lastUpdtTime) > maxUpdateDelay);

		if (noConnection) {
			dc.setColor(0xff0000, Gfx.COLOR_TRANSPARENT);
			dc.drawText(w/2, y, fontBold, "Keine Verbindung!", Gfx.TEXT_JUSTIFY_CENTER);
			y += dyLine;
            itemsDrawn++;
		}

        // --- TODAY ---
        var todaysAllDay = c.getTodaysAllDayEvents(now) as Lang.Array<Calendar.Event>;
        var todaysTimed = c.getTodaysTimedEvents(now) as Lang.Array<Calendar.Event>;
        for (var i = 0; i < todaysAllDay.size() && itemsDrawn < maxitems; i++) {
            drawEvent(dc, todaysAllDay[i], y, getDxFromY(y), 0xaaaaaa);
            y += dyLine;
            itemsDrawn++;
        }
        if (todaysAllDay.size() > 0 && todaysTimed.size() > 0 && itemsDrawn < maxitems) {
            y+= 2;
            dc.setColor(0x555555,Gfx.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            var dashLength = 2;
            var gapLength = 2;
            for (var x = 0; x < w; x += (dashLength + gapLength)) {
                dc.drawLine(x, y-textOffset, x + dashLength, y-textOffset);
            }
            //y += 1;
        }
        for (var i = 0; i < todaysTimed.size() && itemsDrawn < maxitems; i++) {
            drawEvent(dc, todaysTimed[i], y, getDxFromY(y), 0xffffff);
            y += dyLine;
            itemsDrawn++;
        }
        if (todaysAllDay.size() == 0 && todaysTimed.size() == 0) {
            var msg = c.hasAnyEventsToday() ? "Keine Termine mehr heute" : "Heute keine Termine";
            dc.setColor(0xffffff, Gfx.COLOR_TRANSPARENT);
			var descriptionStartX = getDxFromY(y) + 5; // 5px gap
        	dc.drawText(descriptionStartX, y, fontBold, msg, Gfx.TEXT_JUSTIFY_LEFT);
            y += dyLine;
            itemsDrawn++;
        }
        //yAfterToday = y;

        // --- SEPARATOR ---
        y += 4;
        separatorY = y-textOffset;
        dc.setColor(0xaaaaaa,Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0,y-textOffset,w,y-textOffset);
        y += 0;

        // --- TOMORROW ---
        if (itemsDrawn < maxitems) {
            var tomorrowsEvents = c.getTomorrowsEvents(now) as Lang.Array<Calendar.Event>;
            if (tomorrowsEvents.size() == 0) {
                dc.setColor(0xaaaaaa, Gfx.COLOR_TRANSPARENT);
				var msg = "Morgen keine Termine";
				var descriptionStartX = getDxFromY(y) + 5; // 5px gap
        		dc.drawText(descriptionStartX, y, fontBold, msg, Gfx.TEXT_JUSTIFY_LEFT);
                y += dyLine;
                itemsDrawn++;
            } else {
                for (var i = 0; i < tomorrowsEvents.size() && itemsDrawn < maxitems; i++) {
                    drawEvent(dc, tomorrowsEvents[i], y, getDxFromY(y)+3, 0xaaaaaa);
                    y += dyLine;
                    itemsDrawn++;
                }
            }
			y += 4;
			var dashLength = 3;
            var gapLength = 4;
            for (var x = 0; x < w; x += (dashLength + gapLength)) {
                dc.drawLine(x, y-textOffset, x + dashLength, y-textOffset);
            }
            y += 1;
        }
        yAfterTomorrow = y-textOffset;

        // --- FUTURE ---
        var futureEvents = c.getFutureEvents(now) as Lang.Array<Calendar.Event>;
        hasFutureEvents = futureEvents.size() > 0;
        if (itemsDrawn < maxitems && hasFutureEvents) {
            for (var i = 0; i < futureEvents.size() && itemsDrawn < maxitems; i++) {
                drawEvent(dc, futureEvents[i], y, getDxFromY(y), 0x555555);
                y += dyLine;
                itemsDrawn++;
            }
        }
        //yAfterFuture = y;


        // --- DRAW THE OUTER ARCS ---
        dc.setPenWidth(2);
        var radius = (w/2);

        // Arc boundaries
        var arcTodayStartY = yCalendarStart;
        var arcTodayStopY = separatorY+2;

        var arcTomorrowStartY = separatorY;
        var arcTomorrowStopY = yAfterTomorrow;

        // Draw Today Arc
        var start = yToAngle(arcTodayStartY);
        var stop = yToAngle(arcTodayStopY);
        var startR = yToAngleRight(arcTodayStartY);
        var stopR = yToAngleRight(arcTodayStopY);

        if (start != stop) {
            dc.setColor(0xaaaaaa, Gfx.COLOR_TRANSPARENT);
            dc.drawArc(130.5, 129.5, radius, Gfx.ARC_COUNTER_CLOCKWISE, start, stop);
            dc.drawArc(129.5, 129.5, radius, Gfx.ARC_CLOCKWISE, startR, stopR);
            dc.drawLine(1,122,1,135); // there is a tiny gap in the left arc otherwise
        }

        // Draw Tomorrow Arc
		start = yToAngle(arcTomorrowStartY);
		stop = yToAngle(arcTomorrowStopY);
		startR = yToAngleRight(arcTomorrowStartY);
		stopR = yToAngleRight(arcTomorrowStopY);

		if (start != stop) {
			dc.setColor(0x888888, Gfx.COLOR_TRANSPARENT);
			drawDottedArcs(dc, (w)/2.0, (h)/2.0, 129, arcTomorrowStartY, arcTomorrowStopY);
			//drawDottedArc(dc, w/2, h/2, radius, Gfx.ARC_CLOCKWISE, startR, stopR);
			//dc.drawArc(w/2, h/2, radius, Gfx.ARC_COUNTER_CLOCKWISE, start, stop);
			//dc.drawArc(w/2, h/2, radius, Gfx.ARC_CLOCKWISE, startR, stopR);
		}
	}
}

