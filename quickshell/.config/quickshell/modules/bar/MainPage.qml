import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../services"

// Horizontal control-center strip (reference-image layout):
// [toggles] | [capsule: ethernet + bluetooth + accessory] [time + date]
// Mixer/Power/Apps/Wall/Clip open via keybinds, not shown here.
Item {
  id: mainPage
  required property var circle
  required property bool hovered
  implicitWidth: strip.implicitWidth
  implicitHeight: 52
  opacity: (hovered && circle.activePage === "main") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    enabled: circle.opacity > 0.5
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

  // ---- Workspaces (left pill, mirrors collapsed ClockPill dots) ----
  readonly property int currentWsId: Hyprland.focusedWorkspace?.id ?? 1
  readonly property int maxWs: {
    var m = 3;
    if (currentWsId > m) m = currentWsId;
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      var ws = list[i];
      if (ws && ws.id > m && ws.id <= 10) m = ws.id;
    }
    return Math.min(Math.max(m, 3), 10);
  }
  function isOccupied(wsId) {
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      if (list[i] && list[i].id === wsId) return true;
    }
    return false;
  }

  Row {
    id: strip
    anchors.centerIn: parent
    width: implicitWidth
    height: parent.height
    spacing: 4

    // ---- Workspaces pill (left) ----
    Rectangle {
      id: wsCapsule
      anchors.verticalCenter: parent.verticalCenter
      width: wsRow.implicitWidth + 20
      height: 32
      radius: 16
      color: SettingsState.bgCardHover
      border.width: 0

      Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
          model: mainPage.maxWs

          delegate: Item {
            property int wsId: index + 1
            property bool isCurrent: mainPage.currentWsId === wsId
            property bool occupied: mainPage.isOccupied(wsId)

            width: isCurrent ? 22 : 7
            height: 7
            anchors.verticalCenter: parent.verticalCenter

            Behavior on width {
              NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
              }
            }

            Rectangle {
              anchors.fill: parent
              radius: height / 2
              color: parent.isCurrent ? SettingsState.accent : (parent.occupied ? SettingsState.textSecondary : SettingsState.borderBase)

              Behavior on color {
                ColorAnimation { duration: 200 }
              }
            }

            MouseArea {
              anchors.fill: parent
              anchors.margins: -6
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Hyprland.dispatch("workspace " + parent.wsId)
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

    // Main toggles order: calendar first, record+camera together,
    // DND+nightshift together, about+settings together (gear right of about).
    // Mixer/Power removed — keybinds cover them.
    Row {
      id: iconRow
      anchors.verticalCenter: parent.verticalCenter
      spacing: 0

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
        active: AboutState.open
        onClicked: AboutState.toggle()
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
      color: circle.btOn ? SettingsState.bgCardHover : "transparent"
      border.color: SettingsState.borderBase
      border.width: circle.btOn ? 1 : 0

      Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 0

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
      width: Math.max(timeMetrics.implicitWidth, dateMetrics.implicitWidth)
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

      // Widest possible date ("WWW 88 WWW") so "MON 12 OCT" never elides
      Text {
        id: dateMetrics
        visible: false
        text: "WWW 88 WWW"
        font.pixelSize: SettingsState.px(11)
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
