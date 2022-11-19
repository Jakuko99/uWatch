import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
  property int max: 0

  anchors {
    left: parent.left
    top: graphHeader.bottom
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

      /*Component.onCompleted: {
        createValues(this);
      }*/

      YValue {
        valueText: Math.round(max)
      }

      YValue {
        valueText: Math.round(max/5*4)
      }

      YValue {
        valueText: Math.round(max/5*3)
      }

      YValue {
        valueText: Math.round(max/5*2)
      }

      YValue {
        valueText: Math.round(max/5)
      }
    }
  }
}
