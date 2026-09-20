import Quickshell
import QtQuick
import "../services"

// Embedded System & Wi-Fi Authentication subview directly inside ClockPill.
// Handles all PolicyKit root/sudo prompts and Wi-Fi security authentications seamlessly in-place.
Item {
  id: root

  readonly property bool isPolkit: AuthState.authType === "polkit"
  implicitWidth: 460
  implicitHeight: 216

  function forceFocus() {
    pwInput.focus = true;
    pwInput.forceActiveFocus();
  }

  Connections {
    target: AuthState
    function onOpenChanged() {
      if (AuthState.open) {
        pwInput.text = "";
        forceFocus();
        focusRetryTimer.restart();
      }
    }
  }

  Timer {
    id: focusRetryTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (pwInput.activeFocus || count > 8) {
        running = false;
      }
    }
  }

  Column {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12

    // Header: Icon + Title + Description
    Row {
      width: parent.width
      spacing: 14

      // Icon Badge
      Rectangle {
        width: 40
        height: 40
        radius: 12
        color: SettingsState.bgActivePill
        border.color: SettingsState.borderActive
        border.width: 1
        anchors.verticalCenter: parent.verticalCenter

        CCIcon {
          anchors.centerIn: parent
          width: 22
          height: 22
          kind: root.isPolkit ? "lock" : "wifi"
          glyph: SettingsState.accent
        }
      }

      // Title & Subtitle
      Column {
        width: parent.width - 54
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Row {
          width: parent.width
          spacing: 8

          Text {
            text: root.isPolkit ? "System Authentication" : "Wi-Fi Authentication"
            color: SettingsState.textMain
            font.pixelSize: 14
            font.bold: true
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          // User tag for Polkit
          Rectangle {
            visible: root.isPolkit && AuthState.user !== ""
            anchors.verticalCenter: parent.verticalCenter
            height: 18
            width: userLabel.implicitWidth + 10
            radius: 9
            color: SettingsState.bgCard
            border.color: SettingsState.borderBase
            border.width: 1

            Text {
              id: userLabel
              anchors.centerIn: parent
              text: AuthState.user
              color: SettingsState.accent
              font.pixelSize: 10
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }
        }

        Text {
          width: parent.width
          text: root.isPolkit ? (AuthState.message || "Authentication is required to perform this action") : ("Password required to access “" + (AuthState.ssid || "Wi-Fi Network") + "”")
          color: SettingsState.textMuted
          font.pixelSize: 12
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
          maximumLineCount: 2
          wrapMode: Text.WordWrap
        }
      }
    }

    // Password Input Box
    Rectangle {
      id: inputContainer
      width: parent.width
      height: 38
      radius: 10
      color: SettingsState.bgCard
      border.color: AuthState.errorMessage ? "#ef5350" : (pwInput.activeFocus ? SettingsState.accent : SettingsState.borderBase)
      border.width: pwInput.activeFocus ? 1.5 : 1

      Behavior on border.color {
        ColorAnimation { duration: 120 }
      }

      Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 10
        spacing: 8

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Password:"
          color: SettingsState.textSecondary
          font.pixelSize: 12
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        TextInput {
          id: pwInput
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 120
          height: parent.height
          verticalAlignment: TextInput.AlignVCenter
          color: SettingsState.textMain
          font.pixelSize: 13
          font.family: SettingsState.fontFamily
          clip: true
          focus: true
          echoMode: AuthState.showPassword ? TextInput.Normal : TextInput.Password
          selectByMouse: true
          enabled: !AuthState.isConnecting

          Keys.onReturnPressed: function(ev) {
            AuthState.submit(pwInput.text);
            ev.accepted = true;
          }
          Keys.onEnterPressed: function(ev) {
            AuthState.submit(pwInput.text);
            ev.accepted = true;
          }
          Keys.onEscapePressed: function(ev) {
            AuthState.close();
            ev.accepted = true;
          }
        }

        // Show/Hide Password Eye Button
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 28
          height: 28
          radius: 6
          color: eyeMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: AuthState.showPassword ? "eye" : "lock"
            glyph: AuthState.showPassword ? SettingsState.accent : SettingsState.textSecondary
          }

          MouseArea {
            id: eyeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              AuthState.showPassword = !AuthState.showPassword;
              pwInput.forceActiveFocus();
            }
          }
        }
      }
    }

    // Status / Error message row
    Item {
      width: parent.width
      height: 18

      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: AuthState.errorMessage !== ""
        text: AuthState.errorMessage
        color: "#ef5350"
        font.pixelSize: 11
        font.bold: true
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
        width: parent.width - 160
      }

      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: AuthState.isConnecting && AuthState.errorMessage === ""
        text: root.isPolkit ? "Authenticating with system..." : ("Connecting to " + AuthState.ssid + "...")
        color: SettingsState.accent
        font.pixelSize: 11
        font.bold: true
        font.family: SettingsState.fontFamily
      }
    }

    // Footer Action Buttons: Cancel and Authenticate / Connect
    Row {
      anchors.right: parent.right
      spacing: 10

      // Cancel Button
      Rectangle {
        width: 80
        height: 32
        radius: 16
        color: cancelMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: "Cancel"
          color: SettingsState.textSecondary
          font.pixelSize: 12
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: cancelMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: AuthState.close()
        }
      }

      // Authenticate / Connect Button
      Rectangle {
        width: root.isPolkit ? 116 : 96
        height: 32
        radius: 16
        color: AuthState.isConnecting ? SettingsState.bgCard : (connectMouse.containsMouse ? SettingsState.accent : SettingsState.accent)
        opacity: AuthState.isConnecting ? 0.6 : (connectMouse.containsMouse ? 0.9 : 1.0)

        Row {
          anchors.centerIn: parent
          spacing: 6

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: AuthState.isConnecting ? "Verifying..." : (root.isPolkit ? "Authenticate" : "Connect")
            color: SettingsState.isDark ? "#121612" : "#ffffff"
            font.pixelSize: 12
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        MouseArea {
          id: connectMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: !AuthState.isConnecting
          onClicked: AuthState.submit(pwInput.text)
        }
      }
    }
  }
}
