import Quickshell
import QtQuick
import "../services"

// Font family picker: trigger + searchable dropdown list.
// Extracted from SettingsPage.qml.
Column {
  required property var circle
  // 8. Font family dropdown trigger
  Item {
    width: parent.width
    height: 30

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      CCIcon {
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        kind: "font"
        glyph: SettingsState.textSecondary
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Font"
        color: SettingsState.textMain
        font.pixelSize: 15
        font.family: SettingsState.fontFamily
      }
    }

    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 26
      width: Math.min(180, fontDropText.implicitWidth + 28)
      radius: 8
      color: circle.fontDropdownOpen ? SettingsState.bgActivePill : (fontBtnMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: circle.fontDropdownOpen ? SettingsState.borderActive : SettingsState.borderBase
      border.width: 1

      Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
          id: fontDropText
          text: SettingsState.fontFamily
          color: circle.fontDropdownOpen ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: 13
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
          width: Math.min(implicitWidth, 140)
        }

        Text {
          text: circle.fontDropdownOpen ? "\uf077" : "\uf054"
          color: SettingsState.textSecondary
          font.family: SettingsState.nerdIconFont
          font.pixelSize: 13
          font.bold: true
        }
      }

      MouseArea {
        id: fontBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.fontDropdownOpen = !circle.fontDropdownOpen;
          if (circle.fontDropdownOpen) {
            circle.fontSearchQuery = "";
            if (fSearchInput) {
              fSearchInput.text = "";
            }
            Qt.callLater(function() {
              if (fSearchInput) fSearchInput.forceActiveFocus();
            });
          }
        }
      }
    }
  }

  // Dropdown expanded content (Search + Font List)
  Column {
    width: parent.width
    spacing: 8
    visible: circle.fontDropdownOpen

    // Search box
    Rectangle {
      width: parent.width
      height: 32
      radius: 8
      color: SettingsState.bgCard
      border.color: fSearchInput.activeFocus ? SettingsState.borderActive : SettingsState.borderBase
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: ""
          color: SettingsState.textMuted
          font.pixelSize: 14
          font.family: SettingsState.nerdIconFont
        }

        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 48
          height: parent.height

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: fSearchInput.text.length === 0
            text: "Search " + SettingsState.availableFonts.length + " fonts..."
            color: SettingsState.textMuted
            font.pixelSize: 13
            font.family: SettingsState.fontFamily
          }

          TextInput {
            id: fSearchInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
            font.pixelSize: 14
            font.family: SettingsState.fontFamily
            clip: true
            focus: true
            activeFocusOnTab: true
            selectByMouse: true
            onTextChanged: {
              circle.fontSearchQuery = text;
            }
            Keys.onEscapePressed: function(ev) {
              circle.fontDropdownOpen = false;
              ev.accepted = true;
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: fSearchInput.text.length > 0
          text: "✕"
            font.family: SettingsState.nerdIconFont
          color: SettingsState.textMuted
          font.pixelSize: 13
          MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              fSearchInput.text = "";
              fSearchInput.forceActiveFocus();
            }
          }
        }
      }
    }

    // Scrollable Font list with preview
    ListView {
      width: parent.width
      height: 180
      spacing: 4
      clip: true
      model: circle.filteredFonts

      delegate: Rectangle {
        width: ListView.view.width
        height: 32
        radius: 8
        color: SettingsState.fontFamily === modelData ? SettingsState.bgActivePill : (fItemMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
        border.color: SettingsState.fontFamily === modelData ? SettingsState.borderActive : "transparent"
        border.width: 1

        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          Rectangle {
            width: 6
            height: 6
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: SettingsState.fontFamily === modelData ? SettingsState.accent : SettingsState.textMuted
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: modelData
            color: SettingsState.fontFamily === modelData ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: 13
            font.bold: SettingsState.fontFamily === modelData
            font.family: modelData
            elide: Text.ElideRight
          }
        }

        MouseArea {
          id: fItemMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            SettingsState.setFont(modelData);
          }
        }
      }
    }
  }
}
