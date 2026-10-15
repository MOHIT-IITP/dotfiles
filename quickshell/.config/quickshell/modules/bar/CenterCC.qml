import QtQuick
import "../services"

// Full control center hosted inside the center ClockPill.
// Houses subpages (MainPage, WifiPage, BluetoothPage, SettingsPage, AudioPage, MixerPage, RecorderPage, ScreenshotPage, CCCalendarPage, CCStatsPage).
// This item acts as its own `circle` for all child pages.
Item {
  id: root

  property string activePage: "main" // "main" | "wifi" | "bluetooth" | "calendar" | "stats" | "mixer" | "recorder" | "screenshot" | "settings"
  property string settingsSub: ""
  property bool fontDropdownOpen: false
  property string fontSearchQuery: ""
  property bool recMicDropdownOpen: false

  onActivePageChanged: {
    if (root.activePage === "settings")
      root.settingsSub = "";
  }

  readonly property bool wifiUp: NetworkState.wifiUp
  readonly property bool wiredUp: NetworkState.wiredUp

  readonly property bool btOn: BluetoothState.btOn

  readonly property real outVol: AudioState.outVol
  readonly property bool outMuted: AudioState.outMuted
  readonly property real inVol: AudioState.inVol
  readonly property bool inMuted: AudioState.inMuted

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

  // Aliases to the single source of truth in the services (see
  // BluetoothState.sortedDevices / NetworkState.sortedNetworks).
  // Kept so pages can keep using `circle.btDevicesList`.
  readonly property var btDevicesList: BluetoothState.sortedDevices

  readonly property var wifiNetworksList: NetworkState.sortedNetworks

  function forceFocusFontSearch() {
    if (settingsPage) settingsPage.forceFocusFontSearch();
  }

  function resetToMain() {
    root.activePage = "main";
    root.settingsSub = "";
    root.fontDropdownOpen = false;
    root.fontSearchQuery = "";
  }

  implicitWidth: {
    if (root.activePage === "calendar") return 410;
    if (root.activePage === "mixer" || root.activePage === "recorder" || root.activePage === "screenshot" || root.activePage === "settings") return 420;
    if (root.activePage === "main") return mainPage.implicitWidth + 32;
    return 410;
  }

  implicitHeight: {
    if (root.activePage === "settings") return settingsPage.implicitHeight + 76;
    if (root.activePage === "sound") return soundPage.implicitHeight + 32;
    if (root.activePage === "mic") return micPage.implicitHeight + 32;
    if (root.activePage === "mixer") return 380;
    if (root.activePage === "screenshot") return 250;
    if (root.activePage === "bluetooth") return btPage.implicitHeight + 32;
    if (root.activePage === "wifi") return wifiPage.implicitHeight + 32;
    if (root.activePage === "calendar") return calPage.implicitHeight + 32;
    if (root.activePage === "stats") return statsPage.implicitHeight + 32;
    if (root.activePage === "recorder") {
      return recorderPage.implicitHeight + 32;
    }
    return mainPage.implicitHeight + 32;
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
    anchors.topMargin: 16
    anchors.leftMargin: 16
    anchors.rightMargin: 16
    anchors.bottomMargin: 16
    circle: root
    hovered: true
  }

  BluetoothPage {
    id: btPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 16
    circle: root
    hovered: true
  }

  WifiPage {
    id: wifiPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 16
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

  AudioPage {
    id: soundPage
    direction: "output"
    anchors.fill: parent
    anchors.margins: 16
    circle: root
    hovered: true
  }

  AudioPage {
    id: micPage
    direction: "input"
    anchors.fill: parent
    anchors.margins: 16
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
    anchors.margins: 16
    circle: root
    hovered: true
  }

  CCCalendarPage {
    id: calPage
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 16
    // Fixed width (matches implicitWidth 410 - margins) so the pill
    // resize animation doesn't reflow the day grid every frame (jitter).
    width: 378
    circle: root
    hovered: true
  }

  CCStatsPage {
    id: statsPage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 16
    circle: root
    hovered: true
  }
}
