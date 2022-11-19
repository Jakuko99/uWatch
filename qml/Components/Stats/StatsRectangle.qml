import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
  property string icon: ""
  property string text: ""

  height: parent.height
  width: parent.width / 4

  color: "transparent"

  StatsIcon {
    iconName: parent.icon
  }

  StatsLabel {
    labelText: parent.text
  }
}
