import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import QtCharts 2.0

import "./Chart"

Item {
  property string title: ""
  property string page: ""
  property var values: []

  width: parent.width
  height: graph.height

  Graph {
    id: graph

    title: parent.title
    page: parent.page

    width: parent.width

    values: parent.values
  }
}
