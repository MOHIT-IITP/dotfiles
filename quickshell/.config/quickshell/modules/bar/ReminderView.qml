import QtQuick
import "../services"

// Reminder list card (unused while now-playing lives in the center pill).
// Displays active countdowns with cancel/dismiss actions.
Column {
  id: root
  spacing: 8

  // ---- Header ----
  Row {
    width: parent.width
    height: 24
    spacing: 8

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 24
      height: 24
      radius: 12
      color: SettingsState.bgActivePill

      CCIcon {
        anchors.centerIn: parent
        width: 14
        height: 14
        kind: "bell"
        glyph: SettingsState.textSecondary
      }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - 32
      text: ReminderState.count > 0 ? ("Reminders · " + ReminderState.count) : "Reminders"
      color: SettingsState.textMain
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
      elide: Text.ElideRight
    }
  }

  // ---- Empty State ----
  Item {
    width: parent.width
    height: 36
    visible: ReminderState.count === 0

    Text {
      anchors.centerIn: parent
      text: "No active reminders"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(12)
      font.family: SettingsState.fontFamily
    }
  }

  // ---- Active list ----
  ListView {
    id: remList
    width: parent.width
    height: ReminderState.count > 0 ? Math.min(102, ReminderState.count * 34) : 0
    visible: ReminderState.count > 0
    spacing: 4
    clip: true
    model: ReminderState.reminders
    delegate: Rectangle {
      required property var modelData
      required property int index
      readonly property bool isFinished: Boolean(modelData && modelData.finished)
      width: remList.width
      height: 30
      radius: 9
      color: SettingsState.bgSurface
      border.color: SettingsState.borderBase
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 6
        spacing: 8

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - (isFinished ? 0 : (statusText.implicitWidth + 8)) - actionBtn.width - 24
          text: modelData ? modelData.title : ""
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(12)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
          maximumLineCount: 1
        }

        Text {
          id: statusText
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignRight
          visible: !isFinished
          text: modelData && !isFinished ? ReminderState.fmt(modelData.remainingSeconds) : ""
          color: SettingsState.accent
          font.pixelSize: SettingsState.px(12)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          id: actionBtn
          anchors.verticalCenter: parent.verticalCenter
          width: isFinished ? 54 : 22
          height: 22
          radius: 11
          color: isFinished ? (dismissMouse.containsMouse ? "#FF9E2C" : Qt.rgba(1.0, 0.62, 0.17, 0.2)) : (dismissMouse.containsMouse ? Qt.rgba(1.0, 0.62, 0.17, 0.28) : Qt.rgba(1.0, 0.62, 0.17, 0.16))
          border.color: Qt.rgba(1.0, 0.62, 0.17, 0.35)
          border.width: 1

          Behavior on color { ColorAnimation { duration: 150 } }

          Text {
            anchors.centerIn: parent
            visible: isFinished
            text: "Dismiss"
            color: dismissMouse.containsMouse ? (SettingsState.isDark ? "#121612" : "#ffffff") : "#FF9E2C"
            font.pixelSize: SettingsState.px(11)
            font.bold: true
            font.family: SettingsState.fontFamily

            SequentialAnimation on opacity {
              running: isFinished
              loops: Animation.Infinite
              NumberAnimation { from: 1.0; to: 0.3; duration: 500; easing.type: Easing.InOutSine }
              NumberAnimation { from: 0.3; to: 1.0; duration: 500; easing.type: Easing.InOutSine }
            }
          }

          CCIcon {
            anchors.centerIn: parent
            width: 12
            height: 12
            visible: !isFinished
            kind: "close"
            glyph: "#FF9E2C"
          }

          MouseArea {
            id: dismissMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (modelData) ReminderState.cancelReminder(modelData.id);
            }
          }
        }
      }
    }
  }
}
