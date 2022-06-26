import QtQuick 2.9
import Ubuntu.Components 1.3

import "../../js/Helper.js" as Helper

Rectangle {
  id: graphValuesRectangle
  property var values: []

  function calculateHeight(parentHeight, value) {
    var newPercent = value*100/Helper.getMaxValue(values)
    var newHeight = parentHeight * newPercent/100

    return newHeight - units.gu(1)
  }

  color: "transparent"

  Row {
    id: valuesRow
    anchors.fill: parent

    Component.onCompleted: {
      for(let i = 0; i < values.length; i++) {
        let component = Qt.createComponent("GraphValues.qml");
        let obj = component.createObject(valuesRow, {x: 100, y: 100, rectangleHeight: calculateHeight(graphValuesRectangle.height, values[i])});
        if (obj == null) {
            // Error Handling
            console.log("Error creating object");
        }
      }
    }
  }
}
