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

  property bool syncing: false

  // Graph stats
  property var dateArray: []
  property var heartRateVals: []
  property var stepsVals: []

  property string battery: DB.readLastByDate("battery", deviceObject.mac, Helper.getToday())
  property string heartrate: DB.readLastByDate("heartrate", deviceObject.mac, Helper.getToday())
  property string steps: DB.readSumByDate("steps", deviceObject.mac, Helper.getToday())

  header: BaseHeader{
      id: deviceViewHeader
      title: deviceObject.firmware + ' ' + deviceObject.firmwareVersion

      flickable: deviceFlickable

      /*trailingActionBar {
         actions: [
          Action {
           iconName: "settings"
           text: i18n.tr("Settings")

           onTriggered: pageStack.push(Qt.resolvedUrl("Settings.qml"))
         },
          Action {
            id: connectAction
            iconName: "preferences-network-bluetooth-disabled-symbolic"
            text: i18n.tr("Connect")

            onTriggered: {
              python.call('uwatch.connectDevice', [deviceObject.mac], function() {});
            }
          }
        ]
      }*/
  }

  ProgressBar {
    id: indeterminateBar
    anchors {
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      bottomMargin: 5
    }

    indeterminate: true
  }

  ScrollView {
    width: parent.width
    height: parent.height
    contentItem: deviceFlickable
  }

  Flickable {
    id: deviceFlickable

    property bool refreshing: true

    width: parent.width
    height: parent.height

    contentHeight: deviceColumn.height + settings.margin * 2

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
          id: batteryLevel

          icon: "battery_full"
          text: battery + " %"
        }

        StatsRectangle {
          id: heartRateLevel

          icon: "like"
          text: heartrate
        }

        StatsRectangle {
          id: stepsLevel

          icon: "transfer-progress"
          text: steps
        }
      }
    }

    PullToRefresh {
      id: devicePullToRefresh

      property int columnLength: deviceColumn.children.length

      parent: deviceFlickable
      refreshing: deviceColumn.children.length != 3
      onRefresh: pullToRefresh();
    }
  }

  Component.onCompleted: {
    if(deviceObject.firmwareVersion == " ") {
      indeterminateBar.visible = true;
      python.call('uwatch.connectDevice', [deviceObject.mac], function(connected) {
        if(connected) {
          Devices.getInitialDeviceData(deviceObject.id, deviceObject.mac, deviceObject.firmware);
          delay(4000, function() {
            indeterminateBar.visible = false;
            deviceObject.firmwareVersion = DB.readByMAC("watches", deviceObject.mac).rows.item(0).firmwareVersion;
            deviceViewHeader.title= deviceObject.firmware + ' ' + DB.readByMAC("watches", deviceObject.mac).rows.item(0).firmwareVersion;
          })
        }
      })
    }

    updateView();
  }

  function startSync() {
    indeterminateBar.visible = true;
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
      updateView();
    });
  }

  function syncData() {
    let gattobject = GATT.getGATTObject(deviceObject.firmware);
    let timeObject = GATT.getUUIDObject(gattobject, "Current Time");
    let firmwareObject = GATT.getUUIDObject(gattobject, "Firmware Revision String");
    let batteryObject = GATT.getUUIDObject(gattobject, "Battery Level");
    let heartrateObject = GATT.getUUIDObject(gattobject, "Heart Rate Measurement");
    let stepsObject = GATT.getUUIDObject(gattobject, "Step count");

    python.call('uwatch.writeValue', [deviceObject.mac, deviceObject.firmwareVersion, firmwareObject.ValidSinceFirmware, timeObject.UUID, GATT.formatInput(Helper.currentTimeToHex())], function() {})
    python.call('uwatch.readValue', [deviceObject.mac,
     deviceObject.firmwareVersion,
     firmwareObject.ValidSinceFirmware,
     firmwareObject.UUID,
     "big-endian", "string"], function(result) {
       if(result != deviceObject.firmwareVersion) {
         DB.update(deviceObject.id, "watches", "firmwareVersion", result);
         deviceObject.id = result;

         updateView();
       }
    });
    python.call('uwatch.readValue', [deviceObject.mac,
     deviceObject.firmwareVersion,
     batteryObject.ValidSinceFirmware,
     batteryObject.UUID,
     "big-endian", "int"], function(result) {
       DB.writeStats("battery", [new Date().toISOString(), deviceObject.mac, result]);
       deviceView.battery = result;

       updateView();
    });

    python.call('uwatch.readValue',  [deviceObject.mac, deviceObject.firmwareVersion, heartrateObject.ValidSinceFirmware, heartrateObject.UUID, "big-endian", "int"],  function(result) {
      if(result != 0) {
        DB.writeStats("heartrate", [new Date().toISOString(), deviceObject.mac, result]);
        deviceView.heartrate = result;

        updateView();
      }
    });

    python.call('uwatch.readValue',  [deviceObject.mac, deviceObject.firmwareVersion, stepsObject.ValidSinceFirmware, stepsObject.UUID, "little-endian", "int"],  function(result) {
      let value = result - DB.readSumByDate("steps", deviceObject.mac, Helper.getToday());

      if(value > 0) {
        DB.writeStats("steps", [new Date().toISOString(), deviceObject.mac, value]);
      }

      deviceView.steps = DB.readSumByDate("steps", deviceObject.mac, Helper.getToday());

      updateView();
    });
  }

  function updateHeartRateView() {
    let heartrates = []

    let weekdays = Helper.getWeek("long");

    for(let i = 0; i < weekdays.length; i++) {
      let values = DB.readByDate("heartrate", deviceObject.mac, weekdays[i]);
      let valuesArray = [];

      for(let j = 0; j < values.length; j++) {
        valuesArray.push(values.item(j).value);
      }

      if(valuesArray.length > 0) {
        heartrates.push(Math.max.apply(Math, valuesArray));
      } else {
        heartrates.push(0);
      }
    }

    return heartrates;
  }

  function updateStepsView() {
    let steps = []

    let weekdays = Helper.getWeek("long");

    for(let i = 0; i < weekdays.length; i++) {
      steps.push(
          DB.readSumByDate(
            "steps",
            deviceObject.mac,
            weekdays[i]
          )
      );
    }

    return steps
  }

  function updateView() {
    for(let i = 1; i < deviceColumn.children.length; i++) {
      deviceColumn.children[i].destroy();
    }

    let component = Qt.createComponent("../Components/Chart.qml")
    component.createObject(deviceColumn, {title: i18n.tr("Heart rate (Highest)"), page: "Heart rate", values: updateHeartRateView()});
    component.createObject(deviceColumn, {title: i18n.tr("Steps"), page: "Steps", values: updateStepsView()});

    //indeterminateBar.visible = false;
  }

  function pullToRefresh() {
    updateView();

    if(settings.syncAtPull) {
      python.call('uwatch.getConnectionState', [deviceObject.mac], function(result) {
        if(result) {
          syncData();
        }
      });
    }
  }

  Timer {
      id: timer
  }

  function delay(delayTime, cb) {
      timer.interval = delayTime;
      timer.repeat = false;
      timer.triggered.connect(cb);
      timer.start();
  }
}
