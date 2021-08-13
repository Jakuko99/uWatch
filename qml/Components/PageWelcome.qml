import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Qt.labs.platform 1.0
import Ubuntu.Components.Popups 1.3

Page {
    id: welcomeView
    anchors.fill: parent

    property string selectedDevice: ""

    // Workaround to add a device after it was newly add
    property string newFirmware: ""
    property string newMAC: ""

    header: BaseHeader {
        id: welcomeViewHeader
        title: i18n.tr('Start')

        trailingActionBar {
           actions: [
            Action {
             iconName: "add"
             text: "Add device"

             onTriggered: pageStack.push(Qt.resolvedUrl("PageAddDevice.qml"))
            }
          ]
        }
    }

    ListModel {
        id: welcomeListModel
    }

    ScrollView {
        id: welcomeScrollView
        anchors {
          top: welcomeViewHeader.bottom
          left: parent.left
          right: parent.right
          bottom: parent.bottom
        }

        ListView {
            id: welcomeListView
            anchors.fill: parent
            model: welcomeListModel
            delegate: welcomeDelegate
            focus: true

            Label {
                id: noDevicesLabel

                anchors {
                  bottom: startAddLabel.top
                  horizontalCenter: parent.horizontalCenter
                  bottomMargin: units.gu(4)
                }

                text: i18n.tr("No watches yet!")
                textSize: Label.Large
                color: root.accentColor
                visible: welcomeListView.count === 0 && !welcomeListModel.loading
            }

            Label {
                id: startAddLabel
                anchors.centerIn: parent

                width: parent.width - units.gu(8)

                text: i18n.tr("To start, just click on '+' in the top bar")
                visible: welcomeListView.count === 0 && !welcomeListModel.loading
                wrapMode: Label.WordWrap
            }

        }
    }

    Component{
        id: welcomeDelegate

        ListItem {
            id: welcomeItemDelegate

            ListItemLayout {
                anchors.centerIn: parent
                title.text: firmware
                subtitle.text: deviceMAC
            }

            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"

                        onTriggered: {
                          selectedDevice = deviceMAC
                          PopupUtils.open(deleteDeviceDialogComponent)
                        }
                    }
                ]
            }

            onClicked: pageStack.push(Qt.resolvedUrl("PageDevice.qml"), {deviceMAC: deviceMAC, firmware: firmware})
        }
      }

      Component {
        id: deleteDeviceDialogComponent
        Dialog {
          id: deleteDeviceDialog
          title: i18n.tr("Delete device")
          text: i18n.tr("Are you sure you want to delete this device?")

          Button {
              text: "Delete"
              color: theme.palette.normal.negative

              onClicked: {
                PopupUtils.close(deleteDeviceDialog)
                deleteDevice()
              }
          }

          Button {
              text: "Cancel"

              onClicked: {
                PopupUtils.close(deleteDeviceDialog)
              }
          }
        }
      }

    Component.onCompleted: listDevices(StandardPaths.writableLocation(StandardPaths.AppDataLocation))

    function listDevices(appDataPath) {
      if(newFirmware != "" && newMAC != "") {
        welcomeListModel.append({firmware: newFirmware, deviceMAC: newMAC});
      }

      python.call('uwatch.databaseExists', [appDataPath.toString()], function(result) {
        if(result == true) {
          python.call('uwatch.getDevices', [appDataPath.toString()], function(devices) {
            devices.forEach((el, i) => welcomeListModel.append({firmware: el[0], deviceMAC: el[1]}));
          });
        }
      });
    }

    function deleteDevice() {
      python.call('uwatch.deleteDevice', [selectedDevice], function(result) {

      });
    }
}
