import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class LukashianWatchView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        if (DEBUG) {
            System.println("Updating...");
        }
        
        var data = Storage.getValue(DATA_KEY);

        if (!(data instanceof Dictionary)) {
            Background.registerForTemporalEvent(Time.now());
            return;
        }
        if (!data.hasKey("localEpoch")) {
            Background.registerForTemporalEvent(Time.now());
            return;
        }
        
        //Note: localEpoch and offsets are specified in seconds, not milliseconds
        //Note: localEpoch has to correspond with exact start of a day, otherwise time of first day cannot be computed
        var localEpoch = data["localEpoch"] as Number;
        var firstDayNumber = data["firstDayNumber"] as Number;
        var firstYearOfDayNumber = data["firstYearOfDayNumber"] as Number;
        var nextYearStartIndex = data["nextYearStartIndex"] as Number;
        var offsets = data["offsets"] as Array<Number>;

        var currentTime = Time.now().value();

        if (DEBUG) {
            System.println("localEpoch: " + localEpoch);
            System.println("firstDayNumber: " + firstDayNumber);
            System.println("firstYearOfDayNumber: " + firstYearOfDayNumber);
            System.println("nextYearStartIndex: " + nextYearStartIndex);
            System.println("offsets: " + offsets);

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
            Background.registerForTemporalEvent(Time.now());
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

        var day = index < nextYearStartIndex ? (firstDayNumber + index) : (index - nextYearStartIndex + 1);
        var year = index < nextYearStartIndex ? firstYearOfDayNumber : (firstYearOfDayNumber + 1);
        if (DEBUG) {
            System.println("day: " + day);
            System.println("year: " + year);
        }

        var timeString = proportionPassed.format("%04d");
        var dateString = day + " - " + year;

        var center = dc.getWidth() / 2;
        var middle = dc.getHeight() / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.createColor(0, 0, 4, 61));
        dc.clear();

        dc.drawText(center, middle - 90, Graphics.FONT_SYSTEM_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(center, middle + 40, Graphics.FONT_SYSTEM_SMALL, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
