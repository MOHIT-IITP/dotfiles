import Quickshell
import QtQuick
import "../services"

// Clipboard history dropdown modal matching reference UI.
// Supports search filtering, mouse selection, and full keyboard navigation (Up/Down/Enter/Delete/Esc).
Rectangle {
  id: root

  readonly property bool open: ClipboardState.open
  property string query: ""
  property int sel: 0

  readonly property var allItems: ClipboardState.history
  readonly property var filtered: {
    var q = query.trim().toLowerCase();
    var list = allItems || [];
    if (q === "") return list;
    var out = [];
    for (var i = 0; i < list.length; ++i) {
      var item = list[i];
      if (item && item.text && item.text.toLowerCase().indexOf(q) !== -1) {
        out.push(item);
      }
    }
    return out;
  }

  onOpenChanged: {
    if (open) {
      ClipboardState.refresh();
      query = "";
      sel = 0;
      searchInput.text = "";
      searchInput.focus = true;
      clipFocusTimer.restart();
    }
  }

  Timer {
    id: clipFocusTimer
    interval: 30
    repeat: false
    onTriggered: {
      searchInput.forceActiveFocus();
    }
  }

  function copySelected() {
    if (sel >= 0 && sel < filtered.length) {
      ClipboardState.copyItem(filtered[sel].raw);
    }
  }

  function deleteSelected() {
    if (sel >= 0 && sel < filtered.length) {
      var target = filtered[sel].raw;
      ClipboardState.deleteItem(target);
      if (sel >= filtered.length - 1) {
        sel = Math.max(0, filtered.length - 2);
      }
    }
  }

  implicitWidth: 460
  implicitHeight: open ? 420 : 0
  radius: 20
  clip: true

  color: "#101210"
  border.color: "#2e362e"
  border.width: 1

  opacity: open ? 1 : 0
  visible: open || opacity > 0

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 260
      easing.type: Easing.OutCubic
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 180
    }
  }

  Column {
    id: mainCol
    anchors.fill: parent
    anchors.margins: 14
    spacing: 10

    // ---- Top Header Bar ----
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.right: statusRow.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Kanji glyph
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "控"
          color: "#c9dfae"
          font.pixelSize: 17
          font.bold: true
        }

        // Search TextInput
        Item {
          width: parent.width - 32
          height: 30
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: searchInput.text === ""
            text: "Search clipboard"
            color: "#525e52"
            font.pixelSize: 14
            font.family: SettingsState.fontFamily
          }

          TextInput {
            id: searchInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: "#f2f2f2"
            font.pixelSize: 14
            font.family: SettingsState.fontFamily
            clip: true
            focus: true
            activeFocusOnTab: true
            onTextChanged: {
              query = text;
              sel = 0;
            }

            Keys.onPressed: function(ev) {
              if (ev.key === Qt.Key_Down) {
                sel = Math.min(filtered.length - 1, sel + 1);
                clipList.positionViewAtIndex(sel, ListView.Contain);
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Up) {
                sel = Math.max(0, sel - 1);
                clipList.positionViewAtIndex(sel, ListView.Contain);
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) {
                copySelected();
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Delete) {
                deleteSelected();
                ev.accepted = true;
              } else if (ev.key === Qt.Key_Escape) {
                ClipboardState.close();
                ev.accepted = true;
              }
            }
          }
        }
      }

      // Status count & Sweep / Clear button on right
      Row {
        id: statusRow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: filtered.length + " / " + (allItems ? allItems.length : 0)
          color: "#6e7a6e"
          font.pixelSize: 12
          font.family: "monospace"
        }

        // Clear button (Kanji 掃)
        Rectangle {
          width: 24
          height: 24
          radius: 12
          anchors.verticalCenter: parent.verticalCenter
          color: clearMouse.containsMouse ? "#3a2222" : "transparent"

          Text {
            anchors.centerIn: parent
            text: "掃"
            color: clearMouse.containsMouse ? "#ef5350" : "#6e7a6e"
            font.pixelSize: 14
            font.bold: true
          }

          MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ClipboardState.clearAll()
          }
        }
      }
    }

    // Divider line
    Rectangle {
      width: parent.width
      height: 1
      color: "#252b25"
    }

    // Empty state
    Text {
      visible: filtered.length === 0
      text: ClipboardState.loading ? "Loading clipboard..." : "Clipboard is empty"
      color: "#525e52"
      font.pixelSize: 13
      font.family: "monospace"
      anchors.horizontalCenter: parent.horizontalCenter
      topPadding: 20
    }

    // Clipboard entries list
    ListView {
      id: clipList
      width: parent.width
      height: parent.height - 52
      clip: true
      spacing: 3
      visible: filtered.length > 0
      model: filtered
      currentIndex: sel

      delegate: Rectangle {
        id: rowRect
        width: ListView.view.width
        height: 34
        radius: 8
        color: isSelected ? "#232a20" : (itemMouse.containsMouse ? "#181d18" : "transparent")
        border.color: isSelected ? "#3a4a35" : (itemMouse.containsMouse ? "#242a24" : "transparent")
        border.width: 1

        readonly property bool isSelected: root.sel === index

        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 8
          spacing: 8

          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (delBtn.visible ? 30 : 10)
            text: modelData.text || ""
            color: isSelected ? "#f2f2f2" : (itemMouse.containsMouse ? "#d8ded8" : "#9aa39a")
            font.pixelSize: 13
            font.family: SettingsState.fontFamily
            font.bold: isSelected
            elide: Text.ElideRight
            maximumLineCount: 1
          }

          // Delete button (✕)
          Rectangle {
            id: delBtn
            width: 20
            height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            color: delMouse.containsMouse ? "#452424" : "transparent"
            visible: isSelected || itemMouse.containsMouse

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: delMouse.containsMouse ? "#ef5350" : "#6e7a6e"
              font.pixelSize: 11
            }

            MouseArea {
              id: delMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                ClipboardState.deleteItem(modelData.raw);
              }
            }
          }
        }

        MouseArea {
          id: itemMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.sel = index
          onClicked: {
            ClipboardState.copyItem(modelData.raw);
          }
        }
      }
    }
  }
}
