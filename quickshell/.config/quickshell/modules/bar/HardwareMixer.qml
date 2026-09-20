import Quickshell
import Quickshell.Io
import QtQuick
import "../services"

// Standalone centered Hardware Mixer card matching reference UI
// Toggled via Super+Ctrl+M or `qs ipc call mohiitp mixer`.
Rectangle {
  id: root

  readonly property bool open: MixerState.open
  readonly property real outVol: AudioState.outVol
  readonly property bool outMuted: AudioState.outMuted
  readonly property real inVol: AudioState.inVol
  readonly property bool inMuted: AudioState.inMuted

  implicitWidth: 440
  implicitHeight: open ? 360 : 0
  radius: 28
  clip: true

  color: SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1

  opacity: open ? 1 : 0
  visible: open || opacity > 0

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 180
    }
  }

  onOpenChanged: {
    if (open) {
      keyArea.focus = true;
      focusTimer.restart();
    }
  }

  Timer {
    id: focusTimer
    interval: 30
    repeat: false
    onTriggered: {
      keyArea.forceActiveFocus();
    }
  }

  function forceFocus() {
    keyArea.forceActiveFocus();
  }

  Item {
    id: keyArea
    anchors.fill: parent
    focus: true

    Keys.onEscapePressed: function (ev) {
      MixerState.close();
      ev.accepted = true;
    }
  }

  Column {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12

    // Header: [調 MIXER] ---------- [] [] [󰂛] [󰖔] [󰃟]
    Item {
      width: parent.width
      height: 36

      // Left: Japanese Kanji + Title
      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Japanese Kanji Glyph "調" (Tune / Mix)
        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "調"
          color: SettingsState.textMain
          font.pixelSize: 20
          font.bold: true
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "MIXER"
          color: SettingsState.textMain
          font.pixelSize: 15
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 2
        }
      }

      // Right: Pill Cluster of Quick Toggle Buttons
      Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 32
        width: toggleRow.implicitWidth + 8
        radius: 16
        color: SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: 1

        Row {
          id: toggleRow
          anchors.centerIn: parent
          spacing: 2

          // 1. Sound mute toggle
          Rectangle {
            width: 28
            height: 26
            radius: 13
            color: !outMuted ? SettingsState.bgActivePill : (sndBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: outMuted ? "sound-mute" : "sound"
              glyph: !outMuted ? SettingsState.textActive : (outMuted ? "#ff8a8a" : SettingsState.textSecondary)
            }
            MouseArea {
              id: sndBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: AudioState.toggleOutMute()
            }
          }

          // 2. Mic mute toggle
          Rectangle {
            width: 28
            height: 26
            radius: 13
            color: !inMuted ? SettingsState.bgActivePill : (micBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: inMuted ? "mic-mute" : "mic"
              glyph: !inMuted ? SettingsState.textActive : (inMuted ? "#ff8a8a" : SettingsState.textSecondary)
            }
            MouseArea {
              id: micBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: AudioState.toggleInMute()
            }
          }

          // 3. Notification DND toggle
          Rectangle {
            width: 28
            height: 26
            radius: 13
            color: NotifCenter.dnd ? SettingsState.bgActivePill : (dndBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: "bell-slash"
              glyph: NotifCenter.dnd ? SettingsState.textActive : SettingsState.textSecondary
            }
            MouseArea {
              id: dndBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: NotifCenter.toggleDnd()
            }
          }

          // 4. Nightlight toggle
          Rectangle {
            width: 28
            height: 26
            radius: 13
            color: NightlightState.active ? SettingsState.bgActivePill : (eyeBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: "sunset"
              glyph: NightlightState.active ? SettingsState.textActive : SettingsState.textSecondary
            }
            MouseArea {
              id: eyeBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: NightlightState.toggle()
            }
          }

          // 5. Brightness toggle
          Rectangle {
            width: 28
            height: 26
            radius: 13
            color: brBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: "sun"
              glyph: SettingsState.textSecondary
            }
            MouseArea {
              id: brBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: BrightnessState.setBrightness(BrightnessState.brightness > 0.4 ? 0.2 : 0.9)
            }
          }
        }
      }
    }

    // Divider
    Rectangle {
      width: parent.width
      height: 1
      color: SettingsState.borderBase
    }

    // 4 Vertical Faders Row (Matching Reference UI)
    Row {
      width: parent.width
      height: 270
      spacing: Math.max(8, Math.floor((parent.width - (4 * 80)) / 3))

      // 1. Brightness Fader
      VerticalFader {
        width: 80
        height: parent.height
        label: "Brightness"
        icon: "sun"
        value: BrightnessState.brightness
        activeColor: SettingsState.accent
        onSeeked: function (v) {
          BrightnessState.setBrightness(v);
        }
      }

      // 2. Display / Screen Backlight Fader
      VerticalFader {
        width: 80
        height: parent.height
        label: "Display"
        icon: "display"
        value: BrightnessState.brightness
        activeColor: SettingsState.accent
        onSeeked: function (v) {
          BrightnessState.setBrightness(v);
        }
      }

      // 3. Master Volume Fader
      VerticalFader {
        width: 80
        height: parent.height
        label: "Volume"
        icon: "sound"
        value: outVol
        muted: outMuted
        activeColor: SettingsState.accent
        onSeeked: function (v) {
          AudioState.setOutVol(v);
        }
        onIconClicked: AudioState.toggleOutMute()
      }

      // 4. Microphone Fader
      VerticalFader {
        width: 80
        height: parent.height
        label: "Microphone"
        icon: "mic"
        value: inVol
        muted: inMuted
        activeColor: SettingsState.accent
        onSeeked: function (v) {
          AudioState.setInVol(v);
        }
        onIconClicked: AudioState.toggleInMute()
      }
    }
  }
}
