import QtQuick
import QtQuick.Shapes
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
  property real iconSize: Math.round(Math.min(width, height) * 0.85) + 2

  // Exact Material Symbols moon (dark_mode) SVG for moon/sleep/suspend/dnd.
  readonly property bool isMoonSvg: ["moon", "sleep", "suspend", "dnd"].indexOf((kind || "").toLowerCase()) !== -1

  readonly property string iconSymbol: {
    var k = (kind || "").toLowerCase();
    if (k === "wifi") return "";
    if (k === "wifi-off") return "󰤮";
    if (k === "bt" || k === "bluetooth") return "";
    if (k === "bt-connected") return "󰂱";
    if (k === "mouse") return "󰍽";
    if (k === "headphones" || k === "headphone" || k === "headset" || k === "earbuds" || k === "buds") return "";
    if (k === "keyboard") return "";
    if (k === "phone" || k === "mobile" || k === "smartphone") return "";
    if (k === "gamepad" || k === "controller") return "";
    if (k === "watch") return "󰓩";
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
    if (k === "moon" || k === "sleep" || k === "suspend" || k === "dnd") return "󰽧";
    if (k === "sunset" || k === "nightlight" || k === "night") return "󰖔";
    if (k === "sun" || k === "brightness") return "󰃟";
    if (k === "display" || k === "monitor" || k === "screen") return "󰍹";
    if (k === "game" || k === "gamepad" || k === "gaming") return "";
    if (k === "bell-slash") return "󰂛";
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
    if (k === "palette" || k === "theme") return "󰍻";
    if (k === "folder" || k === "folders" || k === "directory") return "";
    if (k === "file" || k === "files" || k === "doc" || k === "document") return "";
    if (k === "scale") return "";
    if (k === "about" || k === "user" || k === "person" || k === "profile" || k === "id") return "";
    if (k === "info") return "";
    if (k === "link" || k === "url" || k === "web") return "";
    if (k === "mail" || k === "email" || k === "envelope") return "";
    if (k === "chrome" || k === "chromium" || k === "google-chrome") return "";
    if (k === "firefox" || k === "zen") return "";
    if (k === "discord" || k === "vesktop") return "󰙯";
    if (k === "spotify") return "";
    if (k === "telegram") return "";
    if (k === "whatsapp") return "";
    if (k === "slack") return "";
    if (k === "steam") return "";
    if (k === "terminal" || k === "term" || k === "console") return "";
    if (k === "vscode" || k === "code" || k === "codium") return "";
    if (k === "github" || k === "gh") return "";
    if (k === "linkedin" || k === "in") return "";
    if (k === "plus" || k === "add") return "";
    if (k === "trash" || k === "delete" || k === "remove") return "";
    if (k === "external" || k === "open") return "";
    if (k === "copy") return "";
    if (k === "wave" || k === "motion") return "󰐊";
    if (k === "font") return "";
    if (k === "eye" || k === "autohide" || k === "hide") return "";
    if (k === "ethernet" || k === "wired") return "󰈀";
    return "";
  }

  Text {
    visible: !root.isMoonSvg
    anchors.fill: parent
    text: root.iconSymbol
    color: root.glyph
    // Icons always use CommitMono Nerd Font Propo, independent of the
    // Appearance font picker (SettingsState.fontFamily is text-only).
    font.family: SettingsState.nerdIconFont
    font.pixelSize: root.iconSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  // Material Symbols dark_mode moon, exact SVG path from Material Icons.
  // Original viewBox 0 -960 960 960 shifted to 0 0 960 960 (+960 Y on absolutes).
  Item {
    visible: root.isMoonSvg
    anchors.centerIn: parent
    width: root.iconSize
    height: root.iconSize
    clip: false

    Shape {
      width: 960
      height: 960
      transformOrigin: Item.TopLeft
      scale: root.iconSize / 960
      antialiasing: true
      asynchronous: true

      ShapePath {
        fillColor: root.glyph
        strokeWidth: 0
        strokeColor: "transparent"
        PathSvg {
          path: "M480 840q-150 0-255-105T120 480q0-150 105-255t255-105q14 0 27.5 1t26.5 3q-41 29-65.5 75.5T444 300q0 90 63 153t153 63q55 0 101-24.5t75-65.5q2 13 3 26.5t1 27.5q0 150-105 255T480 840Zm0-80q88 0 158-48.5T740 585q-20 5-40 8t-40 3q-123 0-209.5-86.5T364 300q0-20 3-40t8-40q-78 32-126.5 102T200 480q0 116 82 198t198 82Zm-10-270Z"
        }
      }
    }
  }
}
