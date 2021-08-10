import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Qt.labs.platform 1.0
import "Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'uwatch.jiho'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property string devices: "{}"
    property string databaseStruct: "{}"

    property string accentColor: "#c74375"

    function readTextFile(fileUrl, callback){
       var xhr = new XMLHttpRequest;
       var result = "";
       xhr.open("GET", fileUrl); // set Method and File
       xhr.send(); // begin the request

       xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;

               if(callback) callback(response);
           }
       }
    }

    Settings {
        id: settings
        property bool firstRun: true
        property bool pairedDevice: false
        property string pairedDeviceName: "None"
        property string mac: "None"
        property string firmware: "None"
        property string devices: Qt.resolvedUrl(".")

        // Some stuff I want to display to not make the App look empty at least until I implemented databases
        property string firmwareVersion: ""
        property int heartRateLevel: 0
        property int stepsLevel: 0
        property int calorieLevel: 0
    }

    PageStack {
      id: pageStack
      Component.onCompleted: pageStack.push(Qt.resolvedUrl("./Components/PageWelcome.qml"))
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            addImportPath(Qt.resolvedUrl('../src/uGatt'));

            importModule('uwatch', function() {
                python.call('uwatch.initialize', function(initialized) {
                });
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }

    Component.onCompleted: {

      readTextFile(Qt.resolvedUrl("../assets/devices.json"), function(result) {
        root.devices = result
      });

      var appDataPath = StandardPaths.writableLocation(StandardPaths.AppDataLocation)

      readTextFile(Qt.resolvedUrl("../assets/database.json"), function(result) {
        python.call('uwatch.initialSetup', [appDataPath.toString(), result], function(state) {

        });
      });
    }
}
