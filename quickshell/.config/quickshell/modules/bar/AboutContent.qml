import QtQuick
import "../services"

// Embedded About / profile-links view directly inside ClockPill.
// Opened via keybind (`qs ipc call mohiitp about`, Super+Ctrl+A).
// Click a row to copy its value; + add manages entries (persisted).
Item {
  id: root

  implicitWidth: 460
  implicitHeight: aboutCol.implicitHeight + 28

  property bool adding: false

  function forceFocus() {
    if (root.adding) {
      labelInput.focus = true;
      labelInput.forceActiveFocus();
    } else {
      keyArea.focus = true;
      keyArea.forceActiveFocus();
    }
  }

  function focusLabel() {
    labelInput.focus = true;
    labelInput.forceActiveFocus();
  }

  onAddingChanged: {
    if (adding) {
      focusLabel();
      focusRetry.restart();
    } else {
      focusRetry.stop();
    }
  }

  Connections {
    target: AboutState
    function onOpenChanged() {
      if (AboutState.open) {
        root.adding = false;
        labelInput.text = "";
        valueInput.text = "";
        forceFocus();
        focusRetry.restart();
      } else {
        focusRetry.stop();
      }
    }
  }

  Timer {
    id: focusRetry
    interval: 50
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      root.forceFocus();
      if (labelInput.activeFocus || valueInput.activeFocus || keyArea.activeFocus || count > 10 || !AboutState.open) {
        running = false;
      }
    }
  }

  // Invisible key handler (Escape closes, mirrors other center views)
  Item {
    id: keyArea
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: function(ev) {
      if (root.adding) root.adding = false;
      else AboutState.close();
      ev.accepted = true;
    }
  }

  Column {
    id: aboutCol
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: 14
    anchors.leftMargin: 14
    anchors.rightMargin: 14
    spacing: 12

    // Header - minimal
    Item {
      width: parent.width
      height: 28

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Rectangle {
          width: 24
          height: 24
          radius: 12
          color: aboutCloseMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "\ueab5"
            font.family: SettingsState.nerdIconFont
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(16)
            font.bold: true
          }

          MouseArea {
            id: aboutCloseMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.adding = false;
              AboutState.close();
            }
          }
        }

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 16
          height: 16
          kind: "about"
          glyph: SettingsState.textSecondary
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "ABOUT"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 0.5
        }
      }

      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: (AboutState.links ? AboutState.links.length : 0) + " links"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(12)
        font.family: SettingsState.fontFamily
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: SettingsState.borderBase
    }

    // Empty state
    Text {
      visible: !AboutState.links || AboutState.links.length === 0
      text: "No links yet — add your email, GitHub, LinkedIn…"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(12)
      font.family: SettingsState.fontFamily
      wrapMode: Text.WordWrap
      width: parent.width
    }

    // Links list - minimal compact rows
    ListView {
      width: parent.width
      height: (!AboutState.links || AboutState.links.length === 0) ? 0 : Math.min(336, AboutState.links.length * 56 - 4)
      spacing: 4
      clip: true
      visible: AboutState.links && AboutState.links.length > 0
      model: AboutState.links

      delegate: Rectangle {
        required property var modelData
        required property int index
        width: ListView.view.width
        height: 52
        radius: 10
        color: aboutRowMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 12
          anchors.topMargin: 6
          anchors.bottomMargin: 6
          spacing: 8
          // Must sit above the row-wide aboutRowMouse below (sibling
          // stacking wins over grandchild z), else row MouseArea eats clicks.
          z: 1

          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28

            CCIcon {
              anchors.centerIn: parent
              width: 18
              height: 18
              kind: AboutState.iconFor(modelData)
              glyph: SettingsState.textSecondary
            }
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 28 - 24 - 24 - 16
            spacing: 1

            Text {
              width: parent.width
              text: (modelData && modelData.label) ? modelData.label : ""
              color: SettingsState.textMuted
              font.pixelSize: SettingsState.px(11)
              font.family: SettingsState.fontFamily
              font.capitalization: Font.AllUppercase
              font.letterSpacing: 0.5
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: (modelData && modelData.value) ? modelData.value : ""
              color: SettingsState.textMain
              font.pixelSize: SettingsState.px(14)
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
              maximumLineCount: 1
            }
          }

          // copy button - minimal ghost
          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            // Above the row-wide aboutRowMouse below, else it eats button clicks
            z: 2

            CCIcon {
              anchors.centerIn: parent
              width: 13
              height: 13
              kind: "copy"
              glyph: copyMouse.containsMouse ? SettingsState.textMain : SettingsState.textMuted
            }

            MouseArea {
              id: copyMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: function(ev) {
                AboutState.copyLink(modelData.value);
                ev.accepted = true;
              }
            }
          }

          // delete button - minimal ghost
          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            // Above the row-wide aboutRowMouse below, else it eats button clicks
            z: 2

            CCIcon {
              anchors.centerIn: parent
              width: 13
              height: 13
              kind: "trash"
              glyph: delMouse.containsMouse ? "#ff8a8a" : SettingsState.textMuted
            }

            MouseArea {
              id: delMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: function(ev) {
                AboutState.removeLink(index);
                ev.accepted = true;
              }
            }
          }
        }

        MouseArea {
          id: aboutRowMouse
          anchors.fill: parent
          z: 0
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            AboutState.copyLink(modelData.value);
          }
        }
      }
    }

    // Inline add form
    Column {
      width: parent.width
      spacing: 8
      visible: root.adding

      Rectangle {
        width: parent.width
        height: 34
        radius: 10
        color: SettingsState.bgCard
        border.color: labelInput.activeFocus ? SettingsState.borderActive : SettingsState.borderBase
        border.width: 1

        Item {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: labelInput.text.length === 0
            text: "label  ·  e.g. github"
            color: SettingsState.textMuted
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          TextInput {
            id: labelInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            clip: true
            selectByMouse: true
            activeFocusOnTab: true
            maximumLength: 24
            Keys.onTabPressed: function(ev) {
              valueInput.forceActiveFocus();
              ev.accepted = true;
            }
            Keys.onEscapePressed: function(ev) {
              root.adding = false;
              ev.accepted = true;
            }
          }
        }
      }

      Rectangle {
        width: parent.width
        height: 34
        radius: 10
        color: SettingsState.bgCard
        border.color: valueInput.activeFocus ? SettingsState.borderActive : SettingsState.borderBase
        border.width: 1

        Item {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: valueInput.text.length === 0
            text: "value  ·  e.g. github.com/mohiitp or you@mail.com"
            color: SettingsState.textMuted
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          TextInput {
            id: valueInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            clip: true
            selectByMouse: true
            activeFocusOnTab: true
            onAccepted: {
              if (AboutState.addLink(labelInput.text, valueInput.text)) {
                labelInput.text = "";
                valueInput.text = "";
                root.adding = false;
              }
            }
            Keys.onEscapePressed: function(ev) {
              root.adding = false;
              ev.accepted = true;
            }
          }
        }
      }

      Row {
        width: parent.width
        spacing: 8

        Rectangle {
          width: (parent.width - 8) / 2
          height: 34
          radius: 17
          color: saveMouse.containsMouse ? SettingsState.accent : SettingsState.bgActivePill
          border.color: SettingsState.borderActive
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: "Save"
            color: saveMouse.containsMouse ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textActive
            font.pixelSize: SettingsState.px(12)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: saveMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (AboutState.addLink(labelInput.text, valueInput.text)) {
                labelInput.text = "";
                valueInput.text = "";
                root.adding = false;
              }
            }
          }
        }

        Rectangle {
          width: (parent.width - 8) / 2
          height: 34
          radius: 17
          color: cancelMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
          border.color: SettingsState.borderBase
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: "Cancel"
            color: SettingsState.textSecondary
            font.pixelSize: SettingsState.px(12)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: cancelMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.adding = false;
            }
          }
        }
      }
    }

    // + add button at the bottom - minimal pill
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 90
      height: 28
      radius: 14
      visible: !root.adding
      color: addMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard
      Row {
        anchors.centerIn: parent
        spacing: 4

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 12
          height: 12
          kind: "plus"
          glyph: addMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "add"
          color: addMouse.containsMouse ? SettingsState.textMain : SettingsState.textSecondary
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }
      }

      MouseArea {
        id: addMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          root.adding = true;
        }
      }
    }
  }

  // Bottom margin for the height flow
  Item {
    anchors.top: aboutCol.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 14
  }
}
