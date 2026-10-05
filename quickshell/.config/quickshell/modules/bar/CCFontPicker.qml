import Quickshell
import QtQuick
import "../services"

// Font family picker: trigger + searchable dropdown list.
// Extracted from SettingsPage.qml.
Column {
  id: fontPickerCol
  required property var circle
  spacing: 2

  // Called after the window keyboard grab activates (see Bar.qml),
  // otherwise the focus request races the layershell focus switch.
  // Retries like LauncherContent.focusRetryTimer until input holds focus.
  function forceSearchFocus() {
    if (!circle.fontDropdownOpen || !fSearchInput) return;
    fSearchInput.focus = true;
    fSearchInput.forceActiveFocus();
    fontFocusRetry.restart();
  }

  Timer {
    id: fontFocusRetry
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      if (circle.fontDropdownOpen && fSearchInput) {
        fSearchInput.focus = true;
        fSearchInput.forceActiveFocus();
      }
      if ((fSearchInput && fSearchInput.activeFocus) || !circle.fontDropdownOpen || count > 20) {
        running = false;
      }
    }
  }
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
        font.pixelSize: SettingsState.px(15)
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
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
          width: Math.min(implicitWidth, 140)
        }

        Text {
          text: circle.fontDropdownOpen ? "\ueab7" : "\ueab6"
          color: SettingsState.textSecondary
          font.family: SettingsState.nerdIconFont
          font.pixelSize: SettingsState.px(13)
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
            fontPickerCol.forceSearchFocus();
          } else {
            fontFocusRetry.running = false;
          }
        }
      }
    }
  }

  // 8b. Font size: slider (-5px .. +5px) with - / + steppers
  Column {
    width: parent.width
    spacing: 4

    Item {
      width: parent.width
      height: 24

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
          text: "Font size"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(15)
          font.family: SettingsState.fontFamily
        }
      }

      Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        width: fontSizeValText.implicitWidth + 12
        radius: 6
        color: SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: 1

        Text {
          id: fontSizeValText
          anchors.centerIn: parent
          text: (SettingsState.fontSizeDelta > 0 ? "+" + SettingsState.fontSizeDelta : "" + SettingsState.fontSizeDelta) + "px"
          color: SettingsState.accent
          font.pixelSize: SettingsState.px(13)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: SettingsState.resetFontSize()
        }
      }
    }

    // Stepper + slider row
    Row {
      width: parent.width
      height: 26
      spacing: 8

      // -1px stepper
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: 8
        color: fontMinusMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgCard
        border.color: fontMinusMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: "\ueacc"
          color: fontMinusMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(16)
          font.bold: true
          font.family: SettingsState.nerdIconFont
        }

        MouseArea {
          id: fontMinusMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: SettingsState.adjustFontSize(-1)
        }
      }

      // Slider track (-5 .. +5 mapped to 0 .. 1)
      Rectangle {
        id: fontSizeTrack
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 26 * 2 - 16
        height: 10
        radius: 5
        color: SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: 1

        // Filled portion
        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: Math.max(8, Math.min(parent.width, ((SettingsState.fontSizeDelta + 5) / 10.0) * parent.width))
          radius: 5
          color: SettingsState.accent
        }

        // Draggable thumb
        Rectangle {
          id: fontSizeThumb
          width: 16
          height: 16
          radius: 8
          anchors.verticalCenter: parent.verticalCenter
          x: Math.max(0, Math.min(fontSizeTrack.width - width, ((SettingsState.fontSizeDelta + 5) / 10.0) * (fontSizeTrack.width - width)))
          color: SettingsState.accent
          border.color: "#ffffff"
          border.width: 2

          Behavior on x {
            enabled: !fontSizeMouse.pressed
            NumberAnimation { duration: 80 }
          }
        }

        MouseArea {
          id: fontSizeMouse
          anchors.fill: parent
          anchors.margins: -6
          cursorShape: Qt.PointingHandCursor
          onPressed: function(ev) {
            var r = Math.min(1.0, Math.max(0.0, ev.x / fontSizeTrack.width));
            SettingsState.setFontSizeDelta(Math.round(r * 10 - 5));
          }
          onPositionChanged: function(ev) {
            if (pressed) {
              var r = Math.min(1.0, Math.max(0.0, ev.x / fontSizeTrack.width));
              SettingsState.setFontSizeDelta(Math.round(r * 10 - 5));
            }
          }
        }
      }

      // +1px stepper
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: 8
        color: fontPlusMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgCard
        border.color: fontPlusMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: "\uea60"
          color: fontPlusMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(16)
          font.bold: true
          font.family: SettingsState.nerdIconFont
        }

        MouseArea {
          id: fontPlusMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: SettingsState.adjustFontSize(1)
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
          text: "\uea6d"
          color: SettingsState.textMuted
          font.pixelSize: SettingsState.px(14)
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
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
          }

          TextInput {
            id: fSearchInput
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            clip: true
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
          text: "\uea76"
            font.family: SettingsState.nerdIconFont
          color: SettingsState.textMuted
          font.pixelSize: SettingsState.px(13)
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
      height: 120
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
            font.pixelSize: SettingsState.px(13)
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
