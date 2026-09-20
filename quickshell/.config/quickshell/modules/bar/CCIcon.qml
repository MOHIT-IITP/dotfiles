import QtQuick
import "../services"

// Crisp icon representation rendering directly with the selected font.
Item {
  id: root
  width: 20
  height: 20
  implicitWidth: 20
  implicitHeight: 20

  property string kind: "wifi"
  property color glyph: "#22301f"
  property real iconSize: Math.round(Math.min(width, height) * 0.85)

  readonly property string iconSymbol: {
    var k = (kind || "").toLowerCase();
    if (k === "wifi") return "";
    if (k === "wifi-off") return "󰤮";
    if (k === "bt" || k === "bluetooth") return "";
    if (k === "bt-connected") return "󰂱";
    if (k === "sound" || k === "speaker" || k === "audio" || k === "volume") return "";
    if (k === "sound-mute" || k === "speaker-mute" || k === "muted" || k === "volume-mute" || k === "mute") return "󰖁";
    if (k === "mic" || k === "microphone") return "";
    if (k === "mic-mute" || k === "microphone-mute") return "";
    if (k === "bell" || k === "notif") return "";
    if (k === "apps" || k === "launcher") return "";
    if (k === "wallpaper" || k === "image" || k === "wall" || k === "gallery") return "";
    if (k === "clipboard" || k === "clip" || k === "copy") return "";
    if (k === "gear" || k === "settings" || k === "config") return "";
    if (k === "lock") return "";
    if (k === "logout" || k === "exit") return "";
    if (k === "moon" || k === "sleep" || k === "suspend") return "";
    if (k === "sunset" || k === "nightlight" || k === "night") return "󰖔";
    if (k === "sun" || k === "brightness") return "󰃟";
    if (k === "display" || k === "monitor" || k === "screen") return "󰍹";
    if (k === "game" || k === "gamepad" || k === "gaming") return "";
    if (k === "bell-slash" || k === "dnd") return "󰂛";
    if (k === "mixer" || k === "tune" || k === "fader" || k === "sliders") return "󰕾";
    if (k === "record" || k === "recorder" || k === "rec" || k === "video") return "󰕧";
    if (k === "camera" || k === "screenshot" || k === "shot" || k === "still" || k === "photo") return "";
    if (k === "window" || k === "app-window") return "";
    if (k === "area" || k === "crop" || k === "selection") return "";
    if (k === "play") return "";
    if (k === "stop") return "";
    if (k === "reboot" || k === "restart") return "";
    if (k === "power" || k === "shutdown") return "";
    if (k === "time" || k === "clock") return "";
    if (k === "stopwatch") return "";
    if (k === "music" || k === "note") return "";
    if (k === "palette" || k === "theme") return "";
    if (k === "folder") return "";
    if (k === "scale") return "";
    if (k === "wave" || k === "motion") return "󰐊";
    if (k === "font") return "";
    if (k === "eye" || k === "autohide" || k === "hide") return "";
    if (k === "ethernet" || k === "wired") return "󰈀";
    return "";
  }

  Text {
    anchors.fill: parent
    text: root.iconSymbol
    color: root.glyph
    font.family: (SettingsState.fontFamily && SettingsState.fontFamily.indexOf("Nerd Font") !== -1)
      ? SettingsState.fontFamily
      : (SettingsState.fontFamily + ", JetBrainsMono Nerd Font, Symbols Nerd Font, Cascadia Code Nerd Font, monospace")
    font.pixelSize: root.iconSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }
}
