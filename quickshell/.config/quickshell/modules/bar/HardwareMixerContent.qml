import QtQuick
import "../services"

// Embedded Hardware Mixer subview directly inside ClockPill.
// Thin wrapper over the shared MixerBody: no back button (Esc closes),
// sound/mic icons forwarded as signals for the center bar to open pages.
Item {
  id: root

  signal openSoundSettings
  signal openMicSettings

  implicitWidth: 440
  implicitHeight: 363

  function forceFocus() {
    keyArea.focus = true;
    keyArea.forceActiveFocus();
  }

  Connections {
    target: MixerState
    function onOpenChanged() {
      if (MixerState.open) {
        forceFocus();
        focusTimer.restart();
      }
    }
  }

  Timer {
    id: focusTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (keyArea.activeFocus || count > 8) {
        running = false;
      }
    }
  }

  Item {
    id: keyArea
    anchors.fill: parent
    focus: true

    Keys.onEscapePressed: function (ev) {
      MixerState.close();
      ev.accepted = true;
    }
  }

  MixerBody {
    anchors.fill: parent
    anchors.margins: 16
    showBack: true
    waveColor: "#e05f65"
    outVol: AudioState.outVol
    outMuted: AudioState.outMuted
    inVol: AudioState.inVol
    inMuted: AudioState.inMuted
    onBack: MixerState.close()
    onOpenSound: root.openSoundSettings()
    onOpenMic: root.openMicSettings()
  }
}
