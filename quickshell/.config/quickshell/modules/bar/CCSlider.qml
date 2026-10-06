import QtQuick
import "../services"
import "WavySliderPaint.js" as WavyPaint

// Wavy interactive slider with handle: sine-wave active fill,
// muted track, accent vertical pill handle.
Column {
  id: root

  property string label: ""
  property string icon: "sound"
  property real value: 0
  property bool available: true
  property bool muted: false

  property string currentDeviceName: ""
  property real waveLen: 0 // 0 = auto 5 waves across width

  signal seeked(real v)
  signal iconClicked
  signal openDevices

  property real currentPos: value
  readonly property real shown: Math.min(1, Math.max(0, currentPos))

  onValueChanged: {
    if (!seekAnim.running && !sliderMouse.dragging) {
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
      if (!sliderMouse.dragging) {
        currentPos = root.value;
        waveCanvas.requestPaint();
      }
    }
  }

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
        font.pixelSize: SettingsState.px(15)
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
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 115)
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\ueab6"
              font.family: SettingsState.nerdIconFont
            color: devChipMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: SettingsState.px(15)
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
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }
    }
  }

  // Wavy slider track with handle
  Item {
    width: parent.width
    height: 26

    Canvas {
      id: waveCanvas
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 22
      antialiasing: true
      renderStrategy: Canvas.Immediate

      onPaint: {
        WavyPaint.paint(getContext("2d"), width, height, {
          shown: root.shown,
          showTrack: true,
          showHandle: true,
          showRemaining: false,
          waveColor: root.muted ? SettingsState.textMuted : SettingsState.accent,
          trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3",
          handleColor: root.muted ? SettingsState.textMuted : SettingsState.accent,
          trackH: 8,
          waveW: 5,
          waveAmp: 2.5,
          waveLen: root.waveLen > 0 ? root.waveLen : (width / 5),
          handleW: 7,
          handleH: 20
        });
      }
    }

    Connections {
      target: root
      function onShownChanged() { waveCanvas.requestPaint(); }
      function onCurrentPosChanged() { waveCanvas.requestPaint(); }
      function onMutedChanged() { waveCanvas.requestPaint(); }
      function onAvailableChanged() { waveCanvas.requestPaint(); }
    }
    Connections {
      target: SettingsState
      function onIsDarkChanged() { waveCanvas.requestPaint(); }
      function onAccentChanged() { waveCanvas.requestPaint(); }
    }
    onWidthChanged: waveCanvas.requestPaint()

    // Expanded interactive drag & click target for easy mouse grabbing
    MouseArea {
      id: sliderMouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.available
      cursorShape: Qt.PointingHandCursor

      property real startX: 0
      property bool dragging: false

      onPressed: function (ev) {
        sliderMouse.startX = ev.x;
        sliderMouse.dragging = false;

        var startVal = root.currentPos;
        var r = Math.min(1, Math.max(0, ev.x / width));

        // Smoothly animate from exact current position to clicked target
        seekAnim.stop();
        root.currentPos = startVal;
        seekAnim.from = startVal;
        seekAnim.to = r;
        seekAnim.restart();

        root.seeked(r);
      }

      onPositionChanged: function (ev) {
        if (!pressed) return;
        if (!sliderMouse.dragging && Math.abs(ev.x - sliderMouse.startX) > 4) {
          sliderMouse.dragging = true;
          seekAnim.stop();
        }
        if (sliderMouse.dragging) {
          var r = Math.min(1, Math.max(0, ev.x / width));
          root.currentPos = r;
          waveCanvas.requestPaint();
          root.seeked(r);
        }
      }

      onReleased: function () {
        sliderMouse.dragging = false;
      }
    }
  }
}
