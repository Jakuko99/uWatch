import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
  property string iconName: ""

  anchors {
    top: parent.top
    left: parent.left
    right: parent.right
    topMargin: units.gu(0.5)
  }

  height: parent.height / 2

  color: "transparent"

  Icon {
    anchors.centerIn: parent

    height: parent.height/1.5

    name: iconName
  }
}
