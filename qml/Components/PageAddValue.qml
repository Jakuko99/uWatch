import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Components.Themes 1.3

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
          color: root.accentColor
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
          color: root.accentColor
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
          color: root.accentColor
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

    function addValue(date, time, value) {
      let action = ""
      switch(page) {
        case "Heart rate":
          action = "insertHeartRate";
          break;
        case "Steps":
          action = "insertSteps";
          break;
        default:
          action = "none";
          break;
      }

      let random = Math.floor(Math.random() * 10000) + 1000;

      if (action != "none") {
        python.call('uwatch.' + action, [deviceMAC, date + "T" + time + "." + random, value], function(result) {

        })
      }
      pageStatBottomEdge.collapse();
    }
}
