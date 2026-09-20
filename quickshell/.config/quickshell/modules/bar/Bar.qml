import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "../services"

// Top bar: centered clock pill with media player on the left
// and network circle on the right, plus notification toasts.
Scope {
  Variants {
    model: Quickshell.screens

    delegate: Scope {
      required property var modelData

      PanelWindow {
        id: barWindow
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        margins {
          top: Math.round(8 * SettingsState.uiScale)
        }

        // Tall enough for the expanded control center, launcher, and wallpaper coverflow;
        // transparent + masked so empty area is click-through.
        implicitHeight: Math.round(960 * SettingsState.uiScale)
        color: "transparent"
        // Reserve a strip so maximized/tiled windows sit below
        // the bar instead of underneath it.
        exclusiveZone: Math.round(44 * SettingsState.uiScale)

        readonly property bool needsFocus: LauncherState.open || WallpaperState.open || PowerState.open || ClipboardState.open || MixerState.open || (netCircle && netCircle.fontDropdownOpen)

        // After a modal opens, suppress onCleared for 500ms so a keyboard-triggered
        // open doesn't immediately close (mouse outside bar causes Hyprland to clear the grab)
        Timer {
          id: openGuard
          interval: 500
          repeat: false
        }

        onNeedsFocusChanged: {
          if (needsFocus) {
            openGuard.restart();
            Qt.callLater(function() {
              if (LauncherState.open && launcher) launcher.forceFocus();
              else if (WallpaperState.open && wallpaperSelector) wallpaperSelector.forceFocus();
              else if (PowerState.open && powerMenu) powerMenu.forceFocus();
              else if (ClipboardState.open && clipboardHistory) clipboardHistory.forceFocus();
              else if (MixerState.open && hardwareMixer) hardwareMixer.forceFocus();
            });
          }
        }

        // Wayland layer-shell keyboard focus for Wayland / Hyprland
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: barWindow.needsFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        focusable: barWindow.needsFocus

        HyprlandFocusGrab {
          id: focusGrab
          active: barWindow.needsFocus
          windows: [barWindow]
          onCleared: {
            // Guard: ignore spurious clear fired right after open (mouse outside bar)
            if (openGuard.running) return;
            // Dismiss any open modal when user clicks outside the bar surface
            if (LauncherState.open) LauncherState.close();
            if (WallpaperState.open) WallpaperState.close();
            if (PowerState.open) PowerState.close();
            if (ClipboardState.open) ClipboardState.close();
            if (MixerState.open) MixerState.close();
          }
        }

        mask: Region {
          item: clockPill
          Region {
            item: netCircle
          }
          Region {
            item: mediaPlayer
          }
          Region {
            item: launcher
          }
          Region {
            item: wallpaperSelector
          }
          Region {
            item: powerMenu
          }
          Region {
            item: clipboardHistory
          }
          Region {
            item: hardwareMixer
          }
        }

        SystemClock {
          id: clock
          precision: SystemClock.Minutes
        }

        Item {
          id: barContent
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          height: parent.height
          scale: SettingsState.uiScale
          transformOrigin: Item.Top

          Behavior on scale {
            NumberAnimation {
              duration: 250
              easing.type: Easing.OutCubic
            }
          }

          ClockPill {
            id: clockPill
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            date: clock.date
          }

          MediaPlayer {
            id: mediaPlayer
            anchors.top: clockPill.top
            anchors.right: clockPill.left
            anchors.rightMargin: 10
          }

          NetworkCircle {
            id: netCircle
            anchors.top: clockPill.top
            anchors.left: clockPill.right
            anchors.leftMargin: 10
          }

          Launcher {
            id: launcher
            anchors.top: clockPill.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
          }

          WallpaperSelector {
            id: wallpaperSelector
            anchors.top: clockPill.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
          }

          PowerMenu {
            id: powerMenu
            anchors.top: clockPill.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
          }

          ClipboardHistory {
            id: clipboardHistory
            anchors.top: clockPill.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
          }

          HardwareMixer {
            id: hardwareMixer
            anchors.top: clockPill.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
          }
        }
      }

      // Pop-up notification toasts, top-right of the same screen
      Toasts {
        screen: modelData
      }
    }
  }
}
