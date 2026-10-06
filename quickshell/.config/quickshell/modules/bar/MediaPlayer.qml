import QtQuick
import QtQuick.Effects
import "../services"
import "../utils"
import "WavySliderPaint.js" as WavyPaint

// Left media player. Collapsed: art thumbnail circle.
// Hovered: compact player card (rounded art, metadata, progress, controls).
Rectangle {
  id: root
  // Public hover flag for the bar's auto-hide tracking: true while the
  // cursor is anywhere on the player, including the expanded card.
  readonly property bool hovered: playerMouse.containsMouse
  readonly property var player: MediaState.activePlayer
  readonly property bool hasPlayer: MediaState.hasPlayer
  readonly property bool hasTrack: MediaState.hasTrack
  readonly property bool isPlaying: MediaState.isPlaying
  // Right-swipe on the expanded card flips to system stats.
  // When nothing is playing, stats show automatically on hover.
  property bool showStats: false
  readonly property bool statsVisible: root.showStats || !root.hasTrack

  implicitWidth: playerMouse.containsMouse ? 328 : 34
  implicitHeight: playerMouse.containsMouse ? (root.statsVisible ? 206 : 148) : 34
  radius: playerMouse.containsMouse ? SettingsState.cardRadius : 17
  color: playerMouse.containsMouse ? "transparent" : SettingsState.bgSurface
  border.color: playerMouse.containsMouse ? "transparent" : SettingsState.barBorder
  border.width: playerMouse.containsMouse ? 0 : 1
  clip: true

  SquircleBackground {
    id: squircleBg
    visible: playerMouse.containsMouse
    radius: SettingsState.cardRadius
    power: SettingsState.cardRoundingPower
    fillColor: SettingsState.bgCard
    strokeColor: SettingsState.barBorder
    strokeWidth: 1
    z: -1
  }

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
      color: SettingsState.bgActivePill
    }

    // Artwork masked to a true circle (Item.clip is rectangular,
    // so a rounded Rectangle alone would leave the image square).
    Item {
      id: thumbClip
      anchors.fill: parent
      visible: root.hasTrack && (player?.trackArtUrl ?? "") !== ""

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
        source: (root.hasTrack && player?.trackArtUrl) ? player.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
      }
    }
    Text {
      anchors.centerIn: parent
      visible: !thumbClip.visible
      text: "\uec1b"
      font.family: SettingsState.nerdIconFont
      color: SettingsState.textSecondary
      font.pixelSize: SettingsState.px(11)
    }
  }

  // Swipe layer over the expanded card: right swipe -> stats, left swipe -> player.
  // Sits below the controls so buttons and progress bar keep their clicks.
  MouseArea {
    id: statsGesture
    anchors.fill: parent
    anchors.margins: 14
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
        // Keep stats when there is no player to go back to.
        if (root.hasTrack)
          root.showStats = false;
      }
    }

    onWheel: wheel => {
      if (wheel.angleDelta.x > 0 || wheel.pixelDelta.x > 0)
        root.showStats = true;
      else if (wheel.angleDelta.x < 0 || wheel.pixelDelta.x < 0) {
        if (root.hasTrack)
          root.showStats = false;
      }
    }
  }

  // ---- Expanded: compact player card ----
  Item {
    id: expandedView
    anchors.fill: parent
    anchors.margins: 14
    opacity: playerMouse.containsMouse ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: playerMouse.containsMouse ? 200 : 120
      }
    }

    Column {
      anchors.fill: parent
      spacing: 8
      visible: hasTrack && !root.statsVisible

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
            color: SettingsState.bgActivePill
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
            text: "\uec1b"
              font.family: SettingsState.nerdIconFont
            color: SettingsState.textSecondary
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
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
            maximumLineCount: 1
          }
          Text {
            width: parent.width
            text: player?.trackArtist || "Unknown Artist"
            color: SettingsState.textSecondary
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
              color: isPlaying ? "#7ee2a8" : SettingsState.textMuted
            }
          }
        }
      }

      // Progress: elapsed | bar | -remaining (click to seek)
      Row {
        width: parent.width
        height: 14
        spacing: 8

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 32
          text: player ? Format.fmtTime(player.position || 0) : "0:00"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }

        Item {
          id: progTrack
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 32 - 38 - 16
          height: 14

          readonly property real liveFraction: (player && player.length > 0) ? Math.min(1, Math.max(0, (player.position || 0) / player.length)) : 0
          property real currentPos: liveFraction
          readonly property real shown: currentPos

          onLiveFractionChanged: {
            if (!seekAnim.running && !trackMouse.pressed) {
              currentPos = liveFraction;
            }
          }

          onShownChanged: progCanvas.requestPaint()
          onCurrentPosChanged: progCanvas.requestPaint()
          onWidthChanged: progCanvas.requestPaint()

          NumberAnimation {
            id: seekAnim
            target: progTrack
            property: "currentPos"
            duration: 350
            easing.type: Easing.InOutCubic
            onRunningChanged: progCanvas.requestPaint()
            onFinished: {
              if (!trackMouse.pressed) {
                currentPos = progTrack.liveFraction;
                progCanvas.requestPaint();
              }
            }
          }

          Canvas {
            id: progCanvas
            anchors.fill: parent
            antialiasing: true
            renderStrategy: Canvas.Immediate
            onPaint: {
              WavyPaint.paint(getContext("2d"), width, height, {
                shown: progTrack.shown,
                showTrack: true,
                showHandle: false,
                showRemaining: false,
                waveColor: SettingsState.accent,
                trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3",
                handleColor: SettingsState.accent,
                trackH: 4,
                waveW: 3,
                waveAmp: 1.6,
                waveLen: 36,
                handleW: 5,
                handleH: 12
              });
            }
          }

          Connections {
            target: SettingsState
            function onAccentChanged() { progCanvas.requestPaint(); }
            function onIsDarkChanged() { progCanvas.requestPaint(); }
          }

          function applySeek(fraction) {
            if (player && player.canSeek && player.length > 0) {
              player.position = fraction * player.length;
              player.positionChanged();
            }
          }

          MouseArea {
            id: trackMouse
            anchors.fill: parent
            anchors.topMargin: -4
            anchors.bottomMargin: -4
            cursorShape: Qt.PointingHandCursor

            property real startX: 0
            property bool dragging: false

            onPressed: function (ev) {
              if (progTrack.width <= 0) return;
              trackMouse.startX = ev.x;
              trackMouse.dragging = false;

              var startVal = progTrack.currentPos;
              var r = Math.min(1, Math.max(0, ev.x / progTrack.width));

              // Smoothly animate from exact current position to clicked target
              seekAnim.stop();
              progTrack.currentPos = startVal;
              seekAnim.from = startVal;
              seekAnim.to = r;
              seekAnim.restart();

              progTrack.applySeek(r);
            }

            onPositionChanged: function (ev) {
              if (!pressed || progTrack.width <= 0) return;
              // Only treat as drag if cursor moved more than 4px (filters out click jitter)
              if (!trackMouse.dragging && Math.abs(ev.x - trackMouse.startX) > 4) {
                trackMouse.dragging = true;
                seekAnim.stop();
              }
              if (trackMouse.dragging) {
                var r = Math.min(1, Math.max(0, ev.x / progTrack.width));
                progTrack.currentPos = r;
                progCanvas.requestPaint();
                progTrack.applySeek(r);
              }
            }

            onReleased: function () {
              trackMouse.dragging = false;
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: 38
          horizontalAlignment: Text.AlignRight
          text: (player && player.length > 0) ? ("-" + Format.fmtTime(Math.max(0, (player.length || 0) - (player.position || 0)))) : "-0:00"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }
      }

      // Controls: prev / play-pause / next + source app
      Item {
        width: parent.width
        height: 42

        Row {
          anchors.centerIn: parent
          spacing: 10

          // Previous
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: 20
            color: prevArea.containsMouse ? SettingsState.bgCardHover : "transparent"
            opacity: player?.canGoPrevious ? 1 : 0.3
            Text {
              anchors.centerIn: parent
              visible: SettingsState.japaneseGlyphs
              text: "前"
              font.family: SettingsState.fontFamily
              font.bold: true
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(22)
            }
            Text {
              anchors.centerIn: parent
              visible: !SettingsState.japaneseGlyphs
              text: "󰼨"
              font.family: SettingsState.nerdIconFont
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(27)
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
            width: 42
            height: 42
            radius: 21
            color: playArea.containsMouse ? SettingsState.bgCardHover : "transparent"
            Text {
              anchors.centerIn: parent
              visible: SettingsState.japaneseGlyphs && !isPlaying
              text: "遊"
              font.family: SettingsState.fontFamily
              font.bold: true
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(24)
            }
            Text {
              anchors.centerIn: parent
              visible: SettingsState.japaneseGlyphs && isPlaying
              text: "時"
              font.family: SettingsState.fontFamily
              font.bold: true
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(24)
            }
            Canvas {
              id: playGlyph
              anchors.centerIn: parent
              width: 22
              height: 22
              visible: !SettingsState.japaneseGlyphs && !isPlaying
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = SettingsState.textMain;
                ctx.beginPath();
                ctx.moveTo(5, 2.5);
                ctx.lineTo(17, 11);
                ctx.lineTo(5, 19.5);
                ctx.closePath();
                ctx.fill();
              }
            }
            Canvas {
              id: pauseGlyph
              anchors.centerIn: parent
              width: 22
              height: 22
              visible: !SettingsState.japaneseGlyphs && isPlaying
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = SettingsState.textMain;
                ctx.fillRect(4.5, 3, 5, 16);
                ctx.fillRect(12.5, 3, 5, 16);
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
            Connections {
              target: SettingsState
              function onTextMainChanged() {
                playGlyph.requestPaint();
                pauseGlyph.requestPaint();
              }
            }
          }

          // Next
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: 20
            color: nextArea.containsMouse ? SettingsState.bgCardHover : "transparent"
            opacity: player?.canGoNext ? 1 : 0.3
            Text {
              anchors.centerIn: parent
              visible: SettingsState.japaneseGlyphs
              text: "次"
              font.family: SettingsState.fontFamily
              font.bold: true
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(22)
            }
            Text {
              anchors.centerIn: parent
              visible: !SettingsState.japaneseGlyphs
              text: "󰼧"
              font.family: SettingsState.nerdIconFont
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(27)
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
          color: SettingsState.textMuted
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
    anchors.fill: parent
    anchors.margins: 14
    anchors.bottomMargin: 14
    opacity: (playerMouse.containsMouse && root.statsVisible) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }

    Grid {
      anchors.fill: parent
      anchors.margins: 6
      columns: 2
      columnSpacing: 18
      rowSpacing: 14

      // 1. RAM cell
      Column {
        width: (parent.width - 18) / 2
        spacing: 3

        // Icon + % Row
        Row {
          width: parent.width
          Item {
            width: parent.width - pctRam.implicitWidth
            height: 20
            CCIcon {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "ram"
              glyph: SettingsState.accent
            }
          }

          Text {
            id: pctRam
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.ramPct) + "%"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(15)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        // Title
        Text {
          text: "RAM"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        // Value subtitle
        Text {
          text: SysStats.ready ? SysStats.ramText : "--"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }

        // Wavy stat slider
        WavyStatSlider {
          width: parent.width
          height: 18
          fraction: SysStats.ramPct / 100
          waveColor: SettingsState.accent
          showTrack: false
          showHandle: false
          showRemaining: true
        }
      }

      // 2. Swap cell
      Column {
        width: (parent.width - 18) / 2
        spacing: 3

        // Icon + % Row
        Row {
          width: parent.width
          Item {
            width: parent.width - pctSwap.implicitWidth
            height: 20
            CCIcon {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "swap"
              glyph: SettingsState.accent
            }
          }

          Text {
            id: pctSwap
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.swapPct) + "%"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(15)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        // Title
        Text {
          text: "Swap"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        // Value subtitle
        Text {
          text: SysStats.ready ? SysStats.swapText : "--"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }

        // Wavy stat slider
        WavyStatSlider {
          width: parent.width
          height: 18
          fraction: SysStats.swapPct / 100
          waveColor: SettingsState.accent
          showTrack: false
          showHandle: false
          showRemaining: true
        }
      }

      // 3. CPU cell
      Column {
        width: (parent.width - 18) / 2
        spacing: 3

        // Icon + % Row
        Row {
          width: parent.width
          Item {
            width: parent.width - pctCpu.implicitWidth
            height: 20
            CCIcon {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "cpu"
              glyph: SettingsState.accent
            }
          }

          Text {
            id: pctCpu
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.cpuPct) + "%"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(15)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        // Title
        Text {
          text: "CPU"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        // Value subtitle
        Text {
          text: SysStats.tempText
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }

        // Wavy stat slider
        WavyStatSlider {
          width: parent.width
          height: 18
          fraction: SysStats.cpuPct / 100
          waveColor: SettingsState.accent
          showTrack: false
          showHandle: false
          showRemaining: true
        }
      }

      // 4. Disk cell
      Column {
        width: (parent.width - 18) / 2
        spacing: 3

        // Icon + % Row
        Row {
          width: parent.width
          Item {
            width: parent.width - pctDisk.implicitWidth
            height: 20
            CCIcon {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "disk"
              glyph: SettingsState.accent
            }
          }

          Text {
            id: pctDisk
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SysStats.diskPct) + "%"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(15)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        // Title
        Text {
          text: "Disk"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        // Value subtitle
        Text {
          text: SysStats.ready ? SysStats.diskText : "--"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
        }

        // Wavy stat slider
        WavyStatSlider {
          width: parent.width
          height: 18
          fraction: SysStats.diskPct / 100
          waveColor: SettingsState.accent
          showTrack: false
          showHandle: false
          showRemaining: true
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
