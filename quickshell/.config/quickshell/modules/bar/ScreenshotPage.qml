import Quickshell
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
    NumberAnimation { duration: 180 }
  }

  Column {
    id: screenshotCol
    anchors.fill: parent
    spacing: 12

    // 1. Header: Back button + Title ("Capture" / "Screen capture") + Mode Tabs ("Still" / "Record")
    Item {
      width: parent.width
      height: 36

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Back button
        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: shotBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "\ueab5"
              font.family: SettingsState.nerdIconFont
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(22)
            font.bold: true
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

        Column {
          anchors.verticalCenter: parent.verticalCenter
          spacing: 1

          Text {
            text: "Capture"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(18)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          Text {
            text: "Screen capture"
            color: SettingsState.textMuted
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
          }
        }
      }

      // Right side: Still / Record Tabs
      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Still Tab (Active)
        Rectangle {
          height: 26
          width: stillTextRow.implicitWidth + 16
          radius: 13
          color: SettingsState.bgActivePill
          border.color: SettingsState.borderActive
          border.width: 1

          Row {
            id: stillTextRow
            anchors.centerIn: parent
            spacing: 5

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 12
              height: 12
              kind: "camera"
              glyph: SettingsState.textActive
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Still"
              color: SettingsState.textActive
              font.pixelSize: SettingsState.px(13)
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }
        }

        // Record Tab (Inactive, switches to recorder subview)
        Rectangle {
          height: 26
          width: recTabRow.implicitWidth + 16
          radius: 13
          color: recTabMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
          border.color: recTabMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Row {
            id: recTabRow
            anchors.centerIn: parent
            spacing: 5

            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 7
              height: 7
              radius: 3.5
              color: recTabMouse.containsMouse ? "#ff5252" : SettingsState.textSecondary
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Record"
              color: recTabMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
              font.pixelSize: SettingsState.px(13)
              font.bold: true
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

    // 2. Middle Section: Mode List (Left) + Target Preview Box (Right)
    Row {
      width: parent.width
      height: 136
      spacing: 12

      // Left Column: 3 Selection Cards (Display, Window, Area)
      Column {
        width: 115
        height: parent.height
        spacing: 6

        // Mode 1: Display
        Rectangle {
          width: parent.width
          height: 38
          radius: 12
          color: (ScreenshotState.mode === "display") ? SettingsState.bgActivePill : (dispMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
          border.color: (ScreenshotState.mode === "display") ? SettingsState.borderActive : (dispMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "display"
              glyph: (ScreenshotState.mode === "display") ? SettingsState.textActive : (dispMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Display"
              color: (ScreenshotState.mode === "display") ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.bold: ScreenshotState.mode === "display"
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: dispMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              ScreenshotState.mode = "display";
              circle.activePage = "main";
              ScreenshotState.capture("display");
            }
          }
        }

        // Mode 2: Window
        Rectangle {
          width: parent.width
          height: 38
          radius: 12
          color: (ScreenshotState.mode === "window") ? SettingsState.bgActivePill : (winMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
          border.color: (ScreenshotState.mode === "window") ? SettingsState.borderActive : (winMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "window"
              glyph: (ScreenshotState.mode === "window") ? SettingsState.textActive : (winMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Window"
              color: (ScreenshotState.mode === "window") ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.bold: ScreenshotState.mode === "window"
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: winMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              ScreenshotState.mode = "window";
              circle.activePage = "main";
              ScreenshotState.capture("window");
            }
          }
        }

        // Mode 3: Area
        Rectangle {
          width: parent.width
          height: 38
          radius: 12
          color: (ScreenshotState.mode === "area") ? SettingsState.bgActivePill : (areaMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
          border.color: (ScreenshotState.mode === "area") ? SettingsState.borderActive : (areaMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              kind: "area"
              glyph: (ScreenshotState.mode === "area") ? SettingsState.textActive : (areaMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Area"
              color: (ScreenshotState.mode === "area") ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.bold: ScreenshotState.mode === "area"
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: areaMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              ScreenshotState.mode = "area";
              circle.activePage = "main";
              ScreenshotState.capture("area");
            }
          }
        }
      }

      // Right Column: Target Graphic Preview Box
      Rectangle {
        width: parent.width - 115 - 12
        height: parent.height
        radius: 14
        color: SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: 1

        Column {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 8

          Text {
            text: ScreenshotState.mode === "display" ? "Display" : (ScreenshotState.mode === "window" ? "Window" : "Area")
            color: SettingsState.textActive
            font.pixelSize: SettingsState.px(14)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          // Graphic Illustration Box
          Rectangle {
            width: parent.width
            height: 64
            radius: 10
            color: SettingsState.isDark ? "#121612" : "#f0f4f0"
            border.color: SettingsState.borderActive
            border.width: 1

            // Window Mockup (when window mode)
            Item {
              anchors.fill: parent
              visible: ScreenshotState.mode === "window"

              Row {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 6
                spacing: 4

                Rectangle { width: 5; height: 5; radius: 2.5; color: "#ff5f56" }
                Rectangle { width: 5; height: 5; radius: 2.5; color: "#ffbd2e" }
                Rectangle { width: 5; height: 5; radius: 2.5; color: "#27c93f" }
              }

              Rectangle {
                anchors.centerIn: parent
                width: parent.width - 24
                height: parent.height - 20
                radius: 6
                color: "transparent"
                border.color: SettingsState.textSecondary
                border.width: 1
                opacity: 0.4
              }
            }

            // Display Mockup (when display mode)
            Item {
              anchors.fill: parent
              visible: ScreenshotState.mode === "display"

              CCIcon {
                anchors.centerIn: parent
                width: 32
                height: 32
                kind: "display"
                glyph: SettingsState.textActive
              }
            }

            // Area Mockup (when area mode)
            Item {
              anchors.fill: parent
              visible: ScreenshotState.mode === "area"

              CCIcon {
                anchors.centerIn: parent
                width: 32
                height: 32
                kind: "area"
                glyph: SettingsState.textActive
              }
            }
          }

          // Bottom Target Hint
          Text {
            text: ScreenshotState.mode === "display" ? "Capture entire screen" : (ScreenshotState.mode === "window" ? "Pick an open window" : "Drag a region to crop")
            color: SettingsState.textSecondary
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
          }
        }
      }
    }

    // 3. Bottom Path Footer
    Item {
      width: parent.width
      height: 20

      Row {
        anchors.fill: parent
        spacing: 8

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 14
          height: 14
          kind: "screenshot"
          glyph: SettingsState.textMuted
        }

        Text {
          width: parent.width - 22
          anchors.verticalCenter: parent.verticalCenter
          text: ScreenshotState.lastPath
          color: lastPathMouse.containsMouse ? SettingsState.textActive : SettingsState.textMuted
          font.pixelSize: SettingsState.px(13)
          font.family: "monospace"
          elide: Text.ElideMiddle
        }
      }

      MouseArea {
        id: lastPathMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          ScreenshotState.openLast();
        }
      }
    }
  }
}
