import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

public const DEBUG as Boolean = true;
public const DATA_KEY as String = "LukashianCalendarData";

(:background)
class LukashianWatchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new DataLoadingServiceDelegate() ];
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new LukashianWatchView() ];
    }

    function onBackgroundData(data) {
        if (DEBUG) {
            System.println("Processing Background Data...");
        }
        Storage.setValue(DATA_KEY, data);
        Background.registerForTemporalEvent(Time.now().add(new Time.Duration(24 * 60 * 60)));
    }
}

function getApp() as LukashianWatchApp {
    return Application.getApp() as LukashianWatchApp;
}
