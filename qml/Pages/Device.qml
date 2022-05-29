import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import "../Components"
import "../Components/Chart"
import "../Components/Stats"

import "../js/Database.js" as DB
import "../js/Devices.js" as Devices
import "../js/GATT.js" as GATT

Page {
    id: deviceView
    anchors.fill: parent

    property string json: "{}"

    // Device specific variables
    property var deviceObject: null

    // Graph stats
    property var dateArray: []
    property var heartRateVals: []
    property var stepsVals: []

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

      contentHeight: deviceColumn.height

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
              labelText: "0 %"
            }
          }

          StatsRectangle {

            StatsIcon {
              iconName: "like"
            }

            StatsLabel {
              id: heartRateLabel
              labelText: "0"
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
              labelText: "0"
            }
          }
        }


        Graph {
          id: heartRateGraph

          width: deviceView.width - units.gu(4)

          property int max: heartRateVals.length > 0 ? Math.max.apply(Math, heartRateVals) : 200

          GraphHeader {
            id: heartRateGraphHeader
            title: i18n.tr("Heart rate (Highest)")
            page: "Heart rate"
          }

          YAchsis {
            id: heartRateyAchsis

            anchors.top:heartRateGraphHeader.bottom

            max: parent.max
          }

          XAchsis {
            id: heartRatexAchsis

            anchors.left: heartRateyAchsis.right

            values: dateArray
          }

          GraphValuesRectangle {
            id: heartRateValues

            anchors {
              left: heartRateyAchsis.right
              right: parent.right
              top: heartRateGraphHeader.bottom
              bottom: heartRatexAchsis.top
            }

            max: parent.max

            values: heartRateVals
          }
        }

        // Display steps graph as steps can be manually added
        Graph {
          id: stepsGraph
          width: deviceView.width - units.gu(4)

          property int max: stepsVals.length > 0 ? Math.max.apply(Math, stepsVals) : 12000

          GraphHeader {
            id: stepsGraphHeader
            title: i18n.tr("Steps")
            page: "Steps"
          }

          YAchsis {
            id: stepsyAchsis

            anchors.top:stepsGraphHeader.bottom

            max: parent.max
          }

          XAchsis {
            id: stepsxAchsis

            anchors.left: stepsyAchsis.right

            values: dateArray
          }

          GraphValuesRectangle {
            anchors {
              left: stepsyAchsis.right
              right: parent.right
              top: stepsGraphHeader.bottom
              bottom: stepsxAchsis.top
            }

            max: parent.max

            values: stepsVals
          }
        }

        // Display only after getting steps to sync
        /*Graph {
          id: caloriesGraph
          width: deviceView.width - units.gu(4)

          property int max: 5000 // Dummy values until database exists

          GraphHeader {
            id: caloriesGraphHeader
            title: i18n.tr("Burnt calories")
            page: "Calories"
          }

          YAchsis {
            id: caloriesyAchsis

            anchors.top:caloriesGraphHeader.bottom

            max: parent.max
          }

          XAchsis {
            id: caloriesxAchsis

            anchors.left: caloriesyAchsis.right

            values: ["04.07.", "05.07.", "06.07.", "07.07.", "08.07.", "09.07.", "10.07."] // Dummy values until database exists
          }

          GraphValuesRectangle {
            anchors {
              left: caloriesyAchsis.right
              right: parent.right
              top: caloriesGraphHeader.bottom
              bottom: caloriesxAchsis.top
            }

            max: parent.max

            values: ["1800", "2200", "2000", "3100", "1700", "1600", "1800"] // Dummy values until database exists
          }
        }*/
    }
  }

  Component.onCompleted: {
    //updateView();
  }

  function syncData() {
    let gattobject = GATT.getGATTObject(deviceObject.firmware);
    let firmwareObject = GATT.getUUIDObject(gattobject, "Firmware Revision String");

    //console.log(firmwareObject);

    python.call('uwatch.writeValue', [root.devices, firmware, firmwareVersion], function() {})
    python.call('uwatch.readValue', [deviceObject.mac,
     deviceObject.firmwareVersion,
     firmwareObject.ValidSinceFirmware, firmwareObject.UUID, "big-endian"], function(result) {
       console.log(result);
    });
    python.call('uwatch.syncBatteryLevel', [deviceObject.mac, root.devices, firmware, firmwareVersion], function(batteryLevel) {

    });

    python.call('uwatch.syncHeartRate', [deviceObject.mac, root.devices, firmware, firmwareVersion], function(heartRateLevel) {

    });

    python.call('uwatch.syncSteps', [deviceObject.mac, root.devices, firmware, firmwareVersion], function(stepsLevel) {

    });

    //updateView();
  }

  function updateHeartRateView() {
    heartRateVals = []

    python.call('uwatch.getLatestHeartRate', [deviceObject.mac], function(result) {
      heartRateLabel.labelText = result[0]
    })

    // Get the date range for which to fetch data from the database
    python.call('uwatch.getISODateArray', [7], function(result) {
      var tvalues = []

      // Fetch all database entries for the date and get the max value
      for(let i = 0; i < result.length; i++) {
        python.call('uwatch.getHeartRateForDate', [deviceObject.mac, result[i]], function(result) {
          if(result.length >0) {
            tvalues.push(Math.max.apply(Math, result))
          } else {
            tvalues.push(0)
          }
          heartRateVals = tvalues
        })
      }
    })

  }

  function updateStepsView() {
    stepsVals = []

    python.call('uwatch.getISODateArray', [1], function(result) {
      python.call('uwatch.getStepsForDate', [deviceObject.mac, result[0]], function(result) {
        stepsLabel.labelText = result
      })
    })

    // Get the date range for which to fetch data from the database
    python.call('uwatch.getISODateArray', [7], function(result) {
      var tvalues = []

      // Fetch all database entries for the date and get the max value
      for(let i = 0; i < result.length; i++) {
        python.call('uwatch.getStepsForDate', [deviceObject.mac, result[i]], function(result) {
          if(result > 0) {
            tvalues.push(result)
          } else {
            tvalues.push(0)
          }
          stepsVals = tvalues
        })
      }
    })

  }

  function updateView() {
    python.call('uwatch.getShortISODateArray', [7], function(result) {
      dateArray = result
    })

    python.call('uwatch.getFirmware', [deviceObject.mac], function(result) {
      deviceView.firmware = result[0]
    })

    python.call('uwatch.getFirmwareVersion', [deviceObject.mac], function(result) {
      deviceView.firmwareVersion = result[0]
    })

    python.call('uwatch.getLatestBatteryLevel', [deviceObject.mac], function(result) {
      batteryLevelLabel.labelText = result[0] + " %"
    })

    //updateHeartRateView()
    //updateStepsView()
  }

  function updateFirmwareRevision() {
    python.call('uwatch.syncFirmwareRevision', [root.devices, deviceObject.mac, firmware], function(version) {

    })
  }
}
