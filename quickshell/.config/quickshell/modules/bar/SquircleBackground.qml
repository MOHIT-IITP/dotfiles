import QtQuick
import "../services"

// Renders a smooth superellipse (squircle) background and border with continuous curvature
// Supporting configurable corner radius (default 48px) and rounding power (default 4.0).
Canvas {
  id: canvas
  anchors.fill: parent
  renderStrategy: Canvas.Immediate
  antialiasing: true

  property real radius: SettingsState.cardRadius
  property real power: SettingsState.cardRoundingPower
  property color fillColor: SettingsState.bgCard
  property color strokeColor: SettingsState.barBorder
  property real strokeWidth: 1.0

  onRadiusChanged: requestPaint()
  onPowerChanged: requestPaint()
  onFillColorChanged: requestPaint()
  onStrokeColorChanged: requestPaint()
  onStrokeWidthChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  Connections {
    target: SettingsState
    function onBgCardChanged() { canvas.requestPaint(); }
    function onBgSurfaceChanged() { canvas.requestPaint(); }
    function onBarBorderChanged() { canvas.requestPaint(); }
    function onCardRadiusChanged() { canvas.requestPaint(); }
    function onCardRoundingPowerChanged() { canvas.requestPaint(); }
  }

  onPaint: {
    var ctx = getContext("2d");
    ctx.clearRect(0, 0, width, height);
    if (width <= 0 || height <= 0) return;

    var sw = (strokeWidth > 0 && strokeColor && strokeColor !== "transparent") ? strokeWidth : 0;
    var inset = sw > 0 ? (sw / 2) : 0;
    var w = width - inset * 2;
    var h = height - inset * 2;
    if (w <= 0 || h <= 0) return;

    var maxR = Math.min(w / 2, h / 2);
    var r = Math.min(Math.max(0, radius), maxR);
    var rx = r;
    var ry = r;

    // Smoothly blend rounding power from 2.0 (pure circular capsule at 34px) to full target power
    var blend = Math.min(1.0, Math.max(0.0, (h - 34) / 50.0));
    var targetP = Math.max(1.0, power);
    var p = 2.0 + (targetP - 2.0) * blend;
    var invP = 2.0 / p;
    var steps = 14;

    ctx.save();
    ctx.translate(inset, inset);

    ctx.beginPath();
    // Top edge
    ctx.moveTo(rx, 0);
    ctx.lineTo(w - rx, 0);

    // Top-Right corner (angle from pi/2 down to 0)
    for (var i = 0; i <= steps; i++) {
      var a = (Math.PI / 2) * (1.0 - i / steps);
      var ca = Math.pow(Math.cos(a), invP);
      var sa = Math.pow(Math.sin(a), invP);
      ctx.lineTo((w - rx) + rx * ca, ry - ry * sa);
    }

    // Right edge
    ctx.lineTo(w, h - ry);

    // Bottom-Right corner (angle from 0 to pi/2)
    for (var i = 0; i <= steps; i++) {
      var a = (Math.PI / 2) * (i / steps);
      var ca = Math.pow(Math.cos(a), invP);
      var sa = Math.pow(Math.sin(a), invP);
      ctx.lineTo((w - rx) + rx * ca, (h - ry) + ry * sa);
    }

    // Bottom edge
    ctx.lineTo(rx, h);

    // Bottom-Left corner (angle from pi/2 down to 0)
    for (var i = 0; i <= steps; i++) {
      var a = (Math.PI / 2) * (1.0 - i / steps);
      var ca = Math.pow(Math.cos(a), invP);
      var sa = Math.pow(Math.sin(a), invP);
      ctx.lineTo(rx - rx * ca, (h - ry) + ry * sa);
    }

    // Left edge
    ctx.lineTo(0, ry);

    // Top-Left corner (angle from 0 to pi/2)
    for (var i = 0; i <= steps; i++) {
      var a = (Math.PI / 2) * (i / steps);
      var ca = Math.pow(Math.cos(a), invP);
      var sa = Math.pow(Math.sin(a), invP);
      ctx.lineTo(rx - rx * ca, ry - ry * sa);
    }

    ctx.closePath();

    if (fillColor && fillColor !== "transparent") {
      ctx.fillStyle = fillColor;
      ctx.fill();
    }

    if (sw > 0 && strokeColor && strokeColor !== "transparent") {
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth = sw;
      ctx.stroke();
    }

    ctx.restore();
  }
}
