import QtQuick
import QtQuick.Effects
import "../services"
import "../utils"

// Left media player. Collapsed: art thumbnail circle.
// Hovered: compact player card (rounded art, metadata, progress, controls).
Rectangle {
  id: root
  readonly property var player: MediaState.activePlayer
  readonly property bool hasPlayer: MediaState.hasPlayer
  readonly property bool isPlaying: MediaState.isPlaying
  // Right-swipe on the expanded card flips to system stats.
  property bool showStats: false

  implicitWidth: playerMouse.containsMouse ? 328 : 34
  implicitHeight: playerMouse.containsMouse ? 148 : 34
  radius: playerMouse.containsMouse ? 22 : 17
  clip: true

  color: playerMouse.containsMouse ? SettingsState.bgCard : SettingsState.bgSurface
  border.color: SettingsState.barBorder
  border.width: 1

  Behavior on implicitWidth {
    NumberAnimation {
      duration: 320
      easing.type: Easing.OutCubic
    }
  }
  Behavior on implicitHeight {
    NumberAnimation {
      duration: 320
      easing.type: Easing.OutCubic
    }
  }
  Behavior on radius {
    NumberAnimation {
      duration: 320
      easing.type: Easing.OutCubic
    }
  }
  Behavior on color {
    ColorAnimation {
      duration: 200
    }
  }

  // ---- Collapsed: art thumbnail circle ----
  Item {
    anchors.centerIn: parent
    width: 20
    height: 20
    opacity: playerMouse.containsMouse ? 0 : 1
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: playerMouse.containsMouse ? 100 : 180
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: "#1c1c1c"
    }

    // Artwork masked to a true circle (Item.clip is rectangular,
    // so a rounded Rectangle alone would leave the image square).
    Item {
      id: thumbClip
      anchors.fill: parent
      visible: (player?.trackArtUrl ?? "") !== ""

      layer.enabled: true
      layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: thumbMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
      }

      Rectangle {
        id: thumbMask
        anchors.fill: parent
        radius: width / 2
        visible: false
        layer.enabled: true
      }

      Image {
        anchors.fill: parent
        source: player?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
      }
    }
    Text {
      anchors.centerIn: parent
      visible: !player?.trackArtUrl
      text: "\uf001"
        font.family: SettingsState.nerdIconFont
      color: "#8f8f8f"
      font.pixelSize: SettingsState.px(11)
    }
  }

  // Swipe layer over the expanded card: right swipe -> stats, left swipe -> player.
  // Sits below the controls so buttons and progress bar keep their clicks.
  MouseArea {
    id: statsGesture
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: 14
    anchors.rightMargin: 14
    width: 300
    height: 120
    visible: playerMouse.containsMouse
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    property real _pressX: 0
    property bool _moved: false

    onPressed: function (ev) {
      statsGesture._pressX = ev.x;
      statsGesture._moved = false;
    }

    onPositionChanged: function (ev) {
      if (!statsGesture.pressed || statsGesture._moved)
        return;
      var dx = ev.x - statsGesture._pressX;
      if (dx > 24) {
        statsGesture._moved = true;
        root.showStats = true;
      } else if (dx < -24) {
        statsGesture._moved = true;
        root.showStats = false;
      }
    }

    onWheel: wheel => {
      if (wheel.angleDelta.x > 0 || wheel.pixelDelta.x > 0)
        root.showStats = true;
      else if (wheel.angleDelta.x < 0 || wheel.pixelDelta.x < 0)
        root.showStats = false;
    }
  }

  // ---- Expanded: compact player card ----
  Item {
    id: expandedView
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: 14
    anchors.rightMargin: 14
    width: 300
    height: 120
    opacity: playerMouse.containsMouse ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: playerMouse.containsMouse ? 200 : 120
      }
    }

    Text {
      anchors.centerIn: parent
      visible: !hasPlayer
      text: "Nothing playing"
      color: "#8f8f8f"
      font.pixelSize: SettingsState.px(14)
      font.family: SettingsState.fontFamily
    }

    Column {
      anchors.fill: parent
      spacing: 8
      visible: hasPlayer && !root.showStats

      // Top row: rounded art + title/artist + live EQ
      Row {
        width: parent.width
        height: 48
        spacing: 10

        // Album art with rounded corners
        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: 48
          height: 48

          Rectangle {
            anchors.fill: parent
            radius: 9
            color: "#1c1c1c"
          }

          Item {
            anchors.fill: parent
            visible: (player?.trackArtUrl ?? "") !== ""

            layer.enabled: true
            layer.effect: MultiEffect {
              maskEnabled: true
              maskSource: expArtMask
              maskThresholdMin: 0.5
              maskSpreadAtMin: 1.0
            }

            Rectangle {
              id: expArtMask
              anchors.fill: parent
              radius: 9
              visible: false
              layer.enabled: true
            }

            Image {
              anchors.fill: parent
              source: player?.trackArtUrl ?? ""
              fillMode: Image.PreserveAspectCrop
              smooth: true
              asynchronous: true
            }
          }

          Text {
            anchors.centerIn: parent
            visible: (player?.trackArtUrl ?? "") === ""
            text: "\uf001"
              font.family: SettingsState.nerdIconFont
            color: "#8f8f8f"
            font.pixelSize: SettingsState.px(16)
          }
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 48 - 14 - 20
          spacing: 3

          Text {
            width: parent.width
            text: player?.trackTitle || "Unknown Title"
            color: "#f2f2f2"
            font.pixelSize: SettingsState.px(14)
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            maximumLineCount: 1
          }
          Text {
            width: parent.width
            text: player?.trackArtist || "Unknown Artist"
            color: "#b9b9b9"
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }

        // Live equalizer bars
        Row {
          id: eqRow
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2.5
          property real phase: 0

          NumberAnimation on phase {
            from: 0
            to: 6.2832
            duration: 1200
            loops: Animation.Infinite
            running: isPlaying
          }

          Repeater {
            model: 3
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 3
              height: isPlaying ? (5 + 9 * (0.5 + 0.5 * Math.sin(eqRow.phase + index * 2.1))) : 4
              radius: 1.5
              color: isPlaying ? "#7ee2a8" : "#5a5f5a"
            }
          }
        }
      }

      // Progress: elapsed | bar | -remaining (click to seek)
      Row {
        width: parent.width
        height: 12
        spacing: 8

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 32
          text: player ? Format.fmtTime(player.position || 0) : "0:00"
          color: "#8f8f8f"
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          id: progTrack
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 32 - 38 - 16
          height: 3
          radius: 1.5
          color: "#3a3f3a"

          Rectangle {
            width: (player && player.length > 0) ? parent.width * Math.min(1, (player.position || 0) / player.length) : 0
            height: parent.height
            radius: parent.radius
            color: "#d4d4d4"
          }
          Rectangle {
            x: ((player && player.length > 0) ? progTrack.width * Math.min(1, (player.position || 0) / player.length) : 0) - 3
            anchors.verticalCenter: parent.verticalCenter
            width: 6
            height: 6
            radius: 3
            color: "#7ee2a8"
          }

          MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: function (ev) {
              if (player && player.canSeek && player.length > 0) {
                var r = ev.x / progTrack.width;
                player.position = Math.max(0, Math.min(1, r)) * player.length;
                player.positionChanged();
              }
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 38
          horizontalAlignment: Text.AlignRight
          text: (player && player.length > 0) ? ("-" + Format.fmtTime(Math.max(0, (player.length || 0) - (player.position || 0)))) : "-0:00"
          color: "#8f8f8f"
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }
      }

      // Controls: prev / play-pause / next + source app
      Item {
        width: parent.width
        height: 34

        Row {
          anchors.centerIn: parent
          spacing: 16

          // Previous
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 14
            color: prevArea.containsMouse ? "#2e332e" : "transparent"
            opacity: player?.canGoPrevious ? 1 : 0.3
            Canvas {
              anchors.centerIn: parent
              width: 12
              height: 12
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#e8e8e8";
                ctx.fillRect(1, 3, 2.5, 8);
                ctx.beginPath();
                ctx.moveTo(12.5, 2.5);
                ctx.lineTo(4.5, 7);
                ctx.lineTo(12.5, 11.5);
                ctx.closePath();
                ctx.fill();
              }
            }
            MouseArea {
              id: prevArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              enabled: Boolean(player?.canGoPrevious)
              onClicked: {
                if (player)
                  player.previous();
              }
            }
          }

          // Play / pause
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 34
            radius: 17
            color: playArea.containsMouse ? "#3a403a" : "transparent"
            Canvas {
              anchors.centerIn: parent
              width: 14
              height: 14
              visible: !isPlaying
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#f2f2f2";
                ctx.beginPath();
                ctx.moveTo(4, 2);
                ctx.lineTo(13, 8);
                ctx.lineTo(4, 14);
                ctx.closePath();
                ctx.fill();
              }
            }
            Canvas {
              anchors.centerIn: parent
              width: 14
              height: 14
              visible: isPlaying
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#f2f2f2";
                ctx.fillRect(3, 2, 3.5, 12);
                ctx.fillRect(9.5, 2, 3.5, 12);
              }
            }
            MouseArea {
              id: playArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              enabled: Boolean(player?.canTogglePlaying)
              onClicked: {
                if (player)
                  player.togglePlaying();
              }
            }
          }

          // Next
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 14
            color: nextArea.containsMouse ? "#2e332e" : "transparent"
            opacity: player?.canGoNext ? 1 : 0.3
            Canvas {
              anchors.centerIn: parent
              width: 12
              height: 12
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#e8e8e8";
                ctx.fillRect(10.5, 3, 2.5, 8);
                ctx.beginPath();
                ctx.moveTo(1.5, 2.5);
                ctx.lineTo(9.5, 7);
                ctx.lineTo(1.5, 11.5);
                ctx.closePath();
                ctx.fill();
              }
            }
            MouseArea {
              id: nextArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              enabled: Boolean(player?.canGoNext)
              onClicked: {
                if (player)
                  player.next();
              }
            }
          }
        }

        Text {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          width: 60
          horizontalAlignment: Text.AlignRight
          text: player?.identity ?? ""
          color: "#5a5f5a"
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
          maximumLineCount: 1
        }
      }
    }
  }

  // ---- Expanded: system stats (right-swipe from now playing) ----
  Item {
    id: statsView
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: 14
    anchors.rightMargin: 14
    width: 300
    height: 120
    opacity: (playerMouse.containsMouse && root.showStats) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }

    Grid {
      anchors.fill: parent
      anchors.margins: 8
      columns: 2
      columnSpacing: 14
      rowSpacing: 10

      // RAM cell
      Column {
        width: (parent.width - 14) / 2
        spacing: 1

        Row {
          width: parent.width
          spacing: 6

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            kind: "ram"
            glyph: "#e8a33d"
          }

          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 22 - pctRam.implicitWidth - 12
            height: 1
          }

          Text {
            id: pctRam
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.ramPct) + "%"
            color: "#f2f2f2"
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        Text {
          text: "RAM"
          color: "#b9b9b9"
          font.pixelSize: SettingsState.px(11)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        Text {
          text: SysStats.ready ? SysStats.ramText : "--"
          color: "#8f8f8f"
          font.pixelSize: SettingsState.px(10)
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          width: parent.width
          height: 3
          radius: 2
          color: "#3a3f3a"

          Rectangle {
            width: parent.width * Math.min(1, SysStats.ramPct / 100)
            height: parent.height
            radius: parent.radius
            color: "#e8a33d"
          }
        }
      }

      // Swap cell
      Column {
        width: (parent.width - 14) / 2
        spacing: 1

        Row {
          width: parent.width
          spacing: 6

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            kind: "swap"
            glyph: "#7fb5e8"
          }

          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 22 - pctSwap.implicitWidth - 12
            height: 1
          }

          Text {
            id: pctSwap
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.swapPct) + "%"
            color: "#f2f2f2"
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        Text {
          text: "Swap"
          color: "#b9b9b9"
          font.pixelSize: SettingsState.px(11)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        Text {
          text: SysStats.ready ? SysStats.swapText : "--"
          color: "#8f8f8f"
          font.pixelSize: SettingsState.px(10)
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          width: parent.width
          height: 3
          radius: 2
          color: "#3a3f3a"

          Rectangle {
            width: parent.width * Math.min(1, SysStats.swapPct / 100)
            height: parent.height
            radius: parent.radius
            color: "#7fb5e8"
          }
        }
      }

      // CPU cell
      Column {
        width: (parent.width - 14) / 2
        spacing: 1

        Row {
          width: parent.width
          spacing: 6

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            kind: "cpu"
            glyph: "#e86a65"
          }

          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 22 - pctCpu.implicitWidth - 12
            height: 1
          }

          Text {
            id: pctCpu
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.cpuPct) + "%"
            color: "#f2f2f2"
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        Text {
          text: "CPU"
          color: "#b9b9b9"
          font.pixelSize: SettingsState.px(11)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        Text {
          text: SysStats.tempText
          color: "#8f8f8f"
          font.pixelSize: SettingsState.px(10)
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          width: parent.width
          height: 3
          radius: 2
          color: "#3a3f3a"

          Rectangle {
            width: parent.width * Math.min(1, SysStats.cpuPct / 100)
            height: parent.height
            radius: parent.radius
            color: "#e86a65"
          }
        }
      }

      // Disk cell
      Column {
        width: (parent.width - 14) / 2
        spacing: 1

        Row {
          width: parent.width
          spacing: 6

          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            kind: "disk"
            glyph: "#7ee2a8"
          }

          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 22 - pctDisk.implicitWidth - 12
            height: 1
          }

          Text {
            id: pctDisk
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.diskPct) + "%"
            color: "#f2f2f2"
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        Text {
          text: "Disk"
          color: "#b9b9b9"
          font.pixelSize: SettingsState.px(11)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        Text {
          text: SysStats.ready ? SysStats.diskText : "--"
          color: "#8f8f8f"
          font.pixelSize: SettingsState.px(10)
          font.family: SettingsState.fontFamily
        }

        Rectangle {
          width: parent.width
          height: 3
          radius: 2
          color: "#3a3f3a"

          Rectangle {
            width: parent.width * Math.min(1, SysStats.diskPct / 100)
            height: parent.height
            radius: parent.radius
            color: "#7ee2a8"
          }
        }
      }
    }
  }


  Connections {
    target: playerMouse
    function onContainsMouseChanged() {
      if (!playerMouse.containsMouse)
        root.showStats = false;
    }
  }

  MouseArea {
    id: playerMouse
    anchors.fill: parent
    hoverEnabled: true
    // Track hover only — never eat clicks, so the inner
    // controls (buttons, progress bar) receive them.
    acceptedButtons: Qt.NoButton
    cursorShape: Qt.PointingHandCursor
  }
}
