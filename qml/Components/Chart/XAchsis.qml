import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property var values: []

  function createValues(parent) {
    //Console.log("Leparent " + parent);
    var xComponent = Qt.createComponent("xValue.qml");
    values.forEach((item, index) => {
      var xValue = xComponent.createObject(parent, {x: 0, y: 0, valueText: item});
    });
  }

  anchors {
    bottom: parent.bottom
  }

  height: units.gu(4)
  width: parent.width - units.gu(6)

  color: "transparent"

  Rectangle {
    id: xAchsisBorder

    anchors {
      right: parent.right
      bottom: xAchsis.top
      left: parent.left
    }

    height: 2

    color: "#5D5D5D"
  }

  Rectangle {
    id: xAchsis

    anchors {
      top: parent.top
    }

    height: units.gu(3)
    width: parent.width
    color: "transparent"

    Row {

      anchors {
        left: parent.left
        right: parent.right

      }

      height: units.gu(4)

      Component.onCompleted: {
        createValues(this)
      }
    }
  }
}
