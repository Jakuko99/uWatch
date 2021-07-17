import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

import "Chart"
import "Stats"

Page {
    id: deviceView
    anchors.fill: parent

    property string json: "{}"

    Component.onCompleted: {
      console.log(root.devices);

    }

    header: BaseHeader{
        id: deviceViewHeader
        title: i18n.tr('uWatch')

        trailingActionBar {
           actions: [
            Action {
             iconName: "settings"
             text: i18n.tr("Settings")

             onTriggered: pageStack.push(Qt.resolvedUrl("PageSettings.qml"))
            },
            Action {
              iconName: "sync"
              text: i18n.tr("Sync")

              onTriggered: python.call('uwatch.connect_device', [settings.mac], function(connected) {
                console.log(connected)
                if(connected) {
                    python.call('uwatch.syncTime', [root.devices, settings.firmware], function() {})
                    python.call('uwatch.syncFirmware', [root.devices, settings.firmware], function(firmware) {
                      settings.firmwareVersion = firmware
                    })
                    python.call('uwatch.syncBatteryLevel', [root.devices, settings.firmware], function(batteryLevel) {
                      settings.batteryLevel = batteryLevel
                    })

                    python.call('uwatch.syncHeartRate', [root.devices, settings.firmware], function(heartRateLevel) {
                      settings.heartRateLevel = heartRateLevel
                    })

                    python.call('uwatch.syncSteps', [root.devices, settings.firmware], function(stepsLevel) {
                      settings.stepsLevel = stepsLevel
                    })
                }
              })
            }
          ]
        }
    }

    Row {
      id: deviceStatsView

      anchors {
        top: deviceViewHeader.bottom
        left: parent.left
        right: parent.right
      }

      height: units.gu(7)

      StatsRectangle {

        StatsIcon {
          iconName: "battery_full"
        }

        StatsLabel {
          labelText: settings.batteryLevel + " %"
        }
      }

      StatsRectangle {

        StatsIcon {
          iconName: "like"
        }

        StatsLabel {
          labelText: settings.heartRateLevel
        }
      }

      StatsRectangle {

        StatsIcon {
          iconName: "timer"
        }

        StatsLabel {
          labelText: settings.calorieLevel
        }
      }

      StatsRectangle {

        StatsIcon {
          iconName: "transfer-progress"
        }

        StatsLabel {
          labelText: settings.calorieLevel
        }
      }
    }

    ScrollView {
      anchors {
        top: deviceStatsView.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
      }

      Column {
        id: deviceInfoBox

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          leftMargin: units.gu(2)
          rightMargin: units.gu(2)
        }

        Label {
          id: lblDeviceName

          text: "InfiniTime" // Will be changed as soon as databases are implemented
          textSize: Label.Large
        }

        Label {
          id: lblFirmware

          text: i18n.tr("Firmware: ") + settings.firmwareVersion
          textSize: Label.Small
        }

        Label {
          id: lblHardware

          text: i18n.tr("MAC: ") + settings.mac
          textSize: Label.Small
        }

        Graph {
          id: heartrateGraph

          width: deviceView.width - units.gu(4)

          property int max: 100 // Dummy values until database exists

          GraphHeader {
            id: heartRateGraphHeader
            title: i18n.tr("Heart rate")
            page: "HeartRate"
          }

          YAchsis {
            id: heartRateyAchsis

            anchors.top:heartRateGraphHeader.bottom

            max: parent.max
          }

          XAchsis {
            id: heartRatexAchsis

            anchors.left: heartRateyAchsis.right

            values: ["04.07.", "05.07.", "06.07.", "07.07.", "08.07.", "09.07.", "10.07."] // Dummy values until database exists
          }

          GraphValuesRectangle {
            anchors {
              left: heartRateyAchsis.right
              right: parent.right
              top: heartRateGraphHeader.bottom
              bottom: heartRatexAchsis.top
            }

            max: parent.max

            values: ["53", "78", "96", "50", "67", "62", "80"] // Dummy values until database exists
          }
        }

        Graph {
          id: stepsGraph
          width: deviceView.width - units.gu(4)

          property int max: 12000 // Dummy values until database exists

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

            values: ["04.07.", "05.07.", "06.07.", "07.07.", "08.07.", "09.07.", "10.07."] // Dummy values until database exists
          }

          GraphValuesRectangle {
            anchors {
              left: stepsyAchsis.right
              right: parent.right
              top: stepsGraphHeader.bottom
              bottom: stepsxAchsis.top
            }

            max: parent.max

            values: ["2500", "1200", "8000", "6921", "3267", "9813", "10000"] // Dummy values until database exists
          }
        }

        Graph {
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
        }
    }
  }
}
