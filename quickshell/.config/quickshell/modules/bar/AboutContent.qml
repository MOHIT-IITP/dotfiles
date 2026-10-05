import Quickshell
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

    // Header
    Item {
      width: parent.width
      height: 32

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Rectangle {
          width: 28
          height: 28
          radius: 14
          color: aboutCloseMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
          anchors.verticalCenter: parent.verticalCenter

          Text {
            anchors.centerIn: parent
            text: "\ueab5"
            font.family: SettingsState.nerdIconFont
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(20)
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
          width: 18
          height: 18
          kind: "about"
          glyph: SettingsState.accent
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "ABOUT"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: true
          font.family: SettingsState.fontFamily
          font.letterSpacing: 1.2
        }
      }

      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: (AboutState.links ? AboutState.links.length : 0) + " links"
        color: SettingsState.textMuted
        font.pixelSize: SettingsState.px(11)
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

    // Links list (taller view — fits ~6 entries before scrolling)
    ListView {
      width: parent.width
      height: (!AboutState.links || AboutState.links.length === 0) ? 0 : Math.min(420, AboutState.links.length * 70)
      spacing: 8
      clip: true
      visible: AboutState.links && AboutState.links.length > 0
      model: AboutState.links

      delegate: Rectangle {
        required property var modelData
        required property int index
        width: ListView.view.width
        height: 62
        radius: 14
        color: aboutRowMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard

        // Dashed outline (matches the hand-drawn sketch)
        Canvas {
          anchors.fill: parent
          antialiasing: true
          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()
          property bool hov: aboutRowMouse.containsMouse
          onHovChanged: requestPaint()
          onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            var r = 14;
            var pad = 1;
            var x = pad, y = pad, w = width - pad * 2, h = height - pad * 2;
            ctx.beginPath();
            ctx.moveTo(x + r, y);
            ctx.lineTo(x + w - r, y);
            ctx.arcTo(x + w, y, x + w, y + r, r);
            ctx.lineTo(x + w, y + h - r);
            ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
            ctx.lineTo(x + r, y + h);
            ctx.arcTo(x, y + h, x, y + h - r, r);
            ctx.lineTo(x, y + r);
            ctx.arcTo(x, y, x + r, y, r);
            ctx.closePath();
            try { ctx.setLineDash([7, 5]); } catch (e) {}
            ctx.lineWidth = 1.4;
            ctx.strokeStyle = aboutRowMouse.containsMouse ? SettingsState.borderActive.toString() : SettingsState.textMuted.toString();
            ctx.stroke();
          }
        }

        Row {
          anchors.fill: parent
          anchors.margins: 8
          spacing: 10
          // Must sit above the row-wide aboutRowMouse below (sibling
          // stacking wins over grandchild z), else row MouseArea eats clicks.
          z: 1

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: 11
            color: aboutRowMouse.containsMouse ? SettingsState.accent : SettingsState.bgSurface

            CCIcon {
              anchors.centerIn: parent
              width: 20
              height: 20
              kind: AboutState.iconFor(modelData)
              glyph: aboutRowMouse.containsMouse ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
            }
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40 - 10 - 64
            spacing: 3

            Text {
              width: parent.width
              text: (modelData && modelData.label) ? modelData.label : ""
              color: SettingsState.textMuted
              font.pixelSize: SettingsState.px(13)
              font.bold: true
              font.family: SettingsState.fontFamily
              font.capitalization: Font.AllUppercase
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              text: (modelData && modelData.value) ? modelData.value : ""
              color: aboutRowMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain
              font.pixelSize: SettingsState.px(15)
              font.bold: true
              font.family: SettingsState.fontFamily
              elide: Text.ElideRight
              maximumLineCount: 1
            }
          }

          // copy button
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            radius: 13
            // Above the row-wide aboutRowMouse below, else it eats button clicks
            z: 2
            color: copyMouse.containsMouse ? SettingsState.bgActivePill : "transparent"

            CCIcon {
              anchors.centerIn: parent
              width: 13
              height: 13
              kind: "copy"
              glyph: SettingsState.textSecondary
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

          // delete button
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            radius: 13
            // Above the row-wide aboutRowMouse below, else it eats button clicks
            z: 2
            color: delMouse.containsMouse ? "#3a1e1e" : "transparent"

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

    // + add button at the bottom (per sketch)
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 130
      height: 36
      radius: 12
      visible: !root.adding
      color: addMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgCard
      border.color: addMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase
      border.width: 1
      Row {
        anchors.centerIn: parent
        spacing: 6

        CCIcon {
          anchors.verticalCenter: parent.verticalCenter
          width: 14
          height: 14
          kind: "plus"
          glyph: addMouse.containsMouse ? SettingsState.textActive : SettingsState.textSecondary
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "add"
          color: addMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.bold: true
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
