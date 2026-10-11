pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Aggregates UPower accessory batteries (wireless mouse, keyboard,
// headphones/headset, etc.) so the control center can show e.g.
// "MX Master 2S 55%" alongside Bluetooth battery readouts.
// Laptop batteries / line power / DisplayDevice are excluded.
Singleton {
  id: root

  readonly property var rawDevices: (UPower && UPower.devices) ? UPower.devices.values : []

  // Normalize Quickshell percentage (0..1 fraction on some builds,
  // 0..100 on others) to 0..100 int.
  function pct100(dev) {
    if (!dev || dev.percentage === undefined) return -1;
    var p = Number(dev.percentage);
    if (isNaN(p)) return -1;
    if (p > 0 && p <= 1.01) p = p * 100;
    return Math.round(p);
  }

  function stateText(dev) {
    if (!dev || dev.state === undefined) return "";
    try {
      if (dev.state === UPowerDeviceState.Charging) return "charging";
      if (dev.state === UPowerDeviceState.Discharging) return "discharging";
      if (dev.state === UPowerDeviceState.FullyCharged) return "charged";
      if (dev.state === UPowerDeviceState.PendingCharge) return "pending";
      if (dev.state === UPowerDeviceState.PendingDischarge) return "pending";
      if (dev.state === UPowerDeviceState.Empty) return "empty";
    } catch (e) {}
    return "";
  }

  function iconKindFor(dev) {
    if (!dev) return "mouse";
    var t = undefined;
    try { t = dev.type; } catch (e) {}
    try {
      if (t === UPowerDeviceType.Mouse) return "mouse";
      if (t === UPowerDeviceType.Keyboard) return "keyboard";
      if (t === UPowerDeviceType.Headphones) return "headphones";
      if (t === UPowerDeviceType.Headset) return "headphones";
      if (t === UPowerDeviceType.Speakers) return "speaker";
      if (t === UPowerDeviceType.OtherAudio) return "speaker";
      if (t === UPowerDeviceType.GamingInput) return "gamepad";
      if (t === UPowerDeviceType.Phone) return "phone";
      if (t === UPowerDeviceType.Wearable) return "watch";
      if (t === UPowerDeviceType.Tablet) return "phone";
      if (t === UPowerDeviceType.Touchpad) return "mouse";
    } catch (e) {}
    // Fallback: guess from model string (e.g. "MX Master 2S").
    var m = "";
    try { m = String(dev.model || ""); } catch (e) {}
    m = m.toLowerCase();
    if (m.indexOf("mouse") !== -1 || m.indexOf("mx master") !== -1 || m.indexOf("logi") !== -1) return "mouse";
    if (m.indexOf("keyboard") !== -1) return "keyboard";
    if (m.indexOf("head") !== -1 || m.indexOf("buds") !== -1 || m.indexOf("airpod") !== -1 || m.indexOf("ear") !== -1) return "headphones";
    if (m.indexOf("speaker") !== -1 || m.indexOf("soundcore") !== -1 || m.indexOf("jbl") !== -1 || m.indexOf("bose") !== -1) return "speaker";
    return "mouse";
  }

  function labelFor(dev) {
    if (!dev) return "Unknown";
    var m = "";
    try { m = String(dev.model || "").trim(); } catch (e) {}
    if (m !== "") return m;
    var np = "";
    try { np = String(dev.nativePath || ""); } catch (e) {}
    if (np !== "") return np;
    return "Accessory";
  }

  // Filtered accessory list (plain JS array of UPowerDevice).
  readonly property var accessories: {
    var out = [];
    var list = rawDevices;
    for (var i = 0; i < list.length; ++i) {
      var d = list[i];
      if (!d) continue;
      try {
        if (!d.ready) continue;
        if (d.isLaptopBattery) continue;
        if (d.type === UPowerDeviceType.LinePower) continue;
        if (d.powerSupply === true) continue;
        // Skip empty placeholder devices.
        var hasModel = !!(d.model && String(d.model).trim() !== "");
        var pct = root.pct100(d);
        if (!hasModel && pct < 0) continue;
        if (d.type === UPowerDeviceType.Unknown && !hasModel) continue;
        // UPower Battery entries with no model are usually internal/phantom.
        if (d.type === UPowerDeviceType.Battery && !hasModel) continue;
        out.push(d);
      } catch (e) {}
    }
    return out;
  }

  readonly property bool hasAccessories: accessories.length > 0

  // Compact one-liner for pills, e.g. "MX Master 2S 55%".
  readonly property string summary: {
    if (accessories.length === 0) return "";
    var parts = [];
    for (var i = 0; i < Math.min(2, accessories.length); ++i) {
      var d = accessories[i];
      var p = root.pct100(d);
      parts.push(root.labelFor(d) + (p >= 0 ? " " + p + "%" : ""));
    }
    return parts.join(" · ");
  }
}
