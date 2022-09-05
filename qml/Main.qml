import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Qt.labs.platform 1.0
import QtQuick.LocalStorage 2.0
import Qt.labs.folderlistmodel 2.2
import "Components"

import "./js/Database.js" as DB
import "./js/Helper.js" as Helper

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'uwatch.jiho'
    automaticOrientation: true
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)

    property string devices: "{}"

    Settings {
        id: settings

        readonly property int margin: units.gu(2)

        // Theme settings
        readonly property string accentColor: "#c74375"
        readonly property string cardColor: theme.name == "Ubuntu.Components.Themes.SuruDark" ? "#444444" : "#EAE9E7"

        // Backend Settings
        property bool initializeAtStart: true
        property bool migrationRan: false
        property bool databaseMigrated: false

        property bool displayUnsupportedDevices: false
        property bool syncAtPull: true
        property int syncInterval: 15
    }

    PageStack {
      id: pageStack
      Component.onCompleted: {
        // Init uGatt
        python.call('uwatch.initialize', [], function(result) {
          result ? console.log("Bluetooth backend initialized") : console.log("Could not initialize the bluetooth backend")
        })

        pageStack.push(Qt.resolvedUrl("./Pages/Welcome.qml"))
      }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            addImportPath(Qt.resolvedUrl('../src/uGatt'));

            importModule('uwatch', function() {});
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }

    Component.onCompleted: {
      DB.openDatabase();
      Helper.migrateDatabase(StandardPaths.writableLocation(StandardPaths.AppDataLocation));
    }

    /*Timer {
      interval: settings.syncInterval*60*1000; running: true; repeat: true
      onTriggered: console.log("Timer triggered");

      Component.onCompleted: {
        if(settings.syncInterval == 0) {
          running = false;
        }
      }
    }*/
}
