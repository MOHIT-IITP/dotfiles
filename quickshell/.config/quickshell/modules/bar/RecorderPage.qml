import QtQuick
import "../services"

// Screen recorder subview — restyled to match dark reference:
// thin header, bracket frame, tan highlights, pill start button,
// bar-style audio meters.
Column {
  id: recorderPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "recorder") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    enabled: circle.opacity > 0.5
    NumberAnimation { duration: 220 }
  }

  readonly property color tan: "#c9a87a"
  readonly property color dimBar: "#4b455e"
  readonly property color cardSoft: SettingsState.isDark ? "#2b2b31" : "#e9e9ec"
  readonly property color cardSofter: SettingsState.isDark ? "#2e2e34" : "#e2e2e6"
  readonly property color lineSoft: SettingsState.isDark ? "#34343a" : "#d5d5da"
  readonly property color bracketCol: SettingsState.isDark ? "#55555c" : "#aaaaaa"

  // 1. Header: ‹ RECORD ......... Still  ● IDLE
  Item {
    width: parent.width
    height: 30

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Item {
        width: 22
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        Text {
          anchors.centerIn: parent
          text: "‹"
          color: recBackMouse.containsMouse ? SettingsState.textMain : "#8a8a8a"
          font.pixelSize: SettingsState.px(22)
          font.family: SettingsState.fontFamily
          font.weight: Font.Light
        }
        MouseArea {
          id: recBackMouse
          anchors.fill: parent
          anchors.margins: -4
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: circle.activePage = "main"
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "RECORD"
        color: SettingsState.accent
        font.pixelSize: SettingsState.px(14)
        font.family: SettingsState.fontFamily
        font.letterSpacing: 2
        font.weight: Font.DemiBold
      }
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 14

      // Still link
      Item {
        width: stillRow.implicitWidth + 8
        height: 24
        Row {
          id: stillRow
          anchors.centerIn: parent
          spacing: 5
          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 13
            height: 13
            kind: "camera"
            glyph: stillSwitchMouse.containsMouse ? SettingsState.textMain : "#8a8a8a"
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Still"
            color: stillSwitchMouse.containsMouse ? SettingsState.textMain : "#8a8a8a"
            font.pixelSize: SettingsState.px(13)
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

      // Status: green dot + IDLE / red + time
      Item {
        width: statusRow.implicitWidth
        height: 24
        Row {
          id: statusRow
          anchors.centerIn: parent
          spacing: 6
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: RecorderState.isRecording ? "#e05f65" : "#4ade80"
            SequentialAnimation on opacity {
              running: RecorderState.isRecording
              loops: Animation.Infinite
              NumberAnimation { to: 0.3; duration: 600 }
              NumberAnimation { to: 1.0; duration: 600 }
            }
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: RecorderState.isRecording ? RecorderState.formattedTime : "IDLE"
            color: RecorderState.isRecording ? "#ff8a8a" : "#8a8a8a"
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1.5
          }
        }
      }
    }
  }

  // 2. Bracket frame title + settings dropdown (fps · quality · cursor · countdown)
  Item {
    width: parent.width
    height: headerRow.height + (RecorderState.settingsExpanded ? settingsCol.height + 10 : 0) + 16

    // corner brackets — thin L shapes
    Item { // top-left
      anchors.left: parent.left
      anchors.top: parent.top
      width: 16; height: 16
      Rectangle { width: 16; height: 1.5; color: bracketCol }
      Rectangle { width: 1.5; height: 16; color: bracketCol }
    }
    Item { // top-right
      anchors.right: parent.right
      anchors.top: parent.top
      width: 16; height: 16
      Rectangle { anchors.right: parent.right; width: 16; height: 1.5; color: bracketCol }
      Rectangle { anchors.right: parent.right; width: 1.5; height: 16; color: bracketCol }
    }
    Item { // bottom-left
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      width: 16; height: 16
      Rectangle { anchors.bottom: parent.bottom; width: 16; height: 1.5; color: bracketCol }
      Rectangle { anchors.bottom: parent.bottom; width: 1.5; height: 16; color: bracketCol }
    }
    Item { // bottom-right
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      width: 16; height: 16
      Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 16; height: 1.5; color: bracketCol }
      Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 1.5; height: 16; color: bracketCol }
    }

    Column {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.topMargin: 8
      anchors.leftMargin: 20
      anchors.rightMargin: 20
      spacing: 10

      // Header row (tap to expand/collapse)
      Item {
        id: headerRow
        width: parent.width
        height: 58
        Column {
          anchors.left: parent.left
          anchors.right: chevText.left
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 3
          Text {
            text: "Screen recorder"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(18)
            font.family: SettingsState.fontFamily
            font.weight: Font.DemiBold
          }
          Text {
            text: "● " + RecorderState.summaryText + (RecorderState.mode === "area" && RecorderState.areaGeometry !== "" ? " · " + RecorderState.areaGeometry : "")
            color: SettingsState.isDark ? "#9a8a75" : "#7a6a55"
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            width: parent.width
          }
        }
        Text {
          id: chevText
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: RecorderState.settingsExpanded ? "\ueab7" : "\ueab4"
          color: dropMouse.containsMouse ? SettingsState.textMain : "#8a8a8a"
          font.family: SettingsState.nerdIconFont
          font.pixelSize: SettingsState.px(16)
        }
        MouseArea {
          id: dropMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: !RecorderState.isRecording && !RecorderState.starting
          onClicked: RecorderState.settingsExpanded = !RecorderState.settingsExpanded
        }
      }

      // Expanded settings (matches reference: frame rate · quality · cursor · countdown)
      Column {
        id: settingsCol
        visible: RecorderState.settingsExpanded
        width: parent.width
        spacing: 0

        // Frame rate row
        Item {
          width: parent.width
          height: 34
          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Frame rate"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
          }
          Row {
            anchors.right: parent.right
            y: (parent.height - height) / 2
            spacing: 2
            Repeater {
              model: RecorderState.fpsOptions
              delegate: Rectangle {
                height: 26
                width: fpsTxt.implicitWidth + 16
                radius: 8
                color: RecorderState.fps === modelData ? cardSofter : "transparent"
                Text {
                  id: fpsTxt
                  anchors.centerIn: parent
                  text: String(modelData)
                  color: RecorderState.fps === modelData ? SettingsState.textMain : "#8a8a8a"
                  font.pixelSize: SettingsState.px(13)
                  font.family: SettingsState.fontFamily
                  font.weight: RecorderState.fps === modelData ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  enabled: !RecorderState.isRecording && !RecorderState.starting
                  onClicked: RecorderState.fps = modelData
                }
              }
            }
          }
        }

        Rectangle { width: parent.width; height: 1; color: lineSoft; opacity: 0.5 }

        // Quality row
        Item {
          width: parent.width
          height: 34
          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Quality"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
          }
          Row {
            anchors.right: parent.right
            y: (parent.height - height) / 2
            spacing: 2
            Repeater {
              model: RecorderState.qualityOptions
              delegate: Rectangle {
                height: 26
                width: qTxt.implicitWidth + 16
                radius: 8
                color: RecorderState.quality === modelData ? cardSofter : "transparent"
                Text {
                  id: qTxt
                  anchors.centerIn: parent
                  text: RecorderState.qualityLabel(modelData)
                  color: RecorderState.quality === modelData ? SettingsState.textMain : "#8a8a8a"
                  font.pixelSize: SettingsState.px(13)
                  font.family: SettingsState.fontFamily
                  font.weight: RecorderState.quality === modelData ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  enabled: !RecorderState.isRecording && !RecorderState.starting
                  onClicked: RecorderState.quality = modelData
                }
              }
            }
          }
        }

        Rectangle { width: parent.width; height: 1; color: lineSoft; opacity: 0.5 }

        // Capture cursor row
        Item {
          width: parent.width
          height: 36
          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Capture cursor"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
          }
          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 24
            radius: 12
            color: RecorderState.captureCursor ? "#b07a2a" : dimBar
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              x: RecorderState.captureCursor ? parent.width - width - 3 : 3
              width: 18
              height: 18
              radius: 9
              color: RecorderState.captureCursor ? "#1c1c1c" : "#8a8a8a"
              Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              enabled: !RecorderState.isRecording && !RecorderState.starting
              onClicked: RecorderState.captureCursor = !RecorderState.captureCursor
            }
          }
        }

        Rectangle { width: parent.width; height: 1; color: lineSoft; opacity: 0.5 }

        // Countdown row
        Item {
          width: parent.width
          height: 34
          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Countdown"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
          }
          Row {
            anchors.right: parent.right
            y: (parent.height - height) / 2
            spacing: 2
            Repeater {
              model: RecorderState.countdownOptions
              delegate: Rectangle {
                height: 26
                width: cdTxt.implicitWidth + 16
                radius: 8
                color: RecorderState.countdown === modelData ? cardSofter : "transparent"
                Text {
                  id: cdTxt
                  anchors.centerIn: parent
                  text: modelData === 0 ? "Off" : (String(modelData) + "s")
                  color: RecorderState.countdown === modelData ? SettingsState.textMain : "#8a8a8a"
                  font.pixelSize: SettingsState.px(13)
                  font.family: SettingsState.fontFamily
                  font.weight: RecorderState.countdown === modelData ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  enabled: !RecorderState.isRecording && !RecorderState.starting
                  onClicked: RecorderState.countdown = modelData
                }
              }
            }
          }
        }
      }
    }
  }

  // 3. Start / target picker (tap Start → Screen | Window/Region)
  // 3a. Idle start pill
  Rectangle {
    visible: !RecorderState.isRecording && !RecorderState.starting && !RecorderState.choosingTarget
    width: parent.width
    height: 50
    radius: 25
    color: cardSoft
    Row {
      anchors.left: parent.left
      anchors.leftMargin: 20
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        radius: 7
        color: "#c95f5f"
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Start recording"
        color: SettingsState.isDark ? "#d5d5d5" : "#333333"
        font.pixelSize: SettingsState.px(15)
        font.family: SettingsState.fontFamily
      }
    }
    Text {
      anchors.right: parent.right
      anchors.rightMargin: 20
      anchors.verticalCenter: parent.verticalCenter
      text: "tap"
      color: "#8a8a8a"
      font.pixelSize: SettingsState.px(13)
      font.family: SettingsState.fontFamily
    }
    MouseArea {
      id: recBtnMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: RecorderState.requestStart()
    }
  }

  // 3b. Countdown pill (tap to cancel)
  Rectangle {
    visible: RecorderState.starting && !RecorderState.isRecording
    width: parent.width
    height: 50
    radius: 25
    color: cardSoft
    border.color: "#b07a2a"
    border.width: 1.5
    Row {
      anchors.centerIn: parent
      spacing: 10
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        radius: 7
        color: "#b07a2a"
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Starting in " + RecorderState.countdownLeft + "s… (tap to cancel)"
        color: SettingsState.isDark ? "#d5d5d5" : "#333333"
        font.pixelSize: SettingsState.px(15)
        font.family: SettingsState.fontFamily
      }
    }
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: RecorderState.cancelPending()
    }
  }

  // 3c. Stop pill while recording
  Rectangle {
    visible: RecorderState.isRecording
    width: parent.width
    height: 50
    radius: 25
    color: cardSoft
    border.color: "#e05f65"
    border.width: 1.5
    Row {
      anchors.centerIn: parent
      spacing: 10
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        radius: 7
        color: "#c95f5f"
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Stop recording (" + RecorderState.formattedTime + ")"
        color: SettingsState.isDark ? "#d5d5d5" : "#333333"
        font.pixelSize: SettingsState.px(15)
        font.family: SettingsState.fontFamily
      }
    }
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: RecorderState.toggle()
    }
  }

  // 3d. Target picker (Screen | Window/Region) after tapping Start
  Row {
    visible: RecorderState.choosingTarget && !RecorderState.isRecording && !RecorderState.starting
    width: parent.width
    height: 46
    spacing: 10

    Rectangle {
      width: (parent.width - 10) / 2
      height: 46
      radius: 12
      color: cardSofter
      border.color: lineSoft
      border.width: 1
      Row {
        anchors.centerIn: parent
        spacing: 8
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 16
          height: 16
          kind: "display"
          glyph: tan
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Screen"
          color: tan
          font.pixelSize: SettingsState.px(14)
          font.family: SettingsState.fontFamily
          font.weight: Font.DemiBold
        }
      }
      MouseArea {
        id: fullMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: RecorderState.startScreen()
      }
    }

    Rectangle {
      width: (parent.width - 10) / 2
      height: 46
      radius: 12
      color: cardSofter
      border.color: lineSoft
      border.width: 1
      Row {
        anchors.centerIn: parent
        spacing: 8
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 16
          height: 16
          kind: "area"
          glyph: tan
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Window / Region"
          color: tan
          font.pixelSize: SettingsState.px(14)
          font.family: SettingsState.fontFamily
          font.weight: Font.DemiBold
        }
      }
      MouseArea {
        id: areaRecMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: RecorderState.startAreaFlow()
      }
    }
  }

  // 3e. Area picker strip (Window/Region mode: click a window or drag a region)
  Rectangle {
    visible: RecorderState.choosingTarget && RecorderState.mode === "area" && !RecorderState.isRecording && !RecorderState.starting
    width: parent.width
    height: 36
    radius: 10
    color: "transparent"
    border.color: "#2c2c31"
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
        width: parent.width - selectAreaBtn.width - (clearAreaBtn.visible ? clearAreaBtn.width + 8 : 0) - backTxt.implicitWidth - 32
        text: RecorderState.selectingArea ? "Click a window or drag a region..." : (RecorderState.areaGeometry !== "" ? ("◈ " + RecorderState.areaGeometry) : "Click a window or drag to select")
        color: RecorderState.areaGeometry !== "" ? tan : SettingsState.textMuted
        font.pixelSize: SettingsState.px(12)
        font.family: "monospace"
        elide: Text.ElideRight
      }
      Rectangle {
        id: clearAreaBtn
        visible: RecorderState.areaGeometry !== ""
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: 30
        radius: 12
        color: "transparent"
        border.color: "#3a2a2a"
        border.width: 1
        Text {
          anchors.centerIn: parent
          text: "\uea76"
          color: "#ff8a8a"
          font.family: SettingsState.nerdIconFont
          font.pixelSize: SettingsState.px(12)
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
        color: cardSofter
        border.color: lineSoft
        border.width: 1
        Text {
          id: selectAreaTxt
          anchors.centerIn: parent
          text: RecorderState.selectingArea ? "..." : (RecorderState.areaGeometry !== "" ? "RESELECT" : "SELECT")
          color: tan
          font.pixelSize: SettingsState.px(11)
          font.bold: true
          font.family: SettingsState.fontFamily
        }
        MouseArea {
          id: selAreaMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: !RecorderState.selectingArea
          onClicked: RecorderState.selectArea(false)
        }
      }
      Text {
        id: backTxt
        anchors.verticalCenter: parent.verticalCenter
        text: "‹ Back"
        color: "#8a8a8a"
        font.pixelSize: SettingsState.px(12)
        font.family: SettingsState.fontFamily
        MouseArea {
          anchors.fill: parent
          anchors.margins: -6
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            RecorderState.choosingTarget = false;
            RecorderState.mode = "fullscreen";
          }
        }
      }
    }
  }

  // 5. Audio meters — borderless rows with bar visualizer
  Column {
    width: parent.width
    spacing: 2

    // Mic row
    Item {
      width: parent.width
      height: 36
      Row {
        anchors.fill: parent
        spacing: 8
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 15
          height: 15
          kind: "mic"
          glyph: tan
        }
        // device name + chevron (dropdown trigger)
        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: 128
          height: 24
          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: AudioState.sourceName
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
              width: 108
            }
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: circle.recMicDropdownOpen ? "\ueab7" : "\ueab4"
              color: "#777777"
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
        // bars (click/drag to set mic vol)
        Item {
          id: micBars
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 15 - 8 - 128 - 8 - 44 - 8
          height: 24
          readonly property int count: 20
          readonly property var heights: [7, 12, 16, 9, 14, 19, 12, 8, 15, 21, 16, 11, 7, 13, 18, 12, 8, 14, 10, 6]

          // Tick track exactly spanning the bar row, so the Ame bead can ride
          // the fill edge (mirrors the wavy sliders' bead anchor).
          Item {
            id: micTickTrack
            anchors.centerIn: parent
            width: micBars.count * 3 + (micBars.count - 1) * 3
            height: parent.height

            Row {
              anchors.fill: parent
              spacing: 3
              Repeater {
                model: micBars.count
                delegate: Rectangle {
                  anchors.verticalCenter: parent.verticalCenter
                  width: 3
                  height: micBars.heights[index] !== undefined ? micBars.heights[index] : 10
                  radius: 1.5
                  color: {
                    if (AudioState.inMuted) return dimBar;
                    var frac = (index + 1) / micBars.count;
                    return frac <= AudioState.inVol ? tan : dimBar;
                  }
                }
              }
            }
          }

          // Fill-edge fraction (0..1) of the lit bars, for the bead tick.
          function tickFrac(vol) {
            var v = Math.max(0, Math.min(1, vol));
            var lit = Math.floor(micBars.count * v + 1e-9);
            var edge = lit <= 0 ? 0 : lit * 6 - 3;
            return micTickTrack.width > 0 ? Math.max(0, Math.min(1, edge / micTickTrack.width)) : 0;
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onContainsMouseChanged: {
              if (containsMouse)
                AmeState.followTickH(micTickTrack, micBars.tickFrac(AudioState.inVol));
            }
            onPressed: function (ev) {
              var v = Math.min(1, Math.max(0, ev.x / width));
              AudioState.setInVol(v);
              AmeState.followTickH(micTickTrack, micBars.tickFrac(v));
            }
            onPositionChanged: function (ev) {
              if (!pressed) return;
              var v = Math.min(1, Math.max(0, ev.x / width));
              AudioState.setInVol(v);
              AmeState.followTickH(micTickTrack, micBars.tickFrac(v));
            }
          }
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 44
          horizontalAlignment: Text.AlignRight
          text: AudioState.inMuted ? "Mute" : (Math.round(AudioState.inVol * 100) + "%")
          color: "#8a8a8a"
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }
    }

    // Mic device dropdown
    ListView {
      visible: circle.recMicDropdownOpen
      width: parent.width
      height: circle.recMicDropdownOpen ? Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 40) : 0
      clip: true
      spacing: 4
      model: AudioState.sources
      delegate: Rectangle {
        width: ListView.view.width
        height: 36
        radius: 10
        color: modelData.isDefault ? cardSofter : (mPickMouse.containsMouse ? cardSoft : "transparent")
        border.color: lineSoft
        border.width: 1
        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8
          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 13
            height: 13
            kind: "mic"
            glyph: modelData.isDefault ? tan : SettingsState.textSecondary
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 48
            text: modelData.description || modelData.name || "Microphone"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: modelData.isDefault
            text: "\ueab2"
            font.family: SettingsState.nerdIconFont
            color: tan
            font.pixelSize: SettingsState.px(13)
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

    // Desktop row
    Item {
      width: parent.width
      height: 36
      Row {
        anchors.fill: parent
        spacing: 8
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 15
          height: 15
          kind: "sound"
          glyph: tan
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 128
          text: "Desktop"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
        Item {
          id: deskBars
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 15 - 8 - 128 - 8 - 44 - 8
          height: 24
          readonly property int count: 20
          readonly property var heights: [6, 10, 14, 11, 9, 13, 17, 12, 8, 12, 16, 13, 9, 12, 15, 18, 14, 10, 12, 9]

          // Tick track exactly spanning the bar row (see micBars).
          Item {
            id: deskTickTrack
            anchors.centerIn: parent
            width: deskBars.count * 3 + (deskBars.count - 1) * 3
            height: parent.height

            Row {
              anchors.fill: parent
              spacing: 3
              Repeater {
                model: deskBars.count
                delegate: Rectangle {
                  anchors.verticalCenter: parent.verticalCenter
                  width: 3
                  height: deskBars.heights[index] !== undefined ? deskBars.heights[index] : 10
                  radius: 1.5
                  color: {
                    if (AudioState.outMuted) return dimBar;
                    var frac = (index + 1) / deskBars.count;
                    return frac <= AudioState.outVol ? tan : dimBar;
                  }
                }
              }
            }
          }

          // Fill-edge fraction (0..1) of the lit bars, for the bead tick.
          function tickFrac(vol) {
            var v = Math.max(0, Math.min(1, vol));
            var lit = Math.floor(deskBars.count * v + 1e-9);
            var edge = lit <= 0 ? 0 : lit * 6 - 3;
            return deskTickTrack.width > 0 ? Math.max(0, Math.min(1, edge / deskTickTrack.width)) : 0;
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onContainsMouseChanged: {
              if (containsMouse)
                AmeState.followTickH(deskTickTrack, deskBars.tickFrac(AudioState.outVol));
            }
            onPressed: function (ev) {
              var v = Math.min(1, Math.max(0, ev.x / width));
              AudioState.setOutVol(v);
              AmeState.followTickH(deskTickTrack, deskBars.tickFrac(v));
            }
            onPositionChanged: function (ev) {
              if (!pressed) return;
              var v = Math.min(1, Math.max(0, ev.x / width));
              AudioState.setOutVol(v);
              AmeState.followTickH(deskTickTrack, deskBars.tickFrac(v));
            }
          }
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 44
          horizontalAlignment: Text.AlignRight
          text: AudioState.outMuted ? "Mute" : (Math.round(AudioState.outVol * 100) + "%")
          color: "#8a8a8a"
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }
    }
  }

  // 6. Save destination (minimal)
  Rectangle {
    width: parent.width
    height: 34
    radius: 10
    color: "transparent"
    border.color: "#2c2c31"
    border.width: 1
    Row {
      anchors.left: parent.left
      anchors.leftMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8
      CCIcon {
        anchors.verticalCenter: parent.verticalCenter
        width: 13
        height: 13
        kind: "folder"
        glyph: "#8a8a8a"
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "~/Videos/Recordings"
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(12)
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
      color: openDirMouse.containsMouse ? cardSofter : "transparent"
      border.color: lineSoft
      border.width: 1
      Text {
        id: openBtnText
        anchors.centerIn: parent
        text: "OPEN"
        color: tan
        font.pixelSize: SettingsState.px(11)
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

  // 7. Recent recordings (minimal)
  Item {
    width: parent.width
    height: 20
    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: "RECENT • " + (RecorderState.recentRecordings ? RecorderState.recentRecordings.length : 0)
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(11)
      font.family: SettingsState.fontFamily
      font.letterSpacing: 1.5
    }
    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      visible: RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0
      text: "CLEAR"
      color: "#ff8a8a"
      font.pixelSize: SettingsState.px(11)
      font.bold: true
      font.family: SettingsState.fontFamily
      MouseArea {
        id: clearRecMouse
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: RecorderState.clearAll()
      }
    }
  }

  Text {
    visible: !RecorderState.recentRecordings || RecorderState.recentRecordings.length === 0
    text: "No recent recordings"
    color: SettingsState.textMuted
    font.pixelSize: SettingsState.px(12)
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  ListView {
    id: recList
    width: parent.width
    height: (RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0) ? Math.min(150, RecorderState.recentRecordings.length * 52) : 0
    spacing: 6
    clip: true
    visible: RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0
    model: RecorderState.recentRecordings
    delegate: Rectangle {
      id: recCard
      width: ListView.view.width
      height: 46
      radius: 10
      color: recCardMouse.containsMouse ? cardSoft : "transparent"
      border.color: lineSoft
      border.width: 1
      Row {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 10
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 40
          height: 32
          radius: 8
          color: cardSofter
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: "play"
            glyph: recCardMouse.containsMouse ? "#e05f65" : tan
          }
        }
        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 54
          spacing: 2
          Text {
            width: parent.width
            text: modelData.name || "Recording"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(12)
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
          Row {
            spacing: 8
            Text {
              text: modelData.date || ""
              color: SettingsState.textSecondary
              font.pixelSize: SettingsState.px(11)
              font.family: SettingsState.fontFamily
            }
            Text {
              text: modelData.size || ""
              color: tan
              font.pixelSize: SettingsState.px(11)
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
        onClicked: RecorderState.play(modelData.path)
      }
    }
  }
}
