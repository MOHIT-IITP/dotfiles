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

  function setEnabled(val) {
    if (adapter)
      adapter.enabled = val;
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

  function stopDiscovery() {
    if (adapter) {
      try {
        adapter.discovering = false;
      } catch (e) {
        console.log("Bluetooth stop discovery error: " + e);
      }
    }
  }
}
