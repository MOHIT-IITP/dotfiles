import QtQuick
import "../services"

// iOS-style switch used across the appearance panel.
Rectangle {
  id: root

  property bool on: false
  signal toggled

  width: 40
  height: 23
  radius: 11.5
  color: root.on ? SettingsState.accent : SettingsState.bgCard
  border.color: root.on ? Qt.darker(SettingsState.accent, 1.15) : SettingsState.borderBase
  border.width: 1

  Behavior on color {
    enabled: !SettingsState.reduceMotion
    ColorAnimation { duration: 180 }
  }

  Rectangle {
    width: 17
    height: 17
    radius: 8.5
    color: "#ffffff"
    anchors.verticalCenter: parent.verticalCenter
    x: root.on ? parent.width - width - 3 : 3

    Behavior on x {
      enabled: !SettingsState.reduceMotion
      NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}
