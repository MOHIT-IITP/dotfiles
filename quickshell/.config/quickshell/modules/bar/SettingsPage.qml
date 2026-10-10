import Quickshell
import QtQuick
import "../services"
import "WavySliderPaint.js" as WavyPaint

// Settings / appearance expanded subview. Extracted from NetworkCircle.qml.
// Top level shows three folders (General / UI / Theme); tapping one drills
// into its controls. Back navigates up one level, then to the main page.
Item {
  id: settingsPage
  required property var circle
  required property bool hovered
  implicitHeight: settingsCol.implicitHeight
  opacity: (hovered && circle.activePage === "settings") ? 1 : 0
  visible: opacity > 0

  function forceFocusFontSearch() {
    if (fontPicker) fontPicker.forceSearchFocus();
  }

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  // Fixed Header
  Item {
    id: setHeader
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 32
    z: 10

    Item {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: titleRow.implicitWidth + 8

      Row {
        id: titleRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: circle.settingsSub === "general" ? "般" : (circle.settingsSub === "ui" ? "面" : (circle.settingsSub === "theme" ? "色" : "相"))
          color: titleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
          font.pixelSize: SettingsState.px(20)
          font.bold: true
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: circle.settingsSub === "general" ? "GENERAL" : (circle.settingsSub === "ui" ? "UI" : (circle.settingsSub === "theme" ? "THEME" : "CONFIG"))
          color: titleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
          font.pixelSize: SettingsState.px(16)
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1.5
        }
      }

      MouseArea {
        id: titleMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (circle.settingsSub !== "") {
            circle.fontDropdownOpen = false;
            circle.settingsSub = "";
          } else {
            circle.fontDropdownOpen = false;
            circle.activePage = "main";
          }
        }
      }
    }

    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: 26
      height: 26
      radius: 13
      color: setBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

      Text {
        anchors.centerIn: parent
        text: "\ueab5"
          font.family: SettingsState.nerdIconFont
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(22)
        font.bold: true
      }

      MouseArea {
        id: setBackMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (circle.settingsSub !== "") {
            circle.fontDropdownOpen = false;
            circle.settingsSub = "";
          } else {
            circle.fontDropdownOpen = false;
            circle.activePage = "main";
          }
        }
      }
    }
  }

  // Scrollable Settings Content
  Flickable {
    anchors.top: setHeader.bottom
    anchors.topMargin: 8
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    clip: true
    contentHeight: settingsCol.implicitHeight + 4
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: settingsCol
      width: parent.width
      spacing: 0

      // Divider
      Rectangle {
        width: parent.width
        height: 1
        color: SettingsState.borderBase
      }

      Item {
        width: parent.width
        height: 8
      }

      // ============ FOLDER LIST: General / UI / Theme ============
      Column {
        width: parent.width
        spacing: 8
        visible: circle.settingsSub === ""
        height: visible ? implicitHeight : 0

        Repeater {
          model: [
            { key: "general", title: "General", desc: "Time, glyphs, visualizer", icon: "gear" },
            { key: "ui", title: "UI", desc: "Scale, gap, auto-hide, wallpaper", icon: "display" },
            { key: "theme", title: "Theme", desc: "Light, dark, manual, accent", icon: "palette" }
          ]

          delegate: Rectangle {
            width: settingsCol.width
            height: 52
            radius: 12
            color: folderMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
            border.color: folderMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 12
              spacing: 10

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 10
                color: SettingsState.bgActivePill

                CCIcon {
                  anchors.centerIn: parent
                  width: 16
                  height: 16
                  kind: modelData.icon
                  glyph: SettingsState.accent
                }
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 32 - 10 - 16 - 20
                spacing: 2

                Text {
                  width: parent.width
                  text: modelData.title
                  color: SettingsState.textMain
                  font.pixelSize: SettingsState.px(15)
                  font.bold: true
                  font.family: SettingsState.fontFamily
                }

                Text {
                  width: parent.width
                  text: modelData.desc
                  color: SettingsState.textSecondary
                  font.pixelSize: SettingsState.px(13)
                  font.family: SettingsState.fontFamily
                  elide: Text.ElideRight
                }
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\ueab6"
                  font.family: SettingsState.nerdIconFont
                color: SettingsState.textMuted
                font.pixelSize: SettingsState.px(16)
              }
            }

            MouseArea {
              id: folderMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: circle.settingsSub = modelData.key
            }
          }
        }
      }

      // ============ GENERAL: time, seconds, glyphs, visualizer ============
      Column {
        width: parent.width
        spacing: 8
        visible: circle.settingsSub === "general"
        height: visible ? implicitHeight : 0

        // 1. Time format: (time icon) Time format -> [24H] [12H]
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "time"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Time format"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Rectangle {
              width: 44
              height: 24
              radius: 6
              color: SettingsState.timeFormat === "24h" ? SettingsState.bgActivePill : "transparent"
              border.color: SettingsState.timeFormat === "24h" ? SettingsState.borderActive : "transparent"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "24H"
                color: SettingsState.timeFormat === "24h" ? SettingsState.textActive : SettingsState.textMuted
                font.pixelSize: SettingsState.px(13)
                font.bold: true
                font.family: SettingsState.fontFamily
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: SettingsState.setTimeFormat("24h")
              }
            }

            Rectangle {
              width: 44
              height: 24
              radius: 6
              color: SettingsState.timeFormat === "12h" ? SettingsState.bgActivePill : "transparent"
              border.color: SettingsState.timeFormat === "12h" ? SettingsState.borderActive : "transparent"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "12H"
                color: SettingsState.timeFormat === "12h" ? SettingsState.textActive : SettingsState.textMuted
                font.pixelSize: SettingsState.px(13)
                font.bold: true
                font.family: SettingsState.fontFamily
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: SettingsState.setTimeFormat("12h")
              }
            }
          }
        }

        // 2. Clock seconds: (stopwatch) Clock seconds -> toggle
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "stopwatch"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Clock seconds"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 20
            radius: 10
            color: SettingsState.clockSeconds ? SettingsState.accent : SettingsState.bgCard

            Behavior on color { ColorAnimation { duration: 180 } }

            Rectangle {
              width: 14
              height: 14
              radius: 7
              color: "#ffffff"
              anchors.verticalCenter: parent.verticalCenter
              x: SettingsState.clockSeconds ? parent.width - width - 3 : 3

              Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: SettingsState.toggleClockSeconds()
            }
          }
        }

        // 3. Japanese glyphs: (wave) Japanese glyphs -> toggle
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "wave"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Japanese glyphs"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 20
            radius: 10
            color: SettingsState.japaneseGlyphs ? SettingsState.accent : SettingsState.bgCard

            Behavior on color { ColorAnimation { duration: 180 } }

            Rectangle {
              width: 14
              height: 14
              radius: 7
              color: "#ffffff"
              anchors.verticalCenter: parent.verticalCenter
              x: SettingsState.japaneseGlyphs ? parent.width - width - 3 : 3

              Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: SettingsState.toggleJapaneseGlyphs()
            }
          }
        }

        // 4. Music visualizer: (music) Music visualizer -> toggle
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "music"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Music visualizer"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 20
            radius: 10
            color: SettingsState.musicVisualizer ? SettingsState.accent : SettingsState.bgCard

            Behavior on color { ColorAnimation { duration: 180 } }

            Rectangle {
              width: 14
              height: 14
              radius: 7
              color: "#ffffff"
              anchors.verticalCenter: parent.verticalCenter
              x: SettingsState.musicVisualizer ? parent.width - width - 3 : 3

              Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: SettingsState.toggleMusicVisualizer()
            }
          }
        }
      }

      // ============ UI: wallpaper, scale, gap, font ============
      Column {
        width: parent.width
        spacing: 8
        visible: circle.settingsSub === "ui"
        height: visible ? implicitHeight : 0

        // 6. Wallpaper folder
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "wallpaper"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Wallpaper folder"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            radius: 6
            color: wallPickMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "wallpaper"
              glyph: SettingsState.textActive
            }

            MouseArea {
              id: wallPickMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: WallpaperState.toggle()
            }
          }
        }

        // 6b. Auto-hide bar: slide away until the cursor hits the top edge
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "eye"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Auto-hide bar"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 20
            radius: 10
            color: SettingsState.barAutoHide ? SettingsState.accent : SettingsState.bgCard

            Behavior on color { ColorAnimation { duration: 180 } }

            Rectangle {
              width: 14
              height: 14
              radius: 7
              color: "#ffffff"
              anchors.verticalCenter: parent.verticalCenter
              x: SettingsState.barAutoHide ? parent.width - width - 3 : 3

              Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: SettingsState.toggleBarAutoHide()
            }
          }
        }

        // 7. UI scale: labels 90% | 100% | 110% | 125% | 135% map to 1.35x effective (100% -> 1.35 look)
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "scale"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "UI scale"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Repeater {
              model: [
                { label: "90%", val: 0.9 * 1.35 },
                { label: "100%", val: 1.0 * 1.35 },
                { label: "110%", val: 1.1 * 1.35 },
                { label: "125%", val: 1.25 * 1.35 },
                { label: "135%", val: 1.35 * 1.35 }
              ]
              delegate: Rectangle {
                width: sText.implicitWidth + 12
                height: 22
                radius: 6
                color: Math.abs(SettingsState.uiScale - modelData.val) < 0.01 ? SettingsState.bgActivePill : "transparent"
                border.color: Math.abs(SettingsState.uiScale - modelData.val) < 0.01 ? SettingsState.borderActive : "transparent"
                border.width: 1

                Text {
                  id: sText
                  anchors.centerIn: parent
                  text: modelData.label
                  color: Math.abs(SettingsState.uiScale - modelData.val) < 0.01 ? SettingsState.textActive : SettingsState.textMuted
                  font.pixelSize: SettingsState.px(13)
                  font.family: SettingsState.fontFamily
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: SettingsState.setUiScale(modelData.val)
                }
              }
            }
          }
        }

        // 7b. Gap Slider (Bar window gap below)
        Column {
          width: parent.width
          spacing: 6

          Item {
            width: parent.width
            height: 24

            Row {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: 10

              CCIcon {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                kind: "area"
                glyph: SettingsState.textSecondary
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Bar gap"
                color: SettingsState.textMain
                font.pixelSize: SettingsState.px(15)
                font.family: SettingsState.fontFamily
              }
            }

            Rectangle {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              height: 20
              width: gapValText.implicitWidth + 12
              radius: 6
              color: SettingsState.bgCard
              border.color: SettingsState.borderBase
              border.width: 1

              Text {
                id: gapValText
                anchors.centerIn: parent
                text: Math.round(gapTrack.shown * 24) + "px"
                color: SettingsState.accent
                font.pixelSize: SettingsState.px(13)
                font.bold: true
                font.family: SettingsState.fontFamily
              }
            }
          }

          // Wavy Slider Track with 5 waves and smooth seek animation
          Item {
            id: gapTrack
            width: parent.width
            height: 24

            readonly property real targetFraction: Math.min(1.0, Math.max(0.0, SettingsState.barGap / 24.0))
            property real currentPos: targetFraction
            readonly property real shown: Math.min(1.0, Math.max(0.0, currentPos))

            onTargetFractionChanged: {
              if (!seekAnim.running && !gapMouse.dragging) {
                currentPos = targetFraction;
              }
            }

            onShownChanged: gapCanvas.requestPaint()
            onCurrentPosChanged: gapCanvas.requestPaint()
            onWidthChanged: gapCanvas.requestPaint()

            NumberAnimation {
              id: seekAnim
              target: gapTrack
              property: "currentPos"
              duration: 350
              easing.type: Easing.InOutCubic
              onRunningChanged: gapCanvas.requestPaint()
              onFinished: {
                if (!gapMouse.dragging) {
                  gapTrack.currentPos = gapTrack.targetFraction;
                  gapCanvas.requestPaint();
                }
              }
            }

            Canvas {
              id: gapCanvas
              anchors.fill: parent
              antialiasing: true
              renderStrategy: Canvas.Immediate
              onPaint: {
                WavyPaint.paint(getContext("2d"), width, height, {
                  shown: gapTrack.shown,
                  showTrack: true,
                  showHandle: true,
                  showRemaining: false,
                  waveColor: SettingsState.accent,
                  trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3",
                  handleColor: SettingsState.accent,
                  trackH: 5,
                  waveW: 4.5,
                  waveAmp: 2.2,
                  waveLen: width / 5, // Exactly 5 waves across full width
                  handleW: 6,
                  handleH: 16
                });
              }
            }

            Connections {
              target: SettingsState
              function onAccentChanged() { gapCanvas.requestPaint(); }
              function onIsDarkChanged() { gapCanvas.requestPaint(); }
            }

            MouseArea {
              id: gapMouse
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor

              property real startX: 0
              property bool dragging: false

              onPressed: function(ev) {
                if (gapTrack.width <= 0) return;
                gapMouse.startX = ev.x;
                gapMouse.dragging = false;

                var startVal = gapTrack.currentPos;
                var r = Math.min(1.0, Math.max(0.0, ev.x / gapTrack.width));

                // Smoothly animate from exact current position to clicked target
                seekAnim.stop();
                gapTrack.currentPos = startVal;
                seekAnim.from = startVal;
                seekAnim.to = r;
                seekAnim.restart();

                SettingsState.setBarGap(Math.round(r * 24));
              }

              onPositionChanged: function(ev) {
                if (!pressed || gapTrack.width <= 0) return;
                if (!gapMouse.dragging && Math.abs(ev.x - gapMouse.startX) > 4) {
                  gapMouse.dragging = true;
                  seekAnim.stop();
                }
                if (gapMouse.dragging) {
                  var r = Math.min(1.0, Math.max(0.0, ev.x / gapTrack.width));
                  gapTrack.currentPos = r;
                  gapCanvas.requestPaint();
                  SettingsState.setBarGap(Math.round(r * 24));
                }
              }

              onReleased: function() {
                gapMouse.dragging = false;
              }
            }
          }
        }

        CCFontPicker {
          id: fontPicker
          width: parent.width
          circle: settingsPage.circle
        }
      }

      // ============ THEME: mode, spectrum, accent, hex ============
      Column {
        width: parent.width
        spacing: 8
        visible: circle.settingsSub === "theme"
        height: visible ? implicitHeight : 0

        // 5. THEME SECTION (Matching Reference UI)
        Item {
          width: parent.width
          height: 30

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "palette"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Theme"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.family: SettingsState.fontFamily
            }
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Repeater {
              model: ["Light", "Dark", "Manual"]
              delegate: Rectangle {
                width: tText.implicitWidth + 14
                height: 24
                radius: 6
                color: SettingsState.themeMode === modelData.toLowerCase() ? SettingsState.bgActivePill : "transparent"
                border.color: SettingsState.themeMode === modelData.toLowerCase() ? SettingsState.borderActive : "transparent"
                border.width: 1

                Text {
                  id: tText
                  anchors.centerIn: parent
                  text: modelData
                  color: SettingsState.themeMode === modelData.toLowerCase() ? SettingsState.textActive : SettingsState.textMuted
                  font.pixelSize: SettingsState.px(13)
                  font.bold: SettingsState.themeMode === modelData.toLowerCase()
                  font.family: SettingsState.fontFamily
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: SettingsState.setThemeMode(modelData.toLowerCase())
                }
              }
            }
          }
        }

        // 5b. Color Spectrum Gradient Slider (Manual mode only).
        // Appears when Manual is picked; hue combines with the accent
        // Light/Dark tone below, so manual works in both lightness modes.
        Rectangle {
          id: spectrumTrack
          width: parent.width
          height: SettingsState.themeMode === "manual" ? 14 : 0
          visible: SettingsState.themeMode === "manual"
          radius: 7
          clip: false

          Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }

          gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.00; color: "#ff0000" }
            GradientStop { position: 0.17; color: "#ffff00" }
            GradientStop { position: 0.33; color: "#00ff00" }
            GradientStop { position: 0.50; color: "#00ffff" }
            GradientStop { position: 0.67; color: "#0000ff" }
            GradientStop { position: 0.83; color: "#ff00ff" }
            GradientStop { position: 1.00; color: "#ff0000" }
          }

          // Draggable indicator circle
          Rectangle {
            id: spectrumThumb
            width: 20
            height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(spectrumTrack.width - width, SettingsState.accentHue * (spectrumTrack.width - width)))
            color: SettingsState.accent
            border.color: "#ffffff"
            border.width: 2.5

            Behavior on x {
              enabled: !spectrumMouse.pressed
              NumberAnimation { duration: 100 }
            }
          }

          MouseArea {
            id: spectrumMouse
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onPressed: function(ev) {
              var h = Math.min(1.0, Math.max(0.0, ev.x / spectrumTrack.width));
              SettingsState.setAccentHue(h);
            }
            onPositionChanged: function(ev) {
              if (pressed) {
                var h = Math.min(1.0, Math.max(0.0, ev.x / spectrumTrack.width));
                SettingsState.setAccentHue(h);
              }
            }
          }
        }

        // 5c. Accent Swatch & Accent Tone Row (Manual mode only)
        Item {
          width: parent.width
          height: SettingsState.themeMode === "manual" ? 38 : 0
          visible: SettingsState.themeMode === "manual"

          Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }

          Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            // Swatch Box
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 34
              height: 34
              radius: 9
              color: SettingsState.accent
              border.color: SettingsState.borderActive
              border.width: 1
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2

              Text {
                text: "Accent hue"
                color: SettingsState.textMain
                font.pixelSize: SettingsState.px(15)
                font.bold: true
                font.family: SettingsState.fontFamily
              }

              Text {
                text: SettingsState.accentHex + " • " + SettingsState.accentTone
                color: SettingsState.textSecondary
                font.pixelSize: SettingsState.px(13)
                font.family: SettingsState.fontFamily
              }
            }
          }

          // Accent Light / Dark options (accent lightness, independent of bar theme)
          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Repeater {
              model: ["Light", "Dark"]
              delegate: Rectangle {
                width: Math.max(64, aText.implicitWidth + 14)
                height: 24
                radius: 6
                color: SettingsState.accentTone === modelData.toLowerCase() ? SettingsState.bgActivePill : SettingsState.bgCard
                border.color: SettingsState.accentTone === modelData.toLowerCase() ? SettingsState.borderActive : SettingsState.borderBase
                border.width: 1

                Row {
                  anchors.centerIn: parent
                  spacing: 5
                  CCIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    kind: modelData === "Light" ? "sun" : "moon"
                    glyph: SettingsState.accentTone === modelData.toLowerCase() ? SettingsState.textActive : SettingsState.textMuted
                  }
                  Text {
                    id: aText
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData
                    color: SettingsState.accentTone === modelData.toLowerCase() ? SettingsState.textActive : SettingsState.textMuted
                    font.pixelSize: SettingsState.px(13)
                    font.bold: SettingsState.accentTone === modelData.toLowerCase()
                    font.family: SettingsState.fontFamily
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: SettingsState.setAccentTone(modelData.toLowerCase())
                }
              }
            }
          }
        }

        // 5d. Hex Color Input / Display Row (Manual mode only)
        Rectangle {
          width: parent.width
          height: SettingsState.themeMode === "manual" ? 32 : 0
          visible: SettingsState.themeMode === "manual"
          radius: 8

          Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }
          color: SettingsState.bgCard
          border.color: hexInput.activeFocus ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "#"
              color: SettingsState.textMuted
              font.pixelSize: SettingsState.px(14)
              font.bold: true
              font.family: SettingsState.fontFamily
            }

            TextInput {
              id: hexInput
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 30
              text: SettingsState.accentHex
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.bold: true
              font.family: SettingsState.fontFamily
              clip: true
              selectByMouse: true
              onEditingFinished: {
                SettingsState.setHexColor(text);
              }
              Keys.onReturnPressed: function(ev) {
                SettingsState.setHexColor(text);
                ev.accepted = true;
              }
            }
          }
        }
      }
    }
  }
}
