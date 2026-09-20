pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

// Shared audio state: default sink (sound) + source (microphone) + device management.
// Nodes stay bound via PwObjectTracker for reactive volume/mute.
Singleton {
  id: root

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
  }

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource

  readonly property real outVol: (sink && sink.audio) ? Math.min(1, Math.max(0, sink.audio.volume)) : 0
  readonly property bool outMuted: (sink && sink.audio) ? sink.audio.muted : false

  readonly property real inVol: (source && source.audio) ? Math.min(1, Math.max(0, source.audio.volume)) : 0
  readonly property bool inMuted: (source && source.audio) ? source.audio.muted : false

  property var sinks: []
  property var sources: []

  property string _rawSinkData: ""
  property string _rawSourceData: ""

  readonly property string sinkName: {
    if (sink) {
      return sink.description || sink.nickname || sink.name || "Default Speaker";
    }
    return "Default Speaker";
  }

  readonly property string sourceName: {
    if (source) {
      return source.description || source.nickname || source.name || "Default Mic";
    }
    return "Default Mic";
  }

  function setOutVol(v) {
    if (sink && sink.audio)
      sink.audio.volume = Math.min(1, Math.max(0, v));
  }
  function setInVol(v) {
    if (source && source.audio)
      source.audio.volume = Math.min(1, Math.max(0, v));
  }
  function toggleOutMute() {
    if (sink && sink.audio)
      sink.audio.muted = !sink.audio.muted;
  }
  function toggleInMute() {
    if (source && source.audio)
      source.audio.muted = !source.audio.muted;
  }

  function refreshDevices() {
    _rawSinkData = "";
    _rawSourceData = "";
    if (sinkProc.running) sinkProc.running = false;
    if (sourceProc.running) sourceProc.running = false;
    sinkProc.running = true;
    sourceProc.running = true;
  }

  function setDefaultSink(dev) {
    var target = (dev && dev.id) ? ("" + dev.id) : ((dev && dev.name) ? dev.name : "");
    if (target) {
      setSinkProc.command = ["bash", "/home/mohiitp/.config/quickshell/scripts/audio_devices.sh", "set-sink", target];
      setSinkProc.running = true;
    }
  }

  function setDefaultSource(dev) {
    var target = (dev && dev.id) ? ("" + dev.id) : ((dev && dev.name) ? dev.name : "");
    if (target) {
      setSourceProc.command = ["bash", "/home/mohiitp/.config/quickshell/scripts/audio_devices.sh", "set-source", target];
      setSourceProc.running = true;
    }
  }

  Process {
    id: sinkProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/audio_devices.sh", "sinks"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        root._rawSinkData += data;
      }
    }

    onExited: function (code, status) {
      try {
        var parsed = JSON.parse(root._rawSinkData.trim());
        if (Array.isArray(parsed)) {
          root.sinks = parsed;
        }
      } catch (e) {}
      root._rawSinkData = "";
    }
  }

  Process {
    id: sourceProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/audio_devices.sh", "sources"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        root._rawSourceData += data;
      }
    }

    onExited: function (code, status) {
      try {
        var parsed = JSON.parse(root._rawSourceData.trim());
        if (Array.isArray(parsed)) {
          root.sources = parsed;
        }
      } catch (e) {}
      root._rawSourceData = "";
    }
  }

  Process {
    id: setSinkProc
    running: false
    onExited: function (code, status) {
      root.refreshDevices();
    }
  }

  Process {
    id: setSourceProc
    running: false
    onExited: function (code, status) {
      root.refreshDevices();
    }
  }

  Component.onCompleted: {
    refreshDevices();
  }
}
