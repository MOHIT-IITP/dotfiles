import Quickshell
import QtQuick
import "../services"

// Single notification card in the control-center list.
// Extracted from MainPage.qml.
//
// NOTE: the entry is resolved by index from NotifCenter.trackedList instead of
// via the ListView's `modelData`, which did not propagate the Notification
// objects into delegates (cards rendered blank).
Rectangle {
  required property int entryIndex
  readonly property var entry: {
    var list = NotifCenter.trackedList;
    if (!list || entryIndex < 0 || entryIndex >= list.length)
      return null;
    return list[entryIndex];
  }
  width: ListView.view.width
  radius: 18
  color: "#181d18"
  border.color: "#252c25"
  border.width: 1
  implicitHeight: nrow.implicitHeight + 20

  Row {
    id: nrow
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 10
    spacing: 10

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 30
      height: 30
      radius: 15
      color: "#2c302c"
      Image {
        anchors.centerIn: parent
        width: 20
        height: 20
        visible: entry && entry.appIcon !== ""
        source: (entry && entry.appIcon !== "") ? Quickshell.iconPath(entry.appIcon, "image-missing") : ""
        smooth: true
        asynchronous: true
      }
      Text {
        anchors.centerIn: parent
        visible: !entry || entry.appIcon === ""
        text: (entry && entry.appName) ? entry.appName.substring(0, 1).toUpperCase() : "?"
        color: "#9aa39a"
        font.pixelSize: SettingsState.px(16)
        font.bold: true
      }
    }

    Column {
      width: parent.width - 80
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2
      Text {
        text: (entry && entry.appName) ? entry.appName : ""
        color: "#9aa39a"
        font.pixelSize: SettingsState.px(13)
        font.family: SettingsState.fontFamily
      }
      Text {
        width: parent.width
        text: (entry && entry.summary) ? entry.summary : ""
        textFormat: Text.PlainText
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
      }
      Text {
        width: parent.width
        visible: entry && entry.body !== ""
        text: (entry && entry.body) ? entry.body : ""
        textFormat: Text.PlainText
        color: "#9aa39a"
        font.pixelSize: SettingsState.px(14)
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
          if (entry)
            NotifCenter.dismissNotification(entry);
        }
      }
    }
  }
}
