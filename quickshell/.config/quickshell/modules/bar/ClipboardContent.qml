import Quickshell
import QtQuick
import QtQuick.Effects
import "../services"

// Embedded Clipboard History subview directly inside ClockPill.
// Supports search filtering, thumbnail image previews, mouse selection, and full keyboard navigation (Up/Down/Enter/Delete/Esc).
Item {
  id: root

  property string query: ""
  property int sel: 0

  readonly property var allItems: ClipboardState.history
  readonly property var filtered: {
    var q = query.trim().toLowerCase();
    var list = ClipboardState.history || [];
    if (q === "") return list;
    var out = [];
    for (var i = 0; i < list.length; ++i) {
      var item = list[i];
      if (!item) continue;
      var matchText = item.isImage ? ((item.label || "") + " " + (item.sizeLabel || "")) : (item.text || "");
      if (matchText.toLowerCase().indexOf(q) !== -1) {
        out.push(item);
      }
    }
    return out;
  }

  implicitWidth: 460
  implicitHeight: 420

  function forceFocus() {
    searchInput.focus = true;
    searchInput.forceActiveFocus();
  }

  Connections {
    target: ClipboardState
    function onOpenChanged() {
      if (ClipboardState.open) {
        ClipboardState.refresh();
        query = "";
        sel = 0;
        searchInput.text = "";
        forceFocus();
        clipFocusTimer.restart();
      }
    }
  }

  Timer {
    id: clipFocusTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (searchInput.activeFocus || count > 8) {
        running = false;
      }
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
          color: SettingsState.accent
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
            color: SettingsState.textMuted
            font.pixelSize: 14
            font.family: SettingsState.fontFamily
          }

          TextInput {
            id: searchInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
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
          color: SettingsState.textSecondary
          font.pixelSize: 12
          font.family: "monospace"
        }

        // Clear button (Kanji 掃)
        Rectangle {
          width: 24
          height: 24
          radius: 12
          anchors.verticalCenter: parent.verticalCenter
          color: clearMouse.containsMouse ? (SettingsState.isDark ? "#3a2222" : "#ffebee") : "transparent"

          Text {
            anchors.centerIn: parent
            text: "掃"
            color: clearMouse.containsMouse ? "#ef5350" : SettingsState.textSecondary
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
      color: SettingsState.borderBase
    }

    // Empty state
    Text {
      visible: filtered.length === 0
      text: ClipboardState.loading ? "Loading clipboard..." : "Clipboard is empty"
      color: SettingsState.textMuted
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
      spacing: 4
      visible: filtered.length > 0
      model: filtered
      currentIndex: sel

      delegate: Rectangle {
        id: rowRect
        width: ListView.view.width
        height: modelData.isImage ? 44 : 34
        radius: 8
        color: isSelected ? SettingsState.bgActivePill : (itemMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
        border.color: isSelected ? SettingsState.borderActive : (itemMouse.containsMouse ? SettingsState.borderBase : "transparent")
        border.width: 1

        readonly property bool isSelected: root.sel === index

        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 8
          spacing: 8

          // Thumbnail for images
          Rectangle {
            id: thumbBox
            width: 48
            height: 32
            radius: 5
            anchors.verticalCenter: parent.verticalCenter
            visible: modelData.isImage
            color: SettingsState.bgCard
            border.color: SettingsState.borderBase
            border.width: 1
            clip: true

            Image {
              id: thumbImg
              anchors.fill: parent
              anchors.margins: 1
              source: modelData.isImage && modelData.thumb ? "file://" + modelData.thumb : ""
              sourceSize.width: 96
              sourceSize.height: 96
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              cache: false
              smooth: true
              onStatusChanged: {
                if (thumbImg.status === Image.Error) {
                  thumbImg.source = "";
                }
              }
            }

            // Fallback icon if thumbnail fails or is loading
            Text {
              anchors.centerIn: parent
              visible: thumbImg.status !== Image.Ready
              text: "🖼"
              font.pixelSize: 14
            }
          }

          // Main text / image label
          Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (thumbBox.visible ? 56 : 0) - (sizeTag.visible ? sizeTag.implicitWidth + 8 : 0) - (delBtn.visible ? 30 : 10)
            text: modelData.isImage ? (modelData.label || "Image") : (modelData.text || "")
            color: isSelected ? SettingsState.textActive : (itemMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary)
            font.pixelSize: 13
            font.family: SettingsState.fontFamily
            font.bold: isSelected
            elide: Text.ElideRight
            maximumLineCount: 1
          }

          // Size tag for images
          Text {
            id: sizeTag
            anchors.verticalCenter: parent.verticalCenter
            visible: modelData.isImage && modelData.sizeLabel !== ""
            text: modelData.sizeLabel || ""
            color: SettingsState.textMuted
            font.pixelSize: 11
            font.family: "monospace"
          }

          // Delete button (✕)
          Rectangle {
            id: delBtn
            width: 20
            height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            color: delMouse.containsMouse ? (SettingsState.isDark ? "#452424" : "#ffcdd2") : "transparent"
            visible: isSelected || itemMouse.containsMouse

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: delMouse.containsMouse ? "#ef5350" : SettingsState.textSecondary
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
