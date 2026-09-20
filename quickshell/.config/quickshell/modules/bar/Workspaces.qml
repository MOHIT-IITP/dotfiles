import Quickshell
import Quickshell.Hyprland
import QtQuick

// Workspaces pill: displays workspace indicators (dots for inactive, red bar for active workspace)
Rectangle {
  id: root

  implicitHeight: 34
  implicitWidth: wsRow.implicitWidth + 24
  radius: implicitHeight / 2
  color: "#101010"
  border.color: "#3a2c23"
  border.width: 1

  Behavior on implicitWidth {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  readonly property int currentWsId: Hyprland.focusedWorkspace?.id ?? 1

  // Determine highest workspace number to display (at least 3, up to highest active/occupied or 10)
  readonly property int maxWs: {
    var m = 3;
    if (currentWsId > m) {
      m = currentWsId;
    }
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      var ws = list[i];
      if (ws && ws.id > m && ws.id <= 10) {
        m = ws.id;
      }
    }
    return Math.min(Math.max(m, 3), 10);
  }

  function isOccupied(wsId) {
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      if (list[i] && list[i].id === wsId) {
        return true;
      }
    }
    return false;
  }

  // Workspace indicators row
  Row {
    id: wsRow
    anchors.centerIn: parent
    spacing: 8

    Repeater {
      model: root.maxWs

      delegate: Item {
        id: wsItem
        property int wsId: index + 1
        property bool isCurrent: root.currentWsId === wsId
        property bool occupied: root.isOccupied(wsId)

        width: isCurrent ? 26 : 7
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
          color: wsItem.isCurrent ? "#e05f65" : (wsMouse.containsMouse ? "#d0d0d0" : (wsItem.occupied ? "#888888" : "#454545"))

          Behavior on color {
            ColorAnimation {
              duration: 200
            }
          }
        }

        MouseArea {
          id: wsMouse
          anchors.fill: parent
          anchors.margins: -6
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Hyprland.dispatch("workspace " + wsItem.wsId);
          }
        }
      }
    }
  }

  // Scroll wheel to cycle workspaces
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    cursorShape: Qt.PointingHandCursor
    onWheel: wheel => {
      if (wheel.angleDelta.y > 0) {
        Hyprland.dispatch("workspace e-1");
      } else if (wheel.angleDelta.y < 0) {
        Hyprland.dispatch("workspace e+1");
      }
    }
  }
}
