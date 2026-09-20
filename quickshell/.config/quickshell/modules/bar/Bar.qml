import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
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
              if (LauncherState.open && clockPill) clockPill.forceFocusLauncher();
              else if (WallpaperState.open && clockPill) clockPill.forceFocusWallpaper();
              else if (PowerState.open && clockPill) clockPill.forceFocusPower();
              else if (ClipboardState.open && clockPill) clockPill.forceFocusClipboard();
              else if (MixerState.open && clockPill) clockPill.forceFocusMixer();
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

          // ==========================================
          // DEDICATED DROP SHADOWS (Rendered behind components)
          // ==========================================
          Rectangle {
            anchors.fill: clockPill
            radius: clockPill.radius
            color: SettingsState.bgSurface
            visible: clockPill.visible
            layer.enabled: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: SettingsState.shadowColor
              shadowBlur: 0.55
              shadowVerticalOffset: 3
              shadowHorizontalOffset: 0
            }
          }

          Rectangle {
            anchors.fill: mediaPlayer
            radius: mediaPlayer.radius
            color: SettingsState.bgSurface
            visible: mediaPlayer.visible
            layer.enabled: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: SettingsState.shadowColor
              shadowBlur: 0.55
              shadowVerticalOffset: 3
              shadowHorizontalOffset: 0
            }
          }

          Rectangle {
            anchors.fill: netCircle
            radius: netCircle.radius
            color: SettingsState.bgSurface
            visible: netCircle.visible
            layer.enabled: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: SettingsState.shadowColor
              shadowBlur: 0.55
              shadowVerticalOffset: 3
              shadowHorizontalOffset: 0
            }
          }




          // ==========================================
          // FOREGROUND COMPONENTS (Direct rendering with full subpixel font sharpness)
          // ==========================================
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




        }
      }

      // Pop-up notification toasts, top-right of the same screen
      Toasts {
        screen: modelData
      }
    }
  }
}
