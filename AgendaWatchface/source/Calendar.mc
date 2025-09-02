using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:foreground)
class Calendar
{
	
// single appointment/event:
//
	class Event
	{
		var tStart = 0; // timestamp unix
		var tEnd = 0; // timestamp unix
		var time = "";	
		var desc = "";
		var loc = null;
		var allday = false;
		var lastone = 0; //indicating last event for today
		
	// initialize
	//
		function initialize() {
		}
		
	// decode from csv:
		function decodeCSV( csv, csvChars as Lang.Array<Lang.Char>, start as Lang.Number, end as Lang.Number ) 
		{
			var i; // index
			var arg_i = 0;
			System.println("Decoding CSV!");
		
			// read all args: 
			for ( i = start; i < end; i++ )
			{
				if ( csvChars[i]==';' )
				{	
					if ( start < i ) 
					{
						var s = csv.substring(start,i);
						
						// Timestamp
						if (arg_i==0) {
							tStart = s.toNumber()*60;
						} else
						// Timestamp
						if (arg_i==1) {
							tEnd = s.toNumber()*60;
						} else
						// allday info
						if (arg_i==2) {
							allday = s.length()>0;
						} else
						// Desc
						if (arg_i==3) {
							desc = s;
						} else
						// Location
						if (arg_i==4) {
							loc = s;
						}
						
					}
					start = i+1;
					arg_i++;
				}
			}			
		}	
		
	// format date depending on current time
	//
		function formatDate(today)
		{
			var duration = tStart - today;
			var timeinfo = Gregorian.info( new Time.Moment(tStart), Time.FORMAT_MEDIUM); // all as numbers
			var timeString;
			
			     
		        timeString = Lang.format("$1$:$2$", [timeinfo.hour.format("%02d"), timeinfo.min.format("%02d")]);
		    
			
			if ( duration>=0 && duration < 24*60*60 ) // today
			{
				if (allday) {
					time = "";
				} else {
					time = timeString;
				}
			}
			else
			if ( duration>=0 && duration < 7*24*60*60 ) // week
			{
				if (allday) {
					time = "" + timeinfo.day_of_week + "       ";
				} else {
					time = "" + timeinfo.day_of_week + " " + timeString;
				}
			}
			else // after week or in the past
			{
				if (allday) {
					time = "" + timeinfo.day.format("%02d") + " " + timeinfo.month + "       ";
				} else {
					time = "" + timeinfo.day.format("%02d") + " " + timeinfo.month + " " + timeString;
				}
			}
		}
		
	}
//  
// Item ---------------------------------------------------------------------------------------------
	
	
	// 
	var valid = false;
	var events = new Lang.Array<Calendar.Event>[0];
	var today = 0;
	var dateString = "";
	var dateShortString = "";
	
	function initialize() 
	{
        today = Time.today().value();
		updateDateString();
  	}
	
	// input Items as list like: "111000 Birthday;132000 Meeting;"
	function decodeFromCSV( csv as Lang.String)
	{
		if ( csv != null )
		{
			var csvChars = csv.toCharArray();
			var start = 0; // last start index
			var n = csvChars.size(); // count
			var i; // index
			var e; // event
			
			events = new Lang.Array<Calendar.Event>[0]; // clear array
			if ( n > 0 )
			{
				today = Time.today().value(); // update this, because we format new data in the following:
				
				// read all events: 
				for ( i = 0; i < n; i++ )
				{
					var c = csvChars[i].toNumber(); 
					if ( c.toNumber()==10 ) // New Line
					{	
						if ( (start+1) < i ) 
						{
							e = new Calendar.Event();
							e.decodeCSV( csv, csvChars, start, i );
							events.add( e );
							e.formatDate(today);
						}
						start = i+1;
					}
				}
				
				// last one without separator?
				if ( (start+1) < n )
				{
					e = new Calendar.Event();
					e.decodeCSV( csv, csvChars, start, i );
					events.add( e );
					e.formatDate(today);
				}
			}	
			valid = true;
		}
	}
	
	function getEventIfNotPastAlready( index as Lang.Number, t as Lang.Number) {
		var ev = null;
		if (index>=0 && index<events.size()) {
			if (events[index].tEnd>t) { // not past
				ev = events[index];
			}
		}
		return ev;
	}
	
	function getNumEvents() {
		return events.size();
	}
	
	function getEvent( index ) {
		var ev = null;
		if (index>=0 && index<events.size()) {
			ev = events[index];
		}
		return ev;
	}
	
	// check for a new day and update all date texts:
	function checkForNewDay() {
		var day = Time.today().value();
		if (day!=today) {
    	    today = day;
			updateDateString();
			
			if (!valid) {
				demo();	
			}
			else {
				var n = events.size();
				for ( var i=0; i<n; i++ ) {
					events[i].formatDate(today);
				}
			}
		}
	}
	
	function updateDateString() {
		var todayInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var month = todayInfo.month;
		
        dateString = Lang.format("$1$ $2$ $3$", [ todayInfo.day, month, todayInfo.year ]);
        dateShortString = Lang.format("$1$ $2$", [ todayInfo.day, month ]);
    } 

	function demo() {
		// fill some random data:
		valid = false;
		events = new Lang.Array<Calendar.Event>[0]; // clear array
		
		var e = new Calendar.Event();
		var t = Math.rand() % 4;
		e.tStart = today;
		e.tEnd = e.tStart + 24*3600;
		e.allday = true;
		if (t==0) { e.desc = Ui.loadResource(Rez.Strings.DemoEvent_01); e.loc = "Room 120"; } else
		if (t==1) { e.desc = Ui.loadResource(Rez.Strings.DemoEvent_02); } else
		if (t==2) { e.desc = Ui.loadResource(Rez.Strings.DemoEvent_03); } else
		{ e.desc = Ui.loadResource(Rez.Strings.DemoEvent_04); }
		e.formatDate(today);
		events.add( e );
		
		for ( var d = 1; d<=3; d++ ) {
			for ( var h = 9; h < 18; h+=6 )  {
				var curr_e = new Calendar.Event();
				var curr_t = Math.rand() % 4;
				curr_e.tStart = today + 3600*(h+d*24+Math.rand()%3);
				curr_e.tEnd = curr_e.tStart + 3600;
				if (curr_t==0) { curr_e.desc = Ui.loadResource(Rez.Strings.DemoEvent_01); e.loc = "Room 120"; } else
				if (curr_t==1) { curr_e.desc = Ui.loadResource(Rez.Strings.DemoEvent_02); } else
				if (curr_t==2) { curr_e.desc = Ui.loadResource(Rez.Strings.DemoEvent_03); } else
				{ curr_e.desc = Ui.loadResource(Rez.Strings.DemoEvent_04); }
				curr_e.formatDate(today);
				events.add( curr_e );
			}
		}
	}
		
	function getLastTodayAllday() {
		// find last allday event of today. If none, return null
		var lastTodayAllday = null;
		var timeEndOfToday = Time.today().value() + 24*60*60;
		for (var i = 0; i < events.size(); i++)
		{
			if (events[i].tStart < timeEndOfToday && events[i].allday)
			{
				lastTodayAllday = i;
			}	
		}
		return lastTodayAllday;		
	}
	
	function getLastTodayTimed() {
		// find last timed event of today. If none, return null
		var lastTodayTimed = null;
		var timeEndOfToday = Time.today().value() + 24*60*60;
		for (var i = 0; i < events.size(); i++)
		{
			if (events[i].tEnd > Time.now().value() && events[i].tStart < timeEndOfToday && !events[i].allday)
			{
				lastTodayTimed = i;
			}	
		}
		return lastTodayTimed;
	}
	
	function getLastEvTomorrow() {
		// find last event of tommorow. If none, return null
		var lastEvTomorrow = null;
		var timeStartOfTomorrow = Time.today().value() + 24*60*60;
		var timeEndOfTomorrow   = Time.today().value() + 48*60*60;
		for (var i = 0; i < events.size(); i++)
		{
			if (events[i].tStart >= timeStartOfTomorrow && events[i].tStart < timeEndOfTomorrow)
			{
				lastEvTomorrow = i;
			}	
		}
		return lastEvTomorrow;
	}

}