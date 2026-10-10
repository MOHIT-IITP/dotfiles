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

  property real currentPos: value
  readonly property real shown: Math.min(1, Math.max(0, currentPos))

  onValueChanged: {
    if (!seekAnim.running && !faderMouse.dragging) {
      currentPos = value;
    }
  }

  NumberAnimation {
    id: seekAnim
    target: root
    property: "currentPos"
    duration: 350
    easing.type: Easing.InOutCubic
    onRunningChanged: waveCanvas.requestPaint()
    onFinished: {
      if (!faderMouse.dragging) {
        currentPos = root.value;
        waveCanvas.requestPaint();
      }
    }
  }

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

    property real startY: 0
    property bool dragging: false

    onPressed: function (ev) {
      faderMouse.startY = ev.y;
      faderMouse.dragging = false;

      var h = trackArea.height;
      if (h <= 0) return;
      var val = Math.min(1, Math.max(0, 1.0 - (ev.y / h)));

      var startVal = root.currentPos;
      seekAnim.stop();
      root.currentPos = startVal;
      seekAnim.from = startVal;
      seekAnim.to = val;
      seekAnim.restart();

      root.seeked(val);
    }

    onPositionChanged: function (ev) {
      if (!pressed) return;
      if (!faderMouse.dragging && Math.abs(ev.y - faderMouse.startY) > 4) {
        faderMouse.dragging = true;
        seekAnim.stop();
      }
      if (faderMouse.dragging) {
        var h = trackArea.height;
        if (h <= 0) return;
        var val = Math.min(1, Math.max(0, 1.0 - (ev.y / h)));
        root.currentPos = val;
        waveCanvas.requestPaint();
        root.seeked(val);
      }
    }

    onReleased: {
      faderMouse.dragging = false;
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
      renderStrategy: Canvas.Immediate

      onPaint: {
        WavyPaint.paintVertical(getContext("2d"), width, height, {
          shown: root.shown,
          trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3",
          waveColor: root.muted ? SettingsState.textMuted : root.activeColor,
          handleColor: root.muted ? "#666666" : root.activeColor,
          trackW: 4.5,
          waveW: 4.5,
          waveAmp: 2.5,
          waveLen: height / 5, // Exactly 5 waves across full height
          handleW: 20,
          handleH: 8
        });
      }
    }

    Connections {
      target: root
      function onShownChanged() { waveCanvas.requestPaint(); }
      function onCurrentPosChanged() { waveCanvas.requestPaint(); }
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
