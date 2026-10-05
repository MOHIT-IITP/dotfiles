import QtQuick
import "../services"

// Segmented pill group used across the appearance panel.
// options: array of { label, value }.
Row {
  id: root

  property var options: []
  property var current
  signal picked(var value)

  spacing: 2

  Repeater {
    model: root.options
    delegate: Rectangle {
      readonly property bool isCur: {
        if (typeof modelData.value === "number")
          return Math.abs(Number(root.current) - modelData.value) < 0.015;
        return root.current === modelData.value;
      }

      width: segText.implicitWidth + 14
      height: 24
      radius: 8
      color: isCur ? SettingsState.bgActivePill : "transparent"
      border.color: isCur ? SettingsState.borderActive : "transparent"
      border.width: 1

      Behavior on color {
        enabled: !SettingsState.reduceMotion
        ColorAnimation { duration: 150 }
      }

      Text {
        id: segText
        anchors.centerIn: parent
        text: modelData.label
        color: isCur ? SettingsState.textActive : SettingsState.textMuted
        font.pixelSize: SettingsState.px(13)
        font.bold: isCur
        font.family: SettingsState.fontFamily
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.picked(modelData.value)
      }
    }
  }
}
