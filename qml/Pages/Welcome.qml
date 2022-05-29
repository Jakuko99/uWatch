import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Qt.labs.platform 1.0
import Ubuntu.Components.Popups 1.3
import QtQuick.LocalStorage 2.0
import "../Components"
import "../js/Database.js" as DB
import "../js/Devices.js" as Devices

Page {
    id: welcomePage
    anchors.fill: parent

    property string selectedDevice: ""
    property int selectedIndex: -1

    header: BaseHeader {
        id: welcomePageHeader

        title: 'uWatch'

        trailingActionBar {
           actions: [
            Action {
             iconName: "add"
             text: "Add device"

             onTriggered: pageStack.push(Qt.resolvedUrl("AddDevice.qml"), {watchesObject: welcomeListModel})
            }
          ]
        }
    }

    ScrollView {
        id: welcomeScrollView
        anchors {
          top: welcomePageHeader.bottom
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
                color: settings.accentColor
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

    Component.onCompleted: Devices.listDevices();

    ListModel {
        id: welcomeListModel

        property int deviceID: -1
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
                          selectedIndex = index
                          PopupUtils.open(deleteDeviceDialogComponent)
                        }
                    }
                ]
            }

            onClicked: pageStack.push(Qt.resolvedUrl("Device.qml"), {id: deviceID})
        }
      }

      Component {
        id: deleteDeviceDialogComponent
        Dialog {
          id: deleteDeviceDialog
          title: i18n.tr("Delete device")
          text: i18n.tr("Are you sure you want to delete this device?")

          Button {
              text: i18n.tr("Delete")
              color: theme.palette.normal.negative

              onClicked: {
                PopupUtils.close(deleteDeviceDialog)
                Devices.deleteDevice(selectedIndex);
              }
          }

          Button {
              text: i18n.tr("Cancel")

              onClicked: {
                PopupUtils.close(deleteDeviceDialog)
              }
          }
        }
      }
}
