using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Complications;
using Toybox.Application as App;

class CalendarActiveDelegate extends Ui.WatchFaceDelegate {
    
    var _view;

    function initialize(view) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    // Fenix 8 triggers this on LONG PRESS (Hold)
    function onPress(evt) {
        var coords = evt.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var w = _view.width; // We will add these public vars to View later
        //var h = _view.height;

        // 1. HR / Body Battery Area (Top Center)
        // Approx centered at y=86. Let's define a hit box around it.
        if (y > 50 && y < 110 && x > (w/2 - 50) && x < (w/2 + 50)) {
            exitToBodyBattery();
            return true;
        }

        // 2. Battery Area (Bottom Center)
        // Approx centered at y=234.
        if (y > 200 && x > (w/2 - 50) && x < (w/2 + 50)) {
            toggleBattery();
            return true;
        }

        // 3. Calendar Area (Bottom Half)
        // Starts at y=120 and goes down.
        // We exclude the very bottom battery area we just defined.
        if (y >= 120 && y <= 200) {
            exitToCalendar();
            return true;
        }

        // 4. Weather Area (Top Left)
        if (y > 50 && y < 110 && x < (w/2 - 50)) {
            exitToWeather();
            return true;
        }

        // 5. Weather Area (Top Right)
        if (y > 50 && y < 110 && x > (w/2 + 50)) {
            exitToWeatherForecast();
            return true;
        }

        return false;
    }

    function exitToBodyBattery() {
        if (Toybox.Complications has :exitTo) {
            Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
        } else {
            System.println("Body Battery ExitTo not supported");
        }
    }

    function exitToWeather() {
        if (Toybox.Complications has :exitTo) {
            Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_CURRENT_WEATHER));
        } else {
            System.println("Weather ExitTo not supported");
        }
    }

    function exitToWeatherForecast() {
        if (Toybox.Complications has :exitTo) {
            Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY));
        } else {
            System.println("Weather ExitTo not supported");
        }
    }

    function toggleBattery() {
        _view.triggerFlash();
        GlobalState.displayPhoneBattery = !GlobalState.displayPhoneBattery;
        Ui.requestUpdate();
    }

    function exitToCalendar() {
        // This requires System 6/7/8 devices (Fenix 8 supports this)
        if (Complications has :exitTo) {
            Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS));        
        } else {
            // Fallback for older devices if you share code (Visual feedback or ignore)
            System.println("ExitTo not supported");
        }
    }
}