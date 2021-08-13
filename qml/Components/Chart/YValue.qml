import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property string valueText: ""

  height: parent.height/5
  width: parent.width

  color: "transparent"

  Label {
    anchors.right: parent.right

    text: valueText
  }
}
