using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Lang as Lang; 

(:background)
module GlobalState {

    var runParseTestInSim = false;

    // Application State
    var code = "";
    var calendar_raw = null;
    var calendar_dirty = false;
    var calendar_updated = "";
    var weathermin = "";
    var weathermax = "";
    var weathernow = "";
    var weatherid = 0;
    var phoneBattery = -1;
    var settings_dirty = false;

    // App Settings (Properties)
    var calendar_agendastyle = false;
    var calendar_onelinestyle = true;
    var calendar_alignleft = true;
    var calendar_updaterate = 5;
    var calendar_clockcolor = 0xffffff;
    var calendar_infocolor = 0x00AA55;
    var watch_leftdatafield = 0;
    var watch_rightdatafield = 1;
    var calendar_demo = false;
    var watch_weekday = false;
    var english_month = false;
    var liveHR = false; // Note: This might be better as a view-specific state

    var displayLiveHR = false;       // true = Show Live HR, false = Show Body Battery
    var displayPhoneBattery = false; // true = Show Phone %, false = Show Watch %
    var currentBodyBattery = null;

    function loadInitialState() {
        var temp;
        //read last values from the Object Store
        temp = App.Storage.getValue("Code");
        if (temp != null && temp instanceof Lang.String) { code = temp; }
        
        temp = App.Storage.getValue("calendar_updated");
        if (temp != null && temp instanceof Lang.String) { calendar_updated = temp; }

        temp = App.Storage.getValue("calendar_raw");
        if (temp != null && (temp instanceof Lang.String || temp instanceof Lang.Dictionary)) {
            calendar_raw = temp;
            calendar_dirty = true;
        }
        
        temp = App.Storage.getValue("weathermin");
        if (temp != null && temp instanceof Lang.String) { weathermin = temp; }
        
        temp = App.Storage.getValue("weathermax");
        if (temp != null && temp instanceof Lang.String) { weathermax = temp; }
        
        temp = App.Storage.getValue("weathernow");
        if (temp != null && temp instanceof Lang.String) { weathernow = temp; }

        temp = App.Storage.getValue("weatherid");
        if (temp != null && temp instanceof Lang.Number) { weatherid = temp; }
        
        temp = App.Storage.getValue("phoneBattery");
        if (temp != null && temp instanceof Lang.Number) { phoneBattery = temp; }
        
        readSettings();
        
        if (calendar_demo) {
            calendar_dirty = true;
        }
    }

    function readSettings() {
        // In a real app, you would read these from App.getApp().getProperty()
        calendar_agendastyle = false;
        calendar_onelinestyle = true;
        calendar_alignleft = true;
        calendar_clockcolor = 0xFFFFFF;
        calendar_infocolor = 0x00AA55;
        watch_leftdatafield = 0;
        watch_rightdatafield = 3;
        calendar_demo = false;
        calendar_updaterate = 5;
        watch_weekday = false;
        english_month = false;
    }
}

