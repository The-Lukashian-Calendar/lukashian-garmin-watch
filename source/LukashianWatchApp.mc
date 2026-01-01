import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class LukashianWatchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new LukashianWatchView() ];
    }
}

function getApp() as LukashianWatchApp {
    return Application.getApp() as LukashianWatchApp;
}
