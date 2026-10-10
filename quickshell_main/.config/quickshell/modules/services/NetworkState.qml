pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

// Shared network state: which device is up and what it is connected to.
// Prefer wired when both are up.
Singleton {
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

  readonly property string wifiName: wifiUp ? activeWifiNet.name : "Disconnected"
  readonly property int wifiSignal: (wifiUp && activeWifiNet.signalStrength !== undefined) ? Math.round(activeWifiNet.signalStrength * 100) : 0

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
}
