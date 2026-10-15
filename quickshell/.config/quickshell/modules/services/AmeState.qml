pragma Singleton

import Quickshell
import QtQuick

// Shared hover anchor for the Ame bead (red-dot follower).
// Hover sources never position the bead directly: they just park an anchor
// item here (sticky, like the pill bar's soulTarget — written on enter, never
// cleared on exit). ClockPill maps the anchor into its own coords live, so
// the bead glides between icons and tracks slider handles while they move.
Singleton {
  id: root

  // Item the bead currently parks on (null = hidden). fx/fy is the target
  // point as a fraction of the anchor's size. form is "soul" (icons, dot
  // below the control) or "tick" (sliders, flat marker on the handle).
  property var anchor: null
  property real fx: 0.5
  property real fy: 1.0
  property string form: "soul"

  // Park below an icon / button (anchor bottom-center).
  function follow(item) {
    if (!item)
      return;
    anchor = item;
    fx = 0.5;
    fy = 1.0;
    form = "soul";
  }

  // Park on a horizontal slider handle (frac 0..1 across the track).
  function followTickH(track, frac) {
    if (!track)
      return;
    anchor = track;
    fx = Math.max(0, Math.min(1, frac));
    fy = 0.5;
    form = "tick";
  }

  // Park on a vertical fader handle (frac 0..1, 1 = top).
  function followTickV(track, frac) {
    if (!track)
      return;
    anchor = track;
    fx = 0.5;
    fy = 1.0 - Math.max(0, Math.min(1, frac));
    form = "tick";
  }

  function clear() {
    anchor = null;
    form = "soul";
  }
}
