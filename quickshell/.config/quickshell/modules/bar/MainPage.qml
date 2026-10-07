import Quickshell
import QtQuick
import "../services"

// Main control-center page (pills, sliders, notifications). Extracted from NetworkCircle.qml.
Column {
  id: mainPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "main") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation {
      duration: 220
    }
  }

  // Wi-Fi + Bluetooth Material 3 Pills
  Row {
    width: parent.width
    spacing: 10

    // Wi-Fi Pill
    Rectangle {
      width: (parent.width - 10) / 2
      height: 68
      radius: 24
      color: circle.wifiUp ? SettingsState.bgActivePill : (wifiCardMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: circle.wifiUp ? SettingsState.borderActive : (wifiCardMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 42
          height: 42
          radius: 21
          color: circle.wifiUp ? SettingsState.accent : (wifiCardMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "wifi"
            glyph: circle.wifiUp ? (SettingsState.isDark ? "#121612" : "#ffffff") : (wifiCardMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 62
          spacing: 2

          Text {
            text: "Wi-Fi"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(17)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
          Text {
            width: parent.width
            text: circle.wifiUp ? circle.wifiName : (circle.wiredUp ? circle.wiredName : (circle.wifiEnabled ? "Disconnected" : "Off"))
            color: circle.wifiUp ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }
      }

      MouseArea {
        id: wifiCardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "wifi";
        }
      }
    }

    // Bluetooth Pill
    Rectangle {
      width: (parent.width - 10) / 2
      height: 68
      radius: 24
      color: (circle.btOn && BluetoothState.btDevice) ? SettingsState.bgActivePill : (btCardMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.btOn && BluetoothState.btDevice) ? SettingsState.borderActive : (btCardMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 42
          height: 42
          radius: 21
          color: (circle.btOn && BluetoothState.btDevice) ? SettingsState.accent : (btCardMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "bt"
            glyph: (circle.btOn && BluetoothState.btDevice) ? (SettingsState.isDark ? "#121612" : "#ffffff") : (btCardMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 62
          spacing: 2

          Text {
            text: "Bluetooth"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(17)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
          Text {
            width: parent.width
            text: circle.btName
            color: (circle.btOn && BluetoothState.btDevice) ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }
      }

      MouseArea {
        id: btCardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "bluetooth";
          BluetoothState.startDiscovery();
        }
      }
    }
  }

  // Material 3 Quick Action Pills Grid (3 Columns) - always visible pills.
  // Apps / Wall / Clip / Mixer / Power live in the expandable grid below.
  Grid {
    width: parent.width
    columns: 3
    spacing: 8

    // 4. Hyprsunset Nightlight Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: NightlightState.active ? SettingsState.bgActivePill : (nightMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: NightlightState.active ? SettingsState.borderActive : (nightMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: NightlightState.active ? SettingsState.accent : (nightMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "sunset"
            glyph: NightlightState.active ? (SettingsState.isDark ? "#121612" : "#ffffff") : (nightMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Night"
          color: NightlightState.active ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: nightMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: NightlightState.toggle()
      }
    }

    // 6. Screen Recorder Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: (circle.activePage === "recorder" || RecorderState.isRecording) ? (RecorderState.isRecording ? (SettingsState.isDark ? "#3a1e1e" : "#ffe5e5") : SettingsState.bgActivePill) : (recMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.activePage === "recorder" || RecorderState.isRecording) ? (RecorderState.isRecording ? "#e05f65" : SettingsState.borderActive) : (recMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: (circle.activePage === "recorder" || RecorderState.isRecording) ? (RecorderState.isRecording ? "#e05f65" : SettingsState.accent) : (recMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "record"
            glyph: (circle.activePage === "recorder" || RecorderState.isRecording) ? (RecorderState.isRecording ? "#ffffff" : (SettingsState.isDark ? "#121612" : "#ffffff")) : (recMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: RecorderState.isRecording ? RecorderState.formattedTime : "Record"
          color: (circle.activePage === "recorder" || RecorderState.isRecording) ? (RecorderState.isRecording ? "#e05f65" : SettingsState.textActive) : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: recMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "recorder";
          RecorderState.refreshRecent();
          RecorderState.checkStatus();
        }
      }
    }

    // 7. Screenshot / Capture Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: (circle.activePage === "screenshot") ? SettingsState.bgActivePill : (shotMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.activePage === "screenshot") ? SettingsState.borderActive : (shotMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: (circle.activePage === "screenshot") ? SettingsState.accent : (shotMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "camera"
            glyph: (circle.activePage === "screenshot") ? (SettingsState.isDark ? "#121612" : "#ffffff") : (shotMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Shot"
          color: (circle.activePage === "screenshot") ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: shotMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "screenshot";
          ScreenshotState.refreshLast();
        }
      }
    }

    // 8. Settings Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: (circle.activePage === "settings") ? SettingsState.bgActivePill : (setMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.activePage === "settings") ? SettingsState.borderActive : (setMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: (circle.activePage === "settings") ? SettingsState.accent : (setMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "gear"
            glyph: (circle.activePage === "settings") ? (SettingsState.isDark ? "#121612" : "#ffffff") : (setMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Config"
          color: (circle.activePage === "settings") ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: setMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.settingsSub = "";
          circle.activePage = "settings";
        }
      }
    }

    // 8. DND (Do Not Disturb) Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: NotifCenter.dnd ? SettingsState.bgActivePill : (dndMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: NotifCenter.dnd ? SettingsState.borderActive : (dndMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: NotifCenter.dnd ? SettingsState.accent : (dndMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "moon"
            glyph: NotifCenter.dnd ? (SettingsState.isDark ? "#121612" : "#ffffff") : (dndMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "DND"
          color: NotifCenter.dnd ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: dndMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: NotifCenter.toggleDnd()
      }
    }

    // 10. About Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: (circle.activePage === "about") ? SettingsState.bgActivePill : (aboutMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.activePage === "about") ? SettingsState.borderActive : (aboutMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: (circle.activePage === "about" || aboutMouse.containsMouse) ? SettingsState.accent : SettingsState.bgSurface

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "about"
            glyph: (circle.activePage === "about" || aboutMouse.containsMouse) ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "About"
          color: (circle.activePage === "about" || aboutMouse.containsMouse) ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: aboutMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "about";
        }
      }
    }
  }

  // Expand/collapse dash handle for the hidden pills (Apps, Wall, Clip, Mixer, Power)
  Item {
    width: parent.width
    height: 18

    Rectangle {
      anchors.centerIn: parent
      width: 44
      height: 4
      radius: 2
      color: pillMoreMouse.containsMouse ? SettingsState.accent : SettingsState.borderBase

      Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
      id: pillMoreMouse
      anchors.fill: parent
      anchors.margins: -4
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: circle.pillsExpanded = !circle.pillsExpanded
    }
  }

  // Hidden pills grid: Apps / Wall / Clip / Mixer / Power
  Grid {
    width: parent.width
    columns: 3
    spacing: 8
    visible: circle.pillsExpanded
    height: visible ? implicitHeight : 0

    // 1. App Launcher Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: LauncherState.open ? SettingsState.bgActivePill : (appMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: LauncherState.open ? SettingsState.borderActive : (appMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: LauncherState.open ? SettingsState.accent : (appMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "apps"
            glyph: LauncherState.open ? (SettingsState.isDark ? "#121612" : "#ffffff") : (appMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Apps"
          color: LauncherState.open ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: appMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (LauncherState.open && LauncherState.mode === "apps")
            LauncherState.close();
          else
            LauncherState.openApps();
        }
      }
    }

    // 2. Wallpaper Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: WallpaperState.open ? SettingsState.bgActivePill : (wallMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: WallpaperState.open ? SettingsState.borderActive : (wallMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: WallpaperState.open ? SettingsState.accent : (wallMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "wallpaper"
            glyph: WallpaperState.open ? (SettingsState.isDark ? "#ffffff" : "#000000") : (wallMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Wall"
          color: WallpaperState.open ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: wallMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: WallpaperState.toggle()
      }
    }

    // 3. Clipboard Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: ClipboardState.open ? SettingsState.bgActivePill : (clipMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: ClipboardState.open ? SettingsState.borderActive : (clipMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: ClipboardState.open ? SettingsState.accent : (clipMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "clipboard"
            glyph: ClipboardState.open ? (SettingsState.isDark ? "#121612" : "#ffffff") : (clipMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Clip"
          color: ClipboardState.open ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: clipMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ClipboardState.toggle()
      }
    }

    // 5. Hardware Mixer Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: (circle.activePage === "mixer") ? SettingsState.bgActivePill : (mixerMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.activePage === "mixer") ? SettingsState.borderActive : (mixerMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: (circle.activePage === "mixer") ? SettingsState.accent : (mixerMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface)

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "mixer"
            glyph: (circle.activePage === "mixer") ? (SettingsState.isDark ? "#121612" : "#ffffff") : (mixerMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Mixer"
          color: (circle.activePage === "mixer") ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: mixerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "mixer";
        }
      }
    }

    // 9. Power Menu Pill
    Rectangle {
      width: (parent.width - 16) / 3
      height: 48
      radius: 24
      color: (circle.activePage === "power") ? SettingsState.bgActivePill : (powerMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: (circle.activePage === "power") ? SettingsState.borderActive : (powerMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 34
          height: 34
          radius: 17
          color: (circle.activePage === "power" || powerMouse.containsMouse) ? SettingsState.accent : SettingsState.bgSurface

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "power"
            glyph: (circle.activePage === "power" || powerMouse.containsMouse) ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 46
          text: "Power"
          color: (circle.activePage === "power" || powerMouse.containsMouse) ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: powerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.activePage = "power";
        }
      }
    }
  }

  // Sound + microphone sliders
  CCSlider {
    id: soundSlider
    width: parent.width
    label: "Sound"
    icon: "sound"
    value: circle.outVol
    muted: circle.outMuted
    available: AudioState.sink !== null && AudioState.sink !== undefined
    currentDeviceName: AudioState.sinkName
    onOpenDevices: {
      AudioState.refreshDevices();
      circle.activePage = "sound";
    }
    onSeeked: function (v) {
      AudioState.setOutVol(v);
    }
    onIconClicked: AudioState.toggleOutMute()
  }

  CCSlider {
    id: micSlider
    width: parent.width
    label: "Microphone"
    icon: "mic"
    value: circle.inVol
    muted: circle.inMuted
    available: AudioState.source !== null && AudioState.source !== undefined
    currentDeviceName: AudioState.sourceName
    onOpenDevices: {
      AudioState.refreshDevices();
      circle.activePage = "mic";
    }
    onSeeked: function (v) {
      AudioState.setInVol(v);
    }
    onIconClicked: AudioState.toggleInMute()
  }

  // Notifications header
  Item {
    width: parent.width
    height: 24

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: "Notifications"
      color: SettingsState.textMain
      font.pixelSize: SettingsState.px(16)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    // Clear all pill button
    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 24
      width: clearAllText.implicitWidth + 16
      radius: 12
      color: NotifCenter.count > 0 ? (clearMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard) : "transparent"
      border.color: NotifCenter.count > 0 ? SettingsState.borderBase : "transparent"
      border.width: 1

      Text {
        id: clearAllText
        anchors.centerIn: parent
        text: "Clear all"
        color: NotifCenter.count > 0 ? SettingsState.accent : SettingsState.textMuted
        font.pixelSize: SettingsState.px(14)
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

  // Notifications list (wheel-scrollable)
  Text {
    visible: NotifCenter.count === 0
    text: "No notifications"
    color: SettingsState.textMuted
    font.pixelSize: SettingsState.px(15)
    font.family: SettingsState.fontFamily
  }

  ListView {
    id: notifList
    width: parent.width
    height: NotifCenter.count > 0 ? Math.min(180, NotifCenter.count * 68) : 0
    spacing: 8
    clip: true
    visible: NotifCenter.count > 0
    model: NotifCenter.trackedList
    delegate: CCNotifCard {
    }
  }
}
