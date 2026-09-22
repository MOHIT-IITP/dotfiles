import Quickshell
import QtQuick
import QtQuick.Effects
import "../services"

// Embedded Wallpaper Selector subview directly inside ClockPill.
// Provides coverflow wallpaper preview, filtering, keyboard navigation, and instant wallpaper setting.
Item {
  id: root

  readonly property var list: WallpaperState.filteredWallpapers
  readonly property int count: list ? list.length : 0

  property bool resizeOpen: false
  readonly property string resizeLabel: {
    var m = SettingsState.wallpaperResizeMode;
    if (m === "fit") return "Fit";
    if (m === "stretch") return "Stretch";
    if (m === "no") return "Center";
    return "Fill";
  }

  implicitWidth: 720
  implicitHeight: 260

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
      anchors.leftMargin: 20
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 12
      text: "壁"
      color: SettingsState.isDark ? "#f2f2f2" : "#111111"
      opacity: 0.05
      font.pixelSize: 64
      font.bold: true
      font.family: "serif"
    }

    // ---- Top Header Bar ----
    Item {
      id: header
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 18
      anchors.bottomMargin: 0
      height: 28

      // Directory path text
      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: WallpaperState.dirPath
        color: SettingsState.textMuted
        font.pixelSize: 13
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
              font.pixelSize: 12
              font.bold: root.resizeOpen
              font.family: SettingsState.fontFamily
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.resizeOpen ? "▲" : "▼"
              color: SettingsState.textMuted
              font.pixelSize: 9
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
                  font.pixelSize: 12
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
            text: "↻"
            color: SettingsState.textSecondary
            font.pixelSize: 16
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
            text: "✕"
            color: SettingsState.textSecondary
            font.pixelSize: 12
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
      anchors.rightMargin: 18
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
                font.pixelSize: 8
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                color: SettingsState.wallpaperResizeMode === modelData.value ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textMain
                font.pixelSize: 12
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
      anchors.topMargin: 4
      anchors.bottomMargin: 4

      // Empty state
      Text {
        anchors.centerIn: parent
        visible: root.count === 0
        text: "No wallpapers found in " + WallpaperState.dirPath
        color: SettingsState.textMuted
        font.pixelSize: 13
        font.family: SettingsState.fontFamily
      }

      // Left navigation button
      Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        radius: 16
        color: lMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface
        border.color: SettingsState.borderBase
        border.width: 1
        z: 200
        visible: root.count > 1

        Text {
          anchors.centerIn: parent
          text: "‹"
          color: SettingsState.textMain
          font.pixelSize: 18
        }

        MouseArea {
          id: lMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: WallpaperState.prev()
        }
      }

      // Right navigation button
      Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        radius: 16
        color: rMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgSurface
        border.color: SettingsState.borderBase
        border.width: 1
        z: 200
        visible: root.count > 1

        Text {
          anchors.centerIn: parent
          text: "›"
          color: SettingsState.textMain
          font.pixelSize: 18
        }

        MouseArea {
          id: rMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: WallpaperState.next()
        }
      }

      // Horizontal Coverflow PathView
      PathView {
        id: coverflow
        anchors.fill: parent
        visible: root.count > 0
        model: root.list
        currentIndex: WallpaperState.currentIndex
        highlightMoveDuration: 280
        onCurrentIndexChanged: {
          if (currentIndex !== WallpaperState.currentIndex) {
            WallpaperState.selectIndex(currentIndex);
          }
        }
        pathItemCount: Math.min(5, Math.max(1, root.count))
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange

        path: Path {
          startX: 80
          startY: carouselArea.height / 2
          PathAttribute { name: "itemZ"; value: 10 }
          PathAttribute { name: "itemScale"; value: 0.72 }
          PathAttribute { name: "itemOpacity"; value: 0.60 }

          PathLine {
            x: carouselArea.width * 0.28
            y: carouselArea.height / 2
          }
          PathAttribute { name: "itemZ"; value: 50 }
          PathAttribute { name: "itemScale"; value: 0.86 }
          PathAttribute { name: "itemOpacity"; value: 0.85 }

          PathLine {
            x: carouselArea.width / 2
            y: carouselArea.height / 2
          }
          PathAttribute { name: "itemZ"; value: 100 }
          PathAttribute { name: "itemScale"; value: 1.0 }
          PathAttribute { name: "itemOpacity"; value: 1.0 }

          PathLine {
            x: carouselArea.width * 0.72
            y: carouselArea.height / 2
          }
          PathAttribute { name: "itemZ"; value: 50 }
          PathAttribute { name: "itemScale"; value: 0.86 }
          PathAttribute { name: "itemOpacity"; value: 0.85 }

          PathLine {
            x: carouselArea.width - 80
            y: carouselArea.height / 2
          }
          PathAttribute { name: "itemZ"; value: 10 }
          PathAttribute { name: "itemScale"; value: 0.72 }
          PathAttribute { name: "itemOpacity"; value: 0.60 }
        }

        delegate: Item {
          id: cardItem
          width: 224
          height: 138
          z: Math.round(PathView.itemZ || (isCur ? 100 : 10))
          scale: PathView.itemScale || (isCur ? 1.0 : 0.85)
          opacity: PathView.itemOpacity || (isCur ? 1.0 : 0.7)

          readonly property bool isCur: PathView.isCurrentItem
          readonly property bool isApplying: WallpaperState.isApplying && WallpaperState.lastApplied === modelData.path
          readonly property real cardRadius: isCur ? 16 : 14

          // Clipped wallpaper image item
          Item {
            id: imgWrapper
            anchors.fill: parent

            layer.enabled: true
            layer.effect: MultiEffect {
              maskEnabled: true
              maskSource: maskShape
              maskThresholdMin: 0.5
              maskSpreadAtMin: 1.0
            }

            Rectangle {
              id: maskShape
              width: imgWrapper.width
              height: imgWrapper.height
              radius: cardItem.cardRadius
              visible: false
              layer.enabled: true

              Behavior on radius {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
              }
            }

            Image {
              id: cardImg
              anchors.fill: parent
              source: modelData && modelData.path ? ("file://" + modelData.path) : ""
              fillMode: Image.PreserveAspectCrop
              smooth: true
              asynchronous: true
              sourceSize.width: 450
              sourceSize.height: 280
            }

            // Dark vignette overlay on non-selected cards
            Rectangle {
              anchors.fill: parent
              color: "#000000"
              opacity: isCur ? 0 : 0.45

              Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
              }
            }
          }

          // Outer rounded border
          Rectangle {
            anchors.fill: parent
            radius: cardItem.cardRadius
            color: "transparent"
            border.color: isCur ? (isApplying ? "#f2c14e" : SettingsState.accent) : SettingsState.borderBase
            border.width: isCur ? 2 : 1
            opacity: isCur ? 1 : 0.6

            Behavior on radius {
              NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on border.color {
              ColorAnimation { duration: 180 }
            }
            Behavior on opacity {
              NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
            }
          }

          // Center pill resolution badge on active card
          Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 8
            height: 20
            width: resText.implicitWidth + 14
            radius: 10
            color: SettingsState.isDark ? "#cc0c0e0c" : "#eeffffff"
            visible: isCur
            border.color: isApplying ? "#f2c14e" : SettingsState.borderBase
            border.width: 1

            Text {
              id: resText
              anchors.centerIn: parent
              text: isApplying ? "Applying..." : (cardImg.implicitWidth > 0 ? (cardImg.implicitWidth + "×" + cardImg.implicitHeight) : "Click to Set")
              color: isApplying ? "#f2c14e" : SettingsState.textMain
              font.pixelSize: 11
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

      // Wheel handler for horizontal scrolling
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function (wheel) {
          if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
            WallpaperState.next();
          } else if (wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0) {
            WallpaperState.prev();
          }
        }
      }
    }

    // ---- Bottom Shortcuts Bar ----
    Row {
      id: bottomBar
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 8
      visible: root.count > 0

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
          font.pixelSize: 10
          font.family: SettingsState.fontFamily
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "set"
        color: SettingsState.textMuted
        font.pixelSize: 11
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
          font.pixelSize: 10
          font.family: SettingsState.fontFamily
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "delete"
        color: SettingsState.textMuted
        font.pixelSize: 11
        font.family: SettingsState.fontFamily
      }
    }
  }
}
