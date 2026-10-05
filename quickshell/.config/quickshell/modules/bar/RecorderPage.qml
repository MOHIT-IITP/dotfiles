import Quickshell
import QtQuick
import "../services"

// Screen recorder subview. Extracted from NetworkCircle.qml.
Column {
  id: recorderPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "recorder") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  // 1. Header: [‹] [録 RECORD] ---------------- [● RECORDING 00:15 / IDLE]
  Item {
    width: parent.width
    height: 32

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      // Back button
      Rectangle {
        width: 26
        height: 26
        radius: 13
        color: recBackMouse.containsMouse ? "#252b25" : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
            font.family: SettingsState.nerdIconFont
          color: "#f2f2f2"
          font.pixelSize: SettingsState.px(22)
          font.bold: true
        }

        MouseArea {
          id: recBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "main";
          }
        }
      }

      // Japanese Kanji Glyph "録" (Record)
      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: SettingsState.japaneseGlyphs
        text: "録"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(20)
        font.bold: true
      }

      // Title
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "RECORD"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 2
      }
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      // Still button
      Rectangle {
        height: 24
        width: stillSwitchRow.implicitWidth + 14
        radius: 12
        color: stillSwitchMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
        border.color: stillSwitchMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
        border.width: 1

        Row {
          id: stillSwitchRow
          anchors.centerIn: parent
          spacing: 4

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            kind: "camera"
            glyph: stillSwitchMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Still"
            color: stillSwitchMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        MouseArea {
          id: stillSwitchMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "screenshot";
            ScreenshotState.refreshLast();
          }
        }
      }

      // Right Status Badge
      Rectangle {
        height: 24
        width: recStatusRow.implicitWidth + 16
        radius: 12
        color: RecorderState.isRecording ? "#3a1b1b" : "#171c17"
        border.color: RecorderState.isRecording ? "#662c2c" : "#283028"
        border.width: 1

        Row {
          id: recStatusRow
          anchors.centerIn: parent
          spacing: 6

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: RecorderState.isRecording ? "#ff5252" : "#7ee2a8"

            SequentialAnimation on opacity {
              running: RecorderState.isRecording
              loops: Animation.Infinite
              NumberAnimation { to: 0.3; duration: 600 }
              NumberAnimation { to: 1.0; duration: 600 }
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: RecorderState.isRecording ? ("REC " + RecorderState.formattedTime) : "IDLE"
            color: RecorderState.isRecording ? "#ff8a8a" : "#7ee2a8"
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1
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

  // 2. Preset Frame Card with Corner Brackets
  Rectangle {
    width: parent.width
    height: 60
    radius: 12
    color: "#161b16"
    border.color: "#252c25"
    border.width: 1

    // Top-Left bracket: ⌜
    Text {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.margins: 4
      text: "⌜"
      color: "#e05f65"
      font.pixelSize: SettingsState.px(16)
      font.bold: true
    }
    // Top-Right bracket: ⌝
    Text {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 4
      text: "⌝"
      color: "#e05f65"
      font.pixelSize: SettingsState.px(16)
      font.bold: true
    }
    // Bottom-Left bracket: ⌞
    Text {
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.margins: 4
      text: "⌞"
      color: "#e05f65"
      font.pixelSize: SettingsState.px(16)
      font.bold: true
    }
    // Bottom-Right bracket: ⌟
    Text {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 4
      text: "⌟"
      color: "#e05f65"
      font.pixelSize: SettingsState.px(16)
      font.bold: true
    }

    Row {
      anchors.fill: parent
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      spacing: 12

      Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 3

        Row {
          spacing: 6
          Text {
            text: "Screen recorder"
            color: "#f2f2f2"
            font.pixelSize: SettingsState.px(15)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        Text {
          text: RecorderState.mode === "area" ? (RecorderState.areaGeometry !== "" ? ("• 60 fps • High quality • " + RecorderState.areaGeometry) : "• 60 fps • High quality • Select an area") : "• 60 fps • High quality • Fullscreen"
          color: "#8e998e"
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }
    }
  }

  // 2b. Capture Target: Fullscreen | Record area
  Row {
    width: parent.width
    height: 40
    spacing: 8

    // Fullscreen mode card
    Rectangle {
      width: (parent.width - 8) / 2
      height: 40
      radius: 12
      color: (RecorderState.mode === "fullscreen") ? "#223022" : (fullMouse.containsMouse ? "#1d241d" : "#161b16")
      border.color: (RecorderState.mode === "fullscreen") ? "#4a6b4a" : (fullMouse.containsMouse ? "#425842" : "#252c25")
      border.width: 1

      Row {
        anchors.centerIn: parent
        spacing: 8
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 15
          height: 15
          kind: "display"
          glyph: (RecorderState.mode === "fullscreen") ? "#7ee2a8" : SettingsState.textSecondary
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Fullscreen"
          color: (RecorderState.mode === "fullscreen") ? "#f2f2f2" : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: RecorderState.mode === "fullscreen"
          font.family: SettingsState.fontFamily
        }
      }

      MouseArea {
        id: fullMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: !RecorderState.isRecording
        onClicked: RecorderState.mode = "fullscreen"
      }
    }

    // Area mode card
    Rectangle {
      width: (parent.width - 8) / 2
      height: 40
      radius: 12
      color: (RecorderState.mode === "area") ? "#223022" : (areaRecMouse.containsMouse ? "#1d241d" : "#161b16")
      border.color: (RecorderState.mode === "area") ? "#4a6b4a" : (areaRecMouse.containsMouse ? "#425842" : "#252c25")
      border.width: 1

      Row {
        anchors.centerIn: parent
        spacing: 8
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 15
          height: 15
          kind: "area"
          glyph: (RecorderState.mode === "area") ? "#7ee2a8" : SettingsState.textSecondary
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Record area"
          color: (RecorderState.mode === "area") ? "#f2f2f2" : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: RecorderState.mode === "area"
          font.family: SettingsState.fontFamily
        }
      }

      MouseArea {
        id: areaRecMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: !RecorderState.isRecording
        onClicked: {
          RecorderState.mode = "area";
          if (RecorderState.areaGeometry === "" && !RecorderState.selectingArea) {
            RecorderState.selectArea(false);
          }
        }
      }
    }
  }

  // 2c. Area selection row (only in area mode)
  Rectangle {
    visible: RecorderState.mode === "area"
    width: parent.width
    height: RecorderState.mode === "area" ? 36 : 0
    radius: 12
    color: "#161b16"
    border.color: "#252c25"
    border.width: 1
    clip: true

    Row {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 6
      anchors.topMargin: 6
      anchors.bottomMargin: 6
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - selectAreaBtn.width - (clearAreaBtn.visible ? clearAreaBtn.width + 8 : 0) - 24
        text: RecorderState.selectingArea ? "Drag to select area..." : (RecorderState.areaGeometry !== "" ? ("◈ " + RecorderState.areaGeometry) : "No area selected")
        color: RecorderState.areaGeometry !== "" ? "#7ee2a8" : "#8e998e"
        font.pixelSize: SettingsState.px(13)
        font.family: "monospace"
        elide: Text.ElideRight
      }

      Rectangle {
        id: clearAreaBtn
        visible: RecorderState.areaGeometry !== "" && !RecorderState.isRecording
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: clearAreaTxt.implicitWidth + 14
        radius: 12
        color: clearAreaMouse.containsMouse ? "#322222" : "#221a1a"
        border.color: "#382525"
        border.width: 1

        Text {
          id: clearAreaTxt
          anchors.centerIn: parent
          text: "\uea76"
          color: "#ff8a8a"
          font.family: SettingsState.nerdIconFont
          font.pixelSize: SettingsState.px(12)
          font.bold: true
        }

        MouseArea {
          id: clearAreaMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: RecorderState.clearArea()
        }
      }

      Rectangle {
        id: selectAreaBtn
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: selectAreaTxt.implicitWidth + 16
        radius: 12
        color: RecorderState.selectingArea ? "#223022" : (selAreaMouse.containsMouse ? "#2a3a2a" : "#1e2a1e")
        border.color: "#4a6b4a"
        border.width: 1

        Text {
          id: selectAreaTxt
          anchors.centerIn: parent
          text: RecorderState.selectingArea ? "..." : (RecorderState.areaGeometry !== "" ? "RESELECT" : "SELECT")
          color: "#7ee2a8"
          font.pixelSize: SettingsState.px(12)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: selAreaMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: !RecorderState.isRecording && !RecorderState.selectingArea
          onClicked: RecorderState.selectArea(false)
        }
      }
    }
  }

  // 3. Main Record Pill Button
  Rectangle {
    width: parent.width
    height: 48
    radius: 24
    color: RecorderState.isRecording ? "#3d1818" : (recBtnMouse.containsMouse ? "#242e24" : "#1b231b")
    border.color: RecorderState.isRecording ? "#ff5252" : (recBtnMouse.containsMouse ? "#425842" : "#2d382d")
    border.width: 1.5

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Row {
      anchors.centerIn: parent
      spacing: 10

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: 12
        color: RecorderState.isRecording ? "#ff5252" : "#e05f65"

        Rectangle {
          anchors.centerIn: parent
          width: RecorderState.isRecording ? 10 : 8
          height: RecorderState.isRecording ? 10 : 8
          radius: RecorderState.isRecording ? 2 : 4
          color: "#ffffff"
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: RecorderState.isRecording ? ("Stop recording (" + RecorderState.formattedTime + ")") : (RecorderState.selectingArea ? "Select area on screen..." : ((RecorderState.mode === "area" && RecorderState.areaGeometry === "") ? "Select area & record" : "Start recording"))
        color: RecorderState.isRecording ? "#ff8a8a" : "#f2f2f2"
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        font.family: SettingsState.fontFamily
      }
    }

    MouseArea {
      id: recBtnMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: RecorderState.toggle()
    }
  }

  // 4. Audio Controls Section (Dual Compact Horizontal Faders + Mic Selector Dropdown)
  Rectangle {
    width: parent.width
    height: 84 + (circle.recMicDropdownOpen ? (Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) + 8) : 0)
    radius: 14
    color: "#161b16"
    border.color: "#252c25"
    border.width: 1
    clip: true

    Behavior on height {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Column {
      anchors.fill: parent
      anchors.margins: 10
      spacing: 6

      // Microphone track + Device selector dropdown chip
      Row {
        width: parent.width
        height: 28
        spacing: 8

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 24
          height: 24
          radius: 12
          color: AudioState.inMuted ? (SettingsState.isDark ? "#2a1e1e" : "#ffebeb") : SettingsState.bgCard
          CCIcon {
            anchors.centerIn: parent
            width: 12
            height: 12
            kind: "mic"
            glyph: AudioState.inMuted ? "#ff8a8a" : SettingsState.accent
          }
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: AudioState.toggleInMute()
          }
        }

        // Microphone dropdown selector pill button
        Rectangle {
          id: rMicDevChip
          anchors.verticalCenter: parent.verticalCenter
          height: 24
          width: Math.min(150, rMicDevRow.implicitWidth + 16)
          radius: 12
          color: circle.recMicDropdownOpen ? SettingsState.bgActivePill : (rMicDevMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
          border.color: circle.recMicDropdownOpen ? SettingsState.borderActive : (rMicDevMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
          border.width: 1
          clip: true

          Row {
            id: rMicDevRow
            anchors.centerIn: parent
            spacing: 4

            Text {
              text: AudioState.sourceName
              color: circle.recMicDropdownOpen ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(13)
              font.bold: true
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
              width: Math.min(implicitWidth, 110)
            }

            Text {
              text: circle.recMicDropdownOpen ? "\ueab7" : "\ueab4"
              color: SettingsState.textSecondary
              font.family: SettingsState.nerdIconFont
              font.pixelSize: SettingsState.px(10)
            }
          }

          MouseArea {
            id: rMicDevMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              AudioState.refreshDevices();
              circle.recMicDropdownOpen = !circle.recMicDropdownOpen;
            }
          }
        }

        // Slider bar
        Rectangle {
          id: micBar
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 24 - 8 - rMicDevChip.width - 8 - 38 - 8
          height: 10
          radius: 5
          color: SettingsState.bgCardHover
          clip: true

          Rectangle {
            height: parent.height
            width: Math.max(parent.height, parent.width * (AudioState.inMuted ? 0 : AudioState.inVol))
            radius: parent.radius
            color: AudioState.inMuted ? SettingsState.borderBase : SettingsState.accent
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: ev => AudioState.setInVol(Math.min(1, Math.max(0, ev.x / parent.width)))
            onPositionChanged: ev => {
              if (pressed) AudioState.setInVol(Math.min(1, Math.max(0, ev.x / parent.width)))
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 38
          text: AudioState.inMuted ? "Mute" : (Math.round(AudioState.inVol * 100) + "%")
          color: AudioState.inMuted ? "#ff8a8a" : SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
          horizontalAlignment: Text.AlignRight
        }
      }

      // Expanded Microphone Device Dropdown List
      ListView {
        visible: circle.recMicDropdownOpen
        width: parent.width
        height: circle.recMicDropdownOpen ? Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) : 0
        clip: true
        spacing: 4
        model: AudioState.sources

        delegate: Rectangle {
          width: ListView.view.width
          height: 40
          radius: 10
          color: modelData.isDefault ? SettingsState.bgActivePill : (mPickMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
          border.color: modelData.isDefault ? SettingsState.borderActive : (mPickMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 14
              height: 14
              kind: "mic"
              glyph: modelData.isDefault ? SettingsState.accent : SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 48
              text: modelData.description || modelData.name || "Microphone"
              color: modelData.isDefault ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(13)
              font.bold: modelData.isDefault
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              visible: modelData.isDefault
              text: "\ueab2"
                font.family: SettingsState.nerdIconFont
              color: SettingsState.isDark ? "#121612" : "#ffffff"
              font.pixelSize: SettingsState.px(14)
              font.bold: true
            }
          }

          MouseArea {
            id: mPickMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              AudioState.setDefaultSource(modelData);
              circle.recMicDropdownOpen = false;
            }
          }
        }
      }

      // Desktop audio track
      Row {
        width: parent.width
        height: 28
        spacing: 8

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 24
          height: 24
          radius: 12
          color: AudioState.outMuted ? (SettingsState.isDark ? "#2a1e1e" : "#ffebeb") : SettingsState.bgCard
          CCIcon {
            anchors.centerIn: parent
            width: 12
            height: 12
            kind: "sound"
            glyph: AudioState.outMuted ? "#ff8a8a" : SettingsState.accent
          }
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: AudioState.toggleOutMute()
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 72
          text: "Desktop"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }

        // Slider bar
        Rectangle {
          id: deskBar
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 152
          height: 10
          radius: 5
          color: SettingsState.bgCardHover
          clip: true

          Rectangle {
            height: parent.height
            width: Math.max(parent.height, parent.width * (AudioState.outMuted ? 0 : AudioState.outVol))
            radius: parent.radius
            color: AudioState.outMuted ? SettingsState.borderBase : SettingsState.accent
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: ev => AudioState.setOutVol(Math.min(1, Math.max(0, ev.x / parent.width)))
            onPositionChanged: ev => {
              if (pressed) AudioState.setOutVol(Math.min(1, Math.max(0, ev.x / parent.width)))
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 38
          text: AudioState.outMuted ? "Mute" : (Math.round(AudioState.outVol * 100) + "%")
          color: AudioState.outMuted ? "#ff8a8a" : SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
          horizontalAlignment: Text.AlignRight
        }
      }
    }
  }

  // 5. Save Destination Row
  Rectangle {
    width: parent.width
    height: 34
    radius: 12
    color: SettingsState.bgCard
    border.color: SettingsState.borderBase
    border.width: 1

    Row {
      anchors.left: parent.left
      anchors.leftMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      CCIcon {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        kind: "folder"
        glyph: SettingsState.textSecondary
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "SAVE TO"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(12)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 1
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "~/Videos/Recordings"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(13)
        font.family: SettingsState.fontFamily
      }
    }

    Rectangle {
      anchors.right: parent.right
      anchors.rightMargin: 6
      anchors.verticalCenter: parent.verticalCenter
      height: 22
      width: openBtnText.implicitWidth + 14
      radius: 11
      color: openDirMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgSurface
      border.color: SettingsState.borderBase
      border.width: 1

      Text {
        id: openBtnText
        anchors.centerIn: parent
        text: "OPEN"
        color: SettingsState.accent
        font.pixelSize: SettingsState.px(12)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      MouseArea {
        id: openDirMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: RecorderState.openDir()
      }
    }
  }

  // 6. Recent Recordings Header
  Item {
    width: parent.width
    height: 22

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "録"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(15)
        font.bold: true
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "RECENT • " + (RecorderState.recentRecordings ? RecorderState.recentRecordings.length : 0)
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(13)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 1
      }
    }

    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 20
      width: clearRecText.implicitWidth + 12
      radius: 10
      visible: RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0
      color: clearRecMouse.containsMouse ? "#322222" : "#221a1a"
      border.color: clearRecMouse.containsMouse ? "#553030" : "#382525"
      border.width: 1

      Text {
        id: clearRecText
        anchors.centerIn: parent
        text: "払 CLEAR"
        color: "#ff8a8a"
        font.pixelSize: SettingsState.px(12)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      MouseArea {
        id: clearRecMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: RecorderState.clearAll()
      }
    }
  }

  // Recent recordings list
  Text {
    visible: !RecorderState.recentRecordings || RecorderState.recentRecordings.length === 0
    text: "No recent recordings"
    color: SettingsState.textMuted
    font.pixelSize: SettingsState.px(14)
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  ListView {
    id: recList
    width: parent.width
    height: (RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0) ? Math.min(180, RecorderState.recentRecordings.length * 60) : 0
    spacing: 6
    clip: true
    visible: RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0
    model: RecorderState.recentRecordings

    delegate: Rectangle {
      id: recCard
      width: ListView.view.width
      height: 54
      radius: 12
      color: recCardMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
      border.color: recCardMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 10

        // Video thumbnail box with play icon
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 46
          height: 38
          radius: 8
          color: recCardMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgSurface
          border.color: SettingsState.borderBase
          border.width: 1

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "play"
            glyph: recCardMouse.containsMouse ? "#e05f65" : SettingsState.accent
          }
        }

        // Details column
        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 60
          spacing: 2

          Text {
            width: parent.width
            text: modelData.name || "Recording"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Row {
            spacing: 8
            Text {
              text: modelData.date || ""
              color: SettingsState.textSecondary
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
            }
            Text {
              text: "•"
                font.family: SettingsState.nerdIconFont
              color: SettingsState.textMuted
              font.pixelSize: SettingsState.px(13)
            }
            Text {
              text: modelData.size || ""
              color: SettingsState.accent
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
            }
          }
        }
      }

      MouseArea {
        id: recCardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          RecorderState.play(modelData.path);
        }
      }
    }
  }
}
