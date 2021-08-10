import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
    id: welcomeView
    anchors.fill: parent

    function listDevices() {
      python.call('uwatch.databaseExists', [root.appDataPath.toString()], function(result) {
        if(result == true) {
          python.call('uwatch.getDevices', [root.appDataPath.toString()], function(devices) {
            devices.forEach((el, i) => welcomeListModel.append({firmware: el[0], deviceMAC: el[1]}));
          });
        }
      });
    }

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
                    }
                ]
            }

            onClicked: pageStack.push(Qt.resolvedUrl("PageDevice.qml"), {deviceMAC: deviceMAC})
        }
      }

    Component.onCompleted: listDevices()
}
