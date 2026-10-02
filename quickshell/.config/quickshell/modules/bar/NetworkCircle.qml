import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import "../services"

// Right circle: collapsed wifi/ethernet icon with dark amber ring.
// Hovered: full control center (wifi, bluetooth, sound, microphone, notifications).
// Clicking Wi-Fi, Bluetooth, or Power opens detailed subview matching reference UI.
Rectangle {
  id: root

  property string activePage: "main" // "main" | "wifi" | "bluetooth" | "power" | "about"

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
  // True while the About add-form is open in the control center — Bar.qml
  // uses this to grab keyboard focus (same mechanism as fontDropdownOpen).
  // NOTE: the keybind-driven About view lives in the center ClockPill and
  // uses AboutState.open directly; this only covers the hover subview here.
  readonly property bool aboutInputOpen: root.activePage === "about" && aboutPage.adding && netMouse.containsMouse
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

  implicitWidth: {
    if (!netMouse.containsMouse) return 34;
    if (root.activePage === "power") return 340;
    if (root.activePage === "mixer" || root.activePage === "recorder" || root.activePage === "screenshot" || root.activePage === "settings") return 420;
    return 410;
  }

  implicitHeight: {
    if (!netMouse.containsMouse) return 34;
    if (root.activePage === "power") return 130;
    if (root.activePage === "settings") return settingsPage.implicitHeight + 76;
    if (root.activePage === "sound" || root.activePage === "mic") return 520;
    if (root.activePage === "mixer") return 380;
    if (root.activePage === "screenshot") return 254;
    if (root.activePage === "bluetooth") return btPage.implicitHeight + 36;
    if (root.activePage === "wifi") return wifiPage.implicitHeight + 36;
    if (root.activePage === "about") return aboutPage.implicitHeight + 36;
    if (root.activePage === "recorder") {
      var extraMic = root.recMicDropdownOpen ? (Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) + 8) : 0;
      var extraList = (RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0) ? Math.min(180, RecorderState.recentRecordings.length * 60) : 30;
      var extraMode = 52; // Fullscreen | Record area toggle
      if (RecorderState.mode === "area") extraMode += 48; // area selection row
      return 460 + extraMode + extraMic + extraList;
    }
    return mainPage.implicitHeight + 36;
  }
  radius: netMouse.containsMouse ? 30 : 17
  clip: true

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

  function forceFocusFontSearch() {
    if (settingsPage) settingsPage.forceFocusFontSearch();
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

  // ---- Main control-center page (pills, sliders, notifications). (see MainPage.qml) ----
  MainPage {
    id: mainPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Bluetooth expanded subview. (see BluetoothPage.qml) ----
  BluetoothPage {
    id: btPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Wi-Fi expanded subview. (see WifiPage.qml) ----
  WifiPage {
    id: wifiPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Power menu expanded subview. (see PowerPage.qml) ----
  PowerPage {
    id: powerPage
    anchors.fill: parent
    anchors.margins: 12
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Settings / appearance expanded subview. (see SettingsPage.qml) ----
  SettingsPage {
    id: settingsPage
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Sound output subview. (see SoundPage.qml) ----
  SoundPage {
    id: soundPage
    anchors.fill: parent
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Microphone input subview. (see MicPage.qml) ----
  MicPage {
    id: micPage
    anchors.fill: parent
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Hardware mixer subview. (see MixerPage.qml) ----
  MixerPage {
    id: mixerPage
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Screen recorder subview. (see RecorderPage.qml) ----
  RecorderPage {
    id: recorderPage
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- Screenshot / capture view. (see ScreenshotPage.qml) ----
  ScreenshotPage {
    id: screenshotPage
    anchors.fill: parent
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
  }

  // ---- About / profile-links subview. (see AboutPage.qml) ----
  AboutPage {
    id: aboutPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: netMouse.containsMouse
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
