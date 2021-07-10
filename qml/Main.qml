import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import "Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'uwatch.jiho'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property string devices: "{}"

    property string accentColor: "#c74375"

    function readTextFile(fileUrl){
       var xhr = new XMLHttpRequest;
       xhr.open("GET", fileUrl); // set Method and File
       xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;

               root.devices = response
           }
       }
       xhr.send(); // begin the request
    }

    Settings {
        id: settings
        property bool pairedDevice: false
        property string pairedDeviceName: "None"
        property string mac: "None"
        property string firmware: "None"
        property string devices: Qt.resolvedUrl(".")

        // Some stuff I want to display to not make the App look empty at least until I implemented databases
        property string firmwareVersion: ""
        property int batteryLevel: 0
        property int heartRateLevel: 0
        property int stepsLevel: 0
        property int calorieLevel: 0
    }

    PageStack {
      id: pageStack
      Component.onCompleted: {
        readTextFile(Qt.resolvedUrl("../assets/devices.json"))

        if(settings.pairedDevice == true)
        {
          console.log("Settings device view");
          pageStack.push(Qt.resolvedUrl("./Components/PageDevice.qml"))
        } else {
          pageStack.push(Qt.resolvedUrl("./Components/PageWelcome.qml"))
        }
      }
    }

    Python {
        id: python

        property bool initialized: false

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            addImportPath(Qt.resolvedUrl('../src/uGatt'));

            importModule('uwatch', function() {
                console.log('module imported');

                python.call('uwatch.initialize', function(initialized) {
                  python.initialized = initialized;

                  console.log("Backend initialized: " + initialized);
                });
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
