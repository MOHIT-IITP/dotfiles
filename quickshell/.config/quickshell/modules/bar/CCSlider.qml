import QtQuick
import "../services"

// Material 3 pill-shaped slider: chunky rounded track with integrated icon
// and a prominent dropdown button to choose input/output audio devices.
Column {
  id: root

  property string label: ""
  property string icon: "sound"
  property real value: 0
  property bool available: true
  property bool muted: false

  property string currentDeviceName: ""

  signal seeked(real v)
  signal iconClicked
  signal openDevices

  property bool _drag: false
  property real _v: 0

  readonly property real shown: Math.min(1, Math.max(0, _drag ? _v : value))

  spacing: 6
  opacity: available ? 1 : 0.4

  // Header: Label (Left) + Device Dropdown Button & Percentage Badge (Right)
  Item {
    width: parent.width
    height: 26

    // Left: Label ("Sound" / "Microphone") + clickable to open device list
    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: "#d4dbd4"
        font.pixelSize: 14
        font.bold: true
        font.family: SettingsState.fontFamily
      }
    }

    // Right: Action cluster (Device pill button + percentage badge)
    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      // Device selector dropdown pill button
      Rectangle {
        id: devChip
        height: 24
        width: Math.min(200, devRow.implicitWidth + 18)
        radius: 12
        color: devChipMouse.containsMouse ? "#2b3b28" : "#1a221a"
        border.color: devChipMouse.containsMouse ? "#4e6a45" : "#2e3a2e"
        border.width: 1
        clip: true

        Behavior on color {
          ColorAnimation { duration: 120 }
        }

        Row {
          id: devRow
          anchors.centerIn: parent
          spacing: 5

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 13
            height: 13
            kind: root.icon
            glyph: devChipMouse.containsMouse ? "#c9dfae" : "#8ea08e"
          }

          Text {
            id: devText
            anchors.verticalCenter: parent.verticalCenter
            text: root.currentDeviceName ? root.currentDeviceName : "Select device"
            color: devChipMouse.containsMouse ? "#c9dfae" : "#d0dad0"
            font.pixelSize: 11
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 120)
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "›"
            color: devChipMouse.containsMouse ? "#c9dfae" : "#8ea08e"
            font.pixelSize: 14
            font.bold: true
          }
        }

        MouseArea {
          id: devChipMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.openDevices()
        }
      }

      // Percentage badge
      Rectangle {
        id: percBadge
        height: 24
        width: percText.implicitWidth + 14
        radius: 12
        color: root.muted ? "#2a2222" : "#1f261f"
        border.color: root.muted ? "#4a2c2c" : "#2f3a2f"
        border.width: 1

        Text {
          id: percText
          anchors.centerIn: parent
          text: root.muted ? "Muted" : Math.round(root.shown * 100) + "%"
          color: root.muted ? "#ff8a8a" : "#c9dfae"
          font.pixelSize: 11
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }
    }
  }

  // Material 3 Chunky Pill Track with right-side dropdown button
  Rectangle {
    id: track
    width: parent.width
    height: 40
    radius: 20
    color: "#181d18"
    border.color: "#283028"
    border.width: 1
    clip: true

    // Active fill pill
    Rectangle {
      width: Math.max(height, parent.width * root.shown)
      height: parent.height
      radius: parent.radius
      color: root.muted ? "#424b42" : "#c9dfae"

      Behavior on width {
        enabled: !root._drag
        NumberAnimation { duration: 120 }
      }
    }

    // Left Icon Circle inside Track (Mute / Unmute)
    Rectangle {
      id: iconPill
      anchors.left: parent.left
      anchors.leftMargin: 4
      anchors.verticalCenter: parent.verticalCenter
      width: 32
      height: 32
      radius: 16
      color: iconMouse.containsMouse ? "#2f382f" : "#1b221b"

      CCIcon {
        anchors.centerIn: parent
        width: 18
        height: 18
        kind: root.muted ? (root.icon + "-mute") : root.icon
        glyph: root.muted ? "#ff8a8a" : (root.shown > 0.15 ? "#c9dfae" : "#9aa39a")
      }

      MouseArea {
        id: iconMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.iconClicked()
      }
    }

    // Right chevron button inside Track (Opens Device Selector)
    Rectangle {
      id: arrowPill
      anchors.right: parent.right
      anchors.rightMargin: 4
      anchors.verticalCenter: parent.verticalCenter
      width: 32
      height: 32
      radius: 16
      color: arrowMouse.containsMouse ? "#2f382f" : "#1b221b"
      border.color: arrowMouse.containsMouse ? "#4e6a45" : "transparent"
      border.width: 1

      Text {
        anchors.centerIn: parent
        text: "›"
        color: arrowMouse.containsMouse ? "#c9dfae" : "#8ea08e"
        font.pixelSize: 16
        font.bold: true
      }

      MouseArea {
        id: arrowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.openDevices()
      }
    }

    // Drag / click mouse area across the center of track
    MouseArea {
      anchors.left: iconPill.right
      anchors.right: arrowPill.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      enabled: root.available
      cursorShape: Qt.PointingHandCursor
      onPressed: function (ev) {
        root._drag = true;
        root._v = Math.min(1, Math.max(0, (ev.x + iconPill.width + 4) / track.width));
        root.seeked(root._v);
      }
      onPositionChanged: function (ev) {
        if (root._drag) {
          root._v = Math.min(1, Math.max(0, (ev.x + iconPill.width + 4) / track.width));
          root.seeked(root._v);
        }
      }
      onReleased: {
        root._drag = false;
      }
    }
  }
}
