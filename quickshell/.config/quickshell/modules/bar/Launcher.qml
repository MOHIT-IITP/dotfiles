import Quickshell
import QtQuick
import "../services"

// Minimalist, fast Spotlight/Raycast-style App Launcher.
// Features keyboard navigation (Up/Down/Enter/Esc), search filtering, and sleek theming.
Rectangle {
  id: root
  readonly property bool open: LauncherState.open
  focus: true

  property string query: ""
  property int sel: 0

  function forceFocus() {
    search.focus = true;
    search.forceActiveFocus();
  }

  onOpenChanged: {
    if (open) {
      query = "";
      sel = 0;
      search.text = "";
      forceFocus();
      focusRetryTimer.restart();
    }
  }

  Timer {
    id: focusRetryTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (search.activeFocus || count > 6) {
        running = false;
      }
    }
  }

  readonly property var allApps: DesktopEntries.applications.values
  readonly property var filtered: {
    var q = query.trim().toLowerCase();
    var out = [];
    for (var i = 0; i < allApps.length; ++i) {
      var a = allApps[i];
      if (!a) continue;
      if (q === "") {
        out.push(a);
      } else {
        var hay = (a.name || "") + " " + (a.genericName || "") + " " + (a.id || "");
        if (a.keywords) {
          for (var k = 0; k < a.keywords.length; ++k)
            hay += " " + a.keywords[k];
        }
        if (hay.toLowerCase().indexOf(q) !== -1)
          out.push(a);
      }
      if (out.length >= 25)
        break;
    }
    return out;
  }

  function launch(entry) {
    if (!entry) return;
    LauncherState.close();
    entry.execute();
  }

  function launchSelected() {
    if (sel >= 0 && sel < filtered.length)
      launch(filtered[sel]);
  }

  implicitWidth: 420
  implicitHeight: open ? contentCol.implicitHeight + 24 : 0
  radius: 16
  clip: true

  color: SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1
  opacity: open ? 1 : 0
  visible: open || opacity > 0

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 220
      easing.type: Easing.OutCubic
    }
  }
  Behavior on opacity {
    NumberAnimation {
      duration: 160
    }
  }

  Column {
    id: contentCol
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 12
    spacing: 10

    // Minimal Search Input Bar
    Row {
      width: parent.width
      height: 32
      spacing: 10

      // Search Icon
      CCIcon {
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        kind: "apps"
        glyph: search.text.length > 0 ? SettingsState.accent : SettingsState.textSecondary
      }

      // Input field + Placeholder
      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 54
        height: parent.height

        Text {
          anchors.fill: parent
          verticalAlignment: Text.AlignVCenter
          visible: search.text === ""
          text: "Search apps..."
          color: SettingsState.textMuted
          font.pixelSize: 13
          font.family: SettingsState.fontFamily
        }

        TextInput {
          id: search
          anchors.fill: parent
          verticalAlignment: TextInput.AlignVCenter
          color: SettingsState.textMain
          font.pixelSize: 13
          font.family: SettingsState.fontFamily
          clip: true
          focus: true
          activeFocusOnTab: true
          selectByMouse: true
          onTextChanged: {
            query = text;
            sel = 0;
          }
          Keys.onPressed: function (ev) {
            if (ev.key === Qt.Key_Down) {
              sel = Math.min(filtered.length - 1, sel + 1);
              appListView.positionViewAtIndex(sel, ListView.Contain);
              ev.accepted = true;
            } else if (ev.key === Qt.Key_Up) {
              sel = Math.max(0, sel - 1);
              appListView.positionViewAtIndex(sel, ListView.Contain);
              ev.accepted = true;
            } else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) {
              launchSelected();
              ev.accepted = true;
            } else if (ev.key === Qt.Key_Escape) {
              LauncherState.close();
              ev.accepted = true;
            }
          }
        }
      }

      // Clear or Escape hint
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20
        radius: 10
        color: clearMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

        Text {
          anchors.centerIn: parent
          text: search.text.length > 0 ? "✕" : "⎋"
          color: clearMouse.containsMouse ? SettingsState.textActive : SettingsState.textMuted
          font.pixelSize: 11
          font.bold: true
        }

        MouseArea {
          id: clearMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (search.text.length > 0) {
              search.text = "";
              search.forceActiveFocus();
            } else {
              LauncherState.close();
            }
          }
        }
      }
    }

    // Subtle 1px Divider
    Rectangle {
      width: parent.width
      height: 1
      color: SettingsState.borderBase
      visible: filtered.length > 0 || search.text.length > 0
    }

    // Empty state
    Text {
      visible: filtered.length === 0
      anchors.horizontalCenter: parent.horizontalCenter
      text: "No applications found"
      color: SettingsState.textMuted
      font.pixelSize: 12
      font.italic: true
      font.family: SettingsState.fontFamily
      padding: 10
    }

    // Minimal App List
    ListView {
      id: appListView
      width: parent.width
      height: Math.min(7, filtered.length) * 38
      visible: filtered.length > 0
      spacing: 2
      clip: true
      model: filtered
      currentIndex: sel

      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool isSelected: index === root.sel

        width: ListView.view.width
        height: 36
        radius: 8
        color: isSelected ? SettingsState.bgActivePill : (itemMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
        border.color: isSelected ? SettingsState.borderActive : "transparent"
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 80 }
        }

        Row {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          spacing: 10

          // App Icon
          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22

            Image {
              anchors.centerIn: parent
              width: 20
              height: 20
              visible: modelData && modelData.icon !== ""
              source: (modelData && modelData.icon !== "") ? Quickshell.iconPath(modelData.icon, "application-x-executable") : ""
              smooth: true
              asynchronous: true
            }

            Text {
              anchors.centerIn: parent
              visible: !modelData || modelData.icon === ""
              text: (modelData && modelData.name) ? modelData.name.substring(0, 1).toUpperCase() : "?"
              color: isSelected ? SettingsState.textActive : SettingsState.textSecondary
              font.pixelSize: 12
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }

          // App Name
          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (isSelected ? 62 : 36)
            text: (modelData && modelData.name) ? modelData.name : ""
            color: isSelected ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: 13
            font.bold: isSelected
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          // Return / Launch Hint Badge
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: isSelected
            width: 18
            height: 18
            radius: 4
            color: SettingsState.accent

            Text {
              anchors.centerIn: parent
              text: "⏎"
              color: SettingsState.isDark ? "#121612" : "#ffffff"
              font.pixelSize: 10
              font.bold: true
            }
          }
        }

        MouseArea {
          id: itemMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: {
            root.sel = index;
          }
          onClicked: {
            root.launch(modelData);
          }
        }
      }
    }
  }
}
