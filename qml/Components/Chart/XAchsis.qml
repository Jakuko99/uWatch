import QtQuick 2.9
import Lomiri.Components 1.3
import "../../js/Helper.js" as Helper

Rectangle {
  property var values: Helper.getWeek("short")

  anchors {
    bottom: parent.bottom
    left: graphyAchsis.right
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

      XValue {
        valueText: values.length > 0 ? values[0] : ""
      }

      XValue {
        valueText: values.length > 0 ? values[1] : ""
      }

      XValue {
        valueText: values.length > 0 ? values[2] : ""
      }
      XValue {
        valueText: values.length > 0 ? values[3] : ""
      }
      XValue {
        valueText: values.length > 0 ? values[4] : ""
      }
      XValue {
        valueText: values.length > 0 ? values[5] : ""
      }
      XValue {
        valueText: values.length > 0 ? values[6] : ""
      }
    }
  }
}
