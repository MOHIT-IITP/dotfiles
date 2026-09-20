pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Shared media state: picks the playing player,
// else the last active one.
Singleton {
  readonly property var activePlayer: {
    var ps = (Mpris.players) ? Mpris.players.values : [];
    var fallback = null;
    for (var i = 0; i < ps.length; ++i) {
      var p = ps[i];
      if (!p)
        continue;
      if (p.isPlaying)
        return p;
      if (!fallback && p.trackTitle)
        fallback = p;
      if (!fallback)
        fallback = p;
    }
    return fallback;
  }

  readonly property bool hasPlayer: activePlayer !== null && activePlayer !== undefined
  readonly property bool isPlaying: hasPlayer && activePlayer.isPlaying

  // Keep position flowing while playing (per MprisPlayer docs)
  FrameAnimation {
    running: isPlaying
    onTriggered: {
      if (activePlayer)
        activePlayer.positionChanged();
    }
  }
}
