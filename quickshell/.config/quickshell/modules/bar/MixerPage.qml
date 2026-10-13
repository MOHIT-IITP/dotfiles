import QtQuick
import "../services"

// Hardware mixer subview (control center). Thin wrapper over the shared
// MixerBody: back navigates to main, sound/mic icons open device pages.
MixerBody {
  required property var circle
  required property bool hovered

  showBack: true
  waveColor: "#e05f65"
  outVol: circle.outVol
  outMuted: circle.outMuted
  inVol: circle.inVol
  inMuted: circle.inMuted

  opacity: (hovered && circle.activePage === "mixer") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  onBack: circle.activePage = "main"
  onOpenSound: circle.activePage = "sound"
  onOpenMic: circle.activePage = "mic"
}
