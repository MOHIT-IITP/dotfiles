import QtQuick
import "../services"

// Calendar sub-page for the control center — no header, swipe-right to go back
Column {
  id: root
  required property var circle
  required property bool hovered
  spacing: 0
  opacity: (hovered && circle.activePage === "calendar") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    enabled: circle.opacity > 0.5
    NumberAnimation {
      duration: 220
    }
  }

  Item {
    width: parent.width
    height: 160

    WeatherCalendarView {
      id: weatherCalView
      anchors.fill: parent
    }
  }
}
