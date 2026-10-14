import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import "../services"

// Top bar: centered clock pill (right swipe opens control center,
// left swipe opens calendar, then timer, then reminders).
Scope {
  Variants {
    model: Quickshell.screens

    delegate: Scope {
      id: screenScope
      required property var modelData

      // Auto-hide state: the bar slides away until the cursor hits the
      // top edge (revealStrip) or hovers the bar itself. Open modals
      // (needsFocus) always force the bar visible.
      property bool topHover: false
      // Precise hover straight from the pills — covers expanded panels of
      // any height (settings, control center, calendar, player card).
      // ClockPill.isExpanded is true while hovered or showing any
      // modal / weather / timer / notification view.
      readonly property bool barHover: (clockPill && clockPill.isExpanded) || (reminderCircle && reminderCircle.hovered)
      property bool barRevealed: true

      function shouldReveal() {
        if (RecorderState.selectingArea) return true;
        if (!SettingsState.barAutoHide) return true;
        if (screenScope.topHover || screenScope.barHover) return true;
        if (barWindow && barWindow.needsFocus) return true;
        return false;
      }

      function updateReveal() {
        if (screenScope.shouldReveal()) {
          hideTimer.stop();
          screenScope.barRevealed = true;
        } else {
          hideTimer.restart();
        }
      }

      onTopHoverChanged: updateReveal()
      onBarHoverChanged: updateReveal()

      Component.onCompleted: {
        if (SettingsState.barAutoHide) updateReveal();
      }

      Connections {
        target: SettingsState
        function onBarAutoHideChanged() {
          if (!SettingsState.barAutoHide) {
            hideTimer.stop();
            screenScope.barRevealed = true;
          } else {
            screenScope.updateReveal();
          }
        }
      }

      Connections {
        target: RecorderState
        function onSelectingAreaChanged() {
          screenScope.updateReveal();
        }
      }

      Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: {
          if (!screenScope.shouldReveal()) screenScope.barRevealed = false;
        }
      }

      // Hover strip at the top center of the screen to reveal the bar.
      // Always present while auto-hide is on so hover-exited always fires.
      // Masked specifically to the top center area so cursor at top-left / top-right
      // does not trigger the bar or block window controls.
      PanelWindow {
        id: revealStrip
        screen: modelData
        visible: SettingsState.barAutoHide && !RecorderState.selectingArea

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 8
        // -1 pins the strip at the screen edge, ignoring exclusive zone
        exclusiveZone: -1
        color: "transparent"
        focusable: false
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        mask: Region {
          item: revealTriggerArea
        }

        Item {
          id: revealTriggerArea
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          width: Math.max(500, Math.round(550 * SettingsState.uiScale))
          height: parent.height

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: screenScope.topHover = true
            onExited: screenScope.topHover = false
          }
        }
      }

      PanelWindow {
        id: barWindow
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        // Tall enough for the expanded control center, launcher, and wallpaper coverflow;
        // transparent + masked so empty area is click-through.
        implicitHeight: Math.round(960 * SettingsState.uiScale)
        color: "transparent"
        // Keep the bar visible while picking a screen-record area. The window
        // drops below slurp's overlay (Bottom < Overlay) so slurp stays
        // topmost and receives all pointer input, instead of hiding the bar.
        visible: true
        // Reserve a strip so maximized/tiled windows sit below the bar with configurable gap.
        // While auto-hide is enabled, exclusiveZone stays 0 so windows don't jump/resize on hover.
        exclusiveZone: (!SettingsState.barAutoHide && screenScope.barRevealed) ? Math.round((30 + 6 + SettingsState.barGap) * SettingsState.uiScale) : 0

        readonly property bool needsFocus: LauncherState.open || WallpaperState.open || PowerState.open || ClipboardState.open || MixerState.open || AuthState.open || FileTrayState.open || AboutState.open || NotifCenter.inboxOpen || ReminderState.promptOpen || ReminderState.editing || (clockPill && (clockPill.ccFontDropdownOpen || clockPill.swipeOpen || clockPill.pillNeedsFocus))

        // After a modal opens, suppress onCleared for 500ms so a keyboard-triggered
        // open doesn't immediately close (mouse outside bar causes Hyprland to clear the grab)
        Timer {
          id: openGuard
          interval: 500
          repeat: false
        }

        onNeedsFocusChanged: {
          screenScope.updateReveal();
          if (needsFocus) {
            openGuard.restart();
            Qt.callLater(function() {
              if (LauncherState.open && clockPill) clockPill.forceFocusLauncher();
              else if (WallpaperState.open && clockPill) clockPill.forceFocusWallpaper();
              else if (PowerState.open && clockPill) clockPill.forceFocusPower();
              else if (ClipboardState.open && clockPill) clockPill.forceFocusClipboard();
              else if (MixerState.open && clockPill) clockPill.forceFocusMixer();
              else if (AuthState.open && clockPill) clockPill.forceFocusAuth();
              else if (AboutState.open && clockPill) clockPill.forceFocusAbout();
              else if (NotifCenter.inboxOpen && clockPill) clockPill.forceFocusNotifInbox();
              else if (ReminderState.promptOpen && clockPill) clockPill.forceFocusReminder();
              else if (clockPill && clockPill.ccFontDropdownOpen) clockPill.forceFocusCCFontSearch();
              // Sticky swipe views / hover card opened via mouse gesture have no
              // dedicated input to focus: give the pill itself active focus so
              // Esc reliably closes it (focus:true alone isn't active focus).
              else if (clockPill) clockPill.forceActiveFocus();
            });
          }
        }

        // Wayland layer-shell keyboard focus for Wayland / Hyprland
        // Dropped below slurp during area selection so the picker gets input
        // while the bar stays visible underneath.
        WlrLayershell.layer: RecorderState.selectingArea ? WlrLayer.Bottom : WlrLayer.Overlay
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
            if (AuthState.open) AuthState.close();
            if (AboutState.open) AboutState.close();
            if (NotifCenter.inboxOpen) NotifCenter.closeInbox();
            if (FileTrayState.open) FileTrayState.close();
            if (ReminderState.promptOpen) ReminderState.closePrompt();
            if (ReminderState.editing) ReminderState.editing = false;
            if (clockPill) clockPill.collapseAll();
          }
        }

        mask: Region {
          item: clockPill
          Region {
            item: (reminderCircle && reminderCircle.visible) ? reminderCircle : null
          }
        }

        SystemClock {
          id: clock
          precision: SettingsState.clockSeconds ? SystemClock.Seconds : SystemClock.Minutes
        }

        Item {
          id: barContent
          anchors.left: parent.left
          anchors.right: parent.right
          height: parent.height
          scale: SettingsState.uiScale
          transformOrigin: Item.Top

          state: screenScope.barRevealed ? "visible" : "hidden"

          states: [
            State {
              name: "visible"
              PropertyChanges {
                target: barContent
                y: Math.round(6 * SettingsState.uiScale)
                opacity: 1.0
              }
            },
            State {
              name: "hidden"
              PropertyChanges {
                target: barContent
                y: -(Math.round(80 * SettingsState.uiScale))
                opacity: 0.0
              }
            }
          ]

          transitions: [
            Transition {
              to: "visible"
              ParallelAnimation {
                NumberAnimation {
                  target: barContent
                  property: "y"
                  duration: 550
                  easing.type: Easing.OutExpo
                }
                NumberAnimation {
                  target: barContent
                  property: "opacity"
                  duration: 400
                  easing.type: Easing.OutCubic
                }
              }
            },
            Transition {
              to: "hidden"
              SequentialAnimation {
                // 1. First goes up partially (not fully hidden yet)
                NumberAnimation {
                  target: barContent
                  property: "y"
                  to: -(Math.round(20 * SettingsState.uiScale))
                  duration: 380
                  easing.type: Easing.InOutCubic
                }
                // 2. Stops at that point for a while
                PauseAnimation {
                  duration: 250
                }
                // 3. Completes the upward slide and hides fully
                ParallelAnimation {
                  NumberAnimation {
                    target: barContent
                    property: "y"
                    to: -(Math.round(80 * SettingsState.uiScale))
                    duration: 450
                    easing.type: Easing.InOutCubic
                  }
                  NumberAnimation {
                    target: barContent
                    property: "opacity"
                    to: 0.0
                    duration: 380
                    easing.type: Easing.InOutCubic
                  }
                }
              }
            }
          ]

          Behavior on scale {
            NumberAnimation {
              duration: 350
              easing.type: Easing.OutExpo
            }
          }

          // ==========================================
          // DEDICATED DROP SHADOWS (Rendered behind components)
          // ==========================================
          Rectangle {
            anchors.fill: clockPill
            radius: clockPill.radius
            color: "transparent"
            visible: clockPill.visible
            layer.enabled: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: SettingsState.shadowColor
              shadowBlur: 0.4
              shadowVerticalOffset: 0
              shadowHorizontalOffset: 0
            }

            SquircleBackground {
              radius: clockPill.radius
              power: SettingsState.cardRoundingPower
              fillColor: SettingsState.bgCard
              strokeColor: "transparent"
              strokeWidth: 0
            }
          }

          Rectangle {
            anchors.fill: reminderCircle
            radius: reminderCircle.radius
            color: "transparent"
            visible: reminderCircle.visible && reminderCircle.opacity > 0.05
            opacity: reminderCircle.opacity
            scale: reminderCircle.scale
            layer.enabled: true
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: SettingsState.shadowColor
              shadowBlur: 0.4
              shadowVerticalOffset: 0
              shadowHorizontalOffset: 0
            }

            SquircleBackground {
              radius: reminderCircle.radius
              power: SettingsState.cardRoundingPower
              fillColor: SettingsState.bgCard
              strokeColor: "transparent"
              strokeWidth: 0
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

          ReminderCircle {
            id: reminderCircle
            anchors.top: clockPill.top
            anchors.right: clockPill.left
            anchors.rightMargin: 10
            clockPill: clockPill
          }
        }
      }
    }
  }
}
