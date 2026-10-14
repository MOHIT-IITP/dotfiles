import QtQuick
import "../services"

// Screenshot / capture view. Extracted from NetworkCircle.qml.
Item {
  id: screenshotPage
  required property var circle
  required property bool hovered
  visible: opacity > 0
  opacity: (hovered && circle.activePage === "screenshot") ? 1 : 0

  Behavior on opacity {
    enabled: circle.opacity > 0.5
    NumberAnimation { duration: 180 }
  }

  Column {
    id: screenshotCol
    anchors.fill: parent
    spacing: 10

    // 1. Header: Back + "Capture" + Still / Record tabs - minimal
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Back button
        Rectangle {
          width: 24
          height: 24
          radius: 12
          color: shotBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "\ueab5"
            font.family: SettingsState.nerdIconFont
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(18)
          }

          MouseArea {
            id: shotBackMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              circle.activePage = "main";
            }
          }
        }

        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: shotTitleText.implicitWidth + 4
          height: 28

          Text {
            id: shotTitleText
            anchors.verticalCenter: parent.verticalCenter
            text: "CAPTURE"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            font.letterSpacing: 2
            font.weight: Font.DemiBold
          }

          MouseArea {
            id: shotTitleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              circle.activePage = "main";
            }
          }
        }
      }

      // Right side: Still (pill) / Record (plain)
      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Still Tab (Active pill)
        Rectangle {
          height: 24
          width: stillTextRow.implicitWidth + 16
          radius: 12
          color: SettingsState.bgCardHover

          Row {
            id: stillTextRow
            anchors.centerIn: parent
            spacing: 5

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              height: 12
              kind: "camera"
              glyph: SettingsState.textMain
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Still"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
            }
          }
        }

        // Record (plain text, switches to recorder subview)
        Item {
          anchors.verticalCenter: parent.verticalCenter
          height: 24
          width: recTabRow.implicitWidth + 4
          implicitWidth: recTabRow.implicitWidth + 4
          implicitHeight: 24

          Row {
            id: recTabRow
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 6
              height: 6
              radius: 3
              color: recTabMouse.containsMouse ? "#ff5252" : SettingsState.textMuted
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Record"
              color: recTabMouse.containsMouse ? SettingsState.textMain : SettingsState.textMuted
              font.pixelSize: SettingsState.px(13)
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: recTabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              circle.activePage = "recorder";
              RecorderState.refreshRecent();
            }
          }
        }
      }
    }

    // 2. Middle Section: Mode List (Left) + Preview Box (Right) - minimal
    Row {
      width: parent.width
      height: 134
      spacing: 8

      // Left Column: 3 minimal rows (Display, Window, Area) - tint-only select
      Column {
        width: 115
        height: parent.height
        spacing: 4

        // Mode 1: Display
        Rectangle {
          width: parent.width
          height: 42
          radius: 10
          color: dispMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "display"
              glyph: (ScreenshotState.mode === "display") ? SettingsState.textActive : (dispMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Display"
              color: (ScreenshotState.mode === "display") ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: dispMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ScreenshotState.mode = "display"
          }
        }

        // Mode 2: Window
        Rectangle {
          width: parent.width
          height: 42
          radius: 10
          color: winMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "window"
              glyph: (ScreenshotState.mode === "window") ? SettingsState.textActive : (winMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Window"
              color: (ScreenshotState.mode === "window") ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: winMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ScreenshotState.mode = "window"
          }
        }

        // Mode 3: Area
        Rectangle {
          width: parent.width
          height: 42
          radius: 10
          color: areaMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: "area"
              glyph: (ScreenshotState.mode === "area") ? SettingsState.textActive : (areaMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Area"
              color: (ScreenshotState.mode === "area") ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: areaMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ScreenshotState.mode = "area"
          }
        }
      }

      // Right Column: Preview Box
      Rectangle {
        width: parent.width - 115 - 8
        height: parent.height
        radius: 10
        color: SettingsState.bgSurface

        Column {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 6

          // Traffic lights
          Row {
            spacing: 6

            Rectangle { width: 10; height: 10; radius: 5; color: "#ff5f56" }
            Rectangle { width: 10; height: 10; radius: 5; color: "#ffbd2e" }
            Rectangle { width: 10; height: 10; radius: 5; color: "#27c93f" }
          }

          // Graphic Illustration Box - overlapping windows line art
          Item {
            width: parent.width
            height: 70

            // Display: overlapping windows sketch
            Item {
              anchors.fill: parent
              visible: ScreenshotState.mode === "display"

              Rectangle {
                x: (parent.width - 96) / 2 + 14
                y: 8
                width: 62
                height: 42
                radius: 3
                color: "transparent"
                border.color: SettingsState.textMuted
                border.width: 1
                opacity: 0.35
              }
              Rectangle {
                x: (parent.width - 96) / 2 + 4
                y: 14
                width: 62
                height: 42
                radius: 3
                color: "transparent"
                border.color: SettingsState.textMuted
                border.width: 1
                opacity: 0.45
              }
              Rectangle {
                x: (parent.width - 96) / 2 - 6
                y: 4
                width: 62
                height: 42
                radius: 3
                color: SettingsState.bgSurface
                border.color: SettingsState.textMuted
                border.width: 1
                opacity: 0.8

                Rectangle {
                  anchors.top: parent.top
                  anchors.left: parent.left
                  anchors.right: parent.right
                  height: 9
                  radius: 3
                  color: "transparent"
                  border.color: SettingsState.textMuted
                  border.width: 1
                  opacity: 0.8
                }
              }
            }

            // Window: single window outline
            Item {
              anchors.fill: parent
              visible: ScreenshotState.mode === "window"

              Rectangle {
                anchors.centerIn: parent
                width: 84
                height: 52
                radius: 3
                color: "transparent"
                border.color: SettingsState.textMuted
                border.width: 1
                opacity: 0.6

                Rectangle {
                  anchors.top: parent.top
                  anchors.left: parent.left
                  anchors.right: parent.right
                  height: 11
                  radius: 3
                  color: "transparent"
                  border.color: SettingsState.textMuted
                  border.width: 1
                  opacity: 0.8
                }
              }
            }

            // Area: crop corners
            Item {
              anchors.fill: parent
              visible: ScreenshotState.mode === "area"

              Rectangle {
                anchors.centerIn: parent
                width: 84
                height: 52
                radius: 3
                color: "transparent"
                border.color: SettingsState.textMuted
                border.width: 1
                opacity: 0.6
              }
              Text {
                anchors.centerIn: parent
                text: "+"
                color: SettingsState.textMuted
                font.pixelSize: SettingsState.px(16)
                font.family: SettingsState.fontFamily
                opacity: 0.6
              }
            }
          }

          // Bottom Target Hint
          Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: ScreenshotState.mode === "display" ? "Capture entire display" : (ScreenshotState.mode === "window" ? "Pick an open window" : "Drag a region to crop")
            color: SettingsState.textMuted
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }
      }
    }

    // 3. Bottom row: Capture pill centered + sparkle right
    Item {
      width: parent.width
      height: 28

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 100
        height: 28
        radius: 14
        color: captureMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard

        Text {
          anchors.centerIn: parent
          text: ScreenshotState.capturing ? "Working…" : "Capture"
          color: captureMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: captureMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: !ScreenshotState.capturing
          onClicked: {
            circle.activePage = "main";
            ScreenshotState.capture(ScreenshotState.mode);
          }
        }
      }
    }
  }
}
