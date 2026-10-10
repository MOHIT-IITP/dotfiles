import QtQuick
import "../services"

// Calendar sub-page for the control center (both right circle and center pill).
// Shows the full dual-pane Weather + Calendar view with a back header.
Column {
  id: root
  required property var circle
  required property bool hovered
  spacing: 10
  opacity: (hovered && circle.activePage === "calendar") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation {
      duration: 220
    }
  }

  // Header with back button
  Item {
    width: parent.width
    height: 30

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Rectangle {
        width: 28
        height: 28
        radius: 14
        color: calBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
          font.family: SettingsState.nerdIconFont
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(22)
          font.bold: true
        }

        MouseArea {
          id: calBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: circle.activePage = "main"
        }
      }

      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "暦"
          color: calTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
          font.pixelSize: SettingsState.px(20)
          font.bold: true
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "CALENDAR"
          color: calTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
          font.pixelSize: SettingsState.px(17)
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }

    }

    MouseArea {
      id: calTitleMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: circle.activePage = "main"
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: CalendarState.city
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(12)
      font.bold: true
      font.family: SettingsState.fontFamily
      font.letterSpacing: 1.1
      elide: Text.ElideRight
      width: Math.min(140, implicitWidth)
    }
  }

  Rectangle {
    width: parent.width
    height: 1
    color: SettingsState.borderBase
  }

  WeatherCalendarView {
    width: parent.width
    height: 250
  }
}
