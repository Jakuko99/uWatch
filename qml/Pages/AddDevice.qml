import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import "../Components"
import "../js/Devices.js" as Devices

Page {
    id: addDeviceView

    property string selectedFirmware: ""
    property string selectedMAC: ""
    property var watchesObject: null

    anchors.fill: parent

    header: BaseHeader {
        id: addDeviceViewHeader
        title: i18n.tr('Add device')

        trailingActionBar {
           actions: [
            Action {
              iconName: "sync"
              text: i18n.tr("Sync")

              onTriggered: Devices.scanDevices();
            }
          ]
        }
    }

    ListModel {
        id: listModel
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
            model: listModel
            delegate: devicesDelegate
            focus: true

            Label {
                id: scanLabel
                anchors.centerIn: parent
                text: i18n.tr("Scanning...")
                visible: devicesListView.count === 0 && !listModel.loading
            }
        }
    }

    Component.onCompleted: Devices.scanDevices();

    Component{
        id:devicesDelegate

        ListItem {
            id: deviceItemDelegate

            onClicked: {
              selectedFirmware = firmware
              selectedMAC = deviceMAC
              PopupUtils.open(pairDialogComponent)
            }

            ListItemLayout {
                anchors.centerIn: parent
                title.text: firmware
                subtitle.text: deviceMAC
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
              python.call('uwatch.addDevice', [addDeviceView.selectedMAC, "", addDeviceView.selectedFirmware, ""], function(result) {

              })
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
              pageStack.pop()
              pageStack.pop()
              pageStack.push(Qt.resolvedUrl("./PageWelcome.qml"), {newFirmware: addDeviceView.selectedFirmware, newMAC: addDeviceView.selectedMAC})
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