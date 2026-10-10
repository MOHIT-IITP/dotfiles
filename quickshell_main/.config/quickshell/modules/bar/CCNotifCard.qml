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
  required property int index
  readonly property var entry: {
    var list = NotifCenter.trackedList;
    if (!list || index < 0 || index >= list.length)
      return null;
    return list[index];
  }
  width: ListView.view.width
  radius: 18
  color: SettingsState.bgCardHover
  border.color: SettingsState.borderBase
  border.width: 1
  implicitHeight: nrow.implicitHeight + 12

  Row {
    id: nrow
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    anchors.topMargin: 6
    anchors.bottomMargin: 6
    spacing: 8

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 24
      height: 24
      radius: 12
      color: SettingsState.bgActivePill
      Image {
        id: nicon
        anchors.centerIn: parent
        width: 16
        height: 16
        visible: status === Image.Ready
        source: {
          var s = NotifCenter.iconSourceFor(entry);
          if (s && (s + "") !== "") return s;
          if (entry && entry.image) return entry.image;
          return "";
        }
        smooth: true
        asynchronous: true
      }
      CCIcon {
        anchors.centerIn: parent
        width: 14
        height: 14
        visible: nicon.status !== Image.Ready
        kind: NotifCenter.iconKindFor(entry)
        glyph: SettingsState.textSecondary
      }
    }

    Column {
      width: parent.width - 68
      anchors.verticalCenter: parent.verticalCenter
      spacing: 0
      Text {
        text: (entry && entry.appName) ? entry.appName : ""
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(11)
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
      }
      Text {
        width: parent.width
        text: (entry && entry.summary) ? entry.summary : ""
        textFormat: Text.PlainText
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(13)
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
      }
      Text {
        width: parent.width
        visible: entry && entry.body !== ""
        text: (entry && entry.body) ? entry.body : ""
        textFormat: Text.PlainText
        color: SettingsState.textSecondary
        font.pixelSize: SettingsState.px(12)
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }

    Canvas {
      anchors.verticalCenter: parent.verticalCenter
      width: 10
      height: 10
      onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);
        ctx.strokeStyle = SettingsState.textMuted;
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
