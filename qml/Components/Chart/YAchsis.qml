import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property int max: 100

  function createValues(parent) {
    //Console.log("Leparent " + parent);
    var values = []
    var m = max/5
    for(var i = 5; i>0; i--) {
      values[i] = Math.round(m*i)
    }

    values.sort(function(a,b){return b-a});

    var component = Qt.createComponent("yValue.qml");
    values.forEach((item, index) => {
      var value = component.createObject(parent, {x: 0, y: 0, valueText: item});
    });
  }

  anchors {
    left: parent.left
  }

  width: units.gu(6)
  height: parent.height - units.gu(12)

  color: "transparent"

  Rectangle {
    id: yAchsisBorder

    anchors {
      top: parent.top
      bottom: parent.bottom
      left: yAchsis.right
    }

    width: 2

    color: "#5D5D5D"
  }

  Rectangle {
    id: yAchsis

    anchors {
      left: parent.left
    }

    width: units.gu(6)
    height: parent.height
    color: "transparent"

    Column {
      anchors.right: parent.right
      anchors.rightMargin: units.gu(1)

      height: parent.height
      width: parent.width

      Component.onCompleted: {
        createValues(this);
      }
    }
  }
}
