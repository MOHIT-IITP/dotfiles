import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io
import QtQuick
import "../services"

// Right circle: collapsed wifi/ethernet icon with dark amber ring.
// Hovered: full control center (wifi, bluetooth, sound, microphone, notifications).
// Clicking Wi-Fi, Bluetooth, or Power opens detailed subview matching reference UI.
Rectangle {
  id: root

  property string activePage: "main" // "main" | "wifi" | "bluetooth" | "power"

  readonly property string activeType: NetworkState.activeType
  readonly property bool wifiUp: NetworkState.wifiUp
  readonly property string wifiName: NetworkState.wifiName
  readonly property bool wiredUp: NetworkState.wiredUp
  readonly property string wiredName: NetworkState.wiredName
  readonly property bool wifiEnabled: NetworkState.wifiEnabled

  readonly property bool btOn: BluetoothState.btOn
  readonly property string btName: BluetoothState.btName

  readonly property real outVol: AudioState.outVol
  readonly property bool outMuted: AudioState.outMuted
  readonly property real inVol: AudioState.inVol
  readonly property bool inMuted: AudioState.inMuted

  property bool fontDropdownOpen: false
  property bool recMicDropdownOpen: false
  property string fontSearchQuery: ""
  readonly property var filteredFonts: {
    var all = SettingsState.availableFonts || [];
    var q = (fontSearchQuery || "").trim().toLowerCase();
    if (q === "") return all;
    var res = [];
    for (var i = 0; i < all.length; ++i) {
      var name = all[i] || "";
      if (name.toLowerCase().indexOf(q) !== -1) {
        res.push(name);
      }
    }
    return res;
  }

  implicitWidth: netMouse.containsMouse ? (root.activePage === "power" ? 340 : (root.activePage === "mixer" ? 420 : (root.activePage === "recorder" ? 420 : (root.activePage === "settings" ? 420 : 410)))) : 34
  implicitHeight: netMouse.containsMouse ? (root.activePage === "power" ? 130 : (root.activePage === "settings" ? (settingsCol.implicitHeight + 56) : ((root.activePage === "sound" || root.activePage === "mic") ? 520 : (root.activePage === "mixer" ? 380 : (root.activePage === "recorder" ? (460 + (root.recMicDropdownOpen ? (Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) + 8) : 0) + ((RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0) ? Math.min(180, RecorderState.recentRecordings.length * 60) : 30)) : (mainPage.implicitHeight + 40)))))) : 34
  radius: netMouse.containsMouse ? 30 : 17

  color: netMouse.containsMouse ? SettingsState.bgSurface : SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1

  Behavior on implicitWidth {
    NumberAnimation {
      duration: 350
      easing.type: Easing.OutCubic
    }
  }
  Behavior on implicitHeight {
    NumberAnimation {
      duration: 350
      easing.type: Easing.OutCubic
    }
  }
  Behavior on radius {
    NumberAnimation {
      duration: 350
      easing.type: Easing.OutCubic
    }
  }

  Process {
    id: powerProc
  }

  function execCmd(args) {
    powerProc.command = args;
    powerProc.running = true;
  }

  // Bluetooth device list sorted by connected > paired > name
  readonly property var btDevicesList: {
    var ds = (Bluetooth.devices) ? Bluetooth.devices.values : [];
    var arr = [];
    for (var i = 0; i < ds.length; ++i) {
      var d = ds[i];
      if (d) {
        arr.push(d);
      }
    }
    arr.sort(function(a, b) {
      if (a.connected !== b.connected) return a.connected ? -1 : 1;
      if (a.paired !== b.paired) return a.paired ? -1 : 1;
      var na = a.name || a.deviceName || a.address || "";
      var nb = b.name || b.deviceName || b.address || "";
      return na.localeCompare(nb);
    });
    return arr;
  }

  // Wi-Fi network list sorted by connected > signal
  readonly property var wifiNetworksList: {
    var dev = NetworkState.wifiDev;
    if (!dev || !dev.networks) return [];
    var ns = dev.networks.values;
    var arr = [];
    var seen = {};
    for (var i = 0; i < ns.length; ++i) {
      var net = ns[i];
      if (net && net.name && !seen[net.name]) {
        seen[net.name] = true;
        arr.push(net);
      }
    }
    arr.sort(function(a, b) {
      if (a.connected !== b.connected) return a.connected ? -1 : 1;
      var sa = a.signalStrength || 0;
      var sb = b.signalStrength || 0;
      return sb - sa;
    });
    return arr;
  }

  // ---- Collapsed: icon circle ----
  Item {
    id: netIcon
    anchors.centerIn: parent
    width: 20
    height: 20
    opacity: netMouse.containsMouse ? 0 : 1
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 180
      }
    }

    CCIcon {
      anchors.centerIn: parent
      width: 18
      height: 18
      kind: activeType === "wired" ? "ethernet" : (wifiUp ? "wifi" : (activeType === "none" ? "wifi-off" : "wifi"))
      glyph: activeType === "none" ? "#6e756e" : "#f2f2f2"
    }
  }

  // =========================================================================
  // ---- MAIN CONTROL CENTER PAGE ----
  // =========================================================================
  Column {
    id: mainPage
    anchors.fill: parent
    anchors.margins: 18
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "main") ? 1 : 0
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
        color: wifiUp ? "#243322" : (wifiCardMouse.containsMouse ? "#1e241e" : "#181d18")
        border.color: wifiUp ? "#3d5438" : (wifiCardMouse.containsMouse ? "#2d382d" : "#242a24")
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
            color: wifiUp ? "#c9dfae" : "#283028"

            CCIcon {
              anchors.centerIn: parent
              width: 20
              height: 20
              kind: "wifi"
              glyph: wifiUp ? "#182415" : "#838e83"
            }
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 62
            spacing: 2

            Text {
              text: "Wi-Fi"
              color: "#f2f2f2"
              font.pixelSize: 15
              font.bold: true
            }
            Text {
              width: parent.width
              text: wifiUp ? wifiName : (wiredUp ? wiredName : (wifiEnabled ? "Disconnected" : "Off"))
              color: wifiUp ? "#c9dfae" : "#9aa39a"
              font.pixelSize: 12
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
            root.activePage = "wifi";
          }
        }
      }

      // Bluetooth Pill
      Rectangle {
        width: (parent.width - 10) / 2
        height: 68
        radius: 24
        color: (btOn && BluetoothState.btDevice) ? "#243322" : (btCardMouse.containsMouse ? "#1e241e" : "#181d18")
        border.color: (btOn && BluetoothState.btDevice) ? "#3d5438" : (btCardMouse.containsMouse ? "#2d382d" : "#242a24")
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
            color: (btOn && BluetoothState.btDevice) ? "#c9dfae" : "#283028"

            CCIcon {
              anchors.centerIn: parent
              width: 20
              height: 20
              kind: "bt"
              glyph: (btOn && BluetoothState.btDevice) ? "#182415" : "#838e83"
            }
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 62
            spacing: 2

            Text {
              text: "Bluetooth"
              color: "#f2f2f2"
              font.pixelSize: 15
              font.bold: true
            }
            Text {
              width: parent.width
              text: btName
              color: (btOn && BluetoothState.btDevice) ? "#c9dfae" : "#9aa39a"
              font.pixelSize: 12
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
            root.activePage = "bluetooth";
            BluetoothState.startDiscovery();
          }
        }
      }
    }

    // Material 3 Quick Action Pills Grid (3 Columns)
    Grid {
      width: parent.width
      columns: 3
      spacing: 8

      // 1. App Launcher Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: LauncherState.open ? "#243322" : (appMouse.containsMouse ? "#202620" : "#171c17")
        border.color: LauncherState.open ? "#3f5938" : (appMouse.containsMouse ? "#2e392e" : "#222722")
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
            color: LauncherState.open ? "#c9dfae" : (appMouse.containsMouse ? "#2a332a" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "apps"
              glyph: LauncherState.open ? "#182415" : (appMouse.containsMouse ? "#c9dfae" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "Apps"
            color: LauncherState.open ? "#c9dfae" : "#f2f2f2"
            font.pixelSize: 12
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
          onClicked: LauncherState.toggle()
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
            font.pixelSize: 12
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
        color: ClipboardState.open ? "#243322" : (clipMouse.containsMouse ? "#202620" : "#171c17")
        border.color: ClipboardState.open ? "#3f5938" : (clipMouse.containsMouse ? "#2e392e" : "#222722")
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
            color: ClipboardState.open ? "#c9dfae" : (clipMouse.containsMouse ? "#2a332a" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "clipboard"
              glyph: ClipboardState.open ? "#182415" : (clipMouse.containsMouse ? "#c9dfae" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "Clip"
            color: ClipboardState.open ? "#c9dfae" : "#f2f2f2"
            font.pixelSize: 12
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

      // 4. Hyprsunset Nightlight Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: NightlightState.active ? "#382c1e" : (nightMouse.containsMouse ? "#26221c" : "#171c17")
        border.color: NightlightState.active ? "#664928" : (nightMouse.containsMouse ? "#3d3224" : "#222722")
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
            color: NightlightState.active ? "#ffb877" : (nightMouse.containsMouse ? "#332a20" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "sunset"
              glyph: NightlightState.active ? "#2a1d0d" : (nightMouse.containsMouse ? "#ffb877" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "Night"
            color: NightlightState.active ? "#ffb877" : "#f2f2f2"
            font.pixelSize: 12
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

      // 5. Hardware Mixer Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: (root.activePage === "mixer") ? "#243322" : (mixerMouse.containsMouse ? "#202620" : "#171c17")
        border.color: (root.activePage === "mixer") ? "#3f5938" : (mixerMouse.containsMouse ? "#2e392e" : "#222722")
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
            color: (root.activePage === "mixer") ? "#c9dfae" : (mixerMouse.containsMouse ? "#2a332a" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "mixer"
              glyph: (root.activePage === "mixer") ? "#182415" : (mixerMouse.containsMouse ? "#c9dfae" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "Mixer"
            color: (root.activePage === "mixer") ? "#c9dfae" : "#f2f2f2"
            font.pixelSize: 12
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
            root.activePage = "mixer";
          }
        }
      }

      // 6. Screen Recorder Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: (root.activePage === "recorder" || RecorderState.isRecording) ? "#3a1e1e" : (recMouse.containsMouse ? "#202620" : "#171c17")
        border.color: (root.activePage === "recorder" || RecorderState.isRecording) ? "#662c2c" : (recMouse.containsMouse ? "#2e392e" : "#222722")
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
            color: (root.activePage === "recorder" || RecorderState.isRecording) ? "#ff8a8a" : (recMouse.containsMouse ? "#2a332a" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "record"
              glyph: (root.activePage === "recorder" || RecorderState.isRecording) ? "#2a0e0e" : (recMouse.containsMouse ? "#c9dfae" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: RecorderState.isRecording ? RecorderState.formattedTime : "Record"
            color: (root.activePage === "recorder" || RecorderState.isRecording) ? "#ff8a8a" : "#f2f2f2"
            font.pixelSize: 12
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
            root.activePage = "recorder";
            RecorderState.refreshRecent();
            RecorderState.checkStatus();
          }
        }
      }

      // 7. Settings Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: (root.activePage === "settings") ? "#243322" : (setMouse.containsMouse ? "#202620" : "#171c17")
        border.color: (root.activePage === "settings") ? "#3f5938" : (setMouse.containsMouse ? "#2e392e" : "#222722")
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
            color: (root.activePage === "settings") ? "#c9dfae" : (setMouse.containsMouse ? "#2a332a" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "gear"
              glyph: (root.activePage === "settings") ? "#182415" : (setMouse.containsMouse ? "#c9dfae" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "Config"
            color: (root.activePage === "settings") ? "#c9dfae" : "#f2f2f2"
            font.pixelSize: 12
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
            root.activePage = "settings";
          }
        }
      }

      // 8. DND (Do Not Disturb) Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: NotifCenter.dnd ? "#243322" : (dndMouse.containsMouse ? "#202620" : "#171c17")
        border.color: NotifCenter.dnd ? "#3f5938" : (dndMouse.containsMouse ? "#2e392e" : "#222722")
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
            color: NotifCenter.dnd ? "#c9dfae" : (dndMouse.containsMouse ? "#2a332a" : "#222722")

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "bell-slash"
              glyph: NotifCenter.dnd ? "#182415" : (dndMouse.containsMouse ? "#c9dfae" : "#9aa39a")
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "DND"
            color: NotifCenter.dnd ? "#c9dfae" : "#f2f2f2"
            font.pixelSize: 12
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

      // 9. Power Menu Pill
      Rectangle {
        width: (parent.width - 16) / 3
        height: 48
        radius: 24
        color: (root.activePage === "power") ? "#381e1e" : (powerMouse.containsMouse ? "#261c1c" : "#171c17")
        border.color: (root.activePage === "power") ? "#662c2c" : (powerMouse.containsMouse ? "#3d2222" : "#222722")
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
            color: (root.activePage === "power" || powerMouse.containsMouse) ? "#ff8a8a" : "#222722"

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "power"
              glyph: (root.activePage === "power" || powerMouse.containsMouse) ? "#2a0e0e" : "#9aa39a"
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 46
            text: "Power"
            color: (root.activePage === "power" || powerMouse.containsMouse) ? "#ff8a8a" : "#f2f2f2"
            font.pixelSize: 12
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
            root.activePage = "power";
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
      value: outVol
      muted: outMuted
      available: AudioState.sink !== null && AudioState.sink !== undefined
      currentDeviceName: AudioState.sinkName
      onOpenDevices: {
        AudioState.refreshDevices();
        root.activePage = "sound";
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
      value: inVol
      muted: inMuted
      available: AudioState.source !== null && AudioState.source !== undefined
      currentDeviceName: AudioState.sourceName
      onOpenDevices: {
        AudioState.refreshDevices();
        root.activePage = "mic";
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
        color: "#d4dbd4"
        font.pixelSize: 14
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
        color: NotifCenter.count > 0 ? (clearMouse.containsMouse ? "#2a342a" : "#1f261f") : "transparent"
        border.color: NotifCenter.count > 0 ? "#333f33" : "transparent"
        border.width: 1

        Text {
          id: clearAllText
          anchors.centerIn: parent
          text: "Clear all"
          color: NotifCenter.count > 0 ? "#c9dfae" : "#525252"
          font.pixelSize: 12
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
      color: "#6e756e"
      font.pixelSize: 13
      font.family: SettingsState.fontFamily
    }

    ListView {
      id: notifList
      width: parent.width
      height: NotifCenter.count > 0 ? Math.min(180, NotifCenter.count * 68) : 0
      spacing: 8
      clip: true
      visible: NotifCenter.count > 0
      model: NotifCenter.tracked
      delegate: Rectangle {
        width: ListView.view.width
        radius: 18
        color: "#181d18"
        border.color: "#252c25"
        border.width: 1
        implicitHeight: nrow.implicitHeight + 20

        Row {
          id: nrow
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 10
          spacing: 10

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 15
            color: "#2c302c"
            Image {
              anchors.centerIn: parent
              width: 20
              height: 20
              visible: modelData && modelData.appIcon !== ""
              source: (modelData && modelData.appIcon !== "") ? Quickshell.iconPath(modelData.appIcon, "image-missing") : ""
              smooth: true
              asynchronous: true
            }
            Text {
              anchors.centerIn: parent
              visible: !modelData || modelData.appIcon === ""
              text: (modelData && modelData.appName) ? modelData.appName.substring(0, 1).toUpperCase() : "?"
              color: "#9aa39a"
              font.pixelSize: 14
              font.bold: true
            }
          }

          Column {
            width: parent.width - 80
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
              text: (modelData && modelData.appName) ? modelData.appName : ""
              color: "#9aa39a"
              font.pixelSize: 11
              font.family: SettingsState.fontFamily
            }
            Text {
              width: parent.width
              text: (modelData && modelData.summary) ? modelData.summary : ""
              textFormat: Text.PlainText
              color: "#f2f2f2"
              font.pixelSize: 14
              font.bold: true
              elide: Text.ElideRight
              maximumLineCount: 1
            }
            Text {
              width: parent.width
              visible: modelData && modelData.body !== ""
              text: (modelData && modelData.body) ? modelData.body : ""
              textFormat: Text.PlainText
              color: "#9aa39a"
              font.pixelSize: 12
              elide: Text.ElideRight
              maximumLineCount: 2
              wrapMode: Text.WordWrap
            }
          }

          Canvas {
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            onPaint: {
              var ctx = getContext("2d");
              ctx.reset();
              ctx.clearRect(0, 0, width, height);
              ctx.strokeStyle = "#6e756e";
              ctx.lineWidth = 1.6;
              ctx.lineCap = "round";
              ctx.beginPath();
              ctx.moveTo(2, 2);
              ctx.lineTo(10, 10);
              ctx.moveTo(10, 2);
              ctx.lineTo(2, 10);
              ctx.stroke();
            }
            MouseArea {
              anchors.fill: parent
              anchors.margins: -8
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (modelData)
                  modelData.dismiss();
              }
            }
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- BLUETOOTH EXPANDED SUBVIEW ----
  // =========================================================================
  Column {
    id: btPage
    anchors.fill: parent
    anchors.margins: 18
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "bluetooth") ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 220
      }
    }

    // Bluetooth Header
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Back button
        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: btBackMouse.containsMouse ? "#252b25" : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 20
            font.bold: true
          }

          MouseArea {
            id: btBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Kanji glyph
        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "歯"
          color: "#f2f2f2"
          font.pixelSize: 18
          font.bold: true
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "BLUETOOTH"
          color: "#f2f2f2"
          font.pixelSize: 15
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: BluetoothState.discovering ? "Scanning..." : (BluetoothState.btOn ? "Ready" : "Off")
          color: BluetoothState.discovering ? "#e05f65" : (BluetoothState.btOn ? "#7ee2a8" : "#6e756e")
          font.pixelSize: 12
          font.family: SettingsState.fontFamily
        }

        // Toggle switch
        Rectangle {
          width: 40
          height: 22
          radius: 11
          color: BluetoothState.btOn ? "#e05f65" : "#252b25"
          anchors.verticalCenter: parent.verticalCenter

          Behavior on color {
            ColorAnimation { duration: 200 }
          }

          Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            x: BluetoothState.btOn ? parent.width - width - 3 : 3

            Behavior on x {
              NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: BluetoothState.toggle()
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

    // Empty or Off state
    Text {
      visible: !BluetoothState.btOn || root.btDevicesList.length === 0
      text: !BluetoothState.btOn ? "Bluetooth is turned off" : "No Bluetooth devices found"
      color: "#6e756e"
      font.pixelSize: 13
      font.family: SettingsState.fontFamily
      anchors.horizontalCenter: parent.horizontalCenter
    }

    // Devices List
    ListView {
      width: parent.width
      height: parent.height - 56
      spacing: 8
      clip: true
      visible: BluetoothState.btOn && root.btDevicesList.length > 0
      model: root.btDevicesList

      delegate: Rectangle {
        id: btRow
        width: ListView.view.width
        height: 56
        radius: 14
        color: modelData.connected ? "#1e261e" : (btRowMouse.containsMouse ? "#191d19" : "#141714")
        border.color: modelData.connected ? "#3a4a35" : (btRowMouse.containsMouse ? "#283028" : "transparent")
        border.width: 1

        readonly property bool isAudio: {
          var name = (modelData.name || modelData.deviceName || "").toLowerCase();
          var icon = (modelData.icon || "").toLowerCase();
          return name.includes("bud") || name.includes("head") || name.includes("ear") || name.includes("audio") || name.includes("speaker") || name.includes("tv") || icon.includes("audio");
        }

        // Left Icon Box
        Rectangle {
          id: iconBox
          anchors.left: parent.left
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          width: 36
          height: 36
          radius: 10
          color: modelData.connected ? "#2c382c" : "#202520"

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: btRow.isAudio ? "speaker" : "bt"
            glyph: modelData.connected ? "#7ee2a8" : "#8e998e"
          }
        }

        // Right Action Button
        Rectangle {
          id: actionBtn
          anchors.right: parent.right
          anchors.rightMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          height: 26
          width: btnText.implicitWidth + 18
          radius: 13
          color: btnMouse.containsMouse ? "#2e362e" : "#222722"
          border.color: "#303830"
          border.width: 1
          z: 5

          Text {
            id: btnText
            anchors.centerIn: parent
            text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
            color: modelData.connected ? "#e05f65" : "#d0d8d0"
            font.pixelSize: 11
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (modelData.connected) {
                modelData.connected = false;
              } else if (modelData.paired) {
                modelData.connected = true;
              } else {
                modelData.pair();
              }
            }
          }
        }

        // Center Details
        Column {
          anchors.left: iconBox.right
          anchors.leftMargin: 10
          anchors.right: actionBtn.left
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2

          Text {
            width: parent.width
            text: modelData.name || modelData.deviceName || modelData.address || "Unknown Device"
            color: "#f2f2f2"
            font.pixelSize: 13
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: (modelData.paired ? "paired" : "unpaired") + " · " + (modelData.connected ? "connected" : "disconnected") + (modelData.address ? (" · " + modelData.address) : "")
            color: modelData.connected ? "#7ee2a8" : "#6e756e"
            font.pixelSize: 11
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        MouseArea {
          id: btRowMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton
          onClicked: {
            if (modelData.connected) {
              modelData.connected = false;
            } else {
              modelData.connected = true;
            }
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- WI-FI EXPANDED SUBVIEW ----
  // =========================================================================
  Column {
    id: wifiPage
    anchors.fill: parent
    anchors.margins: 18
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "wifi") ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 220
      }
    }

    // Wi-Fi Header
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Back button
        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: wifiBackMouse.containsMouse ? "#252b25" : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 20
            font.bold: true
          }

          MouseArea {
            id: wifiBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Kanji glyph
        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "波"
          color: "#f2f2f2"
          font.pixelSize: 18
          font.bold: true
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "WI-FI"
          color: "#f2f2f2"
          font.pixelSize: 15
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: NetworkState.wifiEnabled ? (root.wifiUp ? "Connected" : "Available") : "Off"
          color: root.wifiUp ? "#7ee2a8" : "#6e756e"
          font.pixelSize: 12
          font.family: SettingsState.fontFamily
        }

        // Toggle switch
        Rectangle {
          width: 40
          height: 22
          radius: 11
          color: NetworkState.wifiEnabled ? "#e05f65" : "#252b25"
          anchors.verticalCenter: parent.verticalCenter

          Behavior on color {
            ColorAnimation { duration: 200 }
          }

          Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            x: NetworkState.wifiEnabled ? parent.width - width - 3 : 3

            Behavior on x {
              NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: NetworkState.toggleWifi()
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

    // Empty / Off state
    Text {
      visible: !NetworkState.wifiEnabled || root.wifiNetworksList.length === 0
      text: !NetworkState.wifiEnabled ? "Wi-Fi is turned off" : "No Wi-Fi networks found"
      color: "#6e756e"
      font.pixelSize: 13
      font.family: SettingsState.fontFamily
      anchors.horizontalCenter: parent.horizontalCenter
    }

    // Networks List
    ListView {
      width: parent.width
      height: parent.height - 56
      spacing: 8
      clip: true
      visible: NetworkState.wifiEnabled && root.wifiNetworksList.length > 0
      model: root.wifiNetworksList

      delegate: Rectangle {
        id: wifiRow
        width: ListView.view.width
        height: 56
        radius: 14
        color: modelData.connected ? "#1e261e" : (wifiRowMouse.containsMouse ? "#191d19" : "#141714")
        border.color: modelData.connected ? "#3a4a35" : (wifiRowMouse.containsMouse ? "#283028" : "transparent")
        border.width: 1

        // Left Icon Box
        Rectangle {
          id: wIconBox
          anchors.left: parent.left
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          width: 36
          height: 36
          radius: 10
          color: modelData.connected ? "#2c382c" : "#202520"

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "wifi"
            glyph: modelData.connected ? "#7ee2a8" : "#8e998e"
          }
        }

        // Right Action Button
        Rectangle {
          id: wActionBtn
          anchors.right: parent.right
          anchors.rightMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          height: 26
          width: wBtnText.implicitWidth + 18
          radius: 13
          color: wBtnMouse.containsMouse ? "#2e362e" : "#222722"
          border.color: "#303830"
          border.width: 1
          z: 5

          Text {
            id: wBtnText
            anchors.centerIn: parent
            text: modelData.connected ? "Disconnect" : "Connect"
            color: modelData.connected ? "#e05f65" : "#d0d8d0"
            font.pixelSize: 11
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: wBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (modelData.connected) {
                // disconnect
              } else {
                modelData.connect();
              }
            }
          }
        }

        // Center Details
        Column {
          anchors.left: wIconBox.right
          anchors.leftMargin: 10
          anchors.right: wActionBtn.left
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2

          Text {
            width: parent.width
            text: modelData.name || "Hidden Network"
            color: "#f2f2f2"
            font.pixelSize: 13
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: (modelData.connected ? "connected" : "available") + " · " + Math.round((modelData.signalStrength || 0) * 100) + "% signal"
            color: modelData.connected ? "#7ee2a8" : "#6e756e"
            font.pixelSize: 11
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        MouseArea {
          id: wifiRowMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton
          onClicked: {
            if (!modelData.connected) {
              modelData.connect();
            }
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- POWER MENU EXPANDED SUBVIEW ----
  // =========================================================================
  Column {
    id: powerPage
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8
    opacity: (netMouse.containsMouse && root.activePage === "power") ? 1 : 0
    visible: opacity > 0

    readonly property string hoveredAction: {
      if (lockBtnMouse.containsMouse) return "Lock";
      if (logoutBtnMouse.containsMouse) return "Logout";
      if (sleepBtnMouse.containsMouse) return "Sleep";
      if (rebootBtnMouse.containsMouse) return "Restart";
      if (powerOffBtnMouse.containsMouse) return "Power Off";
      return "";
    }

    Behavior on opacity {
      NumberAnimation {
        duration: 220
      }
    }

    // Power Header
    Item {
      width: parent.width
      height: 26

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Back button
        Rectangle {
          width: 24
          height: 24
          radius: 12
          color: powerBackMouse.containsMouse ? "#252b25" : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 18
            font.bold: true
          }

          MouseArea {
            id: powerBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Kanji glyph
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "電"
          color: "#f2f2f2"
          font.pixelSize: 16
          font.bold: true
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "POWER"
          color: "#f2f2f2"
          font.pixelSize: 14
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1.5
        }
      }

      // Hovered action label on right
      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: powerPage.hoveredAction
        color: powerPage.hoveredAction === "Power Off" ? "#ef5350" : (powerPage.hoveredAction === "Restart" ? "#ffd23f" : "#7ee2a8")
        font.pixelSize: 12
        font.bold: true
        font.family: SettingsState.fontFamily
        opacity: powerPage.hoveredAction !== "" ? 1 : 0

        Behavior on opacity {
          NumberAnimation { duration: 150 }
        }
      }
    }

    // Divider
    Rectangle {
      width: parent.width
      height: 1
      color: "#252b25"
    }

    // 5 Power Action Buttons Row (Lock, Logout, Suspend, Reboot, Shutdown)
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 8

      // 1. Lock
      Rectangle {
        width: 48
        height: 48
        radius: 13
        color: lockBtnMouse.containsMouse ? "#252d25" : "#181c18"
        border.color: lockBtnMouse.containsMouse ? "#3a4a35" : "#283028"
        border.width: 1

        CCIcon {
          anchors.centerIn: parent
          width: 20
          height: 20
          kind: "lock"
          glyph: lockBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
        }

        MouseArea {
          id: lockBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.execCmd(["hyprlock"]);
          }
        }
      }

      // 2. Logout
      Rectangle {
        width: 48
        height: 48
        radius: 13
        color: logoutBtnMouse.containsMouse ? "#252d25" : "#181c18"
        border.color: logoutBtnMouse.containsMouse ? "#3a4a35" : "#283028"
        border.width: 1

        CCIcon {
          anchors.centerIn: parent
          width: 20
          height: 20
          kind: "logout"
          glyph: logoutBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
        }

        MouseArea {
          id: logoutBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.execCmd(["hyprctl", "dispatch", "exit"]);
          }
        }
      }

      // 3. Suspend / Sleep
      Rectangle {
        width: 48
        height: 48
        radius: 13
        color: sleepBtnMouse.containsMouse ? "#252d25" : "#181c18"
        border.color: sleepBtnMouse.containsMouse ? "#3a4a35" : "#283028"
        border.width: 1

        CCIcon {
          anchors.centerIn: parent
          width: 20
          height: 20
          kind: "moon"
          glyph: sleepBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
        }

        MouseArea {
          id: sleepBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.execCmd(["systemctl", "suspend"]);
          }
        }
      }

      // 4. Reboot
      Rectangle {
        width: 48
        height: 48
        radius: 13
        color: rebootBtnMouse.containsMouse ? "#252d25" : "#181c18"
        border.color: rebootBtnMouse.containsMouse ? "#3a4a35" : "#283028"
        border.width: 1

        CCIcon {
          anchors.centerIn: parent
          width: 20
          height: 20
          kind: "reboot"
          glyph: rebootBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
        }

        MouseArea {
          id: rebootBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.execCmd(["systemctl", "reboot"]);
          }
        }
      }

      // 5. Shutdown
      Rectangle {
        width: 48
        height: 48
        radius: 13
        color: powerOffBtnMouse.containsMouse ? "#3a1e1e" : "#181c18"
        border.color: powerOffBtnMouse.containsMouse ? "#6a2e2e" : "#283028"
        border.width: 1

        CCIcon {
          anchors.centerIn: parent
          width: 20
          height: 20
          kind: "power"
          glyph: powerOffBtnMouse.containsMouse ? "#ef5350" : "#a8b3a8"
        }

        MouseArea {
          id: powerOffBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.execCmd(["systemctl", "poweroff"]);
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- SETTINGS / APPEARANCE EXPANDED SUBVIEW ----
  // =========================================================================
  // =========================================================================
  // ---- SETTINGS / APPEARANCE EXPANDED SUBVIEW ----
  // =========================================================================
  Item {
    id: settingsPage
    anchors.fill: parent
    anchors.margins: 16
    opacity: (netMouse.containsMouse && root.activePage === "settings") ? 1 : 0
    visible: opacity > 0

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
          font.pixelSize: 18
          font.bold: true
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "APPEARANCE"
          color: SettingsState.textMain
          font.pixelSize: 14
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
          text: "‹"
          color: SettingsState.textMain
          font.pixelSize: 20
          font.bold: true
        }

        MouseArea {
          id: setBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.fontDropdownOpen = false;
            root.activePage = "main";
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
        spacing: 10

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
              font.pixelSize: 13
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
                font.pixelSize: 11
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
                font.pixelSize: 11
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
              font.pixelSize: 13
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
              font.pixelSize: 13
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
              font.pixelSize: 13
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
              font.pixelSize: 13
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
                  font.pixelSize: 11
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
                font.pixelSize: 13
                font.bold: true
                font.family: SettingsState.fontFamily
              }

              Text {
                text: SettingsState.accentHex + " • " + (SettingsState.isDark ? "dark" : "light")
                color: SettingsState.textSecondary
                font.pixelSize: 11
                font.family: SettingsState.fontFamily
              }
            }
          }

          // Dark / Light Pill Switcher
          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Rectangle {
              width: 46
              height: 24
              radius: 6
              color: SettingsState.isDark ? SettingsState.bgActivePill : "transparent"
              border.color: SettingsState.isDark ? SettingsState.borderActive : "transparent"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "Dark"
                color: SettingsState.isDark ? SettingsState.textActive : SettingsState.textMuted
                font.pixelSize: 11
                font.bold: SettingsState.isDark
                font.family: SettingsState.fontFamily
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: SettingsState.setIsDark(true)
              }
            }

            Rectangle {
              width: 46
              height: 24
              radius: 6
              color: !SettingsState.isDark ? SettingsState.bgActivePill : "transparent"
              border.color: !SettingsState.isDark ? SettingsState.borderActive : "transparent"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "Light"
                color: !SettingsState.isDark ? SettingsState.textActive : SettingsState.textMuted
                font.pixelSize: 11
                font.bold: !SettingsState.isDark
                font.family: SettingsState.fontFamily
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: SettingsState.setIsDark(false)
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
              font.pixelSize: 12
              font.bold: true
              font.family: SettingsState.fontFamily
            }

            TextInput {
              id: hexInput
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 30
              text: SettingsState.accentHex
              color: SettingsState.textMain
              font.pixelSize: 12
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
              font.pixelSize: 13
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
              font.pixelSize: 13
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
                  font.pixelSize: 11
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

        // 8. Font family dropdown trigger
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
              kind: "font"
              glyph: SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Font"
              color: SettingsState.textMain
              font.pixelSize: 13
              font.family: SettingsState.fontFamily
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 26
            width: Math.min(180, fontDropText.implicitWidth + 28)
            radius: 8
            color: root.fontDropdownOpen ? SettingsState.bgActivePill : (fontBtnMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
            border.color: root.fontDropdownOpen ? SettingsState.borderActive : SettingsState.borderBase
            border.width: 1

            Row {
              anchors.centerIn: parent
              spacing: 6

              Text {
                id: fontDropText
                text: SettingsState.fontFamily
                color: root.fontDropdownOpen ? SettingsState.textActive : SettingsState.textMain
                font.pixelSize: 11
                font.bold: true
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 140)
              }

              Text {
                text: root.fontDropdownOpen ? "▲" : "›"
                color: SettingsState.textSecondary
                font.pixelSize: 11
                font.bold: true
              }
            }

            MouseArea {
              id: fontBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.fontDropdownOpen = !root.fontDropdownOpen;
                if (root.fontDropdownOpen) {
                  root.fontSearchQuery = "";
                  if (fSearchInput) {
                    fSearchInput.text = "";
                  }
                  Qt.callLater(function() {
                    if (fSearchInput) fSearchInput.forceActiveFocus();
                  });
                }
              }
            }
          }
        }

        // Dropdown expanded content (Search + Font List)
        Column {
          width: parent.width
          spacing: 8
          visible: root.fontDropdownOpen

          // Search box
          Rectangle {
            width: parent.width
            height: 32
            radius: 8
            color: SettingsState.bgCard
            border.color: fSearchInput.activeFocus ? SettingsState.borderActive : SettingsState.borderBase
            border.width: 1

            Row {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: SettingsState.textMuted
                font.pixelSize: 12
                font.family: SettingsState.fontFamily
              }

              Item {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                height: parent.height

                Text {
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  visible: fSearchInput.text.length === 0
                  text: "Search " + SettingsState.availableFonts.length + " fonts..."
                  color: SettingsState.textMuted
                  font.pixelSize: 11
                  font.family: SettingsState.fontFamily
                }

                TextInput {
                  id: fSearchInput
                  anchors.fill: parent
                  verticalAlignment: TextInput.AlignVCenter
                  color: SettingsState.textMain
                  font.pixelSize: 12
                  font.family: SettingsState.fontFamily
                  clip: true
                  focus: true
                  activeFocusOnTab: true
                  selectByMouse: true
                  onTextChanged: {
                    root.fontSearchQuery = text;
                  }
                  Keys.onEscapePressed: function(ev) {
                    root.fontDropdownOpen = false;
                    ev.accepted = true;
                  }
                }
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: fSearchInput.text.length > 0
                text: "✕"
                color: SettingsState.textMuted
                font.pixelSize: 11
                MouseArea {
                  anchors.fill: parent
                  anchors.margins: -6
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    fSearchInput.text = "";
                    fSearchInput.forceActiveFocus();
                  }
                }
              }
            }
          }

          // Scrollable Font list with preview
          ListView {
            width: parent.width
            height: 180
            spacing: 4
            clip: true
            model: root.filteredFonts

            delegate: Rectangle {
              width: ListView.view.width
              height: 32
              radius: 8
              color: SettingsState.fontFamily === modelData ? SettingsState.bgActivePill : (fItemMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
              border.color: SettingsState.fontFamily === modelData ? SettingsState.borderActive : "transparent"
              border.width: 1

              Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Rectangle {
                  width: 6
                  height: 6
                  radius: 3
                  anchors.verticalCenter: parent.verticalCenter
                  color: SettingsState.fontFamily === modelData ? SettingsState.accent : SettingsState.textMuted
                }

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: modelData
                  color: SettingsState.fontFamily === modelData ? SettingsState.textActive : SettingsState.textMain
                  font.pixelSize: 11
                  font.bold: SettingsState.fontFamily === modelData
                  font.family: modelData
                  elide: Text.ElideRight
                }
              }

              MouseArea {
                id: fItemMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  SettingsState.setFont(modelData);
                }
              }
            }
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- SOUND OUTPUT SUBVIEW ----
  // =========================================================================
  Column {
    id: soundPage
    anchors.fill: parent
    anchors.margins: 18
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "sound") ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 220 }
    }

    // Sound Header
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Back button
        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: soundBackMouse.containsMouse ? "#252b25" : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 20
            font.bold: true
          }

          MouseArea {
            id: soundBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Icon
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 18
          kind: "sound"
          glyph: "#c9dfae"
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "SOUND OUTPUT"
          color: "#f2f2f2"
          font.pixelSize: 14
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1.2
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: outMuted ? "Muted" : (Math.round(outVol * 100) + "%")
          color: outMuted ? "#ff8a8a" : "#c9dfae"
          font.pixelSize: 12
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        // Mute toggle switch
        Rectangle {
          width: 40
          height: 22
          radius: 11
          color: !outMuted ? "#3f5938" : "#252b25"
          anchors.verticalCenter: parent.verticalCenter

          Behavior on color {
            ColorAnimation { duration: 200 }
          }

          Rectangle {
            width: 16
            height: 16
            radius: 8
            color: !outMuted ? "#c9dfae" : "#888888"
            anchors.verticalCenter: parent.verticalCenter
            x: !outMuted ? parent.width - width - 3 : 3

            Behavior on x {
              NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: AudioState.toggleOutMute()
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

    // Volume Slider
    CCSlider {
      width: parent.width
      label: "Volume"
      icon: "sound"
      value: outVol
      muted: outMuted
      available: AudioState.sink !== null && AudioState.sink !== undefined
      onSeeked: function (v) {
        AudioState.setOutVol(v);
      }
      onIconClicked: AudioState.toggleOutMute()
    }

    // Section title
    Item {
      width: parent.width
      height: 20

      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Select Output Device"
        color: "#9aa39a"
        font.pixelSize: 12
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: (AudioState.sinks.length || 0) + " available"
        color: "#6e756e"
        font.pixelSize: 11
        font.family: SettingsState.fontFamily
      }
    }

    // Output Device List
    ListView {
      width: parent.width
      height: 260
      spacing: 8
      clip: true
      model: AudioState.sinks

      delegate: Rectangle {
        required property var modelData
        width: ListView.view.width
        height: 52
        radius: 16
        color: modelData.isDefault ? "#243322" : (sDevMouse.containsMouse ? "#1e251e" : "#171c17")
        border.color: modelData.isDefault ? "#3f5938" : (sDevMouse.containsMouse ? "#2b362b" : "#222822")
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 120 }
        }

        Row {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 12

          // Icon Avatar
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 16
            color: modelData.isDefault ? "#c9dfae" : "#242c24"

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "sound"
              glyph: modelData.isDefault ? "#182415" : "#8e998e"
            }
          }

          // Device Info
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 86
            spacing: 2

            Text {
              width: parent.width
              text: modelData.description || modelData.name || "Output Device"
              color: modelData.isDefault ? "#c9dfae" : "#f2f2f2"
              font.pixelSize: 13
              font.bold: modelData.isDefault
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: modelData.isDefault ? "Active Output Route" : (modelData.name || "Audio Sink")
              color: modelData.isDefault ? "#8ea87e" : "#6e756e"
              font.pixelSize: 11
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }
          }

          // Active indicator checkmark badge
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            radius: 11
            color: modelData.isDefault ? "#3f5938" : "transparent"
            border.color: modelData.isDefault ? "#527549" : "#333d33"
            border.width: 1

            Text {
              anchors.centerIn: parent
              visible: modelData.isDefault
              text: "✓"
              color: "#c9dfae"
              font.pixelSize: 12
              font.bold: true
            }
          }
        }

        MouseArea {
          id: sDevMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            AudioState.setDefaultSink(modelData);
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- MICROPHONE INPUT SUBVIEW ----
  // =========================================================================
  Column {
    id: micPage
    anchors.fill: parent
    anchors.margins: 18
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "mic") ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 220 }
    }

    // Mic Header
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Back button
        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: micBackMouse.containsMouse ? "#252b25" : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 20
            font.bold: true
          }

          MouseArea {
            id: micBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Icon
        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 18
          kind: "mic"
          glyph: "#c9dfae"
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "MICROPHONE INPUT"
          color: "#f2f2f2"
          font.pixelSize: 14
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1.2
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: inMuted ? "Muted" : (Math.round(inVol * 100) + "%")
          color: inMuted ? "#ff8a8a" : "#c9dfae"
          font.pixelSize: 12
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        // Mute toggle switch
        Rectangle {
          width: 40
          height: 22
          radius: 11
          color: !inMuted ? "#3f5938" : "#252b25"
          anchors.verticalCenter: parent.verticalCenter

          Behavior on color {
            ColorAnimation { duration: 200 }
          }

          Rectangle {
            width: 16
            height: 16
            radius: 8
            color: !inMuted ? "#c9dfae" : "#888888"
            anchors.verticalCenter: parent.verticalCenter
            x: !inMuted ? parent.width - width - 3 : 3

            Behavior on x {
              NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: AudioState.toggleInMute()
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

    // Input Volume Slider
    CCSlider {
      width: parent.width
      label: "Input Level"
      icon: "mic"
      value: inVol
      muted: inMuted
      available: AudioState.source !== null && AudioState.source !== undefined
      onSeeked: function (v) {
        AudioState.setInVol(v);
      }
      onIconClicked: AudioState.toggleInMute()
    }

    // Section title
    Item {
      width: parent.width
      height: 20

      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "Select Input Device"
        color: "#9aa39a"
        font.pixelSize: 12
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: (AudioState.sources.length || 0) + " available"
        color: "#6e756e"
        font.pixelSize: 11
        font.family: SettingsState.fontFamily
      }
    }

    // Input Device List
    ListView {
      width: parent.width
      height: 260
      spacing: 8
      clip: true
      model: AudioState.sources

      delegate: Rectangle {
        required property var modelData
        width: ListView.view.width
        height: 52
        radius: 16
        color: modelData.isDefault ? "#243322" : (mDevMouse.containsMouse ? "#1e251e" : "#171c17")
        border.color: modelData.isDefault ? "#3f5938" : (mDevMouse.containsMouse ? "#2b362b" : "#222822")
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 120 }
        }

        Row {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 12

          // Icon Avatar
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 16
            color: modelData.isDefault ? "#c9dfae" : "#242c24"

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "mic"
              glyph: modelData.isDefault ? "#182415" : "#8e998e"
            }
          }

          // Device Info
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 86
            spacing: 2

            Text {
              width: parent.width
              text: modelData.description || modelData.name || "Input Device"
              color: modelData.isDefault ? "#c9dfae" : "#f2f2f2"
              font.pixelSize: 13
              font.bold: modelData.isDefault
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: modelData.isDefault ? "Active Input Route" : (modelData.name || "Audio Source")
              color: modelData.isDefault ? "#8ea87e" : "#6e756e"
              font.pixelSize: 11
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }
          }

          // Active indicator checkmark badge
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            radius: 11
            color: modelData.isDefault ? "#3f5938" : "transparent"
            border.color: modelData.isDefault ? "#527549" : "#333d33"
            border.width: 1

            Text {
              anchors.centerIn: parent
              visible: modelData.isDefault
              text: "✓"
              color: "#c9dfae"
              font.pixelSize: 12
              font.bold: true
            }
          }
        }

        MouseArea {
          id: mDevMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            AudioState.setDefaultSource(modelData);
          }
        }
      }
    }
  }

  // =========================================================================
  // ---- HARDWARE MIXER SUBVIEW (MATCHING REFERENCE UI) ----
  // =========================================================================
  Column {
    id: mixerPage
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "mixer") ? 1 : 0
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
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 20
            font.bold: true
          }

          MouseArea {
            id: mixerBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Japanese Kanji Glyph "調" (Tune / Mix)
        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "調"
          color: "#f2f2f2"
          font.pixelSize: 18
          font.bold: true
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "MIXER"
          color: "#f2f2f2"
          font.pixelSize: 14
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
        color: "#181d18"
        border.color: "#283028"
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
            color: !outMuted ? "#2a3826" : (sndBtnMouse.containsMouse ? "#222822" : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: outMuted ? "sound-mute" : "sound"
              glyph: !outMuted ? "#c9dfae" : (outMuted ? "#ff8a8a" : "#9aa39a")
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
            color: !inMuted ? "#2a3826" : (micBtnMouse.containsMouse ? "#222822" : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: inMuted ? "mic-mute" : "mic"
              glyph: !inMuted ? "#c9dfae" : (inMuted ? "#ff8a8a" : "#9aa39a")
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
            color: NotifCenter.dnd ? "#2a3826" : (dndBtnMouse.containsMouse ? "#222822" : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: "bell-slash"
              glyph: NotifCenter.dnd ? "#c9dfae" : "#9aa39a"
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
            color: NightlightState.active ? "#3a2d1d" : (eyeBtnMouse.containsMouse ? "#222822" : "transparent")
            CCIcon {
              anchors.centerIn: parent
              width: 14
              height: 14
              kind: "sunset"
              glyph: NightlightState.active ? "#ffb877" : "#9aa39a"
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
        value: outVol
        muted: outMuted
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
        value: inVol
        muted: inMuted
        activeColor: "#e05f65"
        onSeeked: function (v) {
          AudioState.setInVol(v);
        }
        onIconClicked: AudioState.toggleInMute()
      }
    }
  }

  // =========================================================================
  // ---- SCREEN RECORDER SUBVIEW (MATCHING REFERENCE UI) ----
  // =========================================================================
  Column {
    id: recorderPage
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12
    opacity: (netMouse.containsMouse && root.activePage === "recorder") ? 1 : 0
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
            text: "‹"
            color: "#f2f2f2"
            font.pixelSize: 20
            font.bold: true
          }

          MouseArea {
            id: recBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.activePage = "main";
            }
          }
        }

        // Japanese Kanji Glyph "録" (Record)
        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "録"
          color: "#f2f2f2"
          font.pixelSize: 18
          font.bold: true
        }

        // Title
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "RECORD"
          color: "#f2f2f2"
          font.pixelSize: 14
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 2
        }
      }

      // Right Status Badge
      Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
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
            font.pixelSize: 11
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1
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
        font.pixelSize: 14
        font.bold: true
      }
      // Top-Right bracket: ⌝
      Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 4
        text: "⌝"
        color: "#e05f65"
        font.pixelSize: 14
        font.bold: true
      }
      // Bottom-Left bracket: ⌞
      Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 4
        text: "⌞"
        color: "#e05f65"
        font.pixelSize: 14
        font.bold: true
      }
      // Bottom-Right bracket: ⌟
      Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        text: "⌟"
        color: "#e05f65"
        font.pixelSize: 14
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
              font.pixelSize: 13
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }

          Text {
            text: "• 60 fps • High quality • Fullscreen"
            color: "#8e998e"
            font.pixelSize: 11
            font.family: SettingsState.fontFamily
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
          text: RecorderState.isRecording ? ("Stop recording (" + RecorderState.formattedTime + ")") : "Start recording"
          color: RecorderState.isRecording ? "#ff8a8a" : "#f2f2f2"
          font.pixelSize: 14
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
      height: 84 + (root.recMicDropdownOpen ? (Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) + 8) : 0)
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
            color: AudioState.inMuted ? "#2a1e1e" : "#222a22"
            CCIcon {
              anchors.centerIn: parent
              width: 12
              height: 12
              kind: "mic"
              glyph: AudioState.inMuted ? "#ff8a8a" : "#c9dfae"
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
            color: root.recMicDropdownOpen ? "#2c3b28" : (rMicDevMouse.containsMouse ? "#242e24" : "#1a221a")
            border.color: root.recMicDropdownOpen ? "#4a6842" : (rMicDevMouse.containsMouse ? "#324032" : "#263026")
            border.width: 1
            clip: true

            Row {
              id: rMicDevRow
              anchors.centerIn: parent
              spacing: 4

              Text {
                text: AudioState.sourceName
                color: root.recMicDropdownOpen ? "#c9dfae" : "#d0dad0"
                font.pixelSize: 11
                font.bold: true
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 110)
              }

              Text {
                text: root.recMicDropdownOpen ? "▲" : "▼"
                color: "#8ea08e"
                font.pixelSize: 8
              }
            }

            MouseArea {
              id: rMicDevMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                AudioState.refreshDevices();
                root.recMicDropdownOpen = !root.recMicDropdownOpen;
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
            color: "#1f261f"
            clip: true

            Rectangle {
              height: parent.height
              width: Math.max(parent.height, parent.width * (AudioState.inMuted ? 0 : AudioState.inVol))
              radius: parent.radius
              color: AudioState.inMuted ? "#525252" : "#e05f65"
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
            color: AudioState.inMuted ? "#ff8a8a" : "#9aa39a"
            font.pixelSize: 11
            font.family: SettingsState.fontFamily
            horizontalAlignment: Text.AlignRight
          }
        }

        // Expanded Microphone Device Dropdown List
        ListView {
          visible: root.recMicDropdownOpen
          width: parent.width
          height: root.recMicDropdownOpen ? Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) : 0
          clip: true
          spacing: 4
          model: AudioState.sources

          delegate: Rectangle {
            width: ListView.view.width
            height: 40
            radius: 10
            color: modelData.isDefault ? "#243322" : (mPickMouse.containsMouse ? "#1e261e" : "#131713")
            border.color: modelData.isDefault ? "#3f5938" : (mPickMouse.containsMouse ? "#2d382d" : "#202620")
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
                glyph: modelData.isDefault ? "#c9dfae" : "#8ea08e"
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                text: modelData.description || modelData.name || "Microphone"
                color: modelData.isDefault ? "#f2f2f2" : "#9aa39a"
                font.pixelSize: 11
                font.bold: modelData.isDefault
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: modelData.isDefault
                text: "✓"
                color: "#c9dfae"
                font.pixelSize: 12
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
                root.recMicDropdownOpen = false;
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
            color: AudioState.outMuted ? "#2a1e1e" : "#222a22"
            CCIcon {
              anchors.centerIn: parent
              width: 12
              height: 12
              kind: "sound"
              glyph: AudioState.outMuted ? "#ff8a8a" : "#c9dfae"
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
            color: "#d4dbd4"
            font.pixelSize: 11
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
            color: "#1f261f"
            clip: true

            Rectangle {
              height: parent.height
              width: Math.max(parent.height, parent.width * (AudioState.outMuted ? 0 : AudioState.outVol))
              radius: parent.radius
              color: AudioState.outMuted ? "#525252" : "#e05f65"
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
            color: AudioState.outMuted ? "#ff8a8a" : "#9aa39a"
            font.pixelSize: 11
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
      color: "#161b16"
      border.color: "#252c25"
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
          glyph: "#9aa39a"
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "SAVE TO"
          color: "#6e756e"
          font.pixelSize: 10
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "~/Videos/Recordings"
          color: "#d4dbd4"
          font.pixelSize: 11
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
        color: openDirMouse.containsMouse ? "#2a342a" : "#1f261f"
        border.color: "#303c30"
        border.width: 1

        Text {
          id: openBtnText
          anchors.centerIn: parent
          text: "OPEN"
          color: "#c9dfae"
          font.pixelSize: 10
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
          color: "#f2f2f2"
          font.pixelSize: 13
          font.bold: true
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "RECENT • " + (RecorderState.recentRecordings ? RecorderState.recentRecordings.length : 0)
          color: "#d4dbd4"
          font.pixelSize: 11
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
          font.pixelSize: 10
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
      color: "#6e756e"
      font.pixelSize: 12
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
        color: recCardMouse.containsMouse ? "#1e251e" : "#161b16"
        border.color: recCardMouse.containsMouse ? "#2f3d2f" : "#242c24"
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
            color: recCardMouse.containsMouse ? "#242e24" : "#101410"
            border.color: "#222a22"
            border.width: 1

            CCIcon {
              anchors.centerIn: parent
              width: 16
              height: 16
              kind: "play"
              glyph: recCardMouse.containsMouse ? "#e05f65" : "#c9dfae"
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
              color: "#f2f2f2"
              font.pixelSize: 12
              font.bold: true
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Row {
              spacing: 8
              Text {
                text: modelData.date || ""
                color: "#8e998e"
                font.pixelSize: 11
                font.family: SettingsState.fontFamily
              }
              Text {
                text: "•"
                color: "#4e584e"
                font.pixelSize: 11
              }
              Text {
                text: modelData.size || ""
                color: "#c9dfae"
                font.pixelSize: 11
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

  // Hover tracker
  MouseArea {
    id: netMouse
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    cursorShape: Qt.PointingHandCursor
  }
}
