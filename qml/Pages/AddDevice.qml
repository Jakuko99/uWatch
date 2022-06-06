import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import QtBluetooth 5.9
import "../Components"
import "../js/Database.js" as DB
import "../js/Devices.js" as Devices

Page {
    id: addDeviceView

    property var listModel: null

    property string selectedFirmware: ""
    property string selectedMAC: ""
    property var watchesObject: null

    anchors.fill: parent

    header: BaseHeader {
        id: addDeviceViewHeader
        title: i18n.tr('Add device')
    }

    ScrollView {
        id: scrollView
        anchors {
          top: addDeviceViewHeader.bottom
          left: parent.left
          right: parent.right
          bottom: parent.bottom
        }

        ListView {
            id: devicesListView
            anchors.fill: parent
            model: btModel
            delegate: devicesDelegate
            focus: true

            Label {
                id: scanLabel
                anchors.centerIn: parent
                text: i18n.tr("Scanning...")
                visible: devicesListView.count === 0
            }
        }
    }

    BluetoothDiscoveryModel {
      id: btModel
      running: true
      discoveryMode: BluetoothDiscoveryModel.DeviceDiscovery
    }

    Component{
        id:devicesDelegate

        ListItem {
            id: deviceItemDelegate

            onClicked: {
              selectedFirmware = qsTr(deviceName)
              selectedMAC = qsTr(remoteAddress)
              PopupUtils.open(pairDialogComponent)
            }

            ListItemLayout {
                anchors.centerIn: parent
                title.text: qsTr(deviceName)
                subtitle.text: qsTr(remoteAddress)
            }
        }
    }

    Component {
      id: pairDialogComponent

      Dialog {
           id: pairDialog
           title: i18n.tr("Pair") + " " + addDeviceView.selectedFirmware
           text: i18n.tr("Are you sure you want to pair with") + " " + addDeviceView.selectedMAC + "?"

           Button {
               text: "Pair"
               color: theme.palette.normal.positive

               onClicked: {
                 PopupUtils.close(pairDialog)
                 PopupUtils.open(attemptPairDialogComponent)
               }
           }

           Button {
               text: "Cancel"
               onClicked: PopupUtils.close(pairDialog)
           }
       }
    }

    Component {
      id: attemptPairDialogComponent
      Dialog {
        id: attemptPairDialog
        title: i18n.tr("Pair device")
        text: i18n.tr("Attempting to pair with") + " " + addDeviceView.selectedMAC

        Component.onCompleted: {
          python.call('uwatch.pairDevice', [addDeviceView.selectedMAC], function(result) {
            PopupUtils.close(attemptPairDialog)
            if(result) {
              DB.createWatch([addDeviceView.selectedMAC, "", addDeviceView.selectedFirmware, ""])
              PopupUtils.open(pairSuccessfulDialogComponent)
            } else {
              PopupUtils.open(pairUnsuccessfulDialogComponent)
            }
          })
        }
      }
    }

    Component {
      id: pairSuccessfulDialogComponent
      Dialog {
        id: pairSuccessfulDialog
        title: i18n.tr("Pair successful")
        text: i18n.tr("Device was successfully paired.")

        Button {
            text: "Close"

            onClicked: {
              PopupUtils.close(pairSuccessfulDialog)

              let newWatch = DB.readByMAC("watches", addDeviceView.selectedMAC);
              listModel.append({deviceObject: newWatch.rows.item(0)})
              pageStack.pop()
            }
        }
      }
    }

    Component {
      id: pairUnsuccessfulDialogComponent
      Dialog {
        id: pairUnsuccessfulDialog
        title: i18n.tr("Pair unsuccessful")
        text: i18n.tr("Device could not be paired.")

        Button {
            text: "Close"
            color: "#F7F7F7"

            onClicked: {
              PopupUtils.close(pairUnsuccessfulDialog)
            }
        }
      }
    }
}
