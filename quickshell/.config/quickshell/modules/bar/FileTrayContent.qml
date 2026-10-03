import Quickshell
import Quickshell.Io
import QtQuick
import "../services"

// Embedded file shelf directly inside ClockPill.
// Staged files live here until dragged out to another app.
Item {
  id: root

  implicitWidth: 480
  implicitHeight: 204

  readonly property bool dndActive: FileTrayState.dndHover

  // Multi-select: Shift+click chips, then drag any selected chip to move them all.
  property var selectedPaths: []

  function isSelected(path) {
    return selectedPaths.indexOf(path) !== -1;
  }
  function toggleSelect(path) {
    if (!path) return;
    var i = selectedPaths.indexOf(path);
    var arr = selectedPaths.slice(0);
    if (i === -1) arr.push(path);
    else arr.splice(i, 1);
    selectedPaths = arr;
  }
  function clearSelection() {
    if (selectedPaths.length > 0) selectedPaths = [];
  }
  function pruneSelection() {
    var files = FileTrayState.files || [];
    var alive = {};
    for (var i = 0; i < files.length; ++i) {
      if (files[i] && files[i].path) alive[files[i].path] = true;
    }
    var arr = [];
    for (var j = 0; j < selectedPaths.length; ++j) {
      if (alive[selectedPaths[j]]) arr.push(selectedPaths[j]);
    }
    if (arr.length !== selectedPaths.length) selectedPaths = arr;
  }
  // Newline-separated uri list for DnD: whole selection if this chip is
  // part of it, otherwise just the single file.
  function dragUrlsFor(path, url) {
    var paths = (isSelected(path) && selectedPaths.length > 1) ? selectedPaths : [path];
    var files = FileTrayState.files || [];
    var byPath = {};
    for (var i = 0; i < files.length; ++i) {
      if (files[i] && files[i].path) byPath[files[i].path] = files[i].url;
    }
    var out = [];
    for (var j = 0; j < paths.length; ++j) {
      var u = byPath[paths[j]] || (paths[j] === path ? url : "");
      if (u) out.push(u);
    }
    return out.join("\r\n") + (out.length > 0 ? "\r\n" : "");
  }

  function forceFocus() {
    // nothing to focus; keep keyboard grab alive via Bar needsFocus
  }

  Connections {
    target: FileTrayState
    function onFilesChanged() { root.pruneSelection(); }
  }

  // Dashed file-tray drop zone filling the whole view.
  Rectangle {
    id: trayBox
    anchors.fill: parent
    anchors.margins: 12
    radius: 30
    color: root.dndActive ? Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.12) : "transparent"
    border.width: 0

    // dashed overlay to mimic the mockup
    Canvas {
      anchors.fill: parent
      onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);
        try { ctx.setLineDash([7, 6]); } catch (e) {}
        ctx.strokeStyle = root.dndActive ? SettingsState.accent.toString() : SettingsState.borderBase.toString();
        ctx.lineWidth = root.dndActive ? 2 : 1.2;
        var r = 30, lw = ctx.lineWidth;
        ctx.beginPath();
        var x = lw, y = lw, w = width - lw * 2, h = height - lw * 2;
        ctx.moveTo(x + r, y);
        ctx.arcTo(x + w, y, x + w, y + h, r);
        ctx.arcTo(x + w, y + h, x, y + h, r);
        ctx.arcTo(x, y + h, x, y, r);
        ctx.arcTo(x, y, x + w, y, r);
        ctx.closePath();
        ctx.stroke();
      }
      onWidthChanged: requestPaint()
      onHeightChanged: requestPaint()
      Connections {
        target: root
        function onDndActiveChanged() { parent.requestPaint(); }
      }
    }

    Column {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 8

      // header
      Item {
        width: parent.width
        height: 26
        Row {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰷏"
            font.family: SettingsState.nerdIconFont
            font.pixelSize: SettingsState.px(15)
            color: root.dndActive ? SettingsState.accent : SettingsState.textSecondary
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.dndActive ? "Drop to stash" : ("Files Tray · " + FileTrayState.count)
            color: root.dndActive ? SettingsState.accent : SettingsState.textMain
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }
        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8
          Rectangle {
            width: 58
            height: 24
            radius: 12
            color: addMouse.containsMouse ? SettingsState.accent : SettingsState.bgCardHover
            border.color: SettingsState.borderBase
            border.width: 1
            Text {
              anchors.centerIn: parent
              text: "+ Add"
              color: addMouse.containsMouse ? (SettingsState.isDark ? "#0d140e" : "#ffffff") : SettingsState.textMain
              font.pixelSize: SettingsState.px(11)
              font.bold: true
              font.family: SettingsState.fontFamily
            }
            MouseArea {
              id: addMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: pickerProc.running = true
            }
          }
          Rectangle {
            width: 54
            height: 24
            radius: 12
            visible: FileTrayState.count > 0
            color: clearMouse.containsMouse ? "#e86a65" : SettingsState.bgCardHover
            border.color: SettingsState.borderBase
            border.width: 1
            Text {
              anchors.centerIn: parent
              text: "Clear"
              color: clearMouse.containsMouse ? "#ffffff" : SettingsState.textSecondary
              font.pixelSize: SettingsState.px(11)
              font.bold: true
              font.family: SettingsState.fontFamily
            }
            MouseArea {
              id: clearMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: FileTrayState.clear()
            }
          }
        }
      }

      // hint (empty / drag-over / single-line when files present)
      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        visible: FileTrayState.count === 0 || root.dndActive
        text: root.dndActive ? "Release to stash files here" : "Drag files onto the clock bar to stash them here — then drag them out to any app."
        color: root.dndActive ? SettingsState.accent : SettingsState.textMuted
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        visible: FileTrayState.count > 0 && !root.dndActive
        text: "Drag out to any app · Shift+click multi-select · click opens · right-click removes"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(10)
        font.family: SettingsState.fontFamily
      }

      // file strip (single horizontal row, scrolls sideways)
      ListView {
        id: strip
        width: parent.width
        height: 100
        visible: FileTrayState.count > 0
        clip: true
        orientation: ListView.Horizontal
        spacing: 8
        model: FileTrayState.files
        delegate: Item {
          id: cell
          width: 92
          height: 100
          required property var modelData
          required property int index

          // Invisible proxy so the MouseArea has a drag target without moving
          // the chip itself (required for MouseArea.drag.active to work).
          Item {
            id: dragProxy
            width: 1
            height: 1
            x: -10
            y: -10
          }

          Rectangle {
            id: chip
            anchors.centerIn: parent
            width: 90
            height: 98
            radius: 14
            color: chipMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface
            border.color: (cell.modelData && root.isSelected(cell.modelData.path)) ? SettingsState.accent : (chipMouse.containsMouse ? SettingsState.accent : SettingsState.borderBase)
            border.width: (cell.modelData && root.isSelected(cell.modelData.path)) ? 2 : (chipMouse.containsMouse ? 1.5 : 1)

            // ---- external drag source ----
            Drag.active: chipMouse.drag.active
            Drag.dragType: Drag.Automatic
            Drag.supportedActions: Qt.CopyAction | Qt.MoveAction | Qt.LinkAction
            Drag.mimeData: ({ "text/uri-list": root.dragUrlsFor(cell.modelData ? cell.modelData.path : "", cell.modelData ? cell.modelData.url : "") })
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            Column {
              anchors.centerIn: parent
              spacing: 3
              width: parent.width - 10

              Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 38
                height: 38

                Image {
                  anchors.fill: parent
                  visible: cell.modelData && cell.modelData.isImage
                  source: (cell.modelData && cell.modelData.isImage) ? cell.modelData.url : ""
                  fillMode: Image.PreserveAspectCrop
                  smooth: true
                  asynchronous: true
                  sourceSize.width: 76
                  sourceSize.height: 76
                  onStatusChanged: {
                    if (status === Image.Error) visible = false;
                  }
                }
                Rectangle {
                  anchors.fill: parent
                  radius: 9
                  visible: !(cell.modelData && cell.modelData.isImage)
                  color: Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.12)
                  Text {
                    anchors.centerIn: parent
                    text: "󰈙"
                    font.family: SettingsState.nerdIconFont
                    font.pixelSize: SettingsState.px(17)
                    color: SettingsState.accent
                  }
                }
                Rectangle {
                  anchors.fill: parent
                  radius: 9
                  color: "transparent"
                  border.color: SettingsState.borderBase
                  border.width: 1
                  visible: cell.modelData && cell.modelData.isImage
                }
              }

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: cell.modelData ? cell.modelData.name : ""
                color: SettingsState.textMain
                font.pixelSize: SettingsState.px(9)
                font.family: SettingsState.fontFamily
                elide: Text.ElideMiddle
                maximumLineCount: 1
                wrapMode: Text.NoWrap
              }
            }

            Rectangle {
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.margins: 4
              width: 17
              height: 17
              radius: 8.5
              color: rmMouse.containsMouse ? "#e86a65" : SettingsState.bgCard
              border.color: SettingsState.borderBase
              border.width: 1
              visible: chipMouse.containsMouse
              Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: SettingsState.px(8)
                font.bold: true
                color: rmMouse.containsMouse ? "#fff" : SettingsState.textMuted
                font.family: SettingsState.fontFamily
              }
              MouseArea {
                id: rmMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: function(ev) {
                  FileTrayState.removeAt(cell.index);
                  ev.accepted = true;
                }
              }
            }

            MouseArea {
              id: chipMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              propagateComposedEvents: false
              preventStealing: true
              drag.target: dragProxy
              drag.axis: Drag.XAndYAxis

              property bool dragging: false

              onPressed: function(ev) {
                dragging = false;
                chip.grabToImage(function(result) {
                  chip.Drag.imageSource = result.url;
                });
              }
              onPositionChanged: {
                if (chipMouse.drag.active) dragging = true;
              }
              onClicked: function(ev) {
                if (dragging) {
                  dragging = false;
                  return;
                }
                var p = cell.modelData ? cell.modelData.path : "";
                if ((ev.modifiers & Qt.ShiftModifier) && ev.button === Qt.LeftButton) {
                  root.toggleSelect(p);
                  return;
                }
                root.clearSelection();
                if (ev.button === Qt.LeftButton) {
                  FileTrayState.openFile(cell.index);
                } else if (ev.button === Qt.RightButton) {
                  FileTrayState.removeAt(cell.index);
                }
              }
              onPressAndHold: {
                FileTrayState.revealFile(cell.index);
              }
            }
          }
        }
      }
    }
  }

  // File picker fallback (zenity / kdialog / yad)
  Process {
    id: pickerProc
    running: false
    command: ["bash", "-c", "if command -v kdialog >/dev/null 2>&1; then kdialog --multiple --getopenfilename ~; elif command -v zenity >/dev/null 2>&1; then zenity --file-selection --multiple --separator=$'\\n'; elif command -v yad >/dev/null 2>&1; then yad --file-selection --multiple --separator=$'\\n'; else echo ''; fi"]
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        var line = (data || "").trim();
        if (line !== "") FileTrayState.addPaths([line]);
      }
    }
    onExited: function(code, status) {
      running = false;
    }
  }
}
