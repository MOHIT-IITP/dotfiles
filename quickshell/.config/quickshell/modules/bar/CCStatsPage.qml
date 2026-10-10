import QtQuick
import "../services"

// System stats sub-page for the control center (RAM / Swap / CPU / Disk).
Column {
  id: root
  required property var circle
  required property bool hovered
  spacing: 10
  opacity: (hovered && circle.activePage === "stats") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation {
      duration: 220
    }
  }

  // Header with back button
  Item {
    width: parent.width
    height: 30

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Rectangle {
        width: 28
        height: 28
        radius: 14
        color: statsBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
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
          id: statsBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: circle.activePage = "main"
        }
      }

      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: SettingsState.japaneseGlyphs
          text: "統"
          color: statsTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
          font.pixelSize: SettingsState.px(20)
          font.bold: true
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "STATS"
          color: statsTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
          font.pixelSize: SettingsState.px(17)
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }

    }

    MouseArea {
      id: statsTitleMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: circle.activePage = "main"
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: SysStats.tempText
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(12)
      font.bold: true
      font.family: SettingsState.fontFamily
      elide: Text.ElideRight
    }
  }

  Rectangle {
    width: parent.width
    height: 1
    color: SettingsState.borderBase
  }

  Grid {
    width: parent.width
    columns: 2
    columnSpacing: 18
    rowSpacing: 14

    // 1. RAM cell
    Column {
      width: (parent.width - 18) / 2
      spacing: 3

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

      Text {
        text: "RAM"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(13)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      Text {
        text: SysStats.ready ? SysStats.ramText : "--"
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }

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

      Text {
        text: "Swap"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(13)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      Text {
        text: SysStats.ready ? SysStats.swapText : "--"
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }

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

      Text {
        text: "CPU"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(13)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      Text {
        text: SysStats.tempText
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }

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

      Text {
        text: "Disk"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(13)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      Text {
        text: SysStats.ready ? SysStats.diskText : "--"
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
      }

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
