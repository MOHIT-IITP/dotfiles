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
  property string wallpaperResizeMode: "crop" // "crop" (Fill) | "fit" | "stretch" | "no" (Center)

  // 3. UI scale & Bar Gap
  property real uiScale: 1.0
  property int barGap: 2 // Extra gap below bar in pixels (0 - 24px)
  property bool barAutoHide: false // slide the bar away until the cursor hits the top edge

  // 3b. Font size offset applied on top of base pixel sizes (-5..+5 px)
  property int fontSizeDelta: 0

  // 3c. Card Corner Styling (Border Radius & Rounding Power)
  property real cardRadius: 47
  property real cardRoundingPower: 3.0

  // 4. Theme & Accent Colors
  property string themeMode: "dark" // "light" | "dark" | "manual"
  property real accentHue: 0.52       // 0.0 - 1.0 (0.52 = #40AABF teal/cyan from reference)
  property real accentSat: 0.65
  property real accentVal: 0.85
  property string accentTone: "dark" // "light" | "dark" — card lightness in Manual (accent auto-inverts)
  property real themeBlend: 1.0 // 0.0 = light, 1.0 = dark (mirrors themeMode)
  property bool isDark: true // mirrored from themeMode, kept for icon logic compat

  // Reactive primary accent color: always the inverse of the cards for
  // contrast — Light preset is monochrome (near-black), light cards get
  // the dark shade of the hue, dark cards get the light shade.
  readonly property color accent: {
    if (themeMode === "light") {
      return Qt.hsva(accentHue, 0.0, 0.20, 1.0);
    }
    if (themeBlend >= 0.5) {
      return Qt.hsva(accentHue, 0.55, 0.92, 1.0);
    }
    return Qt.hsva(accentHue, 0.65, 0.62, 1.0);
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

  // Hue gate for the Light preset: pure black & white means zero
  // saturation on the light ends; Manual/Dark keep the full tint.
  function tint(s, v, a) {
    return Qt.hsva(accentHue, themeMode === "light" ? 0.0 : s, v, a);
  }

  // Dark-end tint for cards: in Manual + dark tone every card takes the
  // dark shade of the hue (green -> ~#1D3C16). Presets keep true black/grays.
  function cardDark(s, v, fallback) {
    if (themeMode === "manual" && accentTone === "dark") return Qt.hsva(accentHue, s, v, 1.0);
    return fallback;
  }

  // Reactive Theme Palettes (blend light -> dark via themeBlend).
  // Dark end is pure black / neutral grays so Dark gives a true black bar.
  readonly property color bgSurface: mixc(tint(0.06, 0.95, 0.96), Qt.rgba(0, 0, 0, 0.96), themeBlend)

  readonly property color bgCard: mixc(tint(0.08, 0.89, 1.0), cardDark(0.50, 0.20, Qt.rgba(0, 0, 0, 1.0)), themeBlend)

  readonly property color bgCardHover: mixc(tint(0.10, 0.84, 1.0), cardDark(0.50, 0.25, Qt.rgba(0.10, 0.10, 0.10, 1.0)), themeBlend)

  readonly property color bgActivePill: mixc(tint(0.30, 0.82, 1.0), cardDark(0.55, 0.28, Qt.rgba(0.16, 0.16, 0.16, 1.0)), themeBlend)

  readonly property color borderBase: mixc(tint(0.18, 0.75, 1.0), cardDark(0.35, 0.30, Qt.rgba(0.22, 0.22, 0.22, 1.0)), themeBlend)

  readonly property color borderActive: mixc(tint(0.45, 0.60, 1.0), cardDark(0.55, 0.38, Qt.rgba(0.32, 0.32, 0.32, 1.0)), themeBlend)

  // Lighter border for the top bar pills (clock, media, network) only.
  readonly property color barBorder: mixc(tint(0.20, 0.75, 1.0), cardDark(0.30, 0.38, Qt.rgba(0.28, 0.28, 0.28, 1.0)), themeBlend)

  readonly property color textMain: mixc("#121612", "#f2f2f2", themeBlend)
  readonly property color textSecondary: mixc("#4c574c", "#9aa39a", themeBlend)
  readonly property color textMuted: mixc("#788478", "#6e756e", themeBlend)
  readonly property color textActive: mixc(tint(0.85, 0.25, 1.0), Qt.hsva(accentHue, 0.28, 0.92, 1.0), themeBlend)

  // 4b. Drop Shadow Properties
  readonly property color shadowColor: mixc("#0f000000", "#70000000", themeBlend)
  readonly property color shadowColorDeep: mixc("#15000000", "#99000000", themeBlend)

  // 5. System & nerd fonts
  readonly property var availableFonts: {
    var sys = [];
    try {
      sys = Qt.fontFamilies();
    } catch(e) {}

    var preferred = [
      "SF Pro Display",
      "SF Pro Text",
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

  // Dedicated icon font: Nerd Font glyphs are missing from regular UI fonts,
  // so icons must never use fontFamily directly.
  // CommitMono Nerd Font Propo is the single icon/symbol font everywhere.
  readonly property string iconFontFamily: {
    var sys = [];
    try {
      sys = Qt.fontFamilies();
    } catch (e) {}
    var prefs = [
      "CommitMono Nerd Font Propo",
      "JetBrainsMono Nerd Font",
      "CaskaydiaCove Nerd Font",
      "FiraCode Nerd Font",
      "Hack Nerd Font",
      "CommitMono Nerd Font",
      "Iosevka Nerd Font",
      "Symbols Nerd Font"
    ];
    for (var i = 0; i < prefs.length; ++i) {
      if (sys.indexOf(prefs[i]) !== -1) return prefs[i];
    }
    for (var j = 0; j < sys.length; ++j) {
      var f = sys[j];
      if (f && f.indexOf("Nerd Font") !== -1) return f;
    }
    return "Symbols Nerd Font";
  }

  // CommitMono Nerd Font Propo for all icons & symbols.
  // Pictographic glyphs must never use fontFamily directly.
  readonly property string nerdIconFont: {
    var sys = [];
    try {
      sys = Qt.fontFamilies();
    } catch (e) {}
    if (sys.indexOf("CommitMono Nerd Font Propo") !== -1) {
      return "CommitMono Nerd Font Propo";
    }
    return iconFontFamily;
  }

  // Map weather kind ("thunder"|"rain"|"snow"|"cloud"|"sun") to a
  // Nerd Fonts weather glyph. Codepoints verified against the
  // CommitMono Nerd Font Propo charset on this system.
  function nerdWeatherIcon(kind): string {
    var k = (kind || "").toLowerCase();
    if (k === "thunder") return "\ue31d"; // nf-weather-thunderstorm
    if (k === "rain") return "\ue318"; // nf-weather-rain
    if (k === "snow") return "\ue31a"; // nf-weather-snow
    if (k === "cloud") return "\ue312"; // nf-weather-cloudy
    return "\ue30d"; // nf-weather-day_sunny
  }

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
    if (mode !== "light" && mode !== "dark" && mode !== "manual") return;
    themeMode = mode;
    if (mode === "light") {
      themeBlend = 0.0;
      isDark = false;
    } else if (mode === "dark") {
      themeBlend = 1.0;
      isDark = true;
      accentHue = 0.083; // orange accent preset
      accentTone = "light";
    }
    // manual: keep the bar as-is but align the tone buttons with the
    // current lightness, so they truthfully describe the cards.
    // Only the hue spectrum becomes editable.
    if (mode === "manual") {
      accentTone = themeBlend >= 0.5 ? "dark" : "light";
    }
    saveSettings();
  }

  function setAccentHue(h) {
    accentHue = Math.min(1.0, Math.max(0.0, h));
    saveSettings();
  }

  function setAccentTone(t) {
    if (t !== "light" && t !== "dark") return;
    accentTone = t;
    // The tone is Manual's light/dark switch: it flips every card between
    // the light and dark shades of the hue, and the accent follows with
    // the opposite shade so contrast always stays readable.
    themeBlend = (t === "light") ? 0.0 : 1.0;
    isDark = (t === "dark");
    saveSettings();
  }

  function setIsDark(d) {
    setThemeMode(d ? "dark" : "light");
  }

  // Kept for compat with persisted settings; UI now uses Light/Dark only.
  function setThemeBlend(v) {
    var vv = Math.min(1.0, Math.max(0.0, v));
    setThemeMode(vv >= 0.5 ? "dark" : "light");
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

  function setBarAutoHide(v) {
    barAutoHide = !!v;
    saveSettings();
  }

  function toggleBarAutoHide() {
    barAutoHide = !barAutoHide;
    saveSettings();
  }

  function setFontSizeDelta(d) {
    fontSizeDelta = Math.max(-5, Math.min(5, Math.round(d)));
    saveSettings();
  }

  function adjustFontSize(by) {
    setFontSizeDelta(fontSizeDelta + by);
  }

  function resetFontSize() {
    setFontSizeDelta(0);
  }

  // Central helper: base size + user offset, e.g. `font.pixelSize: SettingsState.px(15)`
  function px(base) {
    return Math.max(1, Math.round(base) + fontSizeDelta);
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

  function setWallpaperResizeMode(mode) {
    if (mode !== "crop" && mode !== "fit" && mode !== "stretch" && mode !== "no") return;
    wallpaperResizeMode = mode;
    saveSettings();
  }

  function saveSettings() {
    var data = {
      timeFormat: root.timeFormat,
      clockSeconds: root.clockSeconds,
      japaneseGlyphs: root.japaneseGlyphs,
      musicVisualizer: root.musicVisualizer,
      wallpaperFolder: root.wallpaperFolder,
      wallpaperResizeMode: root.wallpaperResizeMode,
      themeMode: root.themeMode,
      accentHue: root.accentHue,
      accentTone: root.accentTone,
      themeBlend: root.themeBlend,
      isDark: root.isDark,
      uiScale: root.uiScale,
      barGap: root.barGap,
      barAutoHide: root.barAutoHide,
      fontSizeDelta: root.fontSizeDelta,
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
          if (parsed.wallpaperResizeMode !== undefined && parsed.wallpaperResizeMode !== "") root.wallpaperResizeMode = parsed.wallpaperResizeMode;
          if (parsed.themeMode !== undefined) {
            var m = parsed.themeMode;
            if (m === "dynamic") {
              root.themeMode = "manual";
            } else if (m === "light" || m === "dark" || m === "manual") {
              root.themeMode = m;
            }
          }
          if (parsed.accentHue !== undefined) root.accentHue = parsed.accentHue;
          if (parsed.accentTone === "light" || parsed.accentTone === "dark") root.accentTone = parsed.accentTone;
          if (parsed.themeBlend !== undefined) {
            root.themeBlend = Math.min(1.0, Math.max(0.0, parsed.themeBlend));
            root.isDark = root.themeBlend >= 0.5;
          } else if (parsed.isDark !== undefined) {
            root.isDark = parsed.isDark;
            root.themeBlend = parsed.isDark ? 1.0 : 0.0;
          }
          // Light/Dark force the bar; Manual keeps its saved bar blend.
          if (root.themeMode === "light") {
            root.themeBlend = 0.0;
            root.isDark = false;
          } else if (root.themeMode === "dark") {
            root.themeBlend = 1.0;
            root.isDark = true;
          }
          if (parsed.uiScale !== undefined) root.uiScale = parsed.uiScale;
          if (parsed.barGap !== undefined) root.barGap = parsed.barGap;
          if (parsed.barAutoHide !== undefined) root.barAutoHide = !!parsed.barAutoHide;
          if (parsed.fontSizeDelta !== undefined) root.fontSizeDelta = Math.max(-5, Math.min(5, Math.round(parsed.fontSizeDelta)));
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
