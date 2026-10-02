pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Shared media state: tracks truly active and playing players,
// filtering out idle/stopped browsers or stub players with no track title.
Singleton {
  id: root

  function isProxy(p) {
    return (p && p.dbusName ? p.dbusName : "").toLowerCase().indexOf("playerctld") >= 0;
  }

  function isIdle(p) {
    if (!p || isProxy(p))
      return true;
    var title = (p.trackTitle ?? "").trim();
    // A player is idle if it is not playing and has no valid track title
    if (!p.isPlaying && title.length === 0)
      return true;
    // Browsers when all media tabs are closed often report Stopped with no title
    if (p.playbackState === MprisPlaybackState.Stopped && title.length === 0)
      return true;
    return false;
  }

  readonly property var activePlayer: {
    var ps = (Mpris.players) ? Mpris.players.values : [];
    var fallback = null;
    for (var i = 0; i < ps.length; ++i) {
      var p = ps[i];
      if (!p || isIdle(p))
        continue;
      if (p.isPlaying)
        return p;
      if (!fallback && (p.trackTitle ?? "").trim().length > 0)
        fallback = p;
      if (!fallback)
        fallback = p;
    }
    return fallback;
  }

  readonly property bool hasPlayer: activePlayer !== null && activePlayer !== undefined
  readonly property bool hasTrack: hasPlayer && !isIdle(activePlayer) && ((activePlayer.trackTitle ?? "").trim() !== "")
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
