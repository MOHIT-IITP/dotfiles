import QtQuick
import "../services"

// Shared pill toggle switch (bluetooth, wifi, audio mute, settings rows).
// Geometry derives from the item size: knob = height - 6, radius = height / 2,
// knob travel inset 3px — identical to the previously hand-rolled toggles.
Rectangle {
  id: root

  property bool on: false
  property color trackOn: SettingsState.accent
  property color trackOff: SettingsState.bgCard
  property color knobOn: "#ffffff"
  property color knobOff: SettingsState.textMuted
  property bool frameWhenOff: false

  signal toggled()

  radius: height / 2
  color: on ? trackOn : trackOff
  border.color: SettingsState.borderBase
  border.width: (!on && frameWhenOff) ? 1 : 0

  Behavior on color {
    ColorAnimation { duration: 200 }
  }

  Rectangle {
    width: parent.height - 6
    height: parent.height - 6
    radius: (parent.height - 6) / 2
    color: root.on ? root.knobOn : root.knobOff
    anchors.verticalCenter: parent.verticalCenter
    x: root.on ? parent.width - width - 3 : 3

    Behavior on x {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}
