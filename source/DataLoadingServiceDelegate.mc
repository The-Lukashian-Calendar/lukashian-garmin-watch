import Toybox.Background;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

(:background)
class DataLoadingServiceDelegate extends System.ServiceDelegate {

    //private const URL as String = "http://localhost:8080/api/watchinfo/earth";
    private const URL as String = "https://www.lukashian.org/api/watchinfo/earth";

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        if (DEBUG) {
            System.println("Retrieving data from Backend...");
        }

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
            Background.exit(data);
        }
    }
}
