pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

// Shared network state: which device is up and what it is connected to.
// Prefer wired when both are up.
Singleton {
  id: root
  readonly property var wifiDev: {
    var ds = (Networking.devices) ? Networking.devices.values : [];
    for (var i = 0; i < ds.length; ++i) {
      if (ds[i] && ds[i].type === DeviceType.Wifi)
        return ds[i];
    }
    return null;
  }

  readonly property var wiredDev: {
    var ds = (Networking.devices) ? Networking.devices.values : [];
    for (var i = 0; i < ds.length; ++i) {
      if (ds[i] && ds[i].type === DeviceType.Wired)
        return ds[i];
    }
    return null;
  }

  readonly property var activeWifiNet: {
    var dev = wifiDev;
    if (!dev || !dev.networks)
      return null;
    var ns = dev.networks.values;
    for (var j = 0; j < ns.length; ++j) {
      if (ns[j] && ns[j].connected)
        return ns[j];
    }
    return null;
  }

  readonly property bool wiredUp: wiredDev && wiredDev.connected
  readonly property bool wifiUp: activeWifiNet !== null && activeWifiNet !== undefined
  readonly property string activeType: wiredUp ? "wired" : (wifiUp ? "wifi" : "none")
  readonly property bool wifiEnabled: Networking.wifiEnabled

  function toggleWifi() {
    Networking.wifiEnabled = !Networking.wifiEnabled;
  }

  function disconnectWifi(net) {
    try {
      if (net && typeof net.disconnect === "function") {
        net.disconnect();
        return;
      }
    } catch (e) {}
    // Fallback: disconnect the whole wifi device
    try {
      if (wifiDev && typeof wifiDev.disconnect === "function")
        wifiDev.disconnect();
    } catch (e) {}
  }

  readonly property string wifiName: wifiUp ? activeWifiNet.name : "Disconnected"

  // Wi-Fi network list sorted by connected > signal, deduped by name.
  // (Single source of truth for WifiPage via circle.wifiNetworksList.)
  readonly property var sortedNetworks: {
    var dev = wifiDev;
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

  readonly property string wiredName: {
    if (!wiredUp)
      return "Disconnected";
    if (wiredDev.networks) {
      var ns = wiredDev.networks.values;
      for (var j = 0; j < ns.length; ++j) {
        if (ns[j] && ns[j].connected && ns[j].name)
          return ns[j].name;
      }
    }
    return wiredDev.name || "Connected";
  }

  // ---- Wired / Ethernet details (interface, IP, link speed) ----
  // Quickshell.Networking only tells us up/down + name, so poll the
  // OS for the interface behind wiredDev (e.g. enp10s0 -> IP/speed).
  property string wiredIface: ""
  property string wiredIp: ""
  property string wiredSpeed: "" // e.g. "1000 Mb/s"
  property string wiredOpState: ""
  property string _netStdout: ""

  function wiredSummary() {
    if (!wiredUp) return "Cable unplugged";
    var bits = [];
    if (wiredIface !== "") bits.push(wiredIface);
    if (wiredIp !== "") bits.push(wiredIp);
    if (wiredSpeed !== "") bits.push(wiredSpeed);
    if (bits.length === 0) return wiredName;
    return bits.join(" · ");
  }

  function refreshWired() {
    _netStdout = "";
    if (netProc.running)
      netProc.running = false;
    var iface = (wiredDev && wiredDev.name) ? String(wiredDev.name) : "";
    root.wiredIface = iface;
    if (iface === "") {
      root.wiredIp = "";
      root.wiredSpeed = "";
      root.wiredOpState = "";
      return;
    }
    netProc.command = ["bash", "-c", "IF=" + "'" + iface.replace(/'/g, "'\\''") + "'; echo \"IF=$IF\"; ip -4 -o addr show \"$IF\" 2>/dev/null | awk '{print \"IP=\" $4}' | cut -d/ -f1 | head -n1; [ -f /sys/class/net/\"$IF\"/speed ] && echo \"SPEED=$(cat /sys/class/net/\"$IF\"/speed 2>/dev/null)\"; [ -f /sys/class/net/\"$IF\"/operstate ] && echo \"STATE=$(cat /sys/class/net/\"$IF\"/operstate 2>/dev/null)\""];
    netProc.running = true;
  }

  Timer {
    interval: 5000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refreshWired()
  }

  Process {
    id: netProc
    running: false
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data)
          root._netStdout += data;
      }
    }
    onExited: function (code, status) {
      try {
        var txt = (root._netStdout || "").trim();
        if (txt === "") return;
        var lines = txt.split("\n");
        var ip = "", speed = "", state = "";
        for (var i = 0; i < lines.length; ++i) {
          var ln = lines[i].trim();
          if (ln.indexOf("IP=") === 0) ip = ln.substring(3).trim();
          else if (ln.indexOf("SPEED=") === 0) speed = ln.substring(6).trim();
          else if (ln.indexOf("STATE=") === 0) state = ln.substring(6).trim();
        }
        root.wiredIp = (ip === "" || ip === "IP=") ? "" : ip;
        if (speed !== "" && speed !== "-1" && speed !== "4294967295") {
          var n = parseInt(speed, 10);
          root.wiredSpeed = isNaN(n) ? "" : (n >= 1000 && n % 1000 === 0 ? (n / 1000) + " Gb/s" : n + " Mb/s");
        } else {
          root.wiredSpeed = "";
        }
        root.wiredOpState = state;
      } catch (e) {}
    }
  }
}
