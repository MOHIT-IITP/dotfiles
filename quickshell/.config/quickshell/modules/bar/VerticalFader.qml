import QtQuick
import "../services"

// Sleek hardware-style vertical mixer fader matching reference UI
Item {
  id: root

  property string label: ""
  property string icon: "sound"
  property real value: 0.5
  property bool muted: false
  property color activeColor: "#e05f65"
  property bool showLabel: true

  signal seeked(real v)
  signal iconClicked

  property bool _drag: false
  property real _v: 0

  readonly property real shown: Math.min(1, Math.max(0, _drag ? _v : value))

  implicitWidth: 70
  implicitHeight: 240

  // Drag mouse area over entire slider track area
  MouseArea {
    id: faderMouse
    anchors.top: trackArea.top
    anchors.bottom: trackArea.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 44
    cursorShape: Qt.PointingHandCursor

    onPressed: function (ev) {
      root._drag = true;
      var h = trackArea.height;
      var val = 1.0 - (ev.y / h);
      root._v = Math.min(1, Math.max(0, val));
      root.seeked(root._v);
    }

    onPositionChanged: function (ev) {
      if (root._drag) {
        var h = trackArea.height;
        var val = 1.0 - (ev.y / h);
        root._v = Math.min(1, Math.max(0, val));
        root.seeked(root._v);
      }
    }

    onReleased: {
      root._drag = false;
    }
  }

  // Fader Track Area
  Item {
    id: trackArea
    anchors.top: parent.top
    anchors.topMargin: 10
    anchors.bottom: footerArea.top
    anchors.bottomMargin: 14
    anchors.horizontalCenter: parent.horizontalCenter
    width: 28

    // Background track groove
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 3
      radius: 1.5
      color: "#2a2222"
    }

    // Active bottom fill
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      width: 3
      height: parent.height * root.shown
      radius: 1.5
      color: root.muted ? "#444444" : root.activeColor

      Behavior on height {
        enabled: !root._drag
        NumberAnimation { duration: 100 }
      }
    }

    // Top indicator cap glow (shown at top of active track)
    Rectangle {
      visible: root.shown >= 0.95 && !root.muted
      anchors.horizontalCenter: parent.horizontalCenter
      y: 0
      width: 12
      height: 4
      radius: 2
      color: root.activeColor
      opacity: 0.9
    }

    // Fader Thumb / Knob (horizontal bar)
    Rectangle {
      id: thumb
      anchors.horizontalCenter: parent.horizontalCenter
      y: Math.max(0, Math.min(parent.height - height, parent.height * (1.0 - root.shown) - height / 2))
      width: 22
      height: 6
      radius: 2
      color: root.muted ? "#666666" : (faderMouse.containsMouse ? "#ffffff" : "#d8d8d8")
      border.color: "#181818"
      border.width: 1

      Behavior on y {
        enabled: !root._drag
        NumberAnimation { duration: 100 }
      }

      // Small accent notch on thumb
      Rectangle {
        anchors.centerIn: parent
        width: 6
        height: 2
        radius: 1
        color: root.muted ? "#333333" : root.activeColor
      }
    }
  }

  // Footer: Percentage + Icon + Label
  Column {
    id: footerArea
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 4
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 3

    // Percentage badge
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.muted ? "MUTE" : (Math.round(root.shown * 100) + "%")
      color: root.muted ? "#ff8a8a" : (faderMouse.containsMouse ? root.activeColor : "#8e998e")
      font.pixelSize: 10
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    // Channel Icon
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 32
      height: 32
      radius: 16
      color: iconAreaMouse.containsMouse ? "#262020" : "transparent"

      CCIcon {
        anchors.centerIn: parent
        width: 18
        height: 18
        kind: root.muted ? (root.icon + "-mute") : root.icon
        glyph: root.muted ? "#ff8a8a" : (faderMouse.containsMouse ? root.activeColor : "#c0c8c0")
      }

      MouseArea {
        id: iconAreaMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.iconClicked()
      }
    }

    // Channel Name Label
    Text {
      visible: root.showLabel && root.label !== ""
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.label
      color: root.muted ? "#777777" : (faderMouse.containsMouse ? "#ffffff" : "#99a299")
      font.pixelSize: 11
      font.bold: true
      font.family: SettingsState.fontFamily
    }
  }
}
