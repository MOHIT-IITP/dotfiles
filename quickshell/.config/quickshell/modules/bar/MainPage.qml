import Quickshell
import QtQuick
import "../services"

// Horizontal control-center strip (reference-image layout):
// [toggles] | [capsule: ethernet + bluetooth + accessory] [time + date]
// Mixer/Power/Apps/Wall/Clip open via keybinds, not shown here.
Item {
  id: mainPage
  required property var circle
  required property bool hovered
  implicitHeight: 52
  opacity: (hovered && circle.activePage === "main") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  SystemClock {
    id: sysClock
    precision: SystemClock.Minutes
  }

  readonly property string timeStr: {
    var fmt = SettingsState.timeFormat === "24h" ? "HH:mm" : "h:mm AP";
    return Qt.formatDateTime(sysClock.date, fmt);
  }
  readonly property string dateStr: {
    return Qt.formatDateTime(sysClock.date, "ddd d MMM").toUpperCase();
  }

  readonly property bool hasAcc: DeviceBatteryState.hasAccessories
  readonly property var firstAcc: hasAcc ? DeviceBatteryState.accessories[0] : null
  readonly property int accPct: firstAcc ? DeviceBatteryState.pct100(firstAcc) : -1
  readonly property string accKind: firstAcc ? DeviceBatteryState.iconKindFor(firstAcc) : "mouse"

  Row {
    id: strip
    anchors.centerIn: parent
    width: implicitWidth
    height: parent.height
    spacing: 8

    // Main toggles order: calendar first, record+camera together,
    // DND+nightshift together, about+settings together (gear right of about).
    // Mixer/Power removed — keybinds cover them.
    Row {
      id: iconRow
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      CCHIcon {
        kind: "calendar"
        active: circle.activePage === "calendar"
        onClicked: {
          CalendarState.refreshWeather();
          circle.activePage = "calendar";
        }
      }
      CCHIcon {
        kind: "record"
        active: circle.activePage === "recorder" || RecorderState.isRecording
        alert: RecorderState.isRecording
        onClicked: {
          circle.activePage = "recorder";
          RecorderState.refreshRecent();
          RecorderState.checkStatus();
        }
      }
      CCHIcon {
        kind: "camera"
        active: circle.activePage === "screenshot"
        onClicked: {
          circle.activePage = "screenshot";
          ScreenshotState.refreshLast();
        }
      }
      CCHIcon {
        kind: "moon"
        active: NotifCenter.dnd
        onClicked: NotifCenter.toggleDnd()
      }
      CCHIcon {
        kind: "sunset"
        active: NightlightState.active
        onClicked: NightlightState.toggle()
      }
      CCHIcon {
        kind: "about"
        active: circle.activePage === "about"
        onClicked: circle.activePage = "about"
      }
      CCHIcon {
        kind: "gear"
        active: circle.activePage === "settings"
        onClicked: {
          circle.settingsSub = "";
          circle.activePage = "settings";
        }
      }
      CCHIcon {
        kind: "cpu"
        active: circle.activePage === "stats"
        onClicked: circle.activePage = "stats"
      }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 1
      height: 30
      color: SettingsState.borderBase
      opacity: 0.7
    }

    // Grouped capsule like the reference: bluetooth + accessory only.
    // Ethernet / wifi stays outside, unsheathed.
    CCHIcon {
      anchors.verticalCenter: parent.verticalCenter
      kind: (circle.wiredUp && !circle.wifiUp) ? "ethernet" : "wifi"
      filled: false
      active: circle.wifiUp || circle.wiredUp || circle.activePage === "wifi"
      onClicked: circle.activePage = "wifi"
    }

    Rectangle {
      id: netCapsule
      anchors.verticalCenter: parent.verticalCenter
      width: netRow.implicitWidth + 14
      height: 44
      radius: 22
      color: SettingsState.bgCardHover
      border.color: SettingsState.borderBase
      border.width: 1

      Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 2

        CCHIcon {
          kind: "bt"
          filled: true
          active: (circle.btOn && BluetoothState.btDevice) || circle.activePage === "bluetooth"
          onClicked: {
            circle.activePage = "bluetooth";
            BluetoothState.startDiscovery();
          }
        }

        // Accessory battery inline with bluetooth - own lighter-shade pill
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: visible ? accRow.implicitWidth + 16 : 0
          height: 32
          radius: 16
          color: SettingsState.bgActivePill
          opacity: accMouse.containsMouse ? 0.8 : 1.0
          visible: mainPage.hasAcc

          Behavior on opacity { NumberAnimation { duration: 150 } }

          Row {
            id: accRow
            anchors.centerIn: parent
            spacing: 6

            CCIcon {
              anchors.verticalCenter: parent.verticalCenter
              width: 18
              height: 18
              kind: mainPage.accKind
              glyph: accMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
            }

            WavyStatSlider {
              anchors.verticalCenter: parent.verticalCenter
              width: 44
              height: 14
              fraction: Math.max(0, Math.min(1, mainPage.accPct / 100))
              waveColor: SettingsState.accent
              trackColor: SettingsState.borderBase
              showTrack: true
              showHandle: false
              showRemaining: false
              doubleWave: false
              flowing: false
              trackH: 4
              waveW: 3
              waveAmp: 2
              waveLen: 12
              waveCount: 2
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: mainPage.accPct >= 0 ? mainPage.accPct + "%" : "--"
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(13)
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }

          MouseArea {
            id: accMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              circle.activePage = "bluetooth";
              BluetoothState.startDiscovery();
            }
          }
        }
      }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 1
      height: 30
      color: SettingsState.borderBase
      opacity: 0.7
    }

    // Time + date on the right
    Column {
      id: timeCol
      anchors.verticalCenter: parent.verticalCenter
      width: timeMetrics.implicitWidth
      spacing: 0

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: mainPage.timeStr
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(20)
        font.bold: true
        font.family: SettingsState.fontFamily
      }
      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: mainPage.dateStr
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
      }

      Text {
        id: timeMetrics
        visible: false
        text: SettingsState.timeFormat === "24h" ? "88:88" : "8:88 PM"
        font.pixelSize: SettingsState.px(20)
        font.bold: true
        font.family: SettingsState.fontFamily
      }
    }
  }

  // Recording dot pinned at top-center
  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: -4
    width: 5
    height: 5
    radius: 2.5
    color: "#ff453a"
    visible: RecorderState.isRecording

    SequentialAnimation on opacity {
      running: RecorderState.isRecording
      loops: Animation.Infinite
      NumberAnimation { from: 1.0; to: 0.2; duration: 900; easing.type: Easing.InOutSine }
      NumberAnimation { from: 0.2; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
    }
  }
}
