import QtQuick
import "../services"

// Single icon button for the horizontal control-center strip.
// Plain outline icon like the reference image: transparent idle,
// accent-soft circle on hover, accent pill when active. No dark hover fill.
Item {
  id: root
  width: 34
  height: 34

  property string kind: "wifi"
  property bool active: false
  property bool alert: false
  property bool filled: false
  property string label: ""

  signal clicked

  readonly property color hoverTint: Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.14)

  Rectangle {
    id: bg
    anchors.centerIn: parent
    width: 32
    height: 32
    radius: 16
    color: root.active ? SettingsState.bgActivePill : (iconMouse.containsMouse ? root.hoverTint : "transparent")
    border.width: 0

    Behavior on color { ColorAnimation { duration: 150 } }

    CCIcon {
      anchors.centerIn: parent
      width: 19
      height: 19
      kind: root.kind
      glyph: root.alert ? "#e05f65" : ((root.active || iconMouse.containsMouse) ? SettingsState.accent : SettingsState.textSecondary)
    }
  }

  // Recording / alert dot pinned above (like the red dot in the reference)
  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.top
    anchors.bottomMargin: -6
    width: 4
    height: 4
    radius: 2
    color: "#ff453a"
    visible: root.alert
  }

  MouseArea {
    id: iconMouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onContainsMouseChanged: {
      if (containsMouse)
        AmeState.follow(root);
    }
    onClicked: root.clicked()
  }
}
