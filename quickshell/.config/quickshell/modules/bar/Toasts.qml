import Quickshell
import QtQuick
import "../services"

// Pop-up toasts, centered directly below the top bar island.
// Auto-hides after the notification's timeout (5s fallback);
// the notification itself stays stored in the control center.
PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }

  margins {
    top: 52
  }

  implicitHeight: Math.max(1, list.implicitHeight + 20)
  color: "transparent"
  exclusiveZone: 0
  visible: NotifCenter.popupCount > 0

  mask: Region {
    item: list
  }

  Column {
    id: list
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    width: 380
    spacing: 10

    Repeater {
      model: NotifCenter.popups

      delegate: Rectangle {
        width: list.width
        radius: 16
        color: "#141714"
        border.color: "#2c332c"
        border.width: 1
        implicitHeight: trow.implicitHeight + 24

        // auto-hide (toast only — tracked copy stays in the CC)
        Timer {
          interval: (modelData && modelData.expireTimeout > 0 ? modelData.expireTimeout : 5) * 1000
          running: true
          onTriggered: NotifCenter.hidePopup(modelData)
        }

        Row {
          id: trow
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 12
          spacing: 10

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 16
            color: "#2c302c"
            Image {
              anchors.centerIn: parent
              width: 20
              height: 20
              visible: modelData && modelData.appIcon !== ""
              source: (modelData && modelData.appIcon !== "") ? Quickshell.iconPath(modelData.appIcon, "image-missing") : ""
              smooth: true
              asynchronous: true
            }
            Text {
              anchors.centerIn: parent
              visible: !modelData || modelData.appIcon === ""
              text: (modelData && modelData.appName) ? modelData.appName.substring(0, 1).toUpperCase() : "?"
              color: "#9aa39a"
              font.pixelSize: 14
              font.bold: true
            }
          }

          Column {
            width: parent.width - 84
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
              text: (modelData && modelData.appName) ? modelData.appName : ""
              color: "#9aa39a"
              font.pixelSize: 10
              font.family: SettingsState.fontFamily
            }
            Text {
              width: parent.width
              text: (modelData && modelData.summary) ? modelData.summary : ""
              textFormat: Text.PlainText
              color: "#f2f2f2"
              font.pixelSize: 13
              font.bold: true
              elide: Text.ElideRight
              maximumLineCount: 1
            }
            Text {
              width: parent.width
              visible: modelData && modelData.body !== ""
              text: (modelData && modelData.body) ? modelData.body : ""
              textFormat: Text.PlainText
              color: "#9aa39a"
              font.pixelSize: 11
              elide: Text.ElideRight
              maximumLineCount: 2
              wrapMode: Text.WordWrap
            }
          }

          Canvas {
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            onPaint: {
              var ctx = getContext("2d");
              ctx.reset();
              ctx.clearRect(0, 0, width, height);
              ctx.strokeStyle = "#6e756e";
              ctx.lineWidth = 1.6;
              ctx.lineCap = "round";
              ctx.beginPath();
              ctx.moveTo(2, 2);
              ctx.lineTo(10, 10);
              ctx.moveTo(10, 2);
              ctx.lineTo(2, 10);
              ctx.stroke();
            }
            MouseArea {
              anchors.fill: parent
              anchors.margins: -8
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (modelData)
                  modelData.dismiss();
              }
            }
          }
        }
      }
    }
  }
}
