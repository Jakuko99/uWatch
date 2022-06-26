import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

import "../Components"

Page {
    id: settingsView
    anchors.fill: parent

    header: BaseHeader {
        id: settingsViewHeader
        title: i18n.tr('Settings')
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
      anchors.fill: parent

      Label {
        id: settingsSyncTitleLabel

        anchors {
          left: parent.left
          top: parent.top
          topMargin: units.gu(2)
          bottomMargin: units.gu(2)
          leftMargin: units.gu(2)
          rightMargin: units.gu(2)
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
          leftMargin: settings.margin
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
          rightMargin: settings.margin
        }

        checked: settings.syncAtPull

        onClicked: settings.syncAtPull = checked
      }

    }
}
