import Quickshell
import QtQuick
import "../services"

// Hardware mixer subview. Extracted from NetworkCircle.qml.
Column {
  id: mixerPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "mixer") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  // Mixer Header: [‹] [調 MIXER] ---------- [] [] [󰂛] [󰖔] [󰃟] []
  Item {
    width: parent.width
    height: 36

    // Left: Back button + Japanese Kanji + Title
    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      // Back button
      Rectangle {
        width: 26
        height: 26
        radius: 13
        color: mixerBackMouse.containsMouse ? "#252b25" : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\uf053"
            font.family: SettingsState.nerdIconFont
          color: "#f2f2f2"
          font.pixelSize: SettingsState.px(22)
          font.bold: true
        }

        MouseArea {
          id: mixerBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "main";
          }
        }
      }

      // Japanese Kanji Glyph "調" (Tune / Mix)
      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: SettingsState.japaneseGlyphs
        text: "調"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(20)
        font.bold: true
      }

      // Title
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "MIXER"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 2
      }
    }

    // Right: Pill Cluster of 6 Quick Toggle Buttons matching reference UI
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
          color: !circle.outMuted ? SettingsState.bgActivePill : (sndBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: circle.outMuted ? "sound-mute" : "sound"
            glyph: !circle.outMuted ? SettingsState.textActive : (circle.outMuted ? "#ff8a8a" : SettingsState.textSecondary)
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
          color: !circle.inMuted ? SettingsState.bgActivePill : (micBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: circle.inMuted ? "mic-mute" : "mic"
            glyph: !circle.inMuted ? SettingsState.textActive : (circle.inMuted ? "#ff8a8a" : SettingsState.textSecondary)
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
            kind: "moon"
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
          color: brBtnMouse.containsMouse ? "#222822" : "transparent"
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: "sun"
            glyph: "#9aa39a"
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
    color: "#252b25"
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
      activeColor: "#e05f65"
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
      activeColor: "#e05f65"
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
      value: circle.outVol
      muted: circle.outMuted
      activeColor: "#e05f65"
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
      value: circle.inVol
      muted: circle.inMuted
      activeColor: "#e05f65"
      onSeeked: function (v) {
        AudioState.setInVol(v);
      }
      onIconClicked: AudioState.toggleInMute()
    }
  }
}
