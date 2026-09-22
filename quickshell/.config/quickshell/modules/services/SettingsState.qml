pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Global settings & theme singleton managing color palette, appearance, and UI behavior.
Singleton {
  id: root

  // 1. Time settings
  property string timeFormat: "24h" // "24h" | "12h"
  property bool clockSeconds: false
  property bool japaneseGlyphs: true

  // 2. Visuals
  property bool musicVisualizer: true
  property string wallpaperFolder: "~/Pictures/Wallpapers"

  // 3. UI scale & Bar Gap
  property real uiScale: 1.0
  property int barGap: 2 // Extra gap below bar in pixels (0 - 24px)

  // 4. Theme & Accent Colors
  property string themeMode: "manual" // "light" | "dark" | "dynamic" | "manual"
  property real accentHue: 0.52       // 0.0 - 1.0 (0.52 = #40AABF teal/cyan from reference)
  property real accentSat: 0.65
  property real accentVal: 0.85
  property real themeBlend: 1.0 // 0.0 = light, 1.0 = dark (slider)
  property bool isDark: true // mirrored from themeBlend (>= 0.5), kept for icon logic compat

  // Reactive primary accent color
  readonly property color accent: {
    if (themeMode === "light") {
      return Qt.hsva(accentHue, 0.75, 0.70, 1.0);
    } else if (themeMode === "dark") {
      return Qt.hsva(0.38, 0.55, 0.85, 1.0); // Classic dark emerald/coral
    }
    return Qt.hsva(accentHue, accentSat, accentVal, 1.0);
  }

  // Reactive hex color string e.g. "#40AABF"
  readonly property string accentHex: {
    var c = accent;
    var r = Math.round(c.r * 255).toString(16).padStart(2, '0');
    var g = Math.round(c.g * 255).toString(16).padStart(2, '0');
    var b = Math.round(c.b * 255).toString(16).padStart(2, '0');
    return ("#" + r + g + b).toUpperCase();
  }

  // Interpolate two colors by t (0 = a/light, 1 = b/dark)
  function mixc(a, b, t) {
    var tt = Math.min(1.0, Math.max(0.0, t));
    var ca = Qt.color(a);
    var cb = Qt.color(b);
    return Qt.rgba(ca.r + (cb.r - ca.r) * tt, ca.g + (cb.g - ca.g) * tt, ca.b + (cb.b - ca.b) * tt, ca.a + (cb.a - ca.a) * tt);
  }

  // Reactive Theme Palettes (blend light -> dark via themeBlend)
  readonly property color bgSurface: mixc(Qt.hsva(accentHue, 0.06, 0.95, 0.96), Qt.hsva(accentHue, 0.12, 0.07, 0.96), themeBlend)

  readonly property color bgCard: mixc(Qt.hsva(accentHue, 0.08, 0.89, 1.0), Qt.hsva(accentHue, 0.15, 0.11, 1.0), themeBlend)

  readonly property color bgCardHover: mixc(Qt.hsva(accentHue, 0.10, 0.84, 1.0), Qt.hsva(accentHue, 0.20, 0.15, 1.0), themeBlend)

  readonly property color bgActivePill: mixc(Qt.hsva(accentHue, 0.30, 0.82, 1.0), Qt.hsva(accentHue, 0.40, 0.18, 1.0), themeBlend)

  readonly property color borderBase: mixc(Qt.hsva(accentHue, 0.15, 0.78, 1.0), Qt.hsva(accentHue, 0.22, 0.18, 1.0), themeBlend)

  readonly property color borderActive: mixc(Qt.hsva(accentHue, 0.45, 0.60, 1.0), Qt.hsva(accentHue, 0.45, 0.35, 1.0), themeBlend)

  readonly property color textMain: mixc("#121612", "#f2f2f2", themeBlend)
  readonly property color textSecondary: mixc("#4c574c", "#9aa39a", themeBlend)
  readonly property color textMuted: mixc("#788478", "#6e756e", themeBlend)
  readonly property color textActive: mixc(Qt.hsva(accentHue, 0.85, 0.25, 1.0), Qt.hsva(accentHue, 0.28, 0.92, 1.0), themeBlend)

  // 4b. Drop Shadow Properties
  readonly property color shadowColor: mixc("#30000000", "#70000000", themeBlend)
  readonly property color shadowColorDeep: mixc("#45000000", "#99000000", themeBlend)

  // 5. System & nerd fonts
  readonly property var availableFonts: {
    var sys = [];
    try {
      sys = Qt.fontFamilies();
    } catch(e) {}

    var preferred = [
      "JetBrainsMono Nerd Font",
      "FiraCode Nerd Font",
      "Hack Nerd Font",
      "MesloLGS Nerd Font",
      "CascadiaCode Nerd Font",
      "Iosevka Nerd Font",
      "SauceCodePro Nerd Font",
      "Symbols Nerd Font",
      "Inter",
      "Roboto",
      "Cantarell",
      "monospace"
    ];

    var result = [];
    for (var i = 0; i < preferred.length; ++i) {
      var p = preferred[i];
      if (sys.indexOf(p) !== -1 || p === "monospace" || p === "JetBrainsMono Nerd Font") {
        if (result.indexOf(p) === -1) result.push(p);
      }
    }
    for (var j = 0; j < sys.length; ++j) {
      var f = sys[j];
      if (f && f.charAt(0) !== "." && result.indexOf(f) === -1) {
        result.push(f);
      }
    }
    return result.length > 0 ? result : preferred;
  }

  property int fontIndex: 0
  property string fontFamily: availableFonts[fontIndex] || "JetBrainsMono Nerd Font"

  function setTimeFormat(fmt) {
    timeFormat = fmt;
    saveSettings();
  }

  function toggleClockSeconds() {
    clockSeconds = !clockSeconds;
    saveSettings();
  }

  function toggleJapaneseGlyphs() {
    japaneseGlyphs = !japaneseGlyphs;
    saveSettings();
  }

  function toggleMusicVisualizer() {
    musicVisualizer = !musicVisualizer;
    saveSettings();
  }

  function setThemeMode(mode) {
    themeMode = mode;
    if (mode === "light") {
      themeBlend = 0.0;
      isDark = false;
    } else if (mode === "dark") {
      themeBlend = 1.0;
      isDark = true;
    }
    saveSettings();
  }

  function setAccentHue(h) {
    accentHue = Math.min(1.0, Math.max(0.0, h));
    themeMode = "manual";
    saveSettings();
  }

  function setIsDark(d) {
    setThemeBlend(d ? 1.0 : 0.0);
  }

  function setThemeBlend(v) {
    themeBlend = Math.min(1.0, Math.max(0.0, v));
    var dark = themeBlend >= 0.5;
    if (isDark !== dark) isDark = dark;
    themeMode = "manual";
    saveSettings();
  }

  function setHexColor(hex) {
    if (!hex) return;
    var clean = hex.trim().replace("#", "");
    if (clean.length === 6) {
      var r = parseInt(clean.substring(0, 2), 16) / 255.0;
      var g = parseInt(clean.substring(2, 4), 16) / 255.0;
      var b = parseInt(clean.substring(4, 6), 16) / 255.0;
      var max = Math.max(r, g, b);
      var min = Math.min(r, g, b);
      var d = max - min;
      var h = 0;
      if (d !== 0) {
        if (max === r) h = ((g - b) / d) % 6;
        else if (max === g) h = (b - r) / d + 2;
        else h = (r - g) / d + 4;
        h = h / 6;
        if (h < 0) h += 1;
      }
      accentHue = h;
      themeMode = "manual";
      saveSettings();
    }
  }

  function setUiScale(s) {
    uiScale = s;
    saveSettings();
  }

  function setBarGap(g) {
    barGap = Math.max(0, Math.min(24, Math.round(g)));
    saveSettings();
  }

  function setFont(f) {
    if (!f) return;
    fontFamily = f;
    var idx = availableFonts.indexOf(f);
    if (idx >= 0) fontIndex = idx;
    saveSettings();
  }

  function setWallpaperFolder(folder) {
    if (!folder) return;
    wallpaperFolder = folder;
    saveSettings();
  }

  function saveSettings() {
    var data = {
      timeFormat: root.timeFormat,
      clockSeconds: root.clockSeconds,
      japaneseGlyphs: root.japaneseGlyphs,
      musicVisualizer: root.musicVisualizer,
      wallpaperFolder: root.wallpaperFolder,
      themeMode: root.themeMode,
      accentHue: root.accentHue,
      themeBlend: root.themeBlend,
      isDark: root.isDark,
      uiScale: root.uiScale,
      barGap: root.barGap,
      fontFamily: root.fontFamily
    };
    var jsonStr = JSON.stringify(data);
    saveProc.command = ["bash", "-c", "mkdir -p ~/.cache/quickshell && cat << 'EOF' > ~/.cache/quickshell/settings.json\n" + jsonStr + "\nEOF"];
    saveProc.running = true;
  }

  Process {
    id: saveProc
    running: false
  }

  // Load persisted settings on launch
  Process {
    id: loadProc
    command: ["bash", "-c", "cat ~/.cache/quickshell/settings.json 2>/dev/null || echo '{}'"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          var parsed = JSON.parse(data);
          if (parsed.timeFormat !== undefined) root.timeFormat = parsed.timeFormat;
          if (parsed.clockSeconds !== undefined) root.clockSeconds = parsed.clockSeconds;
          if (parsed.japaneseGlyphs !== undefined) root.japaneseGlyphs = parsed.japaneseGlyphs;
          if (parsed.musicVisualizer !== undefined) root.musicVisualizer = parsed.musicVisualizer;
          if (parsed.wallpaperFolder !== undefined && parsed.wallpaperFolder !== "") root.wallpaperFolder = parsed.wallpaperFolder;
          if (parsed.themeMode !== undefined) root.themeMode = parsed.themeMode;
          if (parsed.accentHue !== undefined) root.accentHue = parsed.accentHue;
          if (parsed.themeBlend !== undefined) {
            root.themeBlend = Math.min(1.0, Math.max(0.0, parsed.themeBlend));
            root.isDark = root.themeBlend >= 0.5;
          } else if (parsed.isDark !== undefined) {
            root.isDark = parsed.isDark;
            root.themeBlend = parsed.isDark ? 1.0 : 0.0;
          }
          if (parsed.uiScale !== undefined) root.uiScale = parsed.uiScale;
          if (parsed.barGap !== undefined) root.barGap = parsed.barGap;
          if (parsed.fontFamily !== undefined && parsed.fontFamily !== "") {
            root.fontFamily = parsed.fontFamily;
            var idx = root.availableFonts.indexOf(parsed.fontFamily);
            if (idx >= 0) root.fontIndex = idx;
          }
        } catch (e) {}
      }
    }
  }
}
