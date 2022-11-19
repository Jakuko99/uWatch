import QtQuick 2.9
import Lomiri.Components 1.3

import "../../js/Helper.js" as Helper

Rectangle {
  id: graph
  property string title: ""
  property string page: ""
  property var values: []

  height: units.gu(35)

  color: "transparent"

  GraphHeader {
    id: graphHeader
    title: parent.title
    page: parent.page
  }

  YAchsis {
    id: graphyAchsis
    max: Helper.getMaxValue(values)
  }

  XAchsis {
    id: graphxAchsis
  }

  GraphValuesRectangle {
    id: graphValues

    anchors {
      left: graphyAchsis.right
      right: parent.right
      top: graphHeader.bottom
      bottom: graphxAchsis.top
    }

    values: parent.values
  }
}
