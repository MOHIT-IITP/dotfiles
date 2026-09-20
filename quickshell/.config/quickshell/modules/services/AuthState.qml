pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Unified Authentication state singleton for PolicyKit (system authorization)
// and Wi-Fi credentials, running the Polkit agent daemon in the background.
Singleton {
  id: root

  property bool open: false
  property string authType: "polkit" // "polkit" | "wifi"

  // Polkit details
  property string actionId: ""
  property string message: ""
  property string user: ""
  property string promptText: "Password: "
  property string cookie: ""

  // Wi-Fi details
  property string ssid: ""

  // Common input & feedback
  property string password: ""
  property bool showPassword: false
  property bool isConnecting: false
  property string errorMessage: ""

  // Wi-Fi trigger
  function prompt(networkName) {
    var name = (networkName || "").trim();
    if (!name) {
      close();
      return;
    }
    authType = "wifi";
    ssid = name;
    actionId = "";
    message = "Password required to access “" + name + "”";
    user = "";
    password = "";
    showPassword = false;
    isConnecting = false;
    errorMessage = "";
    open = true;
  }

  // System Polkit trigger
  function promptPolkit(actId, msg, usr, cook, prmpt) {
    authType = "polkit";
    actionId = actId || "";
    message = msg || "Authentication is required to perform this system action";
    user = usr || "";
    cookie = cook || "";
    promptText = prmpt || "Password: ";
    ssid = "";
    password = "";
    showPassword = false;
    isConnecting = false;
    errorMessage = "";
    open = true;
  }

  function close() {
    if (authType === "polkit" && open) {
      sendPolkitCancel();
    }
    open = false;
    isConnecting = false;
    errorMessage = "";
    if (wifiProc.running) {
      wifiProc.running = false;
    }
  }

  function submit(pass) {
    if (isConnecting) return;
    password = pass || "";
    isConnecting = true;
    errorMessage = "";

    if (authType === "polkit") {
      sendPolkitResponse(password);
    } else if (authType === "wifi") {
      if (password.length > 0) {
        wifiProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
      } else {
        wifiProc.command = ["nmcli", "dev", "wifi", "connect", ssid];
      }
      wifiProc.running = true;
    }
  }

  function sendPolkitResponse(pw) {
    var payload = JSON.stringify({
      action: "response",
      password: pw
    }) + "\n";
    polkitProc.write(payload);
  }

  function sendPolkitCancel() {
    var payload = JSON.stringify({
      action: "cancel"
    }) + "\n";
    polkitProc.write(payload);
  }

  // Background PolicyKit Agent process
  Process {
    id: polkitProc
    command: ["python3", "/home/mohiitp/.config/quickshell/modules/services/polkit_agent.py"]
    running: true

    stdout: SplitParser {
      onRead: function(line) {
        var str = (line || "").trim();
        if (!str) return;
        try {
          var data = JSON.parse(str);
          if (data.event === "request") {
            root.promptPolkit(data.action_id, data.message, data.user, data.cookie, data.prompt);
          } else if (data.event === "error") {
            root.errorMessage = data.message || "Authentication failed";
            root.isConnecting = false;
          } else if (data.event === "completed") {
            root.isConnecting = false;
            if (data.gained_authorization) {
              root.open = false;
              root.errorMessage = "";
            } else {
              if (!root.errorMessage) {
                root.errorMessage = "Authentication failed. Please try again.";
              }
            }
          } else if (data.event === "cancelled") {
            root.isConnecting = false;
            root.open = false;
          }
        } catch (e) {
          // Ignore non-json logs
        }
      }
    }

    onExited: function(code) {
      // Auto-restart polkit agent if it ever exits unexpectedly
      restartTimer.restart();
    }
  }

  Timer {
    id: restartTimer
    interval: 1000
    repeat: false
    onTriggered: {
      if (!polkitProc.running) {
        polkitProc.running = true;
      }
    }
  }

  // Wi-Fi Connection process
  Process {
    id: wifiProc

    stdout: SplitParser {
      onRead: function(data) {
        if (data && data.toLowerCase().indexOf("error") !== -1) {
          root.errorMessage = data;
        }
      }
    }

    stderr: SplitParser {
      onRead: function(data) {
        if (data) {
          root.errorMessage = data;
        }
      }
    }

    onExited: function(code) {
      root.isConnecting = false;
      if (code === 0) {
        root.open = false;
        root.errorMessage = "";
      } else {
        if (!root.errorMessage) {
          root.errorMessage = "Connection failed. Please check password.";
        }
      }
    }
  }
}
