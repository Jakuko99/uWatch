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
        id: settingsSyncAtStartLabel

        anchors {
          left: parent.left
          top: settingsSyncTitleLabel.bottom
          topMargin: units.gu(2)
          bottomMargin: units.gu(2)
          leftMargin: units.gu(2)
          rightMargin: units.gu(2)
        }

        text: i18n.tr('Sync watch after it connected')
      }
    }
}
