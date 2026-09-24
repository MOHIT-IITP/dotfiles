import QtQuick
import "../services"

// Sleek modern slider with a slim track, crystal-clear icon & header,
// and prominent device selector dropdown.
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

  // Header: Icon + Label (Left) | Device Selector Dropdown + Percentage Badge (Right)
  Item {
    width: parent.width
    height: 22

    // Left: Clickable Mute Icon + Label
    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      // Clickable icon circle
      Rectangle {
        width: 22
        height: 22
        radius: 11
        anchors.verticalCenter: parent.verticalCenter
        color: root.muted ? (SettingsState.isDark ? "#30ef5350" : "#20ef5350") : (iconMouse.containsMouse ? SettingsState.bgActivePill : "transparent")

        CCIcon {
          anchors.centerIn: parent
          width: 15
          height: 15
          kind: root.muted ? (root.icon + "-mute") : root.icon
          glyph: root.muted ? "#ef5350" : (iconMouse.containsMouse ? SettingsState.textActive : SettingsState.accent)
        }

        MouseArea {
          id: iconMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.iconClicked()
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: SettingsState.textMain
        font.pixelSize: 13
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
        height: 22
        width: Math.min(190, devRow.implicitWidth + 16)
        radius: 11
        color: devChipMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgCard
        border.color: devChipMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
        border.width: 1
        clip: true

        Behavior on color {
          ColorAnimation { duration: 120 }
        }

        Row {
          id: devRow
          anchors.centerIn: parent
          spacing: 4

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            kind: root.icon
            glyph: devChipMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
          }

          Text {
            id: devText
            anchors.verticalCenter: parent.verticalCenter
            text: root.currentDeviceName ? root.currentDeviceName : "Select device"
            color: devChipMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: 11
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 115)
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\uf054"
              font.family: SettingsState.nerdIconFont
            color: devChipMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: 13
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
        height: 22
        width: percText.implicitWidth + 12
        radius: 11
        color: root.muted ? (SettingsState.isDark ? "#2a1e1e" : "#ffebeb") : SettingsState.bgCard
        border.color: root.muted ? (SettingsState.isDark ? "#4a2c2c" : "#ffb8b8") : SettingsState.borderBase
        border.width: 1

        Text {
          id: percText
          anchors.centerIn: parent
          text: root.muted ? "Muted" : Math.round(root.shown * 100) + "%"
          color: root.muted ? "#ef5350" : SettingsState.textActive
          font.pixelSize: 11
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }
    }
  }

  // Slim Track Bar
  Item {
    width: parent.width
    height: 16

    Rectangle {
      id: track
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 10
      radius: 5
      color: SettingsState.bgCard
      border.color: sliderMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
      border.width: 1
      clip: true

      // Active fill bar
      Rectangle {
        width: Math.max(0, parent.width * root.shown)
        height: parent.height
        radius: parent.radius
        color: root.muted ? SettingsState.borderBase : SettingsState.accent

        Behavior on width {
          enabled: !root._drag
          NumberAnimation { duration: 100 }
        }
      }
    }

    // Expanded interactive drag & click target for easy mouse grabbing
    MouseArea {
      id: sliderMouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.available
      cursorShape: Qt.PointingHandCursor

      onPressed: function (ev) {
        root._drag = true;
        root._v = Math.min(1, Math.max(0, ev.x / width));
        root.seeked(root._v);
      }
      onPositionChanged: function (ev) {
        if (root._drag) {
          root._v = Math.min(1, Math.max(0, ev.x / width));
          root.seeked(root._v);
        }
      }
      onReleased: {
        root._drag = false;
      }
    }
  }
}
