import QtQuick
import "../services"

// Outline icon set: Codicons (same thin stroke as nf-cod-music U+EC1B) +
// Material outline variants. No solid/filled glyphs.
Item {
  id: root
  width: 20
  height: 20
  implicitWidth: 20
  implicitHeight: 20

  property string kind: "wifi"
  property color glyph: "#22301f"
  property real iconSize: Math.round(Math.min(width, height) * 0.85) + 2

  readonly property string iconSymbol: {
    var k = (kind || "").toLowerCase();
    if (k === "wifi") return "󰖩"; // nf-md-wifi
    if (k === "wifi-off") return "󰖪"; // nf-md-wifi_off
    if (k === "bt" || k === "bluetooth") return "󰂯"; // nf-md-bluetooth
    if (k === "bt-connected") return "󰂱"; // nf-md-bluetooth_connect
    if (k === "mouse") return "󰍽"; // nf-md-mouse
    if (k === "headphones" || k === "headphone" || k === "headset" || k === "earbuds" || k === "buds") return "󰋋"; // nf-md-headphones
    if (k === "keyboard") return "󰥻"; // nf-md-keyboard_outline
    if (k === "phone" || k === "mobile" || k === "smartphone") return "󰷰"; // nf-md-phone_outline
    if (k === "gamepad" || k === "controller") return ""; // nf-cod-game
    if (k === "watch") return ""; // nf-cod-watch
    if (k === "sound" || k === "speaker" || k === "audio" || k === "volume") return "󰕾"; // nf-md-volume_high
    if (k === "sound-mute" || k === "speaker-mute" || k === "muted" || k === "volume-mute" || k === "mute") return "󰖁"; // nf-md-volume_off
    if (k === "mic" || k === "microphone") return ""; // nf-cod-mic
    if (k === "mic-mute" || k === "microphone-mute") return "󰍭"; // nf-md-microphone_off
    if (k === "bell" || k === "notif") return ""; // nf-cod-bell
    if (k === "apps" || k === "launcher") return "󱇙"; // nf-md-view_grid_outline
    if (k === "wallpaper" || k === "image" || k === "wall" || k === "gallery") return "󰥶"; // nf-md-image_outline
    if (k === "clipboard" || k === "clip") return "󰅌"; // nf-md-clipboard_outline
    if (k === "gear" || k === "settings" || k === "config") return ""; // nf-cod-gear
    if (k === "lock") return ""; // nf-cod-lock
    if (k === "logout" || k === "exit") return ""; // nf-cod-sign_out
    if (k === "moon" || k === "sleep" || k === "suspend" || k === "dnd") return "󰖔"; // nf-md-weather_night
    if (k === "sunset" || k === "nightlight" || k === "night") return "󰖚"; // nf-md-weather_sunset
    if (k === "sun" || k === "brightness") return "󰖨"; // nf-md-white_balance_sunny
    if (k === "display" || k === "monitor" || k === "screen") return "󰍹"; // nf-md-monitor
    if (k === "game" || k === "gaming") return ""; // nf-cod-game
    if (k === "bell-slash") return ""; // nf-cod-bell_slash
    if (k === "mixer" || k === "tune" || k === "fader" || k === "sliders") return "󰘮"; // nf-md-tune
    if (k === "record" || k === "recorder" || k === "rec" || k === "video") return ""; // nf-cod-record
    if (k === "camera" || k === "screenshot" || k === "shot" || k === "still" || k === "photo") return "󰵝"; // nf-md-camera_outline
    if (k === "window" || k === "app-window") return ""; // nf-cod-window
    if (k === "area" || k === "crop" || k === "selection") return "󰆞"; // nf-md-crop
    if (k === "play") return "󰼛"; // nf-md-play_outline
    if (k === "stop") return "󰙧"; // nf-md-stop_circle_outline
    if (k === "reboot" || k === "restart") return ""; // nf-cod-refresh
    if (k === "power" || k === "shutdown") return "󰐥"; // nf-md-power
    if (k === "time" || k === "clock") return "󰅐"; // nf-md-clock_outline
    if (k === "calendar" || k === "cal" || k === "date") return "󰃭"; // nf-md-calendar_blank_outline
    if (k === "stopwatch") return "󰔛"; // nf-md-timer_outline
    if (k === "music" || k === "note") return ""; // nf-cod-music
    if (k === "palette" || k === "theme") return "󰸌"; // nf-md-palette_outline
    if (k === "folder" || k === "folders" || k === "directory") return ""; // nf-cod-folder
    if (k === "file" || k === "files" || k === "doc" || k === "document") return ""; // nf-cod-file
    if (k === "scale") return "󰗑"; // nf-md-scale_balance
    if (k === "about" || k === "user" || k === "person" || k === "profile" || k === "id") return "󰀓"; // nf-md-account_outline
    if (k === "info") return "󰋽"; // nf-md-information_outline
    if (k === "link" || k === "url" || k === "web") return ""; // nf-cod-link
    if (k === "mail" || k === "email" || k === "envelope") return "󰇰"; // nf-md-email_outline
    if (k === "chrome" || k === "chromium" || k === "google-chrome") return ""; // brand (no outline)
    if (k === "firefox" || k === "zen") return ""; // brand (no outline)
    if (k === "discord" || k === "vesktop") return "󰙯"; // brand (no outline)
    if (k === "spotify") return ""; // brand (no outline)
    if (k === "telegram") return ""; // brand (no outline)
    if (k === "whatsapp") return ""; // brand (no outline)
    if (k === "slack") return ""; // brand (no outline)
    if (k === "steam") return ""; // brand (no outline)
    if (k === "terminal" || k === "term" || k === "console") return ""; // nf-cod-terminal
    if (k === "vscode" || k === "code" || k === "codium") return ""; // nf-cod-vscode
    if (k === "github" || k === "gh") return ""; // nf-cod-github
    if (k === "linkedin" || k === "in") return ""; // brand (no outline)
    if (k === "plus" || k === "add") return ""; // nf-cod-add
    if (k === "trash" || k === "delete" || k === "remove") return ""; // nf-cod-trash
    if (k === "close" || k === "cancel" || k === "cross" || k === "x") return "\uea76"; // nf-cod-close
    if (k === "check" || k === "tick" || k === "confirm" || k === "done" || k === "accept") return "\ueab2"; // nf-cod-check
    if (k === "arrow-right" || k === "right" || k === "next") return "\uea9c"; // nf-cod-arrow_right
    if (k === "external" || k === "open") return ""; // nf-cod-link_external
    if (k === "copy") return ""; // nf-cod-copy
    if (k === "wave" || k === "motion") return "󰥛"; // nf-md-sine_wave
    if (k === "cpu" || k === "processor" || k === "chip" || k === "pulse" || k === "activity") return ""; // nf-cod-chip
    if (k === "ram" || k === "memory") return "󰍛"; // nf-md-memory
    if (k === "swap" || k === "exchange" || k === "transfer" || k === "swap_horizontal") return "󰓡"; // nf-md-swap_horizontal
    if (k === "disk" || k === "hdd" || k === "drive" || k === "storage") return "󰋊"; // nf-md-harddisk
    if (k === "ethernet" || k === "wired") return "󰈀"; // nf-md-ethernet
    if (k === "font") return "󰛖"; // nf-md-format_font
    if (k === "eye" || k === "autohide" || k === "hide") return "󰛐"; // nf-md-eye_outline
    if (k === "eye-off") return "󰛑"; // nf-md-eye_off_outline
    if (k === "sine_wave") return "󰥛"; // nf-md-sine_wave
    return ""; // nf-cod-question fallback
  }

  Text {
    anchors.fill: parent
    text: root.iconSymbol
    color: root.glyph
    font.family: SettingsState.nerdIconFont
    font.pixelSize: root.iconSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }
}
