import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Themes 1.3
import Ubuntu.Components.Popups 1.3

import "../Components"
import "../js/Database.js" as DB

Page {
    id: pageStatDetails

    property var deviceObject: null
    property string page: ""

    property string selectedFullDate: ""
    property int selectedIndex: -1

    header: BaseHeader {
        id: pageStatDetailsHeader
        title: i18n.tr(page)
    }

    ListModel {
        id: statDetailsListModel

        property string fullDate: ""
    }

    ScrollView {
        id: statDetailsScrollView
        anchors {
          top: pageStatDetailsHeader.bottom
          left: parent.left
          right: parent.right
          bottom: parent.bottom
        }

        ListView {
            id: statDetailsListView
            anchors.fill: parent
            model: statDetailsListModel
            delegate: statDetailsDelegate
            focus: true

            Label {
                id: noStatsLabel

                anchors {
                  bottom: addStatsLabel.top
                  horizontalCenter: parent.horizontalCenter
                  bottomMargin: units.gu(4)
                }

                text: i18n.tr("No stats to display!")
                textSize: Label.Large
                color: settings.accentColor
                visible: statDetailsListView.count === 0 && !statDetailsListModel.loading
            }

            Label {
                id: addStatsLabel
                anchors.centerIn: parent

                width: parent.width - units.gu(8)

                text: i18n.tr("Try to add some by swiping up from the bottom edge")
                visible: statDetailsListView.count === 0 && !statDetailsListModel.loading
                wrapMode: Label.WordWrap
            }

        }
    }

    Component{
        id: statDetailsDelegate

        ListItem {
            id: statDetailsItemDelegate

            ListItemLayout {
                anchors.centerIn: parent
                title.text: value
                subtitle.text: date
            }

            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"

                        onTriggered: {
                          selectedIndex = index
                          selectedFullDate = fullDate
                          PopupUtils.open(deleteValueDialogComponent)
                        }
                    }
                ]
            }
        }
      }

    BottomEdge {
        id: pageStatBottomEdge
        enabled: !Qt.inputMethod.visible
        height: parent.height
        hint.visible: enabled
        hint.text: i18n.tr("Add value")
        preloadContent: true

        contentUrl: Qt.resolvedUrl("AddValue.qml")
    }

    Component {
      id: deleteValueDialogComponent
      Dialog {
        id: deleteValueDialog
        title: i18n.tr("Delete entry")
        text: i18n.tr("Are you sure you want to delete this entry?")

        Button {
            text: "Delete"
            color: theme.palette.normal.negative

            onClicked: {
              PopupUtils.close(deleteValueDialog)
              deleteValue(selectedFullDate)
            }
        }

        Button {
            text: "Cancel"

            onClicked: {
              PopupUtils.close(deleteValueDialog)
            }
        }
      }
    }

    Component.onCompleted: listStats()

    function listStats() {
      let values = null
      switch(page) {
        case "Heart rate":
          values = DB.readAll("heartrate");
          break;
        case "Steps":
          values = DB.readAll("steps");
          break;
        default:
          //action = "none";
          break;
      }

      for(let i = 0; i < values.rows.length; i++) {
        let row = values.rows.item(i);
        let date = new Date(Date.parse(row.date)).toUTCString();//values[2].split("T")[0]
        //let time = values[2].split("T")[1].split(".")[0]
        statDetailsListModel.append({value: row.value, date: date, fullDate: row.date});
      }
    }

    function deleteValue(date) {
      let table = ""
      switch(page) {
        case "Heart rate":
          table = "heartrate";
          break;
        case "Steps":
          table = "steps";
          break;
        default:
          table = "none";
          break;
      }

      python.call('uwatch.deleteValues', [table, deviceObject.mac, date], function(result) {

      });
      statDetailsListModel.remove(selectedIndex);
    }
}
