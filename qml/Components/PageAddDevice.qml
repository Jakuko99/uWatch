import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
    id: addDeviceView
    anchors.fill: parent

    function scanDevices() {
      listModel.clear()
      python.call('uwatch.add_device', [root.devices], function(devices) {
        if(devices.length > 0) {
          devices.forEach((el, i) => listModel.append({deviceName: el[1], deviceMAC: el[0]}));
        } else {
          scanLabel.text = i18n.tr("Could not find any devices.")
        }
      })
    }

    header: BaseHeader {
        id: addDeviceViewHeader
        title: i18n.tr('Add device')

        trailingActionBar {
           actions: [
            Action {
              iconName: "sync"
              text: i18n.tr("Sync")

              onTriggered: scanDevices()
            }
          ]
        }
    }

    Component.onCompleted: scanDevices()

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
                text: i18n.tr("Scanning for devices")
                visible: devicesListView.count === 0 && !listModel.loading
            }
        }
    }

    Component{
        id:devicesDelegate

        ListItem {
            id: deviceItemDelegate

            onClicked:{
                settings.firmware = deviceName
                settings.mac = deviceMAC
                settings.pairedDevice = true
                pageStack.pop()
                pageStack.pop()
                pageStack.push(Qt.resolvedUrl("PageDevice.qml"))
            }

            ListItemLayout {
                anchors.centerIn: parent
                title.text: deviceName
                subtitle.text: deviceMAC
            }
        }
      }
}
