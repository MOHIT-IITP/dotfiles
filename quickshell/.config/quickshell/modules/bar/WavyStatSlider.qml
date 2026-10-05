import QtQuick
import "../services"
import "WavySliderPaint.js" as WavyPaint

// Wavy stat slider matching reference: white sine-wave fill,
// muted purple track, accent vertical pill handle.
Item {
  id: root

  property real fraction: 0 // 0..1
  property color waveColor: SettingsState.isDark ? "#FFFFFF" : "#1c1c22"
  property color trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3"
  property color handleColor: SettingsState.accent
  property color remainingColor: Qt.rgba(waveColor.r, waveColor.g, waveColor.b, 0.3)
  property real remainingW: 3.5
  property real remainingGap: 8
  property bool showTrack: true
  property bool showHandle: true
  property bool showRemaining: false

  property real trackH: 5
  property real waveW: 3
  property real waveAmp: 2.5
  property real waveLen: 18
  property real handleW: 6
  property real handleH: 16

  readonly property real shown: Math.max(0, Math.min(1, animVal))
  property real animVal: Math.max(0, Math.min(1, fraction))

  Behavior on animVal {
    NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
  }
  onAnimValChanged: waveCanvas.requestPaint()
  onWidthChanged: waveCanvas.requestPaint()
  onHeightChanged: waveCanvas.requestPaint()
  onWaveColorChanged: waveCanvas.requestPaint()
  onTrackColorChanged: waveCanvas.requestPaint()
  onHandleColorChanged: waveCanvas.requestPaint()
  onRemainingColorChanged: waveCanvas.requestPaint()
  onShowTrackChanged: waveCanvas.requestPaint()
  onShowHandleChanged: waveCanvas.requestPaint()
  onShowRemainingChanged: waveCanvas.requestPaint()

  implicitHeight: 14

  Canvas {
    id: waveCanvas
    anchors.fill: parent
    antialiasing: true
    renderStrategy: Canvas.Cooperative

    onPaint: {
      WavyPaint.paint(getContext("2d"), width, height, {
        shown: root.shown,
        showTrack: root.showTrack,
        showHandle: root.showHandle,
        showRemaining: root.showRemaining,
        remainingColor: root.remainingColor,
        remainingW: root.remainingW,
        remainingGap: root.remainingGap,
        waveColor: root.waveColor,
        trackColor: root.trackColor,
        handleColor: root.handleColor,
        trackH: root.trackH,
        waveW: root.waveW,
        waveAmp: root.waveAmp,
        waveLen: root.waveLen,
        handleW: root.handleW,
        handleH: root.handleH
      });
    }
  }
}
