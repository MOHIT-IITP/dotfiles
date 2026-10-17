pragma Singleton

import Quickshell
import QtQuick

// Shared hover anchor for the Ame bead (red-dot follower + launcher caret).
// Hover sources never position the bead directly: they just park an anchor
// item here (sticky, like the pill bar's soulTarget — written on enter, never
// cleared on exit). ClockPill maps the anchor into its own coords live, so
// the bead glides between icons and tracks slider handles while they move.
// The launcher parks the text cursor instead (caret form, absolute point
// inside the search field, like the pill bar's ameForm/amePoint).
Singleton {
  id: root

  // Item the bead currently parks on (null = hidden). fx/fy is the target
  // point as a fraction of the anchor's size. form is "soul" (icons, dot
  // below the control), "tick" (sliders, flat marker on the handle),
  // "rowseam" (settings rows, vertical seam on the row's left edge) or
  // "caret" (launcher search field, blinking capsule on the text cursor).
  // Caret uses absolute px/py inside the anchor (cursorRectangle center),
  // because a text cursor is a pixel offset, not a fraction of the field.
  // Rowseam ignores fx/fy: ClockPill maps the anchor's left-edge center
  // (like the pill bar's SettingsSurface rowPoint).
  property var anchor: null
  property real fx: 0.5
  property real fy: 1.0
  property real px: 0
  property real py: 0
  property bool useAbsolute: false
  property string form: "soul"

  // Park below an icon / button (anchor bottom-center).
  function follow(item) {
    if (!item)
      return;
    anchor = item;
    fx = 0.5;
    fy = 1.0;
    useAbsolute = false;
    form = "soul";
  }

  // Park on the launcher text cursor (absolute point inside the field,
  // typically the cursorRectangle center mapped from the search input).
  function followCaret(item, x, y) {
    if (!item)
      return;
    anchor = item;
    px = x;
    py = y;
    useAbsolute = true;
    form = "caret";
  }

  // Park on a horizontal slider handle (frac 0..1 across the track).
  function followTickH(track, frac) {
    if (!track)
      return;
    anchor = track;
    fx = Math.max(0, Math.min(1, frac));
    fy = 0.5;
    useAbsolute = false;
    form = "tick";
  }

  // Park on a vertical fader handle (frac 0..1, 1 = top).
  function followTickV(track, frac) {
    if (!track)
      return;
    anchor = track;
    fx = 0.5;
    fy = 1.0 - Math.max(0, Math.min(1, frac));
    useAbsolute = false;
    form = "tick";
  }

  // Park a vertical seam on a settings row's left edge (absolute mapping
  // in ClockPill, like the pill bar's SettingsSurface rowseam).
  function followRow(item) {
    if (!item)
      return;
    anchor = item;
    fx = 0;
    fy = 0.5;
    useAbsolute = false;
    form = "rowseam";
  }

  function clear() {
    anchor = null;
    useAbsolute = false;
    form = "soul";
  }
}
