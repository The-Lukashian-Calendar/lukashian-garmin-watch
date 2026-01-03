import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class LukashianWatchView extends WatchUi.View {

    private const DEBUG as Boolean = false;
    private const URL as String = "https://www.lukashian.org/api/watchinfo/earth";

    //Note: localEpoch and offsets are specified in seconds, not milliseconds!
    //Note: localEpoch has to correspond with exact start of a day, otherwise time of first day cannot be computed
    private var localEpoch as Number = 0;
    private var offsets as Array<Number> = [];
    private var days as Array<Number> = [];
    private var yearsOfDays as Array<Number> = [];

    private var updateTimerSet as Boolean = false;
    private var isReloading as Boolean = false;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        if (!updateTimerSet) {
            var updateTimer = new Timer.Timer();
            updateTimer.start(method(:timerCallback), 1000, true);
            updateTimerSet = true;
        }
    }

    function timerCallback() as Void {
        requestUpdate();
    }

    function reload() as Void {
        if (DEBUG) {
            System.println("Reloading...");
        }

        if (isReloading) {
            if (DEBUG) {
                System.println("Reload already in progress");
            }
            return;
        }
        isReloading = true;

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var responseCallback = method(:processResponse);

        Communications.makeWebRequest(URL, null, options, responseCallback);
    }

    function processResponse(responseCode as Number, data as Null or Dictionary or String) as Void {
        if (DEBUG) {
            System.println("Processing Response...");
        }

        if (responseCode != 200 || !(data instanceof Dictionary)) {
            if (DEBUG) {
                System.println("Unexpected response: " + responseCode + " " + data);
            }
        } else {
            var response = data as Dictionary;
            
            localEpoch = response["localEpoch"];
            offsets = response["offsets"];
            days = response["days"];
            yearsOfDays = response["yearsOfDays"];

            if (DEBUG) {
                System.println("localEpoch: " + localEpoch);
                System.println("offsets: " + offsets);
                System.println("days: " + days);
                System.println("yearsOfDays: " + yearsOfDays);
            }
        }

        isReloading = false;
    }

    function onUpdate(dc as Dc) as Void {
        if (DEBUG) {
            System.println("Updating...");
        }

        if (localEpoch == 0) {
            reload();
            return;
        }

        var currentTime = Time.now().value();
        if (DEBUG) {
            System.println("currentTime: " + currentTime);
        }
        
        var index = -1;
        var endOfPreviousDay = 0;
        var startOfDay = 0;
        var endOfDay = 0;
        
        for (var i = 0; i < offsets.size(); i++) {
            if (currentTime <= localEpoch + offsets[i]) { //Offset itself marks end of day, and is still included in day itself
                index = i;

                if (i == 0) {
                    endOfPreviousDay = localEpoch - 1;
                } else {
                    endOfPreviousDay = localEpoch + offsets[i-1];
                }
                startOfDay = endOfPreviousDay + 1;
                endOfDay = localEpoch + offsets[i];

                break;
            }
        }
        if (index == -1) {
            reload();
            return;
        }
        if (DEBUG) {
            System.println("index: " + index);
            System.println("endOfPreviousDay: " + endOfPreviousDay);
            System.println("startOfDay: " + startOfDay);
            System.println("endOfDay: " + endOfDay);
        }

        var totalSecondsOfDay = endOfDay - endOfPreviousDay;
        var passedSecondsOfDay = currentTime - startOfDay; //Use startOfDay, in order not to count current second itself as having passed, thereby achieving [0000-9999]
        if (DEBUG) {
            System.println("totalSecondsOfDay: " + totalSecondsOfDay);
            System.println("passedSecondsOfDay: " + passedSecondsOfDay);
        }

        var proportionPassed = ((passedSecondsOfDay.toDouble() / totalSecondsOfDay.toDouble()) * 10000.toDouble()).toNumber();
        if (DEBUG) {
            System.println("proportionPassed: " + proportionPassed);
        }

        var timeString = proportionPassed.format("%04d");
        var dateString = days[index] + " - " + yearsOfDays[index];

        var center = dc.getWidth() / 2;
        var middle = dc.getHeight() / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.createColor(0, 0, 4, 61));
        dc.clear();

        dc.drawText(center, middle - 90, Graphics.FONT_SYSTEM_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(center, middle + 40, Graphics.FONT_SYSTEM_SMALL, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
