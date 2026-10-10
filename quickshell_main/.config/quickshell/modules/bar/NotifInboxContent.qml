import Quickshell
import QtQuick
import "../services"

// Embedded Notification Inbox view directly inside ClockPill.
// Opened via keybind (`qs ipc call mohiitp notifInbox`, Super+Ctrl+N).
// Lists full notification history with DND toggle + clear-all, like other center views.
Item {
  id: root

  implicitWidth: 460
  // Small when empty, grows as notifications arrive (capped so it never
  // takes over the screen). ClockPill uses this +36 for its own height.
  implicitHeight: inboxCol.implicitHeight + 36

  // Approx card height (CCNotifCard) + spacing; list capped at ~4 cards.
  readonly property int maxListHeight: 248
  readonly property int listHeight: NotifCenter.count > 0 ? Math.min(maxListHeight, NotifCenter.count * 56 + Math.max(0, NotifCenter.count - 1) * 6) : 0

  function forceFocus() {
    keyArea.focus = true;
    keyArea.forceActiveFocus();
  }

  Connections {
    target: NotifCenter
    function onInboxOpenChanged() {
      if (NotifCenter.inboxOpen) {
        forceFocus();
        focusTimer.restart();
      } else {
        focusTimer.stop();
      }
    }
  }

  Timer {
    id: focusTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      root.forceFocus();
      if (keyArea.activeFocus || count > 8 || !NotifCenter.inboxOpen) {
        running = false;
      }
    }
  }

  Item {
    id: keyArea
    anchors.fill: parent
    focus: true

    Keys.onEscapePressed: function (ev) {
      NotifCenter.closeInbox();
      ev.accepted = true;
    }
  }

  Column {
    id: inboxCol
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: 16
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    spacing: 12

    // ---- Header ----
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "通"
          color: SettingsState.accent
          font.pixelSize: SettingsState.px(17)
          font.bold: true
          visible: SettingsState.japaneseGlyphs
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "INBOX"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1.2
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: NotifCenter.count + " total"
          color: SettingsState.textMuted
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // DND toggle
        Rectangle {
          width: 32
          height: 28
          radius: 14
          color: NotifCenter.dnd ? SettingsState.bgActivePill : (dndMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
          border.color: NotifCenter.dnd ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: "moon"
            glyph: NotifCenter.dnd ? SettingsState.textActive : SettingsState.textSecondary
          }

          MouseArea {
            id: dndMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: NotifCenter.toggleDnd()
          }
        }

        // Clear all
        Rectangle {
          height: 28
          width: clearText.implicitWidth + 20
          radius: 14
          color: NotifCenter.count > 0 ? (clearMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard) : "transparent"
          border.color: NotifCenter.count > 0 ? SettingsState.borderBase : "transparent"
          border.width: 1

          Text {
            id: clearText
            anchors.centerIn: parent
            text: "Clear all"
            color: NotifCenter.count > 0 ? SettingsState.accent : SettingsState.textMuted
            font.pixelSize: SettingsState.px(12)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: NotifCenter.count > 0
            onClicked: NotifCenter.clearAll()
          }
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: SettingsState.borderBase
    }

    Text {
      visible: NotifCenter.count === 0
      text: "No notifications"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(13)
      font.family: SettingsState.fontFamily
      topPadding: 8
    }

    ListView {
      width: parent.width
      height: root.listHeight
      clip: true
      spacing: 6
      visible: NotifCenter.count > 0
      model: NotifCenter.trackedList
      delegate: CCNotifCard {
      }
    }
  }

  // Bottom margin for the height flow
  Item {
    anchors.top: inboxCol.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 14
  }
}
