import QtQuick
import "../services"
import "../utils"

// Left media player. Collapsed: art thumbnail circle.
// Hovered: full player card (art, metadata, progress, controls).
Rectangle {
  readonly property var player: MediaState.activePlayer
  readonly property bool hasPlayer: MediaState.hasPlayer
  readonly property bool isPlaying: MediaState.isPlaying

  implicitWidth: playerMouse.containsMouse ? 370 : 34
  implicitHeight: playerMouse.containsMouse ? 168 : 34
  radius: playerMouse.containsMouse ? 24 : 17

  color: playerMouse.containsMouse ? SettingsState.bgCard : SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1

  Behavior on implicitWidth {
    NumberAnimation {
      duration: 350
      easing.type: Easing.OutCubic
    }
  }
  Behavior on implicitHeight {
    NumberAnimation {
      duration: 350
      easing.type: Easing.OutCubic
    }
  }
  Behavior on radius {
    NumberAnimation {
      duration: 350
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
        duration: 180
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: "#1c1c1c"
      clip: true
      Image {
        anchors.fill: parent
        source: player?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
      }
      Text {
        anchors.centerIn: parent
        visible: !player?.trackArtUrl
        text: "♪"
        color: "#8f8f8f"
        font.pixelSize: 11
      }
    }
  }

  // ---- Expanded: player card ----
  Item {
    anchors.fill: parent
    anchors.margins: 16
    opacity: playerMouse.containsMouse ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 280
      }
    }

    Text {
      anchors.centerIn: parent
      visible: !hasPlayer
      text: "Nothing playing"
      color: "#8f8f8f"
      font.pixelSize: 14
      font.family: SettingsState.fontFamily
    }

    Row {
      anchors.fill: parent
      spacing: 14
      visible: hasPlayer

      // Album art
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 110
        height: 110
        radius: 12
        color: "#1c1c1c"
        clip: true
        Image {
          anchors.fill: parent
          source: player?.trackArtUrl ?? ""
          fillMode: Image.PreserveAspectCrop
          smooth: true
          asynchronous: true
        }
      }

      Column {
        width: parent.width - 124
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
          width: parent.width
          text: player?.trackTitle || (hasPlayer ? "Unknown Title" : "")
          color: "#f2f2f2"
          font.pixelSize: 17
          font.bold: true
          elide: Text.ElideRight
          maximumLineCount: 1
        }
        Text {
          width: parent.width
          text: player?.trackArtist || (hasPlayer ? "Unknown Artist" : "")
          color: "#d4d4d4"
          font.pixelSize: 14
          elide: Text.ElideRight
          maximumLineCount: 1
        }
        Text {
          width: parent.width
          text: player ? ((player.trackAlbum || "") + (player.identity ? ((player.trackAlbum ? "  •  " : "") + player.identity) : "")) : ""
          color: "#8f8f8f"
          font.pixelSize: 12
          elide: Text.ElideRight
          maximumLineCount: 1
        }

        // Progress bar (click to seek)
        Rectangle {
          id: progTrack
          width: parent.width
          height: 3
          radius: 1.5
          color: "#3a3f3a"

          Rectangle {
            width: (player && player.length > 0) ? parent.width * Math.min(1, (player.position || 0) / player.length) : 0
            height: parent.height
            radius: parent.radius
            color: "#d4d4d4"
          }
          Rectangle {
            x: ((player && player.length > 0) ? progTrack.width * Math.min(1, (player.position || 0) / player.length) : 0) - 3
            anchors.verticalCenter: parent.verticalCenter
            width: 6
            height: 6
            radius: 3
            color: "#7ee2a8"
          }

          MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: function (ev) {
              if (player && player.canSeek && player.length > 0) {
                var r = ev.x / progTrack.width;
                player.position = Math.max(0, Math.min(1, r)) * player.length;
                player.positionChanged();
              }
            }
          }
        }

        Item {
          width: parent.width
          height: 14
          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: player ? Format.fmtTime(player.position || 0) : "0:00"
            color: "#8f8f8f"
            font.pixelSize: 12
            font.family: SettingsState.fontFamily
          }
          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: player ? Format.fmtTime(player.length || 0) : "0:00"
            color: "#8f8f8f"
            font.pixelSize: 12
            font.family: SettingsState.fontFamily
          }
        }

        // Controls
        Row {
          spacing: 18
          anchors.horizontalCenter: parent.horizontalCenter

          // Previous
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 15
            color: prevArea.containsMouse ? "#2e332e" : "transparent"
            Canvas {
              anchors.centerIn: parent
              width: 14
              height: 14
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#e8e8e8";
                ctx.fillRect(1, 3, 2.5, 8);
                ctx.beginPath();
                ctx.moveTo(12.5, 2.5);
                ctx.lineTo(4.5, 7);
                ctx.lineTo(12.5, 11.5);
                ctx.closePath();
                ctx.fill();
              }
            }
            MouseArea {
              id: prevArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              enabled: Boolean(player?.canGoPrevious)
              opacity: enabled ? 1 : 0.3
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
            color: playArea.containsMouse ? "#3a403a" : "#2b302b"
            Canvas {
              anchors.centerIn: parent
              width: 16
              height: 16
              visible: !isPlaying
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#f2f2f2";
                ctx.beginPath();
                ctx.moveTo(4, 2);
                ctx.lineTo(13, 8);
                ctx.lineTo(4, 14);
                ctx.closePath();
                ctx.fill();
              }
            }
            Canvas {
              anchors.centerIn: parent
              width: 16
              height: 16
              visible: isPlaying
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#f2f2f2";
                ctx.fillRect(3, 2, 3.5, 12);
                ctx.fillRect(9.5, 2, 3.5, 12);
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
          }

          // Next
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 15
            color: nextArea.containsMouse ? "#2e332e" : "transparent"
            Canvas {
              anchors.centerIn: parent
              width: 14
              height: 14
              onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = "#e8e8e8";
                ctx.fillRect(10.5, 3, 2.5, 8);
                ctx.beginPath();
                ctx.moveTo(1.5, 2.5);
                ctx.lineTo(9.5, 7);
                ctx.lineTo(1.5, 11.5);
                ctx.closePath();
                ctx.fill();
              }
            }
            MouseArea {
              id: nextArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              enabled: Boolean(player?.canGoNext)
              opacity: enabled ? 1 : 0.3
              onClicked: {
                if (player)
                  player.next();
              }
            }
          }
        }
      }
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
