using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Time;
using Toybox.Background;
using Toybox.Complications;

(:foreground)
class CalendarActiveWatch extends App.AppBase {

    function initialize() {
        AppBase.initialize();
        GlobalState.loadInitialState();

        // If we are in the simulator, set the flag to run our parse test.
        // The ':ServiceDelegate' check is a reliable way to detect the simulator environment.
        /*if (System has :ServiceDelegate) {
            GlobalState.runParseTestInSim = true;
			System.println("Its a simulation!");
        }*/
		System.println("Initialized");
    }
    
    // onStart() is called on application start up
    function onStart(state) {
        
    }

    public function onComplicationChanged(complicationId as Complications.Id) as Void {        
    if (complicationId.getType() == Complications.COMPLICATION_TYPE_BODY_BATTERY) {
            var comp = Complications.getComplication(complicationId);
            
            // Update Global State
            if (comp != null && comp.value != null) {
                GlobalState.currentBodyBattery = comp.value;
            } else {
                GlobalState.currentBodyBattery = null;
            }

            // Force screen update to show new value immediately
            Ui.requestUpdate();
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        if (Toybox.Complications has :registerComplicationChangeCallback) {
            try {
                Complications.registerComplicationChangeCallback(method(:onComplicationChanged));
                // Subscribe specifically to Body Battery
                Complications.subscribeToUpdates(
                    new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY)
                );
            } catch (e) {
                System.println("Complications error: " + e.getErrorMessage());
            }
        }

        requestImmediateUpdate();
        var view = new CalendarActiveView(self);
        // Return BOTH the view and the delegate
        return [ view, new CalendarActiveDelegate(view) ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        GlobalState.readSettings();
        requestImmediateUpdate();
        GlobalState.settings_dirty = true;
        Ui.requestUpdate();
    }
    
    function onBackgroundData(data) {
        if (data != null && (data instanceof Dictionary)) {
            var t = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            var ts = Lang.format( "$3$ $4$ $5$ - $1$:$2$ ", [t.hour, t.min.format("%02d"), t.day, t.month, t.year]);
            var tm = Time.now().value();
            
            if (data.hasKey("code")) {
                GlobalState.code = data["code"];
                App.Storage.setValue("Code", GlobalState.code);

                var hasCalendar = false;
                if (data.hasKey("calendar")) {
                    var calendar = data["calendar"];
                    var updated = data["modified"];
                    
                    if (!(updated instanceof String) || updated != GlobalState.calendar_updated) {
                        if (calendar instanceof String) {
                            hasCalendar = true;
                            GlobalState.calendar_raw = calendar;
                            GlobalState.calendar_updated = updated;
                            GlobalState.calendar_dirty = true;
                            App.Storage.setValue("calendar_raw", GlobalState.calendar_raw);
                            App.Storage.setValue("calendar_updated", GlobalState.calendar_updated);
                            App.Storage.setValue("LastChanged", ts);
                            App.Storage.setValue("LastChangedM", tm);
                        }
                    }
                }
                
                if (!hasCalendar) {
                    GlobalState.calendar_raw = null;
                    GlobalState.calendar_dirty = true;
                    App.Storage.setValue("calendar_raw", null);
                    App.Storage.setValue("calendar_updated", "");
                }
            
                GlobalState.weathermin = data.hasKey("weathermin") ? data["weathermin"] : "";
                App.Storage.setValue("weathermin", GlobalState.weathermin);

                GlobalState.weathermax = data.hasKey("weathermax") ? data["weathermax"] : "";
                App.Storage.setValue("weathermax", GlobalState.weathermax);

                GlobalState.weathernow = data.hasKey("weathernow") ? data["weathernow"] : "";
                App.Storage.setValue("weathernow", GlobalState.weathernow);

                GlobalState.weatherid = data.hasKey("weatherid") ? data["weatherid"] : 0;
                App.Storage.setValue("weatherid", GlobalState.weatherid);

                GlobalState.phoneBattery = data.hasKey("phoneBattery") ? data["phoneBattery"] : -1;
                App.Storage.setValue("phoneBattery", GlobalState.phoneBattery);
                
                if (data.hasKey("error")) {
                    ts = ts + " " + data["error"];
                }
            }    
            App.Storage.setValue("LastRequest", ts);
            App.Storage.setValue("LastRequestM", tm);
            Ui.requestUpdate();
        }
        requestNormalUpdate();
    }    

    function getServiceDelegate(){
        return [new UpdateService()];
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
        Background.deleteTemporalEvent();
        if (GlobalState.calendar_updaterate instanceof Number) { 
            if (GlobalState.calendar_updaterate >= 5) {
                Background.registerForTemporalEvent(new Time.Duration(GlobalState.calendar_updaterate * 60));
            }
        }
    }
}
