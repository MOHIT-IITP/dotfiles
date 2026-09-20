import Quickshell
import QtQuick
import "../services"

// Embedded App Launcher subview directly inside ClockPill.
// Provides instant search, keyboard navigation (Up/Down/Enter/Esc), and fast app execution.
Item {
  id: root

  property string query: ""
  property int sel: 0

  implicitWidth: 440
  implicitHeight: contentCol.implicitHeight

  function forceFocus() {
    search.focus = true;
    search.forceActiveFocus();
  }

  Connections {
    target: LauncherState
    function onOpenChanged() {
      if (LauncherState.open) {
        root.query = "";
        root.sel = 0;
        search.text = "";
        forceFocus();
        focusRetryTimer.restart();
      }
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

  Column {
    id: contentCol
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 14
    spacing: 10

    // Search Input Bar
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
      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20

        Text {
          anchors.centerIn: parent
          visible: search.text === ""
          text: "ESC"
          color: SettingsState.textMuted
          font.pixelSize: 9
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          anchors.fill: parent
          radius: 10
          visible: search.text !== ""
          color: clearBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          Text {
            anchors.centerIn: parent
            text: "✕"
            color: clearBtnMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: 11
          }

          MouseArea {
            id: clearBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              search.text = "";
              search.forceActiveFocus();
            }
          }
        }
      }
    }

    // Divider
    Rectangle {
      width: parent.width
      height: 1
      color: SettingsState.borderBase
    }

    // App Results List
    ListView {
      id: appListView
      width: parent.width
      height: Math.min(filtered.length * 40, 320)
      spacing: 4
      clip: true
      model: filtered
      currentIndex: sel

      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool isSelected: index === root.sel

        width: ListView.view.width
        height: 36
        radius: 12
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

          // Enter key badge
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            radius: 6
            color: SettingsState.accent
            visible: isSelected

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
          onClicked: {
            root.launch(modelData);
          }
        }
      }
    }
  }
}
