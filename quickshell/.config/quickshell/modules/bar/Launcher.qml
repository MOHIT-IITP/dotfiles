import Quickshell
import QtQuick
import "../services"

// Material Design 3 Pill-Shaped App Launcher
// Search filters installed apps; Up/Down navigates, Enter/click launches, Esc closes.
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
    interval: 40
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (search.activeFocus || count > 8) {
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
      if (out.length >= 30)
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

  implicitWidth: 460
  implicitHeight: open ? content.implicitHeight + 36 : 0
  radius: 30
  clip: true

  color: "#121512"
  border.color: "#3a4a35"
  border.width: 1
  opacity: open ? 1 : 0
  visible: open || opacity > 0

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 300
      easing.type: Easing.OutCubic
    }
  }
  Behavior on opacity {
    NumberAnimation {
      duration: 200
    }
  }

  Column {
    id: content
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 18
    spacing: 12

    // Material 3 Pill Search Bar
    Rectangle {
      width: parent.width
      height: 48
      radius: 24
      color: search.activeFocus ? "#1e261e" : "#171c17"
      border.color: search.activeFocus ? "#4e6a45" : "#2a342a"
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 150 }
      }
      Behavior on border.color {
        ColorAnimation { duration: 150 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Left Search Icon Avatar
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 32
          height: 32
          radius: 16
          color: search.activeFocus ? "#c9dfae" : "#242c24"

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "apps"
            glyph: search.activeFocus ? "#182415" : "#8e998e"
          }
        }

        // Input Field & Placeholder
        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 80
          height: parent.height

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: search.text === ""
            text: "Search applications..."
            color: "#6e756e"
            font.pixelSize: 14
            font.family: SettingsState.fontFamily
          }

          TextInput {
            id: search
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: "#f2f2f2"
            font.pixelSize: 14
            font.bold: true
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
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Up) {
                sel = Math.max(0, sel - 1);
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

        // Clear button
        Rectangle {
          visible: search.text.length > 0
          anchors.verticalCenter: parent.verticalCenter
          width: 24
          height: 24
          radius: 12
          color: clearMouse.containsMouse ? "#2e382e" : "transparent"

          Text {
            anchors.centerIn: parent
            text: "✕"
            color: "#8e998e"
            font.pixelSize: 11
            font.bold: true
          }

          MouseArea {
            id: clearMouse
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

    // Results Empty State
    Text {
      visible: filtered.length === 0
      anchors.horizontalCenter: parent.horizontalCenter
      text: "No applications found"
      color: "#6e756e"
      font.pixelSize: 13
      font.italic: true
      font.family: SettingsState.fontFamily
      padding: 12
    }

    // Results Material Pill List
    ListView {
      id: appListView
      width: parent.width
      height: Math.min(6, filtered.length) * 58
      visible: filtered.length > 0
      spacing: 6
      clip: true
      model: filtered
      currentIndex: sel
      highlightFollowsCurrentItem: true

      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool isSelected: index === root.sel

        width: ListView.view.width
        height: 52
        radius: 20
        color: isSelected ? "#243322" : (itemMouse.containsMouse ? "#1c221c" : "#161b16")
        border.color: isSelected ? "#3f5938" : (itemMouse.containsMouse ? "#283228" : "transparent")
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 100 }
        }

        Row {
          anchors.fill: parent
          anchors.margins: 8
          spacing: 12

          // Material App Icon Avatar
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 36
            radius: 18
            color: isSelected ? "#c9dfae" : "#222a22"

            Behavior on color {
              ColorAnimation { duration: 100 }
            }

            Image {
              anchors.centerIn: parent
              width: 24
              height: 24
              visible: modelData && modelData.icon !== ""
              source: (modelData && modelData.icon !== "") ? Quickshell.iconPath(modelData.icon, "application-x-executable") : ""
              smooth: true
              asynchronous: true
            }

            Text {
              anchors.centerIn: parent
              visible: !modelData || modelData.icon === ""
              text: (modelData && modelData.name) ? modelData.name.substring(0, 1).toUpperCase() : "?"
              color: isSelected ? "#182415" : "#9aa39a"
              font.pixelSize: 15
              font.bold: true
            }
          }

          // App Details
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 90
            spacing: 2

            Text {
              width: parent.width
              text: (modelData && modelData.name) ? modelData.name : ""
              color: isSelected ? "#c9dfae" : "#f2f2f2"
              font.pixelSize: 13
              font.bold: isSelected
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: (modelData && (modelData.genericName || modelData.comment)) ? (modelData.genericName || modelData.comment) : "Application"
              color: isSelected ? "#8ea87e" : "#6e756e"
              font.pixelSize: 11
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }
          }

          // Launch Action Indicator (Enter ⏎)
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: isSelected
            width: 22
            height: 22
            radius: 11
            color: "#3f5938"

            Text {
              anchors.centerIn: parent
              text: "⏎"
              color: "#c9dfae"
              font.pixelSize: 11
              font.bold: true
            }
          }
        }

        MouseArea {
          id: itemMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPositionChanged: {
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
