import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property string labelText: ""

  anchors {
    bottom: parent.bottom
    left: parent.left
    right: parent.right
    bottomMargin: units.gu(0.5)
  }

  height: parent.height / 2

  color: "transparent"

  Label {
    anchors.centerIn: parent

    height: parent.height/1.5

    text: labelText
  }
}
