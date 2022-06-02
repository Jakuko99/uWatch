import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import QtCharts 2.0
import "../Components"
import "../Components/Chart"
import "../Components/Stats"

import "../js/Database.js" as DB
import "../js/Devices.js" as Devices
import "../js/GATT.js" as GATT
import "../js/Helper.js" as Helper

Page {
    id: deviceView
    anchors.fill: parent

    property string json: "{}"

    // Device specific variables
    property var deviceObject: null

    // Graph stats
    property var dateArray: []
    property var heartRateVals: []
    property var stepsVals: updateStepsView()

    header: BaseHeader{
        id: deviceViewHeader
        title: deviceObject.firmware + ' ' + deviceObject.firmwareVersion

        flickable: deviceFlickable

        trailingActionBar {
           actions: [
            Action {
             iconName: "settings"
             text: i18n.tr("Settings")

             onTriggered: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            },
            Action {
              iconName: "sync"
              text: i18n.tr("Sync")

              onTriggered: {
                python.call('uwatch.getConnectionState', [deviceObject.mac], function(result) {
                  if(result) {
                    syncData();
                  } else {
                    python.call('uwatch.connectDevice', [deviceObject.mac], function(connected) {
                      if(connected) {
                        syncData();
                      }
                    })
                  }
                })
              }
            }
          ]
        }
    }

    ScrollView {
      width: parent.width
      height: parent.height
      contentItem: deviceFlickable
    }

    Flickable {
      id: deviceFlickable

      width: parent.width
      height: parent.height

      contentHeight: deviceColumn.height + settings.margin*2

      Column {
        id: deviceColumn

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          topMargin: settings.margin
          leftMargin: settings.margin
          rightMargin: settings.margin
          bottomMargin: units.gu(4)
        }

        spacing: settings.margin

        Row {
          id: deviceStatsView

          anchors {
            left: parent.left
            right: parent.right
          }

          height: units.gu(7)

          StatsRectangle {

            StatsIcon {
              iconName: "battery_full"
            }

            StatsLabel {
              id: batteryLevelLabel
              labelText: DB.readLastByDate("battery", deviceObject.mac, Helper.getToday()) + " %"
            }
          }

          StatsRectangle {

            StatsIcon {
              iconName: "like"
            }

            StatsLabel {
              id: heartRateLabel
              labelText: DB.readLastByDate("heartrate", deviceObject.mac, Helper.getToday())
            }
          }

          /*StatsRectangle {

            StatsIcon {
              iconName: "timer"
            }

            StatsLabel {
              labelText: settings.calorieLevel
            }
          }*/

          StatsRectangle {

            StatsIcon {
              iconName: "transfer-progress"
            }

            StatsLabel {
              id: stepsLabel
              labelText: DB.readLastByDate("steps", deviceObject.mac, Helper.getToday())
            }
          }
        }


        Graph {
          id: heartRateGraph

          title: i18n.tr("Heart rate (Highest)")
          page: "Heart rate"

          width: deviceView.width - units.gu(4)

          values: heartRateVals
        }

        // Display steps graph as steps can be manually added
        Graph {
          id: stepsGraph

          title: i18n.tr("Steps")
          page: "Steps"

          width: deviceView.width - units.gu(4)

          values: stepsVals
        }
    }
  }

  Component.onCompleted: {
    updateView();
  }

  function syncData() {
    let gattobject = GATT.getGATTObject(deviceObject.firmware);
    let firmwareObject = GATT.getUUIDObject(gattobject, "Firmware Revision String");
    let batteryObject = GATT.getUUIDObject(gattObject, "Battery Level");
    let heartrateObject = GATT.getUUIDObject(gattObject, "Heart Rate Measurement");
    let stepsObject = GATT.getUUIDObject(gattObject, "Step count");

    python.call('uwatch.writeValue', [root.devices, firmware, firmwareVersion], function() {})
    python.call('uwatch.readValue', [deviceObject.mac,
     deviceObject.firmwareVersion,
     firmwareObject.ValidSinceFirmware,
     firmwareObject.UUID,
     "big-endian"], function(result) {
       console.log(result);
    });
    python.call('uwatch.readValue', [deviceObject.mac,
     deviceObject.firmwareVersion,
     batteryObject.ValidSinceFirmware,
     batteryObject.UUID,
     "big-endian"], function(result) {
       console.log(result);
    });

    python.call('uwatch.readValue',  [deviceObject.mac, deviceObject.firmwareVersion, batteryObject.ValidSinceFirmware, batteryObject.UUID, "big-endian"],  function(result) {
       console.log(result);
    });

    python.call('uwatch.readValue',  [deviceObject.mac, deviceObject.firmwareVersion, stepsObject.ValidSinceFirmware, stepsObject.UUID, "big-endian"],  function(result) {
       console.log(result);
    });

    updateView();
  }

  function updateHeartRateView() {
    heartRateVals = []

    // Get the date range for which to fetch data from the database
    python.call('uwatch.getISODateArray', [7], function(result) {

      // Fetch all database entries for the date and get the max value
      for(let i = 0; i < result.length; i++) {
        //let values = DB.readByDate("heartrate", result[i]);
        if(values.length > 0) {
          heartRateVals.push(Math.max.apply(Math, values.value));
        } else {
          heartRateVals.push(0);
        }
        /*python.call('uwatch.getHeartRateForDate', [deviceObject.mac, result[i]], function(result) {
          if(result.length >0) {
            tvalues.push(Math.max.apply(Math, result))
          } else {
            tvalues.push(0)
          }
          heartRateVals = tvalues
        })*/
      }
    })

  }

  function updateStepsView() {
    stepsVals = []

    /*python.call('uwatch.getISODateArray', [1], function(result) {
      python.call('uwatch.getStepsForDate', [deviceObject.mac, result[0]], function(result) {
        stepsLabel.labelText = result
      })
    })*/

    let weekdays = Helper.getWeek("long");

    for(let i = 0; i < weekdays.length; i++) {
      let values = DB.readByDate("steps", deviceObject.mac, weekdays[i]);
      var valuesArray = [];

      for(let j = 0; j < values.length; j++) {
        valuesArray.push(values.item(j).value);
      }

      if(valuesArray.length > 0) {
        stepsVals.push(Math.max.apply(Math, valuesArray));
      } else {
        stepsVals.push(0);
      }
    }

    return stepsVals;
  }

  function updateView() {
    //updateHeartRateView()
    updateStepsView()
  }

  function updateFirmwareRevision() {
    /*python.call('uwatch.syncFirmwareRevision', [root.devices, deviceObject.mac, firmware], function(version) {

    })*/
  }
}
