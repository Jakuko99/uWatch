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

        flickable: settingsFlickable
    }

    ScrollView {
      width: parent.width
      height: parent.height
      contentItem: settingsFlickable
    }

    Flickable {
      id: settingsFlickable
      width: parent.width
      height: parent.height

      contentHeight: settingsColumn.height

      Column {
        id: settingsColumn

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          bottom: parent.bottom
          topMargin: settings.margin
          leftMargin: settings.margin
          rightMargin: settings.margin
          bottomMargin: units.gu(4)
        }

        spacing: settings.margin

        Label {
          id: syncTitleLabel

          anchors {
            left: parent.left
            right: parent.right
            topMargin: settings.margin
            leftMargin: settings.margin
          }

          color: settings.accentColor

          text: i18n.tr('Sync')
          textSize: Label.Large
        }

        Label {
          id: syncAtStartLabel

          anchors {
            left: parent.left
            right:parent.right
            leftMargin: settings.margin
            rightMargin: settings.margin
          }

          text: i18n.tr('Sync watch after it connected')
          wrapMode: Text.Wrap
        }
      }
    }
}
