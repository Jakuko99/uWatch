import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property var values: []
  property int max: 0

  function createValues(parent) {
    var component = Qt.createComponent("GraphValues.qml");

    values.forEach((item, index) => {
      var newPercent = item*100/max
      var newHeight = parent.height * newPercent/100

      var value = component.createObject(parent, {x: 0, y: 0, rectangleHeight: newHeight - units.gu(0.5)});
    });
  }

  color: "transparent"

  Row {

    anchors {
      left: parent.left
      right: parent.right
    }

    height: parent.height

    Component.onCompleted: {
      createValues(this)
    }
  }
}
