import Quickshell
import QtQuick
import "../services"

// Embedded Dynamic Island-style Notification card directly inside ClockPill.
// Taller height, generous internal padding, and compact width.
Item {
  id: root

  implicitWidth: 340
  implicitHeight: 118

  readonly property var n: NotifCenter.currentNotification

  function formatAppName(item) {
    if (!item) return "Alert";
    var name = (item.appName || "").trim();
    if (!name) return "Alert";
    if (name.indexOf("chrome-") === 0) {
      var parts = name.split("___");
      if (parts.length > 1) {
        var site = parts[1].split("-")[0].replace("web.", "").replace(".com", "").replace(".org", "");
        return site.charAt(0).toUpperCase() + site.slice(1);
      }
    }
    return name;
  }

  function getActionLabel(item) {
    if (!item) return "Open";
    if (item.actions && item.actions.length > 0) {
      var act = item.actions[0];
      if (act && act.text && act.text.trim().length > 0) return act.text.trim();
      if (typeof act === "string" && act.toLowerCase() !== "default") return act;
    }
    return "Open";
  }

  Column {
    anchors.fill: parent
    anchors.leftMargin: 16
    anchors.rightMargin: 16
    anchors.topMargin: 13
    anchors.bottomMargin: 13
    spacing: 8

    // 1. Top Row: [App Badge / Status] [Icon] [Timestamp]
    Row {
      width: parent.width
      height: 22
      spacing: 8

      // App Pill Badge
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        width: Math.min(120, appText.implicitWidth + 18)
        radius: 10
        color: SettingsState.accent
        opacity: 0.9

        Text {
          id: appText
          anchors.centerIn: parent
          text: root.formatAppName(root.n)
          color: SettingsState.isDark ? "#0d140e" : "#ffffff"
          font.pixelSize: 10
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
          width: parent.width - 8
          horizontalAlignment: Text.AlignHCenter
        }
      }

      Item {
        width: parent.width - (appText.parent.width + 56)
        height: 1
      }

      // App Icon / Favicon in Top-Right
      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20

        Image {
          id: imgView
          anchors.centerIn: parent
          width: 17
          height: 17
          visible: root.n && (root.n.image || root.n.appIcon !== "" || (root.n.appName && root.n.appName.toLowerCase().indexOf("chrome") !== -1))
          source: {
            if (!root.n) return "";
            if (root.n.image) return root.n.image;
            var iconName = (root.n.appIcon || "").trim();
            if (!iconName && root.n.appName) {
              var low = root.n.appName.toLowerCase();
              if (low.indexOf("chrome") !== -1) iconName = "google-chrome";
              else if (low.indexOf("firefox") !== -1) iconName = "firefox";
              else if (low.indexOf("discord") !== -1) iconName = "discord";
              else if (low.indexOf("spotify") !== -1) iconName = "spotify";
            }
            return iconName ? Quickshell.iconPath(iconName, "google-chrome") : "";
          }
          smooth: true
          asynchronous: true
        }

        Text {
          anchors.centerIn: parent
          visible: !imgView.visible || imgView.status === Image.Error
          text: "󰂚"
          color: SettingsState.textSecondary
          font.pixelSize: 13
        }
      }

      // Timestamp (e.g. "now")
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "now"
        color: SettingsState.textMuted
        font.pixelSize: 10
        font.family: SettingsState.fontFamily
      }
    }

    // 2. Middle Content (Summary Title + Body Description)
    Column {
      width: parent.width
      spacing: 2

      Text {
        width: parent.width
        text: (root.n && root.n.summary) ? root.n.summary : ""
        textFormat: Text.StyledText
        color: SettingsState.textMain
        font.pixelSize: 13
        font.bold: true
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
      }

      Text {
        width: parent.width
        visible: root.n && root.n.body !== ""
        text: (root.n && root.n.body) ? root.n.body : ""
        textFormat: Text.StyledText
        color: SettingsState.textSecondary
        font.pixelSize: 11
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }

    // 3. Bottom Row: Action Pills
    Row {
      width: parent.width
      height: 26
      spacing: 8

      // Dismiss Pill (✕)
      Rectangle {
        height: 26
        width: 38
        radius: 13
        color: dismissMouse.containsMouse ? SettingsState.bgCardHover : (SettingsState.isDark ? "#202620" : "#e0e6e0")
        border.color: SettingsState.borderBase
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: "✕"
          color: SettingsState.accent
          font.pixelSize: 11
          font.bold: true
        }

        MouseArea {
          id: dismissMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: NotifCenter.dismissCurrent()
        }
      }

      // Open Action Pill
      Rectangle {
        height: 26
        width: parent.width - 46
        radius: 13
        color: openMouse.containsMouse ? SettingsState.accent : SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 100 }
        }

        Row {
          anchors.centerIn: parent
          spacing: 6

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.getActionLabel(root.n)
            color: openMouse.containsMouse ? (SettingsState.isDark ? "#0d140e" : "#ffffff") : SettingsState.textMain
            font.pixelSize: 11
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "›"
            color: openMouse.containsMouse ? (SettingsState.isDark ? "#0d140e" : "#ffffff") : SettingsState.textSecondary
            font.pixelSize: 13
            font.bold: true
          }
        }

        MouseArea {
          id: openMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: NotifCenter.activateCurrent()
        }
      }
    }
  }

  // Hover detection to pause auto-dismiss timer while reading
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    onEntered: NotifCenter.isHovered = true
    onExited: NotifCenter.isHovered = false
  }
}
