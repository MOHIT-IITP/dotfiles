import Quickshell
import QtQuick
import "../services"

// Embedded App Launcher subview styled exactly as reference:
// - Top search header with 探 glyph, underlined search input, and app counter (e.g. 52 / 52)
// - Clean vertical app list with 2-line title & category layout and sleek selected pill highlight
// - Bottom subtle hint footer "↓ Drag an AppImage onto the pill"
Item {
  id: root

  property string query: ""
  property int sel: 0

  implicitWidth: 380
  implicitHeight: 370

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
        var hay = (a.name || "") + " " + (a.genericName || "") + " " + (a.id || "") + " " + (a.comment || "");
        if (a.keywords) {
          for (var k = 0; k < a.keywords.length; ++k)
            hay += " " + a.keywords[k];
        }
        if (hay.toLowerCase().indexOf(q) !== -1)
          out.push(a);
      }
      if (out.length >= 60)
        break;
    }
    return out;
  }

  function getSubtitle(entry) {
    if (!entry) return "";
    if (entry.genericName && entry.genericName.trim().length > 0)
      return entry.genericName.trim();
    if (entry.comment && entry.comment.trim().length > 0)
      return entry.comment.trim();
    if (entry.categories && entry.categories.length > 0) {
      var cat = Array.isArray(entry.categories) ? entry.categories[0] : entry.categories;
      if (cat && typeof cat === "string") return cat.replace(/;/g, " ").trim();
    }
    return "Application";
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
    anchors.fill: parent
    anchors.margins: 14
    spacing: 8

    // ========================================================
    // 1. TOP SEARCH HEADER (Glyph + Input + Underline + Counter)
    // ========================================================
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.fill: parent
        spacing: 10

        // Search Kanji Glyph 探
        Text {
          id: kanjiGlyph
          anchors.verticalCenter: parent.verticalCenter
          text: "探"
          color: SettingsState.textMuted
          font.pixelSize: 15
          font.family: SettingsState.fontFamily
        }

        // Search Input Container with Underline
        Item {
          id: inputContainer
          width: parent.width - kanjiGlyph.width - counterText.width - 24
          height: parent.height

          // Placeholder
          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: search.text === ""
            text: "Search apps"
            color: SettingsState.textMuted
            font.pixelSize: 13
            font.family: SettingsState.fontFamily
          }

          // Text Input
          TextInput {
            id: search
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: SettingsState.textMain
            font.pixelSize: 13
            font.family: SettingsState.fontFamily
            clip: true
            focus: true
            activeFocusOnTab: true
            selectByMouse: true
            cursorVisible: true

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

          // Subtle Underline beneath Search Input
          Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: SettingsState.borderBase
          }
        }

        // App Counter (e.g. "52 / 52")
        Text {
          id: counterText
          anchors.verticalCenter: parent.verticalCenter
          text: filtered.length + " / " + allApps.length
          color: SettingsState.textMuted
          font.pixelSize: 12
          font.family: SettingsState.fontFamily
          horizontalAlignment: Text.AlignRight
        }
      }
    }

    // ========================================================
    // 2. APP RESULTS LIST (Icon + 2-Line App Info)
    // ========================================================
    ListView {
      id: appListView
      width: parent.width
      height: 278
      spacing: 3
      clip: true
      model: filtered
      currentIndex: sel

      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool isSelected: index === root.sel

        width: ListView.view.width
        height: 44
        radius: 10
        color: isSelected
          ? (SettingsState.isDark ? "#232629" : "#e6eaee")
          : (itemMouse.containsMouse ? (SettingsState.isDark ? "#191c1e" : "#f0f3f6") : "transparent")
        border.color: isSelected ? (SettingsState.isDark ? "#353a3e" : "#d2d8de") : "transparent"
        border.width: 1

        Behavior on color {
          ColorAnimation { duration: 70 }
        }

        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 12

          // App Icon
          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26

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
              color: isSelected ? SettingsState.textActive : SettingsState.textSecondary
              font.pixelSize: 13
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }

          // 2-Line Text: App Name + Subtitle/Category
          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 42
            spacing: 1

            Text {
              width: parent.width
              text: (modelData && modelData.name) ? modelData.name : ""
              color: isSelected ? SettingsState.textMain : SettingsState.textMain
              font.pixelSize: 13
              font.bold: false
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: root.getSubtitle(modelData)
              color: isSelected ? SettingsState.textSecondary : SettingsState.textMuted
              font.pixelSize: 11
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
            }
          }
        }

        MouseArea {
          id: itemMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.sel = index;
            root.launch(modelData);
          }
        }
      }
    }

    // ========================================================
    // 3. BOTTOM FOOTER HINT
    // ========================================================
    Item {
      width: parent.width
      height: 18

      Text {
        anchors.centerIn: parent
        text: "↓  Drag an AppImage onto the pill"
        color: SettingsState.textMuted
        font.pixelSize: 11
        font.family: SettingsState.fontFamily
        opacity: 0.75
      }

      DropArea {
        anchors.fill: parent
        onDropped: function(drop) {
          if (drop.hasUrls && drop.urls.length > 0) {
            var url = drop.urls[0].toString();
            if (url.indexOf("file://") === 0) {
              var path = url.replace("file://", "");
              Quickshell.execute(["chmod", "+x", path]);
              Quickshell.execute([path]);
              LauncherState.close();
            }
          }
        }
      }
    }
  }
}
