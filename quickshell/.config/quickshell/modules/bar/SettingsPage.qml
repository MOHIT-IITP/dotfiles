import Quickshell
import QtQuick
import "../services"

// Settings / appearance expanded subview. Extracted from NetworkCircle.qml.
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

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: SettingsState.japaneseGlyphs
        text: "相"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(20)
        font.bold: true
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "APPEARANCE"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 1.5
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
        text: "\uf053"
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
          circle.fontDropdownOpen = false;
          circle.activePage = "main";
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
      spacing: 8

      // Divider
      Rectangle {
        width: parent.width
        height: 1
        color: SettingsState.borderBase
      }

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
            model: ["Light", "Dark", "Dynamic", "Manual"]
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

      // 5b. Color Spectrum Gradient Slider
      Rectangle {
        id: spectrumTrack
        width: parent.width
        height: 14
        radius: 7
        clip: false

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

      // 5c. Accent Swatch & Dark/Light Mode Switcher Row
      Item {
        width: parent.width
        height: 38

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
              text: SettingsState.accentHex + " • " + (SettingsState.isDark ? "dark" : "light")
              color: SettingsState.textSecondary
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
            }
          }
        }

        // Light <-> Dark slider
        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            kind: "sun"
            glyph: SettingsState.textSecondary
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: SettingsState.setThemeBlend(0.0)
            }
          }

          Rectangle {
            id: themeTrack
            anchors.verticalCenter: parent.verticalCenter
            width: 110
            height: 10
            radius: 5
            color: SettingsState.bgCard
            border.color: SettingsState.borderBase
            border.width: 1

            Rectangle {
              anchors.left: parent.left
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              width: Math.max(8, Math.min(parent.width, SettingsState.themeBlend * parent.width))
              radius: 5
              color: SettingsState.accent
            }

            Rectangle {
              id: themeThumb
              width: 16
              height: 16
              radius: 8
              anchors.verticalCenter: parent.verticalCenter
              x: Math.max(0, Math.min(parent.width - width, SettingsState.themeBlend * (parent.width - width)))
              color: SettingsState.accent
              border.color: "#ffffff"
              border.width: 2

              Behavior on x {
                enabled: !themeMouse.pressed
                NumberAnimation { duration: 80 }
              }
            }

            MouseArea {
              id: themeMouse
              anchors.fill: parent
              anchors.margins: -6
              cursorShape: Qt.PointingHandCursor
              onPressed: function(ev) {
                SettingsState.setThemeBlend(Math.min(1.0, Math.max(0.0, ev.x / themeTrack.width)));
              }
              onPositionChanged: function(ev) {
                if (pressed) {
                  SettingsState.setThemeBlend(Math.min(1.0, Math.max(0.0, ev.x / themeTrack.width)));
                }
              }
            }
          }

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            kind: "moon"
            glyph: SettingsState.textSecondary
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: SettingsState.setThemeBlend(1.0)
            }
          }
        }
      }

      // 5d. Hex Color Input / Display Row
      Rectangle {
        width: parent.width
        height: 32
        radius: 8
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

      // 7. UI scale: (scale) UI scale -> 90% | 100% | 110% | 125%
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
              { label: "90%", val: 0.9 },
              { label: "100%", val: 1.0 },
              { label: "110%", val: 1.1 },
              { label: "125%", val: 1.25 }
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
              text: SettingsState.barGap + "px"
              color: SettingsState.accent
              font.pixelSize: SettingsState.px(13)
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }
        }

        // Slider Track
        Rectangle {
          id: gapTrack
          width: parent.width
          height: 10
          radius: 5
          color: SettingsState.bgCard
          border.color: SettingsState.borderBase
          border.width: 1

          // Filled portion
          Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(8, Math.min(parent.width, (SettingsState.barGap / 24.0) * parent.width))
            radius: 5
            color: SettingsState.accent
          }

          // Draggable Thumb
          Rectangle {
            id: gapThumb
            width: 16
            height: 16
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(gapTrack.width - width, (SettingsState.barGap / 24.0) * (gapTrack.width - width)))
            color: SettingsState.accent
            border.color: "#ffffff"
            border.width: 2

            Behavior on x {
              enabled: !gapMouse.pressed
              NumberAnimation { duration: 80 }
            }
          }

          MouseArea {
            id: gapMouse
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onPressed: function(ev) {
              var r = Math.min(1.0, Math.max(0.0, ev.x / gapTrack.width));
              SettingsState.setBarGap(Math.round(r * 24));
            }
            onPositionChanged: function(ev) {
              if (pressed) {
                var r = Math.min(1.0, Math.max(0.0, ev.x / gapTrack.width));
                SettingsState.setBarGap(Math.round(r * 24));
              }
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
  }
}
