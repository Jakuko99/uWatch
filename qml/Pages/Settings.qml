import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Pickers 1.0

import "../Components"

Page {
    id: settingsView
    anchors.fill: parent

    header: BaseHeader {
        id: settingsViewHeader
        title: i18n.tr('Settings')

        flickable: settingsFlickable

        trailingActionBar {
           actions: [
             Action {
               iconName: "info"
               text: i18n.tr("About")

               onTriggered: pageStack.push(Qt.resolvedUrl("About.qml"))
             }
          ]
        }
    }

    ScrollView {
      anchors {
        top: settingsViewHeader.bottom
      }

      width: parent.width
      height: parent.height
      contentItem: settingsFlickable
    }

    Flickable {
      id: settingsFlickable

      width: parent.width
      height: parent.height

      contentHeight: settingsColumn.height + settings.margin * 2

      Column {
        id: settingsColumn

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          leftMargin: settings.margin
          rightMargin: settings.margin
        }

        spacing: settings.margin

        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
          }

          color: "transparent"

          implicitHeight: settingsGeneralTitleLabel.implicitHeight + settingsSupportedDevicesLabel.implicitHeight + settings.margin * 2

          Label {
            id: settingsGeneralTitleLabel

            anchors {
              left: parent.left
              top: parent.top
              leftMargin: units.gu(2)
              rightMargin: units.gu(2)
            }

            color: settings.accentColor

            text: i18n.tr('General')
            textSize: Label.Large
          }

          Label {
            id: settingsSupportedDevicesLabel

            anchors {
              left: parent.left
              top: settingsGeneralTitleLabel.bottom
              right: settingsSupportedDevicesSwitch.left
              topMargin: settings.margin
              bottomMargin: settings.margin
              leftMargin: settings.margin
              rightMargin: settings.margin
            }

            text: i18n.tr('Display unsupported devices in device list')
            wrapMode: Text.Wrap
          }

          Switch {
            id: settingsSupportedDevicesSwitch
            anchors {
              right: parent.right
              top: settingsGeneralTitleLabel.bottom
              topMargin: settings.margin
              rightMargin: settings.margin
            }

            checked: settings.displayUnsupportedDevices

            onClicked: settings.displayUnsupportedDevices = checked
          }
        }

        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
            leftMargin: settings.margin
            rightMargin: settings.margin
          }

          color: "transparent"

          implicitHeight: settingsSyncTitleLabel.implicitHeight + settingsSyncAtPullLabel.implicitHeight + settings.margin * 2

          Label {
            id: settingsSyncTitleLabel

            anchors {
              left: parent.left
              top: parent.top
            }

            color: settings.accentColor

            text: i18n.tr('Sync')
            textSize: Label.Large
          }

          Label {
            id: settingsSyncAtPullLabel

            anchors {
              left: parent.left
              top: settingsSyncTitleLabel.bottom
              right: settingsSyncAtPullSwitch.left
              topMargin: settings.margin
              bottomMargin: settings.margin
              rightMargin: settings.margin
            }

            text: i18n.tr('Sync with watch when pulling to refresh')
            wrapMode: Text.Wrap
          }

          Switch {
            id: settingsSyncAtPullSwitch
            anchors {
              right: parent.right
              top: settingsSyncTitleLabel.bottom
              topMargin: settings.margin
            }

            checked: settings.syncAtPull

            onClicked: settings.syncAtPull = checked
          }

          Label {
            id: settingsAutoSyncLabel

            anchors {
              left: parent.left
              top: settingsSyncAtPullLabel.bottom
              right: settingsSyncAtPullSwitch.left
              topMargin: settings.margin
              bottomMargin: settings.margin
              rightMargin: settings.margin
            }

            text: i18n.tr('Automatically sync connected watches')
            wrapMode: Text.Wrap
          }

          Switch {
            id: settingsAutoSyncSwitch
            anchors {
              right: parent.right
              top: settingsSyncAtPullLabel.bottom
              topMargin: settings.margin
            }

            checked: settings.syncAutomatically

            onClicked: {
              settings.syncAutomatically = checked
              if(checked == false) {
                syncTimer.stop();
                syncTimer.running = false;
                console.log("Stopping timer");
              }
            }
          }

          Label {
            id: settingsAutoSyncWarningLabel

            anchors {
              left: parent.left
              top: settingsAutoSyncLabel.bottom
              right: settingsAutoSyncSwitch.left
              bottomMargin: settings.margin
              rightMargin: settings.margin
            }

            color: settings.subColor

            text: i18n.tr('App needs to stay active. This might drain the battery faster.')
            wrapMode: Text.Wrap
          }

          Label {
            id: settingsAutomaticSyncLabel

            anchors {
              left: parent.left
              top: settingsAutoSyncWarningLabel.bottom
              right: settingsAutoSyncIntervalTextField.left
              topMargin: settings.margin
              bottomMargin: settings.margin
            }

            text: i18n.tr('Sync interval (in Minutes)')
            wrapMode: Text.Wrap
          }

          TextField {
            id: settingsAutoSyncIntervalTextField
            
            anchors {
              top: settingsAutoSyncWarningLabel.bottom
              right: parent.right
              topMargin: settings.margin
              bottomMargin: settings.margin
            }

            width: units.gu(5)
            height: units.gu(3)

            text: settings.syncInterval
            inputMethodHints: Qt.ImhDigitsOnly

            hasClearButton: false

            onTextChanged: settings.syncInterval = text
          }
        }
      }
    }
}
