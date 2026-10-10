import Quickshell
import QtQuick
import QtQuick.Effects
import "../services"

// Standalone circular pill on the left of the bar for active reminders.
// Shows an animated countdown ring, center bell icon, and finished alert animation.
// Clicking toggles the center bar's reminder view; hovering reveals remaining time.
Rectangle {
  id: root

  property var clockPill: null

  readonly property bool active: ReminderState.count > 0
  readonly property bool hovered: mouseArea.containsMouse

  implicitWidth: 30
  implicitHeight: 30
  width: 30
  height: 30
  radius: 15

  visible: opacity > 0.01
  opacity: active ? 1.0 : 0.0
  scale: active ? 1.0 : 0.6

  Behavior on opacity {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  Behavior on scale {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutBack
    }
  }

  color: SettingsState.bgCard
  border.color: SettingsState.barBorder
  border.width: 1

  // Visual container for pulse animation when a reminder has finished
  Item {
    id: contentWrap
    anchors.fill: parent

    SequentialAnimation on opacity {
      running: ReminderState.hasFinished
      loops: Animation.Infinite
      NumberAnimation {
        from: 1.0
        to: 0.35
        duration: 500
        easing.type: Easing.InOutSine
      }
      NumberAnimation {
        from: 0.35
        to: 1.0
        duration: 500
        easing.type: Easing.InOutSine
      }
    }

    // Countdown ring canvas
    Canvas {
      id: ringCanvas
      anchors.fill: parent
      antialiasing: true
      renderStrategy: Canvas.Immediate

      property real animProgress: ReminderState.soonestProgress

      Behavior on animProgress {
        NumberAnimation {
          duration: 950
          easing.type: Easing.Linear
        }
      }

      onAnimProgressChanged: requestPaint()
      Component.onCompleted: requestPaint()

      Connections {
        target: ReminderState
        function onRemindersChanged() { ringCanvas.requestPaint(); }
        function onSoonestProgressChanged() { ringCanvas.requestPaint(); }
        function onSoonestRemainingChanged() { ringCanvas.requestPaint(); }
        function onSoonestFinishedChanged() { ringCanvas.requestPaint(); }
        function onHasFinishedChanged() { ringCanvas.requestPaint(); }
      }

      Connections {
        target: SettingsState
        function onIsDarkChanged() { ringCanvas.requestPaint(); }
      }

      onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        var cx = width / 2;
        var cy = height / 2;
        ctx.lineWidth = 2.4;
        ctx.lineCap = "round";
        var r = 10.5;

        // 1. Muted Track
        ctx.strokeStyle = SettingsState.isDark ? "#3a2a1a" : "#ffd4a8";
        ctx.beginPath();
        ctx.arc(cx, cy, r, 0, Math.PI * 2);
        ctx.stroke();

        // 2. Active Orange Progress Arc
        if (ReminderState.count > 0) {
          var p = ReminderState.soonestFinished ? 1.0 : Math.min(1.0, Math.max(0.0, animProgress));
          var displayP = Math.max(0.04, p);
          var a0 = -Math.PI / 2;
          var a1 = a0 + Math.PI * 2 * displayP;
          ctx.strokeStyle = "#FF9E2C";
          ctx.beginPath();
          ctx.arc(cx, cy, r, a0, a1);
          ctx.stroke();
        }
      }
    }


  }

  // Interactive mouse area
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        if (ReminderState.hasFinished) {
          ReminderState.dismissAllFinished();
        } else {
          ReminderState.togglePrompt();
        }
      } else {
        if (root.clockPill && typeof root.clockPill.toggleReminders === "function") {
          root.clockPill.toggleReminders();
        } else if (root.clockPill) {
          root.clockPill.isReminderView = !root.clockPill.isReminderView;
        } else {
          ReminderState.togglePrompt();
        }
      }
    }
  }


}
