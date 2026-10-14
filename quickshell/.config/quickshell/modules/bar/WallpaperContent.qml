import QtQuick
import QtQuick.Effects
import "../services"

// Embedded Wallpaper Selector subview directly inside ClockPill.
// Provides coverflow wallpaper preview, filtering, keyboard navigation, and instant wallpaper setting.
Item {
  id: root

  readonly property var list: WallpaperState.filteredWallpapers
  readonly property int count: list ? list.length : 0

  // ---- Filmstrip animation state (ported from quickshell_bar surfaces/Wallpaper.qml) ----
  // Continuous view position chasing WallpaperState.currentIndex. Rendered from
  // this single value so any input rate (key autorepeat, wheel bursts) stays
  // coherent: lag is bounded by the chase time constant, not piled up across
  // per-tile retargeting animations.
  property real pos: 0
  property bool hintShown: false

  readonly property var slotW: [224, 144, 114, 92, 74]
  readonly property var slotH: [126, 81, 64, 52, 42]
  readonly property var slotCX: [0, 156, 248, 322, 388]
  readonly property var slotBright: [1, 0.56, 0.42, 0.30, 0.22]
  readonly property var slotSat: [1, 0.65, 0.55, 0.45, 0.40]

  function slotLerp(arr, ao) {
    if (ao >= 4) return arr[4];
    var i = Math.floor(ao);
    var f = ao - i;
    return arr[i] + (arr[i + 1] - arr[i]) * f;
  }

  function offsetX(off) {
    var ao = Math.abs(off);
    var cx = ao <= 4 ? slotLerp(slotCX, ao) : slotCX[4] + (ao - 4) * 66;
    return off < 0 ? -cx : cx;
  }

  function snapPos() {
    pos = WallpaperState.currentIndex;
  }

  onCountChanged: {
    if (WallpaperState.currentIndex >= count)
      WallpaperState.selectIndex(Math.max(0, count - 1));
    // Clamp without gliding when the list itself changes (filter swap).
    if (pos >= count || pos < 0) snapPos();
  }

  Connections {
    target: WallpaperState
    function onCurrentIndexChanged() {
      // Wrap-around (last -> first) snaps; otherwise the FrameAnimation glides.
      var target = WallpaperState.currentIndex;
      if (Math.abs(target - root.pos) > Math.max(2, root.count / 2))
        root.pos = target;
      root.hintShown = false;
      hintDwell.restart();
    }
  }

  Timer {
    id: hintDwell
    interval: 600
    onTriggered: root.hintShown = true
  }

  FrameAnimation {
    running: root.pos !== WallpaperState.currentIndex
    onTriggered: {
      var k = 1 - Math.exp(-frameTime / 0.14);
      var next = root.pos + (WallpaperState.currentIndex - root.pos) * k;
      root.pos = Math.abs(next - WallpaperState.currentIndex) < 0.005 ? WallpaperState.currentIndex : next;
    }
  }

  Component.onCompleted: snapPos()

  property bool resizeOpen: false
  readonly property string resizeLabel: {
    var m = SettingsState.wallpaperResizeMode;
    if (m === "fit") return "Fit";
    if (m === "stretch") return "Stretch";
    if (m === "no") return "Center";
    return "Fill";
  }

  implicitWidth: 650
  implicitHeight: 236

  function forceFocus() {
    viewArea.focus = true;
    viewArea.forceActiveFocus();
  }

  Connections {
    target: WallpaperState
    function onOpenChanged() {
      if (WallpaperState.open) {
        forceFocus();
        wallFocusRetryTimer.restart();
        WallpaperState.refresh();
        snapPos();
        hintShown = false;
        hintDwell.restart();
      }
    }
  }

  Timer {
    id: wallFocusRetryTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (viewArea.activeFocus || count > 8) {
        running = false;
      }
    }
  }

  // Keyboard navigation & mouse wheel
  Item {
    id: viewArea
    anchors.fill: parent
    focus: true

    Keys.onLeftPressed: function (ev) {
      WallpaperState.prev();
      ev.accepted = true;
    }
    Keys.onRightPressed: function (ev) {
      WallpaperState.next();
      ev.accepted = true;
    }
    Keys.onReturnPressed: function (ev) {
      WallpaperState.applyCurrent();
      WallpaperState.close();
      ev.accepted = true;
    }
    Keys.onEnterPressed: function (ev) {
      WallpaperState.applyCurrent();
      WallpaperState.close();
      ev.accepted = true;
    }
    Keys.onEscapePressed: function (ev) {
      if (root.resizeOpen) {
        root.resizeOpen = false;
      } else {
        WallpaperState.close();
      }
      ev.accepted = true;
    }

    // Kanji watermark '壁' (Wall) on the left
    Text {
      anchors.left: parent.left
      anchors.leftMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 12
      text: "壁"
      color: SettingsState.isDark ? "#f2f2f2" : "#111111"
      opacity: 0.05
      font.pixelSize: SettingsState.px(56)
      font.bold: true
      font.family: "serif"
    }

    // ---- Top Header Bar ----
    Item {
      id: header
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 12
      anchors.bottomMargin: 0
      height: 28

      // Directory path text
      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: WallpaperState.dirPath
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(13)
        font.family: SettingsState.fontFamily
      }

      // Filter tabs pill + refresh button
      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // Resize mode dropdown pill (Fill / Fit / Stretch / Center)
        Rectangle {
          id: resizePill
          height: 28
          width: resizeRow.implicitWidth + 12
          radius: 14
          color: root.resizeOpen ? SettingsState.bgActivePill : SettingsState.bgCard
          border.color: root.resizeOpen ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Row {
            id: resizeRow
            anchors.centerIn: parent
            spacing: 6

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.resizeLabel
              color: root.resizeOpen ? SettingsState.textActive : SettingsState.textSecondary
              font.pixelSize: SettingsState.px(12)
              font.bold: root.resizeOpen
              font.family: SettingsState.fontFamily
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.resizeOpen ? "\ueab7" : "\ueab4"
              color: SettingsState.textMuted
              font.family: SettingsState.nerdIconFont
              font.pixelSize: SettingsState.px(9)
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.resizeOpen = !root.resizeOpen
          }
        }

        // Filter pill
        Rectangle {
          height: 28
          width: filterRow.implicitWidth + 8
          radius: 14
          color: SettingsState.bgCard
          border.color: SettingsState.borderBase
          border.width: 1

          Row {
            id: filterRow
            anchors.centerIn: parent
            spacing: 2

            Repeater {
              model: ["all", "still", "live"]
              delegate: Rectangle {
                width: ftext.implicitWidth + 16
                height: 22
                radius: 11
                color: WallpaperState.filter === modelData ? SettingsState.accent : "transparent"

                Behavior on color {
                  ColorAnimation { duration: 150 }
                }

                Text {
                  id: ftext
                  anchors.centerIn: parent
                  text: modelData
                  color: WallpaperState.filter === modelData ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
                  font.pixelSize: SettingsState.px(12)
                  font.bold: WallpaperState.filter === modelData
                  font.family: SettingsState.fontFamily
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: WallpaperState.setFilter(modelData)
                }
              }
            }
          }
        }

        // Refresh icon button
        Rectangle {
          width: 26
          height: 26
          radius: 13
          color: refMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          Text {
            anchors.centerIn: parent
            text: "\ueb37"
              font.family: SettingsState.nerdIconFont
            color: SettingsState.textSecondary
            font.pixelSize: SettingsState.px(16)
          }

          MouseArea {
            id: refMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: WallpaperState.refresh()
          }
        }

        // Close button
        Rectangle {
          width: 26
          height: 26
          radius: 13
          color: closeMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          Text {
            anchors.centerIn: parent
            text: "\uea76"
              font.family: SettingsState.nerdIconFont
            color: SettingsState.textSecondary
            font.pixelSize: SettingsState.px(12)
          }

          MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: WallpaperState.close()
          }
        }
      }
    }

    // Resize mode dropdown menu (overlays carousel)
    Rectangle {
      id: resizeMenu
      visible: root.resizeOpen
      anchors.top: header.bottom
      anchors.right: parent.right
      anchors.rightMargin: 12
      anchors.topMargin: 2
      width: 130
      height: resizeCol.implicitHeight + 10
      radius: 12
      color: SettingsState.bgCard
      border.color: SettingsState.borderBase
      border.width: 1
      z: 300

      Column {
        id: resizeCol
        anchors.centerIn: parent
        spacing: 2

        Repeater {
          model: [
            { label: "Fill", value: "crop", desc: "crop to fill" },
            { label: "Fit", value: "fit", desc: "fit inside" },
            { label: "Stretch", value: "stretch", desc: "stretch" },
            { label: "Center", value: "no", desc: "center, no resize" }
          ]

          delegate: Rectangle {
            width: 118
            height: 28
            radius: 8
            color: SettingsState.wallpaperResizeMode === modelData.value ? SettingsState.accent : (optMouse.containsMouse ? SettingsState.bgCardHover : "transparent")

            Row {
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: SettingsState.wallpaperResizeMode === modelData.value ? "●" : "○"
                color: SettingsState.wallpaperResizeMode === modelData.value ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textMuted
                font.pixelSize: SettingsState.px(8)
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                color: SettingsState.wallpaperResizeMode === modelData.value ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textMain
                font.pixelSize: SettingsState.px(12)
                font.bold: SettingsState.wallpaperResizeMode === modelData.value
                font.family: SettingsState.fontFamily
              }
            }

            MouseArea {
              id: optMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                SettingsState.setWallpaperResizeMode(modelData.value);
                root.resizeOpen = false;
              }
            }
          }
        }
      }
    }

    // ---- Center Wallpaper Carousel ----
    Item {
      id: carouselArea
      anchors.top: header.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: bottomBar.top
      anchors.topMargin: 2
      anchors.bottomMargin: 2

      // Empty state
      Text {
        anchors.centerIn: parent
        visible: root.count === 0
        text: "No wallpapers found in " + WallpaperState.dirPath
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(13)
        font.family: SettingsState.fontFamily
      }

      // Left navigation button
      Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        radius: 15
        color: lMouse.containsMouse && WallpaperState.currentIndex > 0 ? SettingsState.bgCardHover : SettingsState.bgSurface
        border.color: SettingsState.borderBase
        border.width: 1
        z: 200
        visible: root.count > 1
        opacity: WallpaperState.currentIndex > 0 ? 1.0 : 0.3
        enabled: WallpaperState.currentIndex > 0

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
          font.family: SettingsState.nerdIconFont
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(18)
        }

        MouseArea {
          id: lMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: WallpaperState.currentIndex > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: WallpaperState.prev()
        }
      }

      // Right navigation button
      Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        radius: 15
        color: rMouse.containsMouse && WallpaperState.currentIndex < root.count - 1 ? SettingsState.bgCardHover : SettingsState.bgSurface
        border.color: SettingsState.borderBase
        border.width: 1
        z: 200
        visible: root.count > 1
        opacity: WallpaperState.currentIndex < root.count - 1 ? 1.0 : 0.3
        enabled: WallpaperState.currentIndex < root.count - 1

        Text {
          anchors.centerIn: parent
          text: "\ueab6"
          font.family: SettingsState.nerdIconFont
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(18)
        }

        MouseArea {
          id: rMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: WallpaperState.currentIndex < root.count - 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: WallpaperState.next()
        }
      }

      // Filmstrip (ported from quickshell_bar): tiles positioned from the single
      // continuous `pos` value, focused thumb large + fully lit, neighbours
      // shrink / dim / desaturate as they slide under it.
      clip: true

      Repeater {
        id: strip
        model: root.list
        visible: root.count > 0

        delegate: Item {
          id: cardItem
          required property int index
          required property var modelData

          readonly property real off: index - root.pos
          readonly property real ao: Math.abs(off)
          readonly property bool isCur: index === WallpaperState.currentIndex
          readonly property bool isApplying: WallpaperState.isApplying && WallpaperState.lastApplied === modelData.path
          readonly property real bright: root.slotLerp(root.slotBright, ao)
          readonly property real sat: root.slotLerp(root.slotSat, ao)
          readonly property real cardRadius: Math.round(15 + 3 * Math.max(0, 1 - ao))
          readonly property real edgeFade: {
            var soft = 70;
            var gap = Math.min(x, carouselArea.width - (x + width));
            return Math.max(0, Math.min(1, gap / soft));
          }

          width: root.slotLerp(root.slotW, ao)
          height: root.slotLerp(root.slotH, ao)
          x: carouselArea.width / 2 + root.offsetX(off) - width / 2
          y: (carouselArea.height - height) / 2
          z: 10 - ao
          visible: ao <= 5
          opacity: edgeFade * (ao <= 4 ? 1 : Math.max(0, 5 - ao))

          // Mask source item for rounded thumbnail
          Rectangle {
            id: maskShape
            anchors.fill: parent
            radius: cardItem.cardRadius
            color: "#ffffff"
            visible: false
            layer.enabled: true
            layer.smooth: true
          }

          // Focused card shadow underlay
          Rectangle {
            anchors.fill: parent
            radius: cardItem.cardRadius
            color: SettingsState.bgCard
            visible: cardItem.isCur
            z: 0
            layer.enabled: true
            layer.smooth: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: SettingsState.shadowColor
              shadowBlur: 0.6
              shadowVerticalOffset: 3
            }
          }

          // Clipped wallpaper thumbnail container
          Item {
            id: imgWrapper
            anchors.fill: parent
            z: 1

            layer.enabled: true
            layer.smooth: true
            layer.effect: MultiEffect {
              maskEnabled: true
              maskSource: maskShape
              maskThresholdMin: 0.5
              maskSpreadAtMin: 1.0
              saturation: cardItem.sat - 1
            }

            Image {
              id: cardImg
              anchors.fill: parent
              source: modelData && modelData.path ? ("file://" + modelData.path) : ""
              fillMode: Image.PreserveAspectCrop
              smooth: true
              asynchronous: true
              cache: false
              sourceSize.width: 480
              sourceSize.height: 270
            }

            // Depth dim: neighbours sink into shadow as they slide under focus.
            Rectangle {
              anchors.fill: parent
              radius: cardItem.cardRadius
              color: "#000000"
              opacity: 1 - cardItem.bright
            }

            // Live badge
            Rectangle {
              anchors.top: parent.top
              anchors.left: parent.left
              anchors.margins: 4
              visible: modelData && modelData.isLive
              width: liveText.implicitWidth + 9
              height: liveText.implicitHeight + 4
              radius: height / 2
              color: "#8c000000"

              Text {
                id: liveText
                anchors.centerIn: parent
                text: "▶"
                color: "#f2f2f2"
                font.pixelSize: SettingsState.px(8)
              }
            }
          }

          // Crisp rounded border frame over the art
          Rectangle {
            anchors.fill: parent
            radius: cardItem.cardRadius
            color: "transparent"
            border.color: {
              var c = Qt.color(cardItem.isCur ? (cardItem.isApplying ? "#f2c14e" : SettingsState.accent) : SettingsState.borderBase);
              return Qt.rgba(c.r, c.g, c.b, cardItem.isCur ? 1 : 0.6);
            }
            border.width: cardItem.isCur ? 2 : 1
            z: 2

            Behavior on border.color {
              ColorAnimation { duration: 150 }
            }
          }

          // Center pill resolution badge on active card
          Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 4
            height: 18
            width: resText.implicitWidth + 10
            radius: 9
            color: SettingsState.isDark ? "#cc0c0e0c" : "#eeffffff"
            visible: isCur
            border.color: isApplying ? "#f2c14e" : SettingsState.borderBase
            border.width: 1

            Text {
              id: resText
              anchors.centerIn: parent
              text: isApplying ? "Applying..." : (modelData && modelData.isLive ? "LIVE · Click to Set" : "Click to Set")
              color: isApplying ? "#f2c14e" : SettingsState.textMain
              font.pixelSize: SettingsState.px(10)
              font.family: SettingsState.fontFamily
            }
          }

          // Thumbnail Click Handler
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (isCur) {
                WallpaperState.applyWallpaper(modelData.path);
                WallpaperState.close();
              } else {
                WallpaperState.selectIndex(index);
              }
            }
          }
        }
      }

      // Wheel handler with notch accumulation so fast scrolls glide coherently
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        z: 20
        property real acc: 0
        onWheel: function (wheel) {
          acc += wheel.angleDelta.y / 120;
          var notches = Math.trunc(acc);
          if (notches !== 0) {
            for (var i = 0; i < Math.abs(notches); i++) {
              if (notches > 0) WallpaperState.prev();
              else WallpaperState.next();
            }
            acc -= notches;
            if ((WallpaperState.currentIndex === 0 && acc > 0) ||
                (WallpaperState.currentIndex >= root.count - 1 && acc < 0)) {
              acc = 0;
            }
          }
          wheel.accepted = true;
        }
      }
    }

    // ---- Bottom Shortcuts Bar ----
    // Gesture hint: hidden while focus moves, revealed after a 600ms dwell.
    Row {
      id: bottomBar
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 6
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 6
      visible: root.count > 0
      opacity: root.hintShown ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }

      Rectangle {
        height: 16
        width: tapLabel.implicitWidth + 8
        radius: 4
        color: SettingsState.bgSurface
        anchors.verticalCenter: parent.verticalCenter
        Text {
          id: tapLabel
          anchors.centerIn: parent
          text: "tap"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(10)
          font.family: SettingsState.fontFamily
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "set"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }

      Item {
        width: 8
        height: 1
      }

      Rectangle {
        height: 16
        width: holdLabel.implicitWidth + 8
        radius: 4
        color: SettingsState.bgSurface
        anchors.verticalCenter: parent.verticalCenter
        Text {
          id: holdLabel
          anchors.centerIn: parent
          text: "hold"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(10)
          font.family: SettingsState.fontFamily
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "delete"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }
    }
  }
}
