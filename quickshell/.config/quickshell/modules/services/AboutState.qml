pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// User profile / about links (email, github, linkedin, ...).
// Persisted to ~/.cache/quickshell/about.json
Singleton {
  id: root

  property var links: [
    { label: "email", value: "codingbymohit@gmail.com" }
  ]

  // Keybind visibility state (`qs ipc call mohiitp about` toggles it).
  // NetworkCircle stays expanded on the About page while this is true,
  // even without hovering the control center.
  property bool open: false

  function toggle() {
    open = !open;
  }

  function close() {
    open = false;
  }

  function iconFor(entry) {
    var v = ((entry && entry.value) || "").toLowerCase();
    var l = ((entry && entry.label) || "").toLowerCase();
    var s = l + " " + v;
    if (s.indexOf("mail") !== -1 || s.indexOf("@") !== -1) return "mail";
    if (s.indexOf("github") !== -1) return "github";
    if (s.indexOf("linkedin") !== -1) return "linkedin";
    if (s.indexOf("twitter") !== -1 || s.indexOf("x.com") !== -1) return "link";
    if (s.indexOf("http") !== -1 || s.indexOf("www.") !== -1 || s.indexOf(".com") !== -1) return "link";
    return "user";
  }

  function displayValue(entry) {
    return (entry && entry.value) || "";
  }

  function addLink(label, value) {
    var l = (label || "").trim();
    var v = (value || "").trim();
    if (v === "") return false;
    if (l === "") l = v;
    var next = [];
    for (var i = 0; i < links.length; ++i) next.push(links[i]);
    next.push({ label: l, value: v });
    links = next;
    save();
    return true;
  }

  function removeLink(index) {
    if (index < 0 || index >= links.length) return;
    var next = [];
    for (var i = 0; i < links.length; ++i) {
      if (i !== index) next.push(links[i]);
    }
    links = next;
    save();
  }

  function openLink(value) {
    var v = (value || "").trim();
    if (v === "") return;
    var target = v;
    // email -> mailto:, bare handle/url -> https://
    if (v.indexOf("@") !== -1 && v.indexOf("://") === -1 && v.indexOf("mailto:") !== 0) {
      // could be "email: foo@bar.com" leftover, strip leading label
      var m = v.match(/[\w.+-]+@[\w-]+\.[\w.]+/);
      if (m) v = m[0];
      target = "mailto:" + v;
    } else if (v.indexOf("://") === -1 && v.indexOf("mailto:") !== 0) {
      // github.com/user, linkedin.com/in/user, www.x -> https://
      if (v.match(/^(github\.com|linkedin\.com|www\.|[\w-]+\.[\w]+)/)) {
        target = "https://" + v;
      }
    }
    if (openProc.running) openProc.running = false;
    openProc.command = ["xdg-open", target];
    openProc.running = true;
  }

  function copyLink(value) {
    var v = (value || "").trim();
    if (v === "" || copyProc.running) return;
    copyProc.command = ["bash", "-c", "printf %s " + quoted(v) + " | wl-copy 2>/dev/null || printf %s " + quoted(v) + " | xclip -selection clipboard 2>/dev/null || true"];
    copyProc.running = true;
  }

  function quoted(s) {
    return "'" + s.replace(/'/g, "'\\''") + "'";
  }

  function save() {
    var jsonStr = JSON.stringify(links);
    if (saveProc.running) saveProc.running = false;
    saveProc.command = ["bash", "-c", "mkdir -p ~/.cache/quickshell && cat << 'EOF' > ~/.cache/quickshell/about.json\n" + jsonStr + "\nEOF"];
    saveProc.running = true;
  }

  Process {
    id: saveProc
    running: false
  }

  Process {
    id: openProc
    running: false
  }

  Process {
    id: copyProc
    running: false
  }

  Process {
    id: loadProc
    command: ["bash", "-c", "cat ~/.cache/quickshell/about.json 2>/dev/null || echo '[]'"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          var parsed = JSON.parse(data);
          if (parsed && parsed.length !== undefined && parsed.length > 0) {
            // normalize to {label, value}
            var out = [];
            for (var i = 0; i < parsed.length; ++i) {
              var e = parsed[i];
              if (typeof e === "string") out.push({ label: e, value: e });
              else if (e && e.value) out.push({ label: e.label || e.value, value: e.value });
            }
            if (out.length > 0) root.links = out;
          }
        } catch (e) {}
      }
    }
  }
}
