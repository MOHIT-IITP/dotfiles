import QtQuick
import "../services"

// Interactive center-bar reminder prompt (triggered via Mod+R / IPC).
// Step 1: Input with placeholder "remind in minutes" + Circular Accent Next button (→)
// Step 2: [ ← 10m ] tag + Title input "Reminder note..." + Circular Accent Finish button (✓)
Item {
  id: root

  implicitWidth: 240
  implicitHeight: 52

  property int step: 1
  property int enteredMins: 10

  function forceFocus() {
    if (step === 1) {
      minsInput.focus = true;
      minsInput.forceActiveFocus();
      minsInput.selectAll();
    } else {
      titleInput.focus = true;
      titleInput.forceActiveFocus();
      titleInput.selectAll();
    }
  }

  function goToStep2() {
    var raw = minsInput.text.trim();
    var m = parseInt(raw, 10);
    if (isNaN(m) || m <= 0) m = 10;
    m = Math.min(1440, Math.max(1, m));
    enteredMins = m;
    step = 2;
    focusRetryTimer.restart();
  }

  function goToStep1() {
    step = 1;
    focusRetryTimer.restart();
  }

  function submit() {
    var title = titleInput.text.trim();
    if (!title) title = "Reminder";
    ReminderState.addReminder(title, enteredMins);
    ReminderState.closePrompt();
  }

  function syncActiveCaret() {
    if (!ReminderState.promptOpen)
      return;
    if (root.step === 1)
      minsInput.syncCaret();
    else
      titleInput.syncCaret();
  }

  Connections {
    target: ReminderState
    function onPromptOpenChanged() {
      if (ReminderState.promptOpen) {
        step = 1;
        enteredMins = 10;
        minsInput.text = "";
        titleInput.text = "";
        focusRetryTimer.restart();
        Qt.callLater(root.syncActiveCaret);
      }
    }
  }

  Timer {
    id: focusRetryTimer
    interval: 35
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      root.forceFocus();
      var focused = (root.step === 1) ? minsInput.activeFocus : titleInput.activeFocus;
      if (focused || count > 8) {
        running = false;
        Qt.callLater(root.syncActiveCaret);
      }
    }
  }

  onStepChanged: Qt.callLater(root.syncActiveCaret)

  // ==========================================
  // STEP 1: TIME SELECTION ("remind in minutes" + Circular → button)
  // ==========================================
  Item {
    id: step1View
    anchors.fill: parent
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    opacity: root.step === 1 ? 1 : 0
    visible: opacity > 0
    enabled: root.step === 1

    Behavior on opacity {
      NumberAnimation { duration: 150 }
    }

    Row {
      anchors.centerIn: parent
      spacing: 8
      width: parent.width

      // Minutes input box with placeholder
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        height: 34
        width: parent.width - 34 - 8
        radius: 10
        color: SettingsState.bgSurface

        Item {
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          clip: true

          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: "remind in minutes"
            color: SettingsState.textSecondary
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
            visible: !minsInput.text && !minsInput.inputMethodComposing
            opacity: 0.65
          }

          TextInput {
            id: minsInput
            anchors.fill: parent
            clip: true
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 1; top: 1440 }
            selectByMouse: true
            selectionColor: SettingsState.accent
            cursorVisible: true
            // Custom blinking block cursor, same as launcher search field:
            // 2px accent bar blinking at 530ms while focused.
            cursorDelegate: Item {
              width: 2
              height: parent.height
              property bool blinkOn: true
              Timer {
                interval: 530
                repeat: true
                running: minsInput.activeFocus
                onTriggered: parent.blinkOn = !parent.blinkOn
              }
              Rectangle {
                anchors.fill: parent
                color: SettingsState.accent
                opacity: parent.blinkOn ? 1 : 0
              }
            }

            // Ame "caret" follower, same as launcher: park the molten bead
            // exactly on the text cursor so typing glides the bead along.
            function syncCaret() {
              if (!ReminderState.promptOpen || root.step !== 1 || !minsInput.activeFocus)
                return;
              try {
                AmeState.followCaret(minsInput, minsInput.cursorRectangle.x + minsInput.cursorRectangle.width / 2, minsInput.cursorRectangle.y + minsInput.cursorRectangle.height / 2);
              } catch (e) {}
            }
            onCursorRectangleChanged: minsInput.syncCaret()
            onActiveFocusChanged: {
              if (activeFocus)
                minsInput.syncCaret();
            }
            onTextChanged: minsInput.syncCaret()

            Keys.onReturnPressed: function(ev) {
              root.goToStep2();
              ev.accepted = true;
            }
            Keys.onEnterPressed: function(ev) {
              root.goToStep2();
              ev.accepted = true;
            }
            Keys.onEscapePressed: function(ev) {
              ReminderState.closePrompt();
              ev.accepted = true;
            }
            Keys.onTabPressed: function(ev) {
              root.goToStep2();
              ev.accepted = true;
            }
          }
        }
      }

      // Circular Next button (with theme accent color)
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: nextMouse.containsMouse ? Qt.darker(SettingsState.accent, 1.15) : SettingsState.accent

        Behavior on color { ColorAnimation { duration: 120 } }

        CCIcon {
          anchors.centerIn: parent
          width: 16
          height: 16
          kind: "arrow-right"
          glyph: SettingsState.isDark ? "#121612" : "#ffffff"
        }

        MouseArea {
          id: nextMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.goToStep2()
        }
      }
    }
  }

  // ==========================================
  // STEP 2: TITLE / MESSAGE INPUT
  // ==========================================
  Item {
    id: step2View
    anchors.fill: parent
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    opacity: root.step === 2 ? 1 : 0
    visible: opacity > 0
    enabled: root.step === 2

    Behavior on opacity {
      NumberAnimation { duration: 150 }
    }

    Row {
      anchors.centerIn: parent
      spacing: 8
      width: parent.width

      // Time tag circle (clickable to jump back to step 1)
      Rectangle {
        id: timeTagBox
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: backMouse.containsMouse ? Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.25) : Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.15)
        border.color: Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.4)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          id: timeTagText
          anchors.centerIn: parent
          text: root.enteredMins + "m"
          color: SettingsState.accent
          font.pixelSize: SettingsState.px(12)
          font.bold: true
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: backMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.goToStep1()
        }
      }

      // Title input box
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        height: 34
        width: parent.width - 34 - 34 - 16
        radius: 10
        color: SettingsState.bgSurface

        Item {
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          clip: true

          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: "Reminder note..."
            color: SettingsState.textSecondary
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
            visible: !titleInput.text && !titleInput.inputMethodComposing
            opacity: 0.65
          }

          TextInput {
            id: titleInput
            anchors.fill: parent
            clip: true
            verticalAlignment: TextInput.AlignVCenter
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
            selectByMouse: true
            selectionColor: SettingsState.accent
            cursorVisible: true
            // Custom blinking block cursor, same as launcher search field.
            cursorDelegate: Item {
              width: 2
              height: parent.height
              property bool blinkOn: true
              Timer {
                interval: 530
                repeat: true
                running: titleInput.activeFocus
                onTriggered: parent.blinkOn = !parent.blinkOn
              }
              Rectangle {
                anchors.fill: parent
                color: SettingsState.accent
                opacity: parent.blinkOn ? 1 : 0
              }
            }

            // Ame "caret" follower, same as launcher.
            function syncCaret() {
              if (!ReminderState.promptOpen || root.step !== 2 || !titleInput.activeFocus)
                return;
              try {
                AmeState.followCaret(titleInput, titleInput.cursorRectangle.x + titleInput.cursorRectangle.width / 2, titleInput.cursorRectangle.y + titleInput.cursorRectangle.height / 2);
              } catch (e) {}
            }
            onCursorRectangleChanged: titleInput.syncCaret()
            onActiveFocusChanged: {
              if (activeFocus)
                titleInput.syncCaret();
            }
            onTextChanged: titleInput.syncCaret()

            Keys.onReturnPressed: function(ev) {
              root.submit();
              ev.accepted = true;
            }
            Keys.onEnterPressed: function(ev) {
              root.submit();
              ev.accepted = true;
            }
            Keys.onEscapePressed: function(ev) {
              ReminderState.closePrompt();
              ev.accepted = true;
            }
            Keys.onBacktabPressed: function(ev) {
              root.goToStep1();
              ev.accepted = true;
            }
          }
        }
      }

      // Submit / Finish button (circular accent tick button)
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: confirmMouse.containsMouse ? Qt.darker(SettingsState.accent, 1.15) : SettingsState.accent

        Behavior on color { ColorAnimation { duration: 120 } }

        CCIcon {
          anchors.centerIn: parent
          width: 16
          height: 16
          kind: "check"
          glyph: SettingsState.isDark ? "#121612" : "#ffffff"
        }

        MouseArea {
          id: confirmMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.submit()
        }
      }
    }
  }
}
