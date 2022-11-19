import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
  property string valueText: ""

  height: parent.height
  width: parent.width/7

  color: "transparent"

  Label {
    anchors.centerIn: parent

    text: valueText
  }
}
