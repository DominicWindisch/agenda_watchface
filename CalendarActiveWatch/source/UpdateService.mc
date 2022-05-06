using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Time.Gregorian;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class UpdateService extends Toybox.System.ServiceDelegate {

	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	
	function onTemporalEvent() {
	    var t = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    	var ts = Lang.format( "$1$:$2$ ", [t.hour,t.min.format("%02d")]) ;
	    updateCalendar();
    }

    function onWakeTime() {
    	var t = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    	var ts = Lang.format( "$1$:$2$ ", [t.hour,t.min.format("%02d")]) ;
    	updateCalendar();
    }
    
    function updateCalendar() {
	    if (System.getDeviceSettings().phoneConnected) {
		    Comm.makeWebRequest(
	        	"http://localhost:8080/Download/myevents.json", 
	        	null, 
	        	{ :method => Comm.HTTP_REQUEST_METHOD_GET, 
	        	  :headers => {"authorization" => "Basic bW5vZWM6bWhrb2lzaGlhdA=="}, 
	        	  :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON },
	        	method(:onWeb)
	        );
        }
        else {
        	Background.exit({ "error" => "not connected" });
        }
    }
    
    function onWeb(responseCode, data) {
        var ts;
        if (responseCode!=200 || data==null) {
            ts = { "error" => "Error: " + responseCode.toString() };
        }
        else if (data instanceof Dictionary) {
        	ts = data;
        	//Sys.println(data);
        }
        else {
        	ts = { "error" => "Error: no data" };
        }
        Background.exit(ts);
    }
}
