/*
 * Copyright (C) 2022  Comiryu
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * putaside is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.0
import "../Components"

Page {
  id: pageSavings

  header: PageHeader {
    title: i18n.tr('About')

    flickable: aboutFlickable
  }

  ScrollView {
      width: parent.width
      height: parent.height
      contentItem: aboutFlickable
  }

  Flickable {
      id: aboutFlickable
      width: parent.width
      height: parent.height
      contentHeight: mainColumn.height
      topMargin: units.gu(2)

      Column {
        id: mainColumn
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        spacing: units.gu(2)

          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter

            width: units.gu(15)
            height: units.gu(15)

            color: "transparent"

            Image {
              anchors.fill: parent

              source: "../../assets/logo.png"
            }
          }

          Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "uWatch"
            textSize: Label.Large
          }

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              leftMargin: settings.margin
              rightMargin: settings.margin
            }

            radius: units.gu(1)
            color: settings.cardColor
            height: translateHeaderLabel.contentHeight + translateLabel.contentHeight + (settings.margin * 3)

            Label {
              id: versionHeaderLabel

              anchors {
                left: parent.left
                top: parent.top
                right: parent.right
                leftMargin: settings.margin
                topMargin: settings.margin
                rightMargin: settings.margin
              }

              text: i18n.tr('Version')
              textSize: Label.Small
            }

            Label {
              id: versionLabel

              anchors {
                left: parent.left
                right: parent.right
                top: versionHeaderLabel.bottom
                topMargin: settings.margin
                leftMargin: settings.margin
                rightMargin: settings.margin
              }

              //wrapMode: Text.Wrap
              text: "0.1"
            }
          }

        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
            leftMargin: settings.margin
            rightMargin: settings.margin
          }

          radius: units.gu(1)
          color: settings.cardColor
          height: developerHeaderLabel.contentHeight + developerLabel.contentHeight + (settings.margin * 2.5)

          Label {
            id: developerHeaderLabel

            anchors {
              left: parent.left
              top: parent.top
              right: parent.right
              leftMargin: settings.margin
              topMargin: settings.margin
              rightMargin: settings.margin
            }

            text: i18n.tr('Developer')
            textSize: Label.Small
          }

          Label {
            id: developerLabel

            anchors {
              left: parent.left
              right: parent.right
              top: developerHeaderLabel.bottom
              topMargin: settings.margin/2
              leftMargin: settings.margin
              rightMargin: settings.margin
            }

            wrapMode: Text.Wrap

            text: "Steven Granger (Comiryu)"
          }
        }

        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
            leftMargin: settings.margin
            rightMargin: settings.margin
          }

          radius: units.gu(1)
          color: settings.cardColor
          height: licenseHeaderLabel.contentHeight + licenseLabel.contentHeight + (settings.margin * 3)

          Label {
            id: licenseHeaderLabel

            anchors {
              left: parent.left
              top: parent.top
              right: parent.right
              leftMargin: settings.margin
              topMargin: settings.margin
              rightMargin: settings.margin
            }

            text: i18n.tr('License')
            textSize: Label.Small
          }

          Label {
            id: licenseLabel

            anchors {
              left: parent.left
              right: openUrlButton.left
              top: licenseHeaderLabel.bottom
              topMargin: settings.margin
              leftMargin: settings.margin
              rightMargin: settings.margin
            }

            //wrapMode: Text.Wrap
//             textFormat: TextEdit.MarkdownText
            text: "GPLv3"
          }

          Button {
            id: openUrlButton

            anchors {
              right: parent.right
              top: parent.top
              bottom: parent.bottom
              topMargin: settings.margin
              rightMargin: settings.margin
              bottomMargin: settings.margin
            }

            width: units.gu(4)

            color: "transparent"

            Icon {
                anchors.centerIn: parent
                width: units.gu(3)
                height: units.gu(3)
                name: "external-link"
            }

            onClicked: Qt.openUrlExternally("https://gitlab.com/jiiho1/uwatch/-/blob/main/LICENSE");
          }
        }

        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
            leftMargin: settings.margin
            rightMargin: settings.margin
          }

          radius: units.gu(1)
          color: settings.cardColor
          height: translateHeaderLabel.contentHeight + translateLabel.contentHeight + (settings.margin * 3)

          Label {
            id: translateHeaderLabel

            anchors {
              left: parent.left
              top: parent.top
              right: parent.right
              leftMargin: settings.margin
              topMargin: settings.margin
              rightMargin: settings.margin
            }

            text: i18n.tr('Help translate the app')
            textSize: Label.Small
          }

          Label {
            id: translateLabel

            anchors {
              left: parent.left
              right: openTranslateUrlButton.left
              top: translateHeaderLabel.bottom
              topMargin: settings.margin
              leftMargin: settings.margin
              rightMargin: settings.margin
            }

            //wrapMode: Text.Wrap
//             textFormat: TextEdit.MarkdownText
            text: "GitLab project"
          }

          Button {
            id: openTranslateUrlButton

            anchors {
              right: parent.right
              top: parent.top
              bottom: parent.bottom
              topMargin: settings.margin
              rightMargin: settings.margin
              bottomMargin: settings.margin
            }

            width: units.gu(4)

            color: "transparent"

            Icon {
                anchors.centerIn: parent
                width: units.gu(3)
                height: units.gu(3)
                name: "external-link"
            }

            onClicked: Qt.openUrlExternally("https://gitlab.com/jiiho1/uwatch/-/blob/main/po/utodon.comiryu.pot");
          }
        }
    }
  }
}
