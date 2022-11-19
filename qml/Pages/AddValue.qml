import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Lomiri.Components.Pickers 1.3
import Lomiri.Components.Themes 1.3

import "../Components"
import "../js/Database.js" as DB

Page {
    id: pageAddValue

    header: BaseHeader {
        id: pageAddValueHeader
        title: i18n.tr("Add value")
    }

    // Using root to get the height otherwise it would be 0
    Rectangle {
      width: parent.width
      height: root.height

      color: theme.palette.normal.background

      ScrollView {
        width: parent.width
        height: root.height
        contentItem: addValueFlickable

        anchors {
          left: parent.left
          right: parent.right
          leftMargin: units.gu(4)
          rightMargin: units.gu(4)
        }
      }
    }

    Flickable {
      id: addValueFlickable
      width: parent.width
      height: root.height
      contentHeight: addValueColumn.height
      topMargin: pageAddValueHeader.height + units.gu(4)
      bottomMargin: Qt.inputMethod.visible
            ? Qt.inputMethod.keyboardRectangle.height + units.gu(4)
            : units.gu(4)

      Column {
        id: addValueColumn

        spacing: units.gu(2)
        width: parent.width

        Label {
          text: i18n.tr("Date")
          textSize: Label.Large
          color: settings.accentColor
        }

        DatePicker {
          id: addValueDatePicker

          anchors.horizontalCenter: parent.horizontalCenter

          minimum: {
            var d = new Date();
            d.setFullYear(d.getFullYear() -1);
            return d;
          }

          maximum: {
            var d = new Date();
            return d;
          }

          locale: Qt.locale()
        }

        Label {
          text: i18n.tr("Time")
          textSize: Label.Large
          color: settings.accentColor
        }

        DatePicker {
          id: addValueTimePicker

          anchors.horizontalCenter: parent.horizontalCenter

          mode: "Hours|Minutes|Seconds"
          locale: Qt.locale()
        }

        Label {
          text: i18n.tr(page)
          textSize: Label.Large
          color: settings.accentColor
        }

        TextField {
          id: addValueTextField
          width: parent.width

          inputMethodHints: Qt.ImhDigitsOnly
        }

        /*Row {
          spacing: units.gu(2)
          width: parent.width

          visible: page == "Steps"

          Label {
            text: "Adding all steps?"
            width: parent.width - allSteps.width - units.gu(2)
          }

          CheckBox {
            id: allSteps
            checked: true
          }
        }*/

        Button {
          width: parent.width
          text: i18n.tr("Add")
          color: theme.palette.normal.positive

          onClicked: !addValueDatePicker.moving && !addValueTimePicker.moving && addValueTextField.text != "" ?
                addValue(Qt.formatDate(addValueDatePicker.date, "yyyy-MM-dd"),
                Qt.formatTime(addValueTimePicker.date, "hh:mm:ss"),
                addValueTextField.text) : console.log("Not doing anything");
        }
        Button {
          width: parent.width
          text: i18n.tr("Cancel")

          onClicked: pageStatBottomEdge.collapse();
        }
      }
    }

    function addValue(d, t, val) {
      let newDate = new Date(d.split("-")[0], d.split("-")[1]-1, d.split("-")[2], t.split(":")[0], t.split(":")[1], t.split(":")[2]);

      DB.writeStats(page.replace(" ", "").toLowerCase(), [newDate.toISOString(), deviceObject.mac, val])
      statDetailsListModel.append({value: val, date: newDate.toLocaleString(), fullDate: newDate.toISOString()});

      pageStatBottomEdge.collapse();
    }
}
