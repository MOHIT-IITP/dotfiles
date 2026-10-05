import QtQuick
import "../services"
import "WavySliderPaint.js" as WavyPaint

// Wavy vertical mixer fader with handle: sine-wave active fill
// rising from the bottom, muted track, horizontal pill handle.
Item {
  id: root

  property string label: ""
  property string icon: "sound"
  property real value: 0.5
  property bool muted: false
  property color activeColor: SettingsState.accent
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

  // Fader Track Area (wavy slider with handle)
  Item {
    id: trackArea
    anchors.top: parent.top
    anchors.topMargin: 10
    anchors.bottom: footerArea.top
    anchors.bottomMargin: 14
    anchors.horizontalCenter: parent.horizontalCenter
    width: 28

    Canvas {
      id: waveCanvas
      anchors.fill: parent
      antialiasing: true
      renderStrategy: Canvas.Cooperative

      onPaint: {
        WavyPaint.paintVertical(getContext("2d"), width, height, {
          shown: root.shown,
          trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3",
          waveColor: root.muted ? SettingsState.textMuted : root.activeColor,
          handleColor: root.muted ? "#666666" : root.activeColor,
          trackW: 7,
          waveW: 4.5,
          waveAmp: 2.5,
          waveLen: 18,
          handleW: 20,
          handleH: 8
        });
      }
    }

    Connections {
      target: root
      function onShownChanged() { waveCanvas.requestPaint(); }
      function onMutedChanged() { waveCanvas.requestPaint(); }
      function onActiveColorChanged() { waveCanvas.requestPaint(); }
    }
    Connections {
      target: SettingsState
      function onIsDarkChanged() { waveCanvas.requestPaint(); }
      function onAccentChanged() { waveCanvas.requestPaint(); }
    }
    onWidthChanged: waveCanvas.requestPaint()
    onHeightChanged: waveCanvas.requestPaint()
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
      font.pixelSize: SettingsState.px(10)
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
      font.pixelSize: SettingsState.px(11)
      font.bold: true
      font.family: SettingsState.fontFamily
    }
  }
}
