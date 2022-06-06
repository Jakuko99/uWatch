import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property int rectangleHeight: units.gu(5)

  height: parent.height
  width: parent.width/7

  color: "transparent"

  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 2

    height: rectangleHeight
    width: parent.width/3

    color: root.accentColor
  }
}
