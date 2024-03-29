import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
  property string title: ""
  property string page: ""

  anchors {
    left: parent.left
    right: parent.right
  }

  height: units.gu(8)

  color: "transparent"

  Label {
    anchors.verticalCenter: parent.verticalCenter

    text: title
    textSize: Label.Large
    color: settings.accentColor
  }

  Button {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter

    width: units.gu(4)

    iconName: "go-next"
    color: "transparent"

    onClicked: pageStack.push(Qt.resolvedUrl("../../Pages/StatDetails.qml"), {page: page, deviceObject})
  }
}
