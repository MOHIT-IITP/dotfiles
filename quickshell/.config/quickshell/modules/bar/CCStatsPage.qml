import QtQuick
import "../services"

// System stats sub-page for the control center (RAM / Swap / CPU / Disk).
Column {
  id: root
  required property var circle
  required property bool hovered
  spacing: 8
  opacity: (hovered && circle.activePage === "stats") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    enabled: circle.opacity > 0.5
    NumberAnimation {
      duration: 220
    }
  }

  // Header — minimal like config: spaced title left, thin chevron right
  Item {
    width: parent.width
    height: 30

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: "STATS"
      color: SettingsState.accent
      font.pixelSize: SettingsState.px(14)
      font.family: SettingsState.fontFamily
      font.letterSpacing: 2
      font.weight: Font.DemiBold
    }

    MouseArea {
      id: statsTitleMouse
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 180
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: circle.activePage = "main"
    }

    Item {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: 24
      height: 24

      Text {
        anchors.centerIn: parent
        text: "‹"
        font.family: SettingsState.fontFamily
        font.weight: Font.Light
        color: statsBackMouse.containsMouse ? SettingsState.textMain : "#8a8a8a"
        font.pixelSize: SettingsState.px(22)
      }

      MouseArea {
        id: statsBackMouse
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: circle.activePage = "main"
      }
    }
  }

  Item {
    width: parent.width
    height: 10
  }

  Grid {
    width: parent.width
    columns: 2
    columnSpacing: 24
    rowSpacing: 18

    // 1. RAM cell — plain row like config: icon | title+detail | pct
    Column {
      width: (parent.width - 24) / 2
      spacing: 6

      Row {
        width: parent.width
        spacing: 12

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 22
          height: 22
          kind: "ram"
          glyph: SettingsState.isDark ? "#b5b5b5" : "#555555"
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 22 - 12 - pctRam.implicitWidth - 8
          spacing: 3

          Text {
            width: parent.width
            text: "RAM"
            color: SettingsState.isDark ? "#e2e2e2" : "#222222"
            font.pixelSize: SettingsState.px(16)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: SysStats.ready ? SysStats.ramText : "--"
            color: SettingsState.isDark ? "#7c7c7c" : "#777777"
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        Text {
          id: pctRam
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(SysStats.ramPct) + "%"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }

      WavyStatSlider {
        width: parent.width
        height: 18
        fraction: SysStats.ramPct / 100
        waveColor: SettingsState.accent
        showTrack: false
        showHandle: false
        showRemaining: true
        remainingW: 2
        doubleWave: false
        flowing: false
        phaseOffset: 0
        waveCount: 2
        waveW: 2
      }
    }

    // 2. Swap cell
    Column {
      width: (parent.width - 24) / 2
      spacing: 6

      Row {
        width: parent.width
        spacing: 12

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 22
          height: 22
          kind: "swap"
          glyph: SettingsState.isDark ? "#b5b5b5" : "#555555"
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 22 - 12 - pctSwap.implicitWidth - 8
          spacing: 3

          Text {
            width: parent.width
            text: "Swap"
            color: SettingsState.isDark ? "#e2e2e2" : "#222222"
            font.pixelSize: SettingsState.px(16)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: SysStats.ready ? SysStats.swapText : "--"
            color: SettingsState.isDark ? "#7c7c7c" : "#777777"
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        Text {
          id: pctSwap
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(SysStats.swapPct) + "%"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }

      WavyStatSlider {
        width: parent.width
        height: 18
        fraction: SysStats.swapPct / 100
        waveColor: SettingsState.accent
        showTrack: false
        showHandle: false
        showRemaining: true
        remainingW: 2
        doubleWave: false
        flowing: false
        phaseOffset: Math.PI / 2
        waveCount: 2
        waveW: 2
      }
    }

    // 3. CPU cell
    Column {
      width: (parent.width - 24) / 2
      spacing: 6

      Row {
        width: parent.width
        spacing: 12

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 22
          height: 22
          kind: "cpu"
          glyph: SettingsState.isDark ? "#b5b5b5" : "#555555"
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 22 - 12 - pctCpu.implicitWidth - 8
          spacing: 3

          Text {
            width: parent.width
            text: "CPU"
            color: SettingsState.isDark ? "#e2e2e2" : "#222222"
            font.pixelSize: SettingsState.px(16)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: SysStats.tempText
            color: SettingsState.isDark ? "#7c7c7c" : "#777777"
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        Text {
          id: pctCpu
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(SysStats.cpuPct) + "%"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }

      WavyStatSlider {
        width: parent.width
        height: 18
        fraction: SysStats.cpuPct / 100
        waveColor: SettingsState.accent
        showTrack: false
        showHandle: false
        showRemaining: true
        remainingW: 2
        doubleWave: false
        flowing: false
        phaseOffset: Math.PI
        waveCount: 2
        waveW: 2
      }
    }

    // 4. Disk cell
    Column {
      width: (parent.width - 24) / 2
      spacing: 6

      Row {
        width: parent.width
        spacing: 12

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 22
          height: 22
          kind: "disk"
          glyph: SettingsState.isDark ? "#b5b5b5" : "#555555"
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 22 - 12 - pctDisk.implicitWidth - 8
          spacing: 3

          Text {
            width: parent.width
            text: "Disk"
            color: SettingsState.isDark ? "#e2e2e2" : "#222222"
            font.pixelSize: SettingsState.px(16)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: SysStats.ready ? SysStats.diskText : "--"
            color: SettingsState.isDark ? "#7c7c7c" : "#777777"
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        Text {
          id: pctDisk
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(SysStats.diskPct) + "%"
          color: SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }

      WavyStatSlider {
        width: parent.width
        height: 18
        fraction: SysStats.diskPct / 100
        waveColor: SettingsState.accent
        showTrack: false
        showHandle: false
        showRemaining: true
        remainingW: 2
        doubleWave: false
        flowing: false
        phaseOffset: Math.PI * 1.5
        waveCount: 2
        waveW: 2
      }
    }
  }
}
