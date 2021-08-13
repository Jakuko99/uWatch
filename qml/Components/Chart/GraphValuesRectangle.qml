import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
  property var values: []
  property int max: 0

  function calculateHeight(parentHeight, value) {
    var newPercent = value*100/max
    var newHeight = parentHeight * newPercent/100

    return newHeight - units.gu(1)
  }

  color: "transparent"

  Row {

    anchors {
      left: parent.left
      right: parent.right
    }

    height: parent.height

    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[0]) : 0
    }
    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[1]) : 0
    }
    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[2]) : 0
    }
    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[3]) : 0
    }
    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[4]) : 0
    }
    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[5]) : 0
    }
    GraphValues {
      rectangleHeight: values.length > 0 ? calculateHeight(parent.height, values[6]) : 0
    }
  }
}
