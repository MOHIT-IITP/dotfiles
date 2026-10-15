import QtQuick

// Hold-to-confirm shared by destructive gestures (wallpaper trash):
// `hold` fills 0→1 while pressed, fires `confirmed` when full and drains
// on release or exit. A release shorter than `tapThreshold` additionally
// fires `tapped` for sites whose hitbox doubles as a click target.
Item {
  id: root

  visible: false

  property real hold: 0
  readonly property bool holding: hold > 0.001
  property real tapThreshold: 0.25
  property bool fired: false

  signal confirmed()
  signal tapped()

  function press() {
    fired = false;
    drain.stop();
    fill.restart();
  }

  function release() {
    fill.stop();
    if (fired || hold >= 1)
      return;
    if (tapThreshold > 0 && hold < tapThreshold)
      tapped();
    drain.restart();
  }

  function cancel() {
    fill.stop();
    drain.restart();
  }

  NumberAnimation {
    id: fill
    target: root
    property: "hold"
    from: 0
    to: 1
    duration: 1100
    onFinished: {
      root.fired = true;
      root.confirmed();
      drain.restart();
    }
  }

  NumberAnimation {
    id: drain
    target: root
    property: "hold"
    to: 0
    duration: 180
  }
}
