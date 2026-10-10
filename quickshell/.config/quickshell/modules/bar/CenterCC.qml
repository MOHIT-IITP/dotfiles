import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io
import QtQuick
import "../services"

// Full control center hosted inside the center ClockPill.
// Reuses the same pages as the right-side NetworkCircle (MainPage handles
// wifi/bt pills; sliders live in mixer; notifications live in the inbox; calendar lives as a pill).
// This item acts as its own `circle` for all child pages.
Item {
  id: root

  property string activePage: "main" // "main" | "wifi" | "bluetooth" | "power" | "about" | "calendar" | "stats" | ...
  property bool pillsExpanded: false
  property string settingsSub: ""
  property bool fontDropdownOpen: false
  property string fontSearchQuery: ""
  property bool recMicDropdownOpen: false

  onActivePageChanged: {
    if (root.activePage === "settings")
      root.settingsSub = "";
  }

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

  readonly property bool aboutInputOpen: root.activePage === "about" && aboutPage.adding
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

  function resetToMain() {
    root.activePage = "main";
    root.pillsExpanded = false;
    root.settingsSub = "";
    root.fontDropdownOpen = false;
    root.fontSearchQuery = "";
  }

  implicitWidth: {
    if (root.activePage === "calendar") return 560;
    if (root.activePage === "power") return 360;
    if (root.activePage === "mixer" || root.activePage === "recorder" || root.activePage === "screenshot" || root.activePage === "settings") return 420;
    return 410;
  }

  implicitHeight: {
    if (root.activePage === "power") return 138 + 36;
    if (root.activePage === "settings") return settingsPage.implicitHeight + 76;
    if (root.activePage === "sound") return soundPage.implicitHeight + 36;
    if (root.activePage === "mic") return micPage.implicitHeight + 36;
    if (root.activePage === "mixer") return 380;
    if (root.activePage === "screenshot") return 254 + 36;
    if (root.activePage === "bluetooth") return btPage.implicitHeight + 36;
    if (root.activePage === "wifi") return wifiPage.implicitHeight + 36;
    if (root.activePage === "about") return aboutPage.implicitHeight + 36;
    if (root.activePage === "calendar") return calPage.implicitHeight + 36;
    if (root.activePage === "stats") return statsPage.implicitHeight + 36;
    if (root.activePage === "recorder") {
      var extraMic = root.recMicDropdownOpen ? (Math.min(160, (AudioState.sources ? AudioState.sources.length : 1) * 44) + 8) : 0;
      var extraList = (RecorderState.recentRecordings && RecorderState.recentRecordings.length > 0) ? Math.min(180, RecorderState.recentRecordings.length * 60) : 30;
      var extraMode = 52;
      if (RecorderState.mode === "area") extraMode += 48;
      return 460 + extraMode + extraMic + extraList;
    }
    return mainPage.implicitHeight + 36;
  }

  // Hover tracking so ClockPill stays expanded while interacting with
  // buttons that sit above its gesture layer.
  property bool ccHover: false
  HoverHandler {
    id: ccHoverHandler
    onHoveredChanged: root.ccHover = hovered
  }

  MainPage {
    id: mainPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: true
  }

  BluetoothPage {
    id: btPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: true
  }

  WifiPage {
    id: wifiPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: true
  }

  PowerPage {
    id: powerPage
    anchors.fill: parent
    anchors.margins: 12
    circle: root
    hovered: true
  }

  SettingsPage {
    id: settingsPage
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: true
  }

  SoundPage {
    id: soundPage
    anchors.fill: parent
    anchors.margins: 18
    circle: root
    hovered: true
  }

  MicPage {
    id: micPage
    anchors.fill: parent
    anchors.margins: 18
    circle: root
    hovered: true
  }

  MixerPage {
    id: mixerPage
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: true
  }

  RecorderPage {
    id: recorderPage
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: true
  }

  ScreenshotPage {
    id: screenshotPage
    anchors.fill: parent
    anchors.margins: 18
    circle: root
    hovered: true
  }

  AboutPage {
    id: aboutPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: true
  }

  CCCalendarPage {
    id: calPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: true
  }

  CCStatsPage {
    id: statsPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    circle: root
    hovered: true
  }
}
