// Shared painter for the wavy slider style:
// straight muted track, sine-wave fill, accent vertical pill handle.
// Pure JS so both WavyStatSlider (display) and CCSlider (interactive)
// render identically.
function paint(ctx, W, H, o) {
  if (!ctx || W <= 0 || H <= 0)
    return;
  var shown = Math.max(0, Math.min(1, o.shown || 0));
  var trackH = o.trackH || 5;
  var waveW = o.waveW || 4.5;
  var waveAmp = (o.waveAmp !== undefined) ? o.waveAmp : 3;
  var waveLen = o.waveLen || 26;
  var handleW = o.handleW || 6;
  var handleH = o.handleH || 16;
  var showTrack = o.showTrack !== false;
  var showHandle = o.showHandle !== false;
  var showRemaining = o.showRemaining === true;

  ctx.clearRect(0, 0, W, H);
  ctx.lineJoin = "round";
  ctx.lineCap = "round";

  var pad = Math.max(showHandle ? handleW : 0, waveW) / 2 + 1;
  var cy = H / 2;
  var x0 = pad;
  var x1 = W - pad;
  var fx = x0 + (x1 - x0) * shown;
  var hx = Math.max(x0, Math.min(x1, fx));

  // 1. Unfilled track (full width)
  if (showTrack) {
    ctx.beginPath();
    ctx.strokeStyle = o.trackColor;
    ctx.lineWidth = trackH;
    ctx.moveTo(x0, cy);
    ctx.lineTo(x1, cy);
    ctx.stroke();
  }

  // 2. Wavy fill (stops at the handle's left edge so its round cap
  // tucks under the handle instead of painting over it;
  // runs the full value length when there is no handle)
  var waveEnd = showHandle ? hx - handleW / 2 + 1 : fx;
  if (shown > 0.005 && waveEnd > x0 + 1) {
    ctx.beginPath();
    ctx.strokeStyle = o.waveColor;
    ctx.lineWidth = waveW;
    var steps = Math.max(8, Math.floor((waveEnd - x0) / 3));
    for (var i = 0; i <= steps; ++i) {
      var x = x0 + (waveEnd - x0) * (i / steps);
      var y = cy + waveAmp * Math.sin((x - x0) / waveLen * Math.PI * 2);
      if (i === 0)
        ctx.moveTo(x, y);
      else
        ctx.lineTo(x, y);
    }
    ctx.stroke();
  }

  // 3. Faint thin line for the remaining (unfilled) stretch,
  // with a small gap after the filled wave
  if (showRemaining && shown < 0.995) {
    var gap = (o.remainingGap !== undefined) ? o.remainingGap : 5;
    var remStart = showHandle ? hx + handleW / 2 - 1 : waveEnd + gap;
    remStart = Math.max(remStart, x0);
    if (x1 - remStart > 1) {
      ctx.beginPath();
      ctx.strokeStyle = o.remainingColor;
      ctx.lineWidth = o.remainingW || 2;
      ctx.moveTo(remStart, cy);
      ctx.lineTo(x1, cy);
      ctx.stroke();
    }
  }

  // 4. Vertical pill handle (stadium path: straight sides + round ends)
  if (!showHandle)
    return;
  var px0 = hx - handleW / 2;
  var px1 = hx + handleW / 2;
  var py0 = cy - handleH / 2;
  var py1 = cy + handleH / 2;
  var r = handleW / 2;
  ctx.beginPath();
  ctx.fillStyle = o.handleColor;
  ctx.moveTo(px0 + r, py0);
  ctx.lineTo(px1 - r, py0);
  ctx.arc(px1 - r, py0 + r, r, -Math.PI / 2, 0);
  ctx.lineTo(px1, py1 - r);
  ctx.arc(px1 - r, py1 - r, r, 0, Math.PI / 2);
  ctx.lineTo(px0 + r, py1);
  ctx.arc(px0 + r, py1 - r, r, Math.PI / 2, Math.PI);
  ctx.lineTo(px0, py0 + r);
  ctx.arc(px0 + r, py0 + r, r, Math.PI, Math.PI * 1.5);
  ctx.closePath();
  ctx.fill();
}

// Vertical variant for mixer faders: straight muted track,
// sine-wave fill rising from the bottom, horizontal accent pill handle.
function paintVertical(ctx, W, H, o) {
  if (!ctx || W <= 0 || H <= 0)
    return;
  var shown = Math.max(0, Math.min(1, o.shown || 0));
  var trackW = o.trackW || 5;
  var waveW = o.waveW || 4.5;
  var waveAmp = (o.waveAmp !== undefined) ? o.waveAmp : 3;
  var waveLen = o.waveLen || 26;
  var handleW = o.handleW || 16;
  var handleH = o.handleH || 6;

  ctx.clearRect(0, 0, W, H);
  ctx.lineJoin = "round";
  ctx.lineCap = "round";

  var cx = W / 2;
  var padV = Math.max(handleH, waveW) / 2 + 1;
  var y0 = H - padV; // bottom (0%)
  var y1 = padV;     // top (100%)
  var fy = y0 - (y0 - y1) * shown;
  var hy = Math.max(y1, Math.min(y0, fy));

  // 1. Unfilled track (full height)
  ctx.beginPath();
  ctx.strokeStyle = o.trackColor;
  ctx.lineWidth = trackW;
  ctx.moveTo(cx, y0);
  ctx.lineTo(cx, y1);
  ctx.stroke();

  // 2. Wavy fill (bottom -> handle's bottom edge, tucks under the handle)
  var waveEnd = hy + handleH / 2 - 1;
  if (shown > 0.005 && (y0 - waveEnd) > 1) {
    ctx.beginPath();
    ctx.strokeStyle = o.waveColor;
    ctx.lineWidth = waveW;
    var steps = Math.max(8, Math.floor((y0 - waveEnd) / 3));
    for (var i = 0; i <= steps; ++i) {
      var y = y0 - (y0 - waveEnd) * (i / steps);
      var x = cx + waveAmp * Math.sin((y0 - y) / waveLen * Math.PI * 2);
      if (i === 0)
        ctx.moveTo(x, y);
      else
        ctx.lineTo(x, y);
    }
    ctx.stroke();
  }

  // 3. Horizontal pill handle (stadium path: straight top/bottom + round ends)
  var px0 = cx - handleW / 2;
  var px1 = cx + handleW / 2;
  var py0 = hy - handleH / 2;
  var py1 = hy + handleH / 2;
  var r = handleH / 2;
  ctx.beginPath();
  ctx.fillStyle = o.handleColor;
  ctx.moveTo(px0 + r, py0);
  ctx.lineTo(px1 - r, py0);
  ctx.arc(px1 - r, py0 + r, r, -Math.PI / 2, Math.PI / 2);
  ctx.lineTo(px0 + r, py1);
  ctx.arc(px0 + r, py1 - r, r, Math.PI / 2, Math.PI * 1.5);
  ctx.closePath();
  ctx.fill();
}
