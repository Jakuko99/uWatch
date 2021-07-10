import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

Page {
    id: welcomeView
    anchors.fill: parent

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
    }

    Label {
        id: startAddLabel
        anchors.centerIn: parent

        text: i18n.tr("To start, just click on '+' in the top bar")
    }
}
