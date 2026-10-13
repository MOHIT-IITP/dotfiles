pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

// Shared bluetooth state: adapter power, discovery, devices list, and active device.
Singleton {
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool btOn: adapter ? adapter.enabled : false
  readonly property bool discovering: adapter ? Boolean(adapter.discovering) : false

  readonly property var devices: (Bluetooth.devices) ? Bluetooth.devices.values : []

  readonly property var btDevice: {
    var ds = devices;
    for (var i = 0; i < ds.length; ++i) {
      if (ds[i] && ds[i].connected)
        return ds[i];
    }
    return null;
  }

  // Device list sorted by connected > paired > name.
  // (Single source of truth for BluetoothPage via circle.btDevicesList.)
  readonly property var sortedDevices: {
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

  readonly property string btName: {
    if (!btOn)
      return "Off";
    if (btDevice)
      return btDevice.name || btDevice.deviceName || "Unknown";
    return "Not connected";
  }

  function toggle() {
    if (adapter)
      adapter.enabled = !adapter.enabled;
  }

  function startDiscovery() {
    if (adapter && adapter.enabled) {
      try {
        adapter.discovering = true;
      } catch (e) {
        console.log("Bluetooth discovery error: " + e);
      }
    }
  }
}
