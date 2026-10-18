import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import "../services"
import "WavySliderPaint.js" as WavyPaint

// Center Date & Time pill.
// Normal state: configurable time format (24h/12h, seconds, font) + Cava visualizer.
// Workspace switch: temporarily reveals workspace dots + active bar.
// Hovered: big clock + 7-day strip.
// Right swipe on hover: seamlessly morphs the center bar itself into the Control Center!
// Left swipe: timer, then reminders. Calendar lives as a subpage inside the control center.
Rectangle {
  id: root

  required property var date

  // Track workspace changes
  readonly property int currentWsId: Hyprland.focusedWorkspace?.id ?? 1
  property bool showWorkspaces: false
  property bool isControlCenterView: false
  property bool isTimerView: false
  property bool isReminderView: false

  onCurrentWsIdChanged: {
    showWorkspaces = true;
    wsTimer.restart();
  }

  Timer {
    id: wsTimer
    interval: 1800
    repeat: false
    onTriggered: {
      root.showWorkspaces = false;
    }
  }

  // Determine highest workspace number to display
  readonly property int maxWs: {
    var m = 3;
    if (currentWsId > m) {
      m = currentWsId;
    }
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      var ws = list[i];
      if (ws && ws.id > m && ws.id <= 10) {
        m = ws.id;
      }
    }
    return Math.min(Math.max(m, 3), 10);
  }

  function isOccupied(wsId) {
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      if (list[i] && list[i].id === wsId) {
        return true;
      }
    }
    return false;
  }

  readonly property bool showLauncher: LauncherState.open
  readonly property bool showWallpaper: WallpaperState.open && !showLauncher
  readonly property bool showPower: PowerState.open && !showLauncher && !showWallpaper
  readonly property bool showClipboard: ClipboardState.open && !showLauncher && !showWallpaper && !showPower
  readonly property bool showMixer: MixerState.open && !showLauncher && !showWallpaper && !showPower && !showClipboard
  readonly property bool showAuth: AuthState.open && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer
  readonly property bool showInbox: NotifCenter.inboxOpen && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth
  readonly property bool showNotif: NotifCenter.showNotificationPill && !showInbox && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth
  readonly property bool showFileTray: (FileTrayState.open || FileTrayState.dndHover) && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif
  readonly property bool showAbout: AboutState.open && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif && !showInbox && !showFileTray
  readonly property bool showReminderPrompt: ReminderState.promptOpen && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif && !showInbox && !showFileTray && !showAbout
  readonly property bool showCC: (isControlCenterView || CalendarState.open || ScreenshotState.open || RecorderState.open) && !isTimerView && !isReminderView && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif && !showInbox && !showFileTray && !showAbout && !showReminderPrompt
  readonly property bool showTimer: isTimerView && !isReminderView && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif && !showInbox && !showFileTray && !showAbout && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !isControlCenterView && !showReminderPrompt
  readonly property bool showReminders: isReminderView && !isTimerView && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif && !showInbox && !showFileTray && !showAbout && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !isControlCenterView && !showReminderPrompt
  // Expanded hover card (big clock + date strip + now playing). Factored out
  // so its fade and slide entrance stay in sync during view transitions.
  readonly property bool showHover: isExpanded && !showCC && !showTimer && !showReminders && !showAbout && !showFileTray && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif && !showInbox && !showReminderPrompt && !dismissLock
  // Hover inside the calendar view (over day/chevron buttons which sit above
  // the gesture MouseArea) must also keep the pill expanded.
  readonly property bool calHovering: ccView.visible && ccView.ccHover
  readonly property bool timerHovering: timerView.visible && timerView.timerHover
  readonly property bool remHovering: reminderWrap.visible && reminderWrap.remHover
  property bool mediaHover: false
  property bool swipeTransitioning: false
  Timer {
    id: swipeTransitionTimer
    interval: 450
    repeat: false
    onTriggered: root.swipeTransitioning = false
  }
  function triggerSwipeTransition() {
    root.swipeTransitioning = true;
    swipeTransitionTimer.restart();
  }

  readonly property bool isHovered: (mouse.containsMouse || calHovering || timerHovering || remHovering || root.mediaHover) && !root.dismissLock
  readonly property bool isExpanded: root.swipeTransitioning || isHovered || root.isControlCenterView || root.isTimerView || root.isReminderView || CalendarState.open || ScreenshotState.open || RecorderState.open || LauncherState.open || WallpaperState.open || PowerState.open || ClipboardState.open || MixerState.open || AuthState.open || AboutState.open || showNotif || NotifCenter.inboxOpen || FileTrayState.open || FileTrayState.dndHover || root.showReminderPrompt
  // While the card is tall (>35px), keep card styling (squircle background, no rectangular border).
  // Only when physically collapsed to the 30px pill does it switch to pill border styling.
  readonly property bool isCardExpanded: isExpanded || implicitHeight > 35
  // Screenshot area/window capture indicator takes over the collapsed center bar
  readonly property bool showCapture: ScreenshotState.capturing && (ScreenshotState.activeMode === "area" || ScreenshotState.activeMode === "window") && !isExpanded
  // Running countdown takes over the collapsed bar: progress ring + MM:SS
  readonly property bool showTimerCollapsed: !isExpanded && !showWorkspaces && !showCapture && (TimerState.running || TimerState.paused || TimerState.finished)

  implicitHeight: isExpanded ? (showLauncher ? (launcherContent.implicitHeight + 32) : (showWallpaper ? 220 : (showPower ? 127 : (showClipboard ? 420 : (showMixer ? 363 : (showAuth ? 196 : (showInbox ? notifInboxContent.implicitHeight : (showNotif ? 136 : (showFileTray ? 204 : (showAbout ? aboutContent.implicitHeight : (showReminderPrompt ? 52 : (showTimer ? 156 : (showReminders ? (reminderListView.implicitHeight + 32) : (showCC ? ccView.implicitHeight : (hoverRow.implicitHeight + 32))))))))))))))) : 30
  implicitWidth: isExpanded ? (showLauncher ? 440 : (showWallpaper ? 650 : (showPower ? 360 : (showClipboard ? 460 : (showMixer ? 440 : (showAuth ? 460 : (showInbox ? 460 : (showNotif ? 380 : (showFileTray ? 480 : (showAbout ? 460 : (showReminderPrompt ? 240 : (showTimer ? 360 : (showReminders ? 360 : (showCC ? ccView.implicitWidth : (hoverRow.implicitWidth + 32))))))))))))))) : (showTimerCollapsed ? (timerCollapsedRow.implicitWidth + 24) : (showCapture ? Math.max(captureRow.implicitWidth + 24, 72) : (showWorkspaces ? Math.max(wsRow.implicitWidth + 24, 72) : collapsedRow.implicitWidth + 44)))

  onIsExpandedChanged: {
    if (isExpanded && !isHovered) {
      root.dismissLock = false;
    }
    if (!isExpanded) {
      AmeState.clear();
    }
  }

  radius: isCardExpanded ? SettingsState.cardRadius + 12 : 15
  color: isCardExpanded ? "transparent" : SettingsState.bgCard
  border.color: isCardExpanded ? "transparent" : SettingsState.barBorder
  border.width: isCardExpanded ? 0 : 1
  clip: true

  SquircleBackground {
    id: squircleBg
    visible: root.isCardExpanded
    radius: root.radius
    power: SettingsState.cardRoundingPower
    fillColor: SettingsState.bgCard
    strokeColor: SettingsState.barBorder
    strokeWidth: 1
    z: -1
  }

  function forceFocusLauncher() {
    if (launcherContent) {
      launcherContent.forceFocus();
    }
  }

  function forceFocusWallpaper() {
    if (wallpaperContent) {
      wallpaperContent.forceFocus();
    }
  }

  function forceFocusPower() {
    if (powerMenuContent) {
      powerMenuContent.forceFocus();
    }
  }

  function forceFocusClipboard() {
    if (clipboardContent) {
      clipboardContent.forceFocus();
    }
  }

  function forceFocusMixer() {
    if (hardwareMixerContent) {
      hardwareMixerContent.forceFocus();
    }
  }

  function forceFocusAuth() {
    if (authContent) {
      authContent.forceFocus();
    }
  }

  function forceFocusAbout() {
    if (aboutContent) {
      aboutContent.forceFocus();
    }
  }

  function forceFocusNotifInbox() {
    if (notifInboxContent) {
      notifInboxContent.forceFocus();
    }
  }

  function forceFocusReminder() {
    if (reminderPromptContent) {
      reminderPromptContent.forceFocus();
    }
  }

  function forceFocusCCFontSearch() {
    if (ccView) {
      ccView.forceFocusFontSearch();
    }
  }

  // Jump from the embedded mixer into the control center's
  // sound / mic device-selection page.
  function openCCPage(page) {
    MixerState.close();
    TimerState.open = false;
    CalendarState.close();
    ScreenshotState.close();
    RecorderState.close();
    root.isTimerView = false;
    root.isReminderView = false;
    if (ReminderState.editing) ReminderState.editing = false;
    // Decide the page BEFORE showing the container so hidden subpages
    // snap (their fade Behavior is disabled while the container is faded
    // out) instead of crossfading the stale main page visibly on open.
    if (ccView) ccView.activePage = page;
    root.isControlCenterView = true;
    AudioState.refreshDevices();
  }

  readonly property bool ccFontDropdownOpen: ccView ? ccView.fontDropdownOpen : false
  // Sticky swipe views (control center / timer / reminders) persist after the
  // pointer leaves until dismissed via Esc, click-outside, click on the pill,
  // or the leave timer.
  readonly property bool swipeOpen: isControlCenterView || isTimerView || isReminderView
  // Any tall expanded state (hover card, swipe views, modals). Used to take
  // keyboard focus + focus grab so Esc and click-outside can always dismiss,
  // even when a hover flag latches stuck (see collapseAll).
  readonly property bool pillOpen: isExpanded && implicitHeight > 30.5
  // Transient notification toast (Dynamic Island) must NEVER take keyboard
  // focus: otherwise every popup steals typing from the terminal / apps
  // via Exclusive layer-shell focus + HyprlandFocusGrab. Only the
  // explicitly-opened inbox (and other modals / swipe views) may grab keys.
  readonly property bool pillNeedsFocus: pillOpen && !showNotif
  // Momentary kill-switch for the gesture layer: flipping it drops a latched
  // containsMouse so a stuck pill can collapse. Re-armed on the next frame.
  property bool hoverReset: false
  // Holds the hover card shut after an Esc / click-outside dismiss while the
  // cursor is still over the pill. Without it, re-arming the gesture layer
  // snaps a parked cursor straight back to expanded, making Esc look dead.
  // Released on full pointer exit (pokeLeaveTimer) or a fresh press.
  property bool dismissLock: false

  // True while any explicitly-opened modal holds the pill tall. Used to
  // collapse the hover latch when the last modal closes: otherwise the
  // inner TextInput keeps activeFocus, the hover card pops up underneath,
  // and Esc is dead (focus never returns to root so the second Esc is lost).
  readonly property bool anyModalOpen: LauncherState.open || WallpaperState.open || PowerState.open || ClipboardState.open || MixerState.open || AuthState.open || AboutState.open || NotifCenter.inboxOpen || FileTrayState.open || FileTrayState.dndHover || ReminderState.promptOpen || ReminderState.editing
  onAnyModalOpenChanged: {
    if (!anyModalOpen) {
      // Defer one frame so a modal-to-modal switch (e.g. mixer -> CC page)
      // can re-expand before we collapse the hover latch.
      Qt.callLater(function() {
        if (!root.anyModalOpen && !root.swipeOpen && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !CCState.open && !TimerState.open) {
          root.collapseAll();
        }
      });
    } else {
      // A fresh modal takes over: drop any stale hover latch.
      root.dismissLock = false;
    }
  }

  focus: pillNeedsFocus
  // focus:true alone doesn't grant *active* focus when the layer gains
  // Exclusive keyboard focus (e.g. hover/swipe opens via mouse), so Esc
  // would be dead. Force it so Esc + click-outside always work.
  onPillNeedsFocusChanged: {
    if (pillNeedsFocus) root.forceActiveFocus();
  }
  function closeAllModals(): void {
    if (LauncherState.open) LauncherState.close();
    if (WallpaperState.open) WallpaperState.close();
    if (PowerState.open) PowerState.close();
    if (ClipboardState.open) ClipboardState.close();
    if (MixerState.open) MixerState.close();
    if (AuthState.open) AuthState.close();
    if (AboutState.open) AboutState.close();
    if (NotifCenter.inboxOpen) NotifCenter.closeInbox();
    if (FileTrayState.open || FileTrayState.dndHover) FileTrayState.close();
    if (ReminderState.promptOpen) ReminderState.closePrompt();
    if (ReminderState.editing) ReminderState.editing = false;
    if (TimerState.open) TimerState.open = false;
    if (CCState.open) CCState.open = false;
  }
  Keys.onEscapePressed: function(ev) {
    // Also answer while dismissLock holds the pill shut but tallness is
    // gone (pillOpen false): otherwise the first Esc blanks the pill and
    // every later Esc is rejected as "nothing to do".
    // Close explicit modals too: collapseAll() alone only clears swipe
    // views, so Esc on a FileTray / launcher-with-lost-focus would look dead.
    if (root.pillOpen || root.dismissLock || root.swipeOpen || root.anyModalOpen) {
      root.closeAllModals();
      root.collapseAll();
      ev.accepted = true;
    }
  }

  function collapseSwipe(): void {
    root.isControlCenterView = false;
    root.isTimerView = false;
    root.isReminderView = false;
    CalendarState.close();
    ScreenshotState.close();
    RecorderState.close();
    // Reset the CC page only after the container has faded out: resetting
    // immediately would crossfade the stale/main page visibly inside the
    // closing container (a split-second ghost + choppy resize).
    ccResetTimer.restart();
  }

  function toggleReminders(): void {
    if (root.isReminderView) {
      root.collapseAll();
    } else {
      root.collapseSwipe();
      root.isReminderView = true;
    }
  }

  // Dismiss everything stuck open: swipe views plus latched hover flags.
  // Hover is re-synced after the collapse animation settles (450ms): the
  // pill shrinking under a stationary cursor never delivers an exit event,
  // so without this the hover latches true and the pill blanks permanently.
  Timer {
    id: hoverResync
    interval: 500
    repeat: false
    onTriggered: root.hoverReset = false
  }

  // Deferred CC page reset: fires after the container fade-out (320ms) so
  // the reset snaps while invisible (subpage fade Behaviors are disabled
  // below opacity 0.5) instead of flashing the main page during close.
  // Guarded: skipped if the CC was reopened meanwhile.
  Timer {
    id: ccResetTimer
    interval: 380
    repeat: false
    onTriggered: {
      if (ccView && !root.showCC) ccView.resetToMain();
    }
  }

  function collapseAll(): void {
    var hovered = mouse.containsMouse || root.mediaHover || root.calHovering || root.timerHovering || root.remHovering;
    root.collapseSwipe();
    root.mediaHover = false;
    reminderWrap.remHover = false;
    leaveTimer.stop();
    root.dismissLock = hovered;
    root.hoverReset = true;
    hoverResync.restart();
  }

  Behavior on implicitWidth {
    NumberAnimation {
      duration: 650
      easing.type: Easing.OutExpo
    }
  }
  Behavior on implicitHeight {
    NumberAnimation {
      duration: 650
      easing.type: Easing.OutExpo
    }
  }
  Behavior on radius {
    NumberAnimation {
      duration: 650
      easing.type: Easing.OutExpo
    }
  }

  // Handle IPC and keybind toggle
  Connections {
    target: TimerState
    function onOpenChanged() {
      if (TimerState.open) {
        root.isTimerView = true;
        root.isControlCenterView = false;
        root.isReminderView = false;
        CalendarState.close();
        ScreenshotState.close();
        RecorderState.close();
      } else if (!mouse.containsMouse) {
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: CCState
    function onOpenChanged() {
      if (CCState.open) {
        root.dismissLock = false;
        root.isControlCenterView = true;
        root.isTimerView = false;
        root.isReminderView = false;
        TimerState.open = false;
        CalendarState.close();
        ScreenshotState.close();
        RecorderState.close();
        if (ccView) ccView.activePage = "main";
      } else {
        root.isControlCenterView = false;
        ccResetTimer.restart();
      }
    }
  }

  Connections {
    target: CalendarState
    function onOpenChanged() {
      if (CalendarState.open) {
        root.dismissLock = false;
        if (ccView) ccView.activePage = "calendar";
        root.isControlCenterView = true;
        root.isTimerView = false;
        root.isReminderView = false;
        ScreenshotState.close();
        RecorderState.close();
        CalendarState.refreshWeather();
      } else if (!mouse.containsMouse && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open && !ScreenshotState.open && !RecorderState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        ccResetTimer.restart();
      }
    }
  }

  Connections {
    target: ScreenshotState
    function onOpenChanged() {
      if (ScreenshotState.open) {
        root.dismissLock = false;
        if (ccView) ccView.activePage = "screenshot";
        root.isControlCenterView = true;
        root.isTimerView = false;
        root.isReminderView = false;
        TimerState.open = false;
        CalendarState.close();
        RecorderState.close();
        ScreenshotState.refreshLast();
      } else if (!mouse.containsMouse && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open && !CalendarState.open && !RecorderState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        ccResetTimer.restart();
      }
    }
  }

  Connections {
    target: RecorderState
    function onOpenChanged() {
      if (RecorderState.open) {
        root.dismissLock = false;
        if (ccView) ccView.activePage = "recorder";
        root.isControlCenterView = true;
        root.isTimerView = false;
        root.isReminderView = false;
        TimerState.open = false;
        CalendarState.close();
        ScreenshotState.close();
        RecorderState.refreshRecent();
        RecorderState.checkStatus();
      } else if (!mouse.containsMouse && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open && !CalendarState.open && !ScreenshotState.open && !RecorderState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        ccResetTimer.restart();
      }
    }
  }

  Connections {
    target: LauncherState
    function onOpenChanged() {
      if (LauncherState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusLauncher();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: WallpaperState
    function onOpenChanged() {
      if (WallpaperState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusWallpaper();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: PowerState
    function onOpenChanged() {
      if (PowerState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusPower();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: ClipboardState
    function onOpenChanged() {
      if (ClipboardState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusClipboard();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !MixerState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: MixerState
    function onOpenChanged() {
      if (MixerState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusMixer();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: AuthState
    function onOpenChanged() {
      if (AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusAuth();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: FileTrayState
    function onOpenChanged() {
      if (FileTrayState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: AboutState
    function onOpenChanged() {
      if (AboutState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusAbout();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: NotifCenter
    function onShowNotificationPillChanged() {
      if (NotifCenter.showNotificationPill) {
        root.dismissLock = false;
      }
    }
    function onInboxOpenChanged() {
      if (NotifCenter.inboxOpen) {
        root.dismissLock = false;
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusNotifInbox();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  Connections {
    target: ReminderState
    function onPromptOpenChanged() {
      if (ReminderState.promptOpen) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
        forceFocusReminder();
      } else if (!mouse.containsMouse && !CalendarState.open && !ScreenshotState.open && !RecorderState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open && !NotifCenter.inboxOpen) {
        root.isControlCenterView = false;
        root.isTimerView = false;
        root.isReminderView = false;
      }
    }
  }

  // Reset to default clock view shortly after the mouse leaves
  Connections {
    target: mouse
    function onContainsMouseChanged() {
      root.pokeLeaveTimer();
    }
  }

  // Live cava levels (0..100) mapped to bar pixel heights.
  // CavaState captures the default-sink monitor, so music and videos
  // drive this accurately; silence rests flat at 3px.
  readonly property var barHeights: {
    var vals = CavaState.values;
    var out = [];
    for (var i = 0; i < 5; ++i) {
      var v = (vals && vals.length > i) ? vals[i] : 0;
      out.push(3 + (Math.max(0, Math.min(100, v)) / 100) * 14);
    }
    return out;
  }

  // ========================================================
  // 1. COLLAPSED VIEW: Cava Visualizer + Time Pill
  // ========================================================
  Row {
    id: collapsedRow
    anchors.centerIn: parent
    spacing: RecorderState.isRecording ? 14 : 7
    opacity: (!root.isExpanded && !root.showWorkspaces && !root.showCapture && !root.showTimerCollapsed) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: root.isExpanded ? 100 : 200; easing.type: Easing.OutCubic }
    }

    // Cava visualizer bars on the left of time
    // Recording indicator: red dot that smoothly blinks while screen recording
    Rectangle {
      id: recDot
      anchors.verticalCenter: parent.verticalCenter
      width: 8
      height: 8
      radius: 4
      color: "#ff453a"
      visible: RecorderState.isRecording

      SequentialAnimation on opacity {
        running: RecorderState.isRecording
        loops: Animation.Infinite
        NumberAnimation {
          from: 1.0
          to: 0.2
          duration: 900
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 0.2
          to: 1.0
          duration: 900
          easing.type: Easing.InOutSine
        }
      }
    }



    Row {
      id: visualizerRow
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2
      visible: SettingsState.musicVisualizer || RecorderState.isRecording

      Repeater {
        model: 5

        delegate: Rectangle {
          width: 2.8
          height: root.barHeights[index] || 3
          radius: 1.4
          color: RecorderState.isRecording ? "#ff453a" : SettingsState.accent
          anchors.verticalCenter: parent.verticalCenter

          Behavior on color {
            ColorAnimation {
              duration: 200
            }
          }
          Behavior on height {
            NumberAnimation {
              duration: 50
              easing.type: Easing.OutQuad
            }
          }
        }
      }
    }

    Text {
      id: timeText
      anchors.verticalCenter: parent.verticalCenter
      visible: !RecorderState.isRecording
      width: timeMetrics.implicitWidth
      horizontalAlignment: Text.AlignHCenter
      text: {
        var fmt = "";
        if (SettingsState.timeFormat === "24h") {
          fmt = SettingsState.clockSeconds ? "HH:mm:ss" : "HH:mm";
        } else {
          fmt = SettingsState.clockSeconds ? "hh:mm:ss AP" : "hh:mm AP";
        }
        return Qt.formatDateTime(root.date, fmt);
      }
      color: SettingsState.accent
      font.pixelSize: SettingsState.px(15)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    // Invisible reserve for timeText: measures widest possible digits ("88:88[:88] [PM]")
    // so character width differences never alter row width or shift the bar.
    Text {
      id: timeMetrics
      visible: false
      text: {
        var s = "88:88";
        if (SettingsState.clockSeconds) s += ":88";
        if (SettingsState.timeFormat !== "24h") s += " PM";
        return s;
      }
      color: "transparent"
      font.pixelSize: SettingsState.px(15)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    Item {
      width: 6
      height: 1
      visible: AudioState.inMuted || AudioState.outMuted
    }

    // Mic mute indicator: right side inside center bar, only when mic is muted
    CCIcon {
      id: micMuteIcon
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "mic-mute"
      glyph: "#ff3b30"
      visible: AudioState.inMuted
    }

    // Sound mute indicator: right side inside center bar, only when output is muted
    CCIcon {
      id: soundMuteIcon
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "sound-mute"
      glyph: "#ff3b30"
      visible: AudioState.outMuted
    }

    // DND indicator: yellow bell-slash, only when Do Not Disturb is on
    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "moon"
      glyph: SettingsState.accent
      visible: NotifCenter.dnd
    }

    // Recording elapsed time: right side, only while screen recording
    Text {
      id: recTimeText
      anchors.verticalCenter: parent.verticalCenter
      visible: RecorderState.isRecording
      width: recTimeMetrics.implicitWidth
      horizontalAlignment: Text.AlignHCenter
      text: RecorderState.formattedTime
      color: "#ff453a"
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    Text {
      id: recTimeMetrics
      visible: false
      text: "88:88:88"
      color: "transparent"
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    // Privacy indicators: solid orange-yellow = mic in use, solid green = camera in use (never blink)
    // Pinned to the right end of the center bar, after DND / recording timer.
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5
      visible: PrivacyState.cameraActive || PrivacyState.micActive

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#30d158"
        visible: PrivacyState.cameraActive
      }

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#ffd60a"
        visible: PrivacyState.micActive
      }
    }

    // File shelf: inline thumbnail of first stashed file + count, click to open
    Item {
      anchors.verticalCenter: parent.verticalCenter
      width: shelfInline.width
      height: 18
      visible: FileTrayState.count > 0

      Row {
        id: shelfInline
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 18

          Rectangle {
            anchors.fill: parent
            radius: 5
            color: Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.12)
            visible: !(FileTrayState.count > 0 && FileTrayState.files[0] && FileTrayState.files[0].isImage)
            Text {
              anchors.centerIn: parent
              text: "󰧮"
              font.family: SettingsState.nerdIconFont
              font.pixelSize: SettingsState.px(10)
              color: SettingsState.accent
            }
          }
          Image {
            anchors.fill: parent
            visible: FileTrayState.count > 0 && FileTrayState.files[0] && FileTrayState.files[0].isImage
            source: (FileTrayState.count > 0 && FileTrayState.files[0] && FileTrayState.files[0].isImage) ? FileTrayState.files[0].url : ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            sourceSize.width: 44
            sourceSize.height: 44
            onStatusChanged: {
              if (status === Image.Error) visible = false;
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: FileTrayState.count
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
          color: shelfInlineMouse.containsMouse ? SettingsState.accent : SettingsState.textSecondary
        }
      }

      MouseArea {
        id: shelfInlineMouse
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: function(ev) {
          FileTrayState.openTray();
          ev.accepted = true;
        }
      }
    }
  }

  // ========================================================
  // 1b. COLLAPSED TIMER VIEW: progress ring + MM:SS (like Dynamic Island)
  // ========================================================
  Row {
    id: timerCollapsedRow
    anchors.centerIn: parent
    spacing: 18
    opacity: root.showTimerCollapsed ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    Canvas {
      id: timerRing
      anchors.verticalCenter: parent.verticalCenter
      width: 26
      height: 26
      transform: Translate { x: -8 }
      property real prog: TimerState.progress
      onProgChanged: requestPaint()
      Component.onCompleted: requestPaint()
      onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        var cx = 13, cy = 13, r = 10;
        ctx.lineWidth = 3;
        ctx.lineCap = "round";
        // Track
        ctx.strokeStyle = "#4a3826";
        ctx.beginPath();
        ctx.arc(cx, cy, r, 0, Math.PI * 2);
        ctx.stroke();
        // Elapsed arc
        var a0 = -Math.PI / 2;
        var p = Math.max(0, Math.min(1, prog));
        var a1 = a0 + Math.PI * 2 * p;
        ctx.strokeStyle = "#FF9E2C";
        ctx.beginPath();
        ctx.arc(cx, cy, r, a0, a1);
        ctx.stroke();
      }
    }

    Text {
      id: timerCollapsedText
      anchors.verticalCenter: parent.verticalCenter
      width: timerCollapsedMetrics.implicitWidth
      horizontalAlignment: Text.AlignHCenter
      text: TimerState.finished ? "00:00" : TimerState.formatted
      color: "#FF9E2C"
      font.pixelSize: SettingsState.px(16)
      font.bold: true
      font.family: SettingsState.fontFamily

      SequentialAnimation on opacity {
        running: TimerState.finished
        loops: Animation.Infinite
        NumberAnimation { from: 1.0; to: 0.4; duration: 600; easing.type: Easing.InOutSine }
        NumberAnimation { from: 0.4; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
      }
    }

    // Invisible reserve: widest digits ("8") so per-second digit changes
    // never alter the visible text width -> Row/pill width stays constant.
    Text {
      id: timerCollapsedMetrics
      visible: false
      text: (TimerState.totalSeconds >= 6000 || TimerState.selectedMinutes >= 100) ? "888:88" : "88:88"
      color: "transparent"
      font.pixelSize: SettingsState.px(16)
      font.bold: true
      font.family: SettingsState.fontFamily
    }
  }

  // ========================================================
  // 2. WORKSPACE SWITCHER INDICATORS
  // ========================================================
  Row {
    id: wsRow
    anchors.centerIn: parent
    spacing: 8
    opacity: (!root.isExpanded && root.showWorkspaces && !root.showCapture) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 8
      height: 8
      radius: 4
      color: "#ff453a"
      visible: RecorderState.isRecording

      SequentialAnimation on opacity {
        running: RecorderState.isRecording && !root.isExpanded && root.showWorkspaces
        loops: Animation.Infinite
        NumberAnimation {
          from: 1.0
          to: 0.2
          duration: 900
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 0.2
          to: 1.0
          duration: 900
          easing.type: Easing.InOutSine
        }
      }
    }

    Repeater {
      model: root.maxWs

      delegate: Item {
        id: wsItem
        property int wsId: index + 1
        property bool isCurrent: root.currentWsId === wsId
        property bool occupied: root.isOccupied(wsId)

        width: isCurrent ? 26 : 7
        height: 7
        anchors.verticalCenter: parent.verticalCenter

        Behavior on width {
          NumberAnimation {
            duration: 350
            easing.type: Easing.OutExpo
          }
        }

        Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: wsItem.isCurrent ? SettingsState.accent : (wsItem.occupied ? SettingsState.textSecondary : SettingsState.borderBase)

          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }

        MouseArea {
          anchors.fill: parent
          anchors.margins: -6
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Hyprland.dispatch("workspace " + wsItem.wsId);
            root.showWorkspaces = true;
            wsTimer.restart();
          }
        }
      }
    }

    Item {
      width: 6
      height: 1
      visible: AudioState.inMuted || AudioState.outMuted
    }

    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "mic-mute"
      glyph: "#ff3b30"
      visible: AudioState.inMuted
    }

    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "sound-mute"
      glyph: "#ff3b30"
      visible: AudioState.outMuted
    }

    // DND indicator: yellow bell-slash, only when Do Not Disturb is on
    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "moon"
      glyph: SettingsState.accent
      visible: NotifCenter.dnd
    }

    // Privacy indicators: solid orange-yellow = mic in use, solid green = camera in use (never blink)
    // Pinned to the right end, after DND.
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5
      visible: PrivacyState.cameraActive || PrivacyState.micActive

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#30d158"
        visible: PrivacyState.cameraActive
      }

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#ffd60a"
        visible: PrivacyState.micActive
      }
    }

    // File shelf: inline thumbnail + count (mirrors collapsed row)
    Item {
      anchors.verticalCenter: parent.verticalCenter
      width: wsShelfInline.width
      height: 18
      visible: FileTrayState.count > 0

      Row {
        id: wsShelfInline
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Item {
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 18

          Rectangle {
            anchors.fill: parent
            radius: 5
            color: Qt.rgba(SettingsState.accent.r, SettingsState.accent.g, SettingsState.accent.b, 0.12)
            visible: !(FileTrayState.count > 0 && FileTrayState.files[0] && FileTrayState.files[0].isImage)
            Text {
              anchors.centerIn: parent
              text: "󰧮"
              font.family: SettingsState.nerdIconFont
              font.pixelSize: SettingsState.px(10)
              color: SettingsState.accent
            }
          }
          Image {
            anchors.fill: parent
            visible: FileTrayState.count > 0 && FileTrayState.files[0] && FileTrayState.files[0].isImage
            source: (FileTrayState.count > 0 && FileTrayState.files[0] && FileTrayState.files[0].isImage) ? FileTrayState.files[0].url : ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            sourceSize.width: 44
            sourceSize.height: 44
            onStatusChanged: {
              if (status === Image.Error) visible = false;
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: FileTrayState.count
          font.pixelSize: SettingsState.px(11)
          font.family: SettingsState.fontFamily
          color: wsShelfInlineMouse.containsMouse ? SettingsState.accent : SettingsState.textSecondary
        }
      }

      MouseArea {
        id: wsShelfInlineMouse
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: function(ev) {
          FileTrayState.openTray();
          ev.accepted = true;
        }
      }
    }
  }

  // ========================================================
  // 2b. SCREENSHOT CAPTURE INDICATOR (area / window mode)
  // ========================================================
  Row {
    id: captureRow
    anchors.centerIn: parent
    spacing: 7
    opacity: root.showCapture ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "camera"
      glyph: SettingsState.accent
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Capture"
      color: SettingsState.accent
      font.pixelSize: SettingsState.px(17)
      font.bold: true
      font.family: SettingsState.fontFamily

      SequentialAnimation on opacity {
        running: root.showCapture
        loops: Animation.Infinite
        NumberAnimation {
          from: 1.0
          to: 0.45
          duration: 700
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 0.45
          to: 1.0
          duration: 700
          easing.type: Easing.InOutSine
        }
      }
    }
  }

  // ========================================================
  // 3. EXPANDED HOVER VIEW: Big Time + 7-Day Strip + Swipe Hint
  // ========================================================
  Item {
    width: hoverRow.implicitWidth + 36
    height: hoverRow.implicitHeight + 36
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    opacity: root.showHover ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 260
        easing.type: Easing.OutCubic
      }
    }

    HoverHandler {
      id: hoverMediaHandler
      onHoveredChanged: root.mediaHover = hovered
    }

    // Safety: if hover sticks while this view hides, force it back so the
    // pill can collapse (Esc / click-outside rely on isExpanded going false).
    onVisibleChanged: {
      if (!visible) root.mediaHover = false;
    }

    Row {
      id: hoverRow
      anchors.top: parent.top
      anchors.topMargin: 16
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      // LEFT: Now playing (only when a track is active)
      Item {
        id: hoverMedia
        anchors.verticalCenter: parent.verticalCenter
        visible: MediaState.hasTrack
        width: visible ? 236 : 0
        height: Math.max(mediaCol.height, clockCol.height)

        readonly property var player: MediaState.activePlayer
        readonly property bool playing: MediaState.isPlaying
        readonly property real frac: (player && player.length > 0) ? Math.min(1, Math.max(0, (player.position || 0) / player.length)) : 0

        // Directional poster flip: next song flips toward the right,
        // previous song flips toward the left.
        property int flipDir: 1 // 1 = next/right, -1 = prev/left
        property int animDir: 1
        property bool _artInit: false
        // Frozen display values: swapped atomically at the flip midpoint so
        // staged MPRIS metadata (title first, art later) never half-updates.
        property string shownArtUrl: ""
        property string shownTitle: "Unknown Title"
        property string shownAlbum: ""
        property string shownArtist: ""
        readonly property string trackKey: (hoverMedia.player?.trackTitle ?? "") + "\n" + (hoverMedia.player?.trackArtist ?? "") + "|" + (hoverMedia.player?.trackArtUrl ?? "")
        onTrackKeyChanged: {
          if (hoverMedia._artInit) {
            // Coalesce staged metadata arrivals into a single flip.
            artSettle.restart();
          } else {
            hoverMedia._artInit = true;
            hoverMedia.syncShown();
          }
        }

        function syncShown(): void {
          var p = hoverMedia.player;
          hoverMedia.shownTitle = p?.trackTitle || "Unknown Title";
          hoverMedia.shownAlbum = p?.trackAlbum || p?.identity || "";
          hoverMedia.shownArtist = p?.trackArtist || "";
          hoverMedia.shownArtUrl = p?.trackArtUrl ?? "";
        }

        // Fires once metadata settles: preload new art so the flip
        // midpoint never shows a blank while the image downloads.
        Timer {
          id: artSettle
          interval: 180
          repeat: false
          onTriggered: {
            var art = hoverMedia.player?.trackArtUrl ?? "";
            if (art === "" || art === hoverMedia.shownArtUrl) {
              hoverMedia.syncShown();
              hoverMedia.flipArt();
            } else {
              artPreload.source = art;
              artFallbackTimer.restart();
            }
          }
        }

        // Offscreen preloader sharing the image cache with the poster.
        Image {
          id: artPreload
          visible: false
          asynchronous: true
          sourceSize.width: 168
          sourceSize.height: 168
          onStatusChanged: {
            if (status === Image.Ready) {
              artFallbackTimer.stop();
              hoverMedia.syncShown();
              hoverMedia.flipArt();
            } else if (status === Image.Error) {
              artFallbackTimer.stop();
              hoverMedia.syncShown();
              hoverMedia.shownArtUrl = "";
              hoverMedia.flipArt();
            }
          }
        }

        // Never leave the UI stuck waiting on a hung download.
        Timer {
          id: artFallbackTimer
          interval: 1500
          repeat: false
          onTriggered: {
            artPreload.source = "";
            hoverMedia.syncShown();
            hoverMedia.flipArt();
          }
        }

        function flipArt(): void {
          hoverMedia.animDir = hoverMedia.flipDir;
          hoverArtShift.x = 0;
          hoverArtScale.xScale = 1;
          hoverArtFlipAnim.restart();
        }

        SequentialAnimation {
          id: hoverArtFlipAnim
          // Phase 1: collapse edge-on while drifting toward the flip direction
          ParallelAnimation {
            NumberAnimation { target: hoverArtScale; property: "xScale"; from: 1; to: 0; duration: 140; easing.type: Easing.InQuad }
            NumberAnimation { target: hoverArtShift; property: "x"; from: 0; to: 18 * hoverMedia.animDir; duration: 140; easing.type: Easing.InQuad }
          }
          // Swap the poster at the edge-on midpoint
          ScriptAction { script: { hoverMedia.shownArtUrl = hoverMedia.player?.trackArtUrl ?? ""; hoverArtShift.x = -18 * hoverMedia.animDir; } }
          // Phase 2: expand back from the opposite side
          ParallelAnimation {
            NumberAnimation { target: hoverArtScale; property: "xScale"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: hoverArtShift; property: "x"; from: -18 * hoverMedia.animDir; to: 0; duration: 200; easing.type: Easing.OutCubic }
          }
        }

        Column {
          id: mediaCol
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width
          spacing: 4
          visible: hoverMedia.visible

          Row {
            width: parent.width
            spacing: 10

            Item {
              width: 84
              height: 84
              anchors.verticalCenter: parent.verticalCenter

              SquircleBackground {
                id: hoverArtMask
                radius: 22
                power: SettingsState.cardRoundingPower
                fillColor: SettingsState.bgActivePill
                strokeColor: "transparent"
                strokeWidth: 0
                visible: false
                layer.enabled: true
              }

              SquircleBackground {
                radius: 22
                power: SettingsState.cardRoundingPower
                fillColor: SettingsState.bgActivePill
                strokeColor: "transparent"
                strokeWidth: 0
              }

              Item {
                id: hoverArtFlip
                anchors.fill: parent
                visible: hoverMedia.shownArtUrl !== ""
                layer.enabled: true
                layer.effect: MultiEffect {
                  maskEnabled: true
                  maskSource: hoverArtMask
                  maskThresholdMin: 0.5
                  maskSpreadAtMin: 1.0
                }
                transform: [
                  Translate { id: hoverArtShift },
                  Scale { id: hoverArtScale; origin.x: 42; origin.y: 42 }
                ]

                Image {
                  anchors.fill: parent
                  source: hoverMedia.shownArtUrl
                  fillMode: Image.PreserveAspectCrop
                  smooth: true
                  asynchronous: true
                  visible: hoverMedia.shownArtUrl !== ""
                }
              }

              Text {
                anchors.centerIn: parent
                visible: hoverMedia.shownArtUrl === ""
                text: ""
                font.family: SettingsState.nerdIconFont
                color: SettingsState.textSecondary
                font.pixelSize: SettingsState.px(18)
              }

              // Crisp squircle frame over the art: evens out the masked
              // edge and stays put while the poster flips beneath it.
              SquircleBackground {
                radius: 22
                power: SettingsState.cardRoundingPower
                fillColor: "transparent"
                strokeColor: SettingsState.barBorder
                strokeWidth: 1
              }
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 94
              spacing: 1

              Text {
                width: parent.width
                text: hoverMedia.player?.trackTitle || "Unknown Title"
                color: SettingsState.textMain
                font.pixelSize: SettingsState.px(10)
                font.bold: true
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                maximumLineCount: 1
              }

              Text {
                width: parent.width
                text: hoverMedia.player?.trackAlbum || hoverMedia.player?.identity || ""
                color: SettingsState.textSecondary
                font.pixelSize: SettingsState.px(9)
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
              }

              Text {
                width: parent.width
                text: hoverMedia.player?.trackArtist || ""
                color: SettingsState.textSecondary
                font.pixelSize: SettingsState.px(9)
                font.family: SettingsState.fontFamily
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
              }

              // Progress: thin wavy slider (above controls)
              Item {
                id: hoverProgTrack
                width: parent.width
                height: 18

                readonly property real liveFraction: hoverMedia.frac
                property real currentPos: liveFraction
                readonly property real shown: Math.min(1, Math.max(0, currentPos))

                onLiveFractionChanged: {
                  if (!hoverSeekAnim.running && !hoverSeekMouse.pressed) {
                    currentPos = liveFraction;
                  }
                }
                onShownChanged: hoverProgCanvas.requestPaint()
                onCurrentPosChanged: {
                  hoverProgCanvas.requestPaint();
                  if (hoverSeekMouse && (hoverSeekMouse.containsMouse || hoverSeekMouse.pressed || hoverSeekAnim.running))
                    AmeState.followTickH(hoverProgTrack, shown);
                }
                onWidthChanged: hoverProgCanvas.requestPaint()

                NumberAnimation {
                  id: hoverSeekAnim
                  target: hoverProgTrack
                  property: "currentPos"
                  duration: 350
                  easing.type: Easing.InOutCubic
                  onRunningChanged: hoverProgCanvas.requestPaint()
                  onFinished: {
                    if (!hoverSeekMouse.pressed) {
                      hoverProgTrack.currentPos = hoverProgTrack.liveFraction;
                      hoverProgCanvas.requestPaint();
                    }
                  }
                }

                Canvas {
                  id: hoverProgCanvas
                  anchors.fill: parent
                  antialiasing: true
                  renderStrategy: Canvas.Immediate
                  onPaint: {
                    WavyPaint.paint(getContext("2d"), width, height, {
                      shown: hoverProgTrack.shown,
                      showTrack: true,
                      showHandle: false,
                      trackGap: 6,
                      showRemaining: false,
                      waveColor: SettingsState.accent,
                      trackColor: SettingsState.isDark ? "#4E445F" : "#D6CFE3",
                      handleColor: SettingsState.accent,
                      trackH: 3,
                      waveW: 3,
                      waveAmp: 2,
                      waveLen: width / 2,
                      handleW: 5,
                      handleH: 14
                    });
                  }
                }

                Connections {
                  target: SettingsState
                  function onAccentChanged() { hoverProgCanvas.requestPaint(); }
                  function onIsDarkChanged() { hoverProgCanvas.requestPaint(); }
                }

                function applySeek(fraction) {
                  var p = hoverMedia.player;
                  if (p && p.canSeek && p.length > 0) {
                    p.position = fraction * p.length;
                  }
                }

                MouseArea {
                  id: hoverSeekMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  property real startX: 0
                  property bool dragging: false
                  onContainsMouseChanged: {
                    if (containsMouse)
                      AmeState.followTickH(hoverProgTrack, hoverProgTrack.shown);
                  }
                  onPressed: function (ev) {
                    if (hoverProgTrack.width <= 0) return;
                    hoverSeekMouse.startX = ev.x;
                    hoverSeekMouse.dragging = false;
                    var startVal = hoverProgTrack.currentPos;
                    var r = Math.min(1, Math.max(0, ev.x / hoverProgTrack.width));
                    hoverSeekAnim.stop();
                    hoverProgTrack.currentPos = startVal;
                    hoverSeekAnim.from = startVal;
                    hoverSeekAnim.to = r;
                    hoverSeekAnim.restart();
                    hoverProgTrack.applySeek(r);
                    AmeState.followTickH(hoverProgTrack, hoverProgTrack.shown);
                  }
                  onPositionChanged: function (ev) {
                    if (!pressed || hoverProgTrack.width <= 0) return;
                    if (!hoverSeekMouse.dragging && Math.abs(ev.x - hoverSeekMouse.startX) > 4) {
                      hoverSeekMouse.dragging = true;
                      hoverSeekAnim.stop();
                    }
                    if (hoverSeekMouse.dragging) {
                      var r = Math.min(1, Math.max(0, ev.x / hoverProgTrack.width));
                      hoverProgTrack.currentPos = r;
                      hoverProgCanvas.requestPaint();
                      hoverProgTrack.applySeek(r);
                      AmeState.followTickH(hoverProgTrack, r);
                    }
                  }
                  onReleased: function () {
                    hoverSeekMouse.dragging = false;
                  }
                }
              }

              // Controls: small icon-only prev / play-pause / next
              Row {
                spacing: 8

                Item {
                  width: 24
                  height: 20
                  opacity: hoverMedia.player?.canGoPrevious ? 1 : 0.3

                  Text {
                    anchors.centerIn: parent
                    text: "󰼨"
                    font.family: SettingsState.nerdIconFont
                    color: hoverPrev.containsMouse ? SettingsState.accent : SettingsState.textMain
                    font.pixelSize: SettingsState.px(14)
                  }

                  MouseArea {
                    id: hoverPrev
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: Boolean(hoverMedia.player?.canGoPrevious)
                    onContainsMouseChanged: {
                      if (containsMouse)
                        AmeState.follow(parent);
                    }
                    onClicked: {
                      hoverMedia.flipDir = -1;
                      if (hoverMedia.player) hoverMedia.player.previous();
                    }
                  }
                }

                Item {
                  width: 24
                  height: 20

                  Text {
                    anchors.centerIn: parent
                    text: hoverMedia.playing ? "󰏤" : "󰐊"
                    font.family: SettingsState.nerdIconFont
                    color: hoverPlay.containsMouse ? SettingsState.accent : SettingsState.textMain
                    font.pixelSize: SettingsState.px(15)
                  }

                  MouseArea {
                    id: hoverPlay
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: Boolean(hoverMedia.player?.canTogglePlaying)
                    onContainsMouseChanged: {
                      if (containsMouse)
                        AmeState.follow(parent);
                    }
                    onClicked: {
                      if (hoverMedia.player) hoverMedia.player.togglePlaying();
                    }
                  }
                }

                Item {
                  width: 24
                  height: 20
                  opacity: hoverMedia.player?.canGoNext ? 1 : 0.3

                  Text {
                    anchors.centerIn: parent
                    text: "󰼧"
                    font.family: SettingsState.nerdIconFont
                    color: hoverNext.containsMouse ? SettingsState.accent : SettingsState.textMain
                    font.pixelSize: SettingsState.px(14)
                  }

                  MouseArea {
                    id: hoverNext
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: Boolean(hoverMedia.player?.canGoNext)
                    onContainsMouseChanged: {
                      if (containsMouse)
                        AmeState.follow(parent);
                    }
                    onClicked: {
                      hoverMedia.flipDir = 1;
                      if (hoverMedia.player) hoverMedia.player.next();
                    }
                  }
                }
              }
            }
          }
        }
      }

            Column {
      id: clockCol
      anchors.verticalCenter: parent.verticalCenter
      width: MediaState.hasTrack ? 196 : 170
      spacing: 2

      // Big time - centered, AM/PM as small superscript
      Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: bigTimeText.implicitWidth
        height: bigTimeText.height

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: bigTimeText.left
          anchors.rightMargin: 8
          width: 10
          height: 10
          radius: 5
          color: "#ff453a"
          visible: RecorderState.isRecording

          SequentialAnimation on opacity {
            running: RecorderState.isRecording
            loops: Animation.Infinite
            NumberAnimation {
              from: 1.0
              to: 0.2
              duration: 900
              easing.type: Easing.InOutSine
            }
            NumberAnimation {
              from: 0.2
              to: 1.0
              duration: 900
              easing.type: Easing.InOutSine
            }
          }
        }

        Text {
          id: bigTimeText
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          text: {
            var h = root.date.getHours();
            var m = root.date.getMinutes();
            var s = root.date.getSeconds();
            function pad(n) {
              return (n < 10 ? "0" : "") + n;
            }
            if (SettingsState.timeFormat === "24h") {
              return pad(h) + ":" + pad(m) + (SettingsState.clockSeconds ? ":" + pad(s) : "");
            }
            var h12 = h % 12;
            if (h12 === 0) {
              h12 = 12;
            }
            return pad(h12) + ":" + pad(m) + (SettingsState.clockSeconds ? ":" + pad(s) : "");
          }
          color: RecorderState.isRecording ? "#ff453a" : SettingsState.accent
          font.pixelSize: SettingsState.px(30)
          font.bold: true
          font.family: SettingsState.fontFamily
        }
        Text {
          id: ampmText
          anchors.left: bigTimeText.right
          anchors.leftMargin: 3
          anchors.top: bigTimeText.top
          anchors.topMargin: 5
          visible: SettingsState.timeFormat !== "24h"
          text: Qt.formatDateTime(root.date, "AP")
          color: SettingsState.accent
          opacity: 0.7
          font.pixelSize: SettingsState.px(11)
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }

      // 5-day strip centered on today (today-2 .. today+2), today full name + big date
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Repeater {
          model: 5

          delegate: Column {
            property int dist: Math.abs(index - 2)
            width: dist === 0 ? 32 : (dist === 1 ? 26 : 22)
            spacing: 2
            // Today biggest + brightest, ±1 medium, ±2 smallest + dimmest.
            opacity: dist === 0 ? 1.0 : (dist === 1 ? 0.7 : 0.38)

            property var dayDate: {
              var d = new Date(root.date);
              d.setDate(d.getDate() + (index - 2));
              return d;
            }
            property bool isToday: index === 2
            property bool isSunday: dayDate.getDay() === 0

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: isToday ? Qt.formatDateTime(dayDate, "ddd").toUpperCase() : Qt.formatDateTime(dayDate, "ddd").substring(0, 1).toUpperCase()
              color: isToday ? SettingsState.accent : (isSunday ? "#e86a65" : SettingsState.textMuted)
              font.pixelSize: SettingsState.px(parent.dist === 0 ? 11 : (parent.dist === 1 ? 10 : 9))
              font.bold: isToday || isSunday
              font.family: SettingsState.fontFamily
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: Qt.formatDateTime(dayDate, "d")
              color: isToday ? SettingsState.accent : (isSunday ? "#e86a65" : SettingsState.textSecondary)
              font.pixelSize: SettingsState.px(parent.dist === 0 ? 20 : (parent.dist === 1 ? 15 : 12))
              font.bold: isToday
              font.family: SettingsState.fontFamily
            }
          }
        }
      }
      }

    }
  }

  // ========================================================
  // 4. CONTROL CENTER VIEW (right swipe in center bar; calendar is a pill inside)
  // ========================================================
  CenterCC {
    id: ccView
    width: ccView.implicitWidth
    height: ccView.implicitHeight
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    opacity: (root.isExpanded && root.showCC && !root.showTimer && !root.showReminders && !root.showFileTray && !root.showLauncher && !root.showWallpaper && !root.showPower && !root.showClipboard && !root.showMixer && !root.showAuth && !root.showNotif && !root.showInbox && !root.showReminderPrompt && !root.showAbout) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: root.isExpanded ? 280 : 160
        easing.type: root.isExpanded ? Easing.InOutCubic : Easing.OutCubic
      }
    }
  }

  // ========================================================
  // 4b. TIMER VIEW (left swipe: Clock -> Calendar -> Timer -> Reminders)
  // ========================================================
  TimerView {
    id: timerView
    anchors.fill: parent
    clip: true
    opacity: (root.isExpanded && root.showTimer) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 260
        easing.type: Easing.OutCubic
      }
    }
  }

  // ========================================================
  // 4c. REMINDER LIST VIEW (left-swipe: Clock -> Calendar -> Timer -> Reminders)
  // ========================================================
  Item {
    id: reminderWrap
    anchors.fill: parent
    opacity: (root.isExpanded && root.showReminders) ? 1 : 0
    visible: opacity > 0

    property bool remHover: false

    HoverHandler {
      id: remHoverHandler
      onHoveredChanged: reminderWrap.remHover = hovered
    }

    onVisibleChanged: {
      if (!visible) reminderWrap.remHover = false;
    }

    ReminderView {
      id: reminderListView
      anchors.fill: parent
      anchors.margins: 16
    }

    Behavior on opacity {
      NumberAnimation {
        duration: 260
        easing.type: Easing.OutCubic
      }
    }
  }

  // ========================================================
  // 5. EMBEDDED APP LAUNCHER VIEW (Directly inside Center Bar)
  // ========================================================
  LauncherContent {
    id: launcherContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showLauncher) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 6. EMBEDDED WALLPAPER SELECTOR VIEW (Directly inside Center Bar)
  // ========================================================
  WallpaperContent {
    id: wallpaperContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showWallpaper) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 7. EMBEDDED POWER MENU VIEW (Directly inside Center Bar)
  // ========================================================
  PowerMenuContent {
    id: powerMenuContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showPower) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 8. EMBEDDED CLIPBOARD HISTORY VIEW (Directly inside Center Bar)
  // ========================================================
  ClipboardContent {
    id: clipboardContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showClipboard) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 9. EMBEDDED HARDWARE MIXER VIEW (Directly inside Center Bar)
  // ========================================================
  HardwareMixerContent {
    id: hardwareMixerContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showMixer) ? 1 : 0
    visible: opacity > 0
    onOpenSoundSettings: root.openCCPage("sound")
    onOpenMicSettings: root.openCCPage("mic")

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 10. EMBEDDED SYSTEM & WI-FI AUTHENTICATION VIEW (Directly inside Center Bar)
  // ========================================================
  AuthContent {
    id: authContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showAuth) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 11. EMBEDDED NOTIFICATION VIEW (Directly inside Center Bar)
  // ========================================================
  NotificationContent {
    id: notificationContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showNotif && !root.showInbox) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 11b. EMBEDDED NOTIFICATION INBOX VIEW (Super+Ctrl+N)
  // ========================================================
  NotifInboxContent {
    id: notifInboxContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showInbox) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // 12. EMBEDDED FILE SHELF VIEW (Directly inside Center Bar)
  // ========================================================
  FileTrayContent {
    id: fileTrayContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showFileTray && !root.showInbox) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 13. EMBEDDED ABOUT / PROFILE LINKS VIEW (keybind Super+Ctrl+A)
  // ========================================================
  AboutContent {
    id: aboutContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showAbout && !root.showInbox) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // ========================================================
  // 14. EMBEDDED REMINDER PROMPT VIEW (keybind / IPC)
  // ========================================================
  ReminderPromptContent {
    id: reminderPromptContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showReminderPrompt && !root.showInbox) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }
  }

  // Close the control center / timer shortly after the pointer fully leaves
  // the pill (both the gesture layer and inner buttons). The delay avoids
  // flicker when moving between the background and inner buttons.
  Timer {
    id: leaveTimer
    interval: 350
    repeat: false
    onTriggered: {
      if (!mouse.containsMouse && !root.calHovering && !root.timerHovering && !root.remHovering && !root.mediaHover && !ReminderState.editing) {
        root.collapseSwipe();
      }
    }
  }

  function pokeLeaveTimer(): void {
    if (!mouse.containsMouse && !root.calHovering && !root.timerHovering && !root.remHovering && !root.mediaHover) {
      root.dismissLock = false;
    }
    if (mouse.containsMouse || root.calHovering || root.timerHovering || root.remHovering || root.mediaHover) {
      leaveTimer.stop();
    } else {
      leaveTimer.restart();
    }
  }

  onCalHoveringChanged: pokeLeaveTimer()
  onTimerHoveringChanged: pokeLeaveTimer()
  onRemHoveringChanged: pokeLeaveTimer()
  onMediaHoverChanged: pokeLeaveTimer()
  // A page switch hides the old anchor's view: drop the bead until the next
  // hover instead of parking it on a stale position.
  onShowCCChanged: if (!showCC) AmeState.clear()
  onShowMixerChanged: if (!showMixer) AmeState.clear()
  onShowLauncherChanged: if (!showLauncher) AmeState.clear()
  onShowWallpaperChanged: if (!showWallpaper) AmeState.clear()
  onShowPowerChanged: if (!showPower) AmeState.clear()
  onShowClipboardChanged: if (!showClipboard) AmeState.clear()
  onShowAuthChanged: if (!showAuth) AmeState.clear()
  onShowInboxChanged: if (!showInbox) AmeState.clear()
  onShowReminderPromptChanged: if (!showReminderPrompt) AmeState.clear()

  Connections {
    target: ccView
    function onActivePageChanged() {
      AmeState.clear();
    }
  }
  onIsTimerViewChanged: {
    if (TimerState.open !== root.isTimerView)
      TimerState.open = root.isTimerView;
  }
  onIsControlCenterViewChanged: {
    if (!root.isControlCenterView && CCState.open)
      CCState.open = false;
  }

  // GESTURE & INTERACTION HANDLER
  // ========================================================
  property real _pressX: 0
  property real _pressY: 0
  property bool _swiped: false
  property real _wheelAccumX: 0
  property bool _wheelCooldown: false
  Timer {
    id: wheelCooldownTimer
    interval: 350
    repeat: false
    onTriggered: {
      root._wheelCooldown = false;
      root._wheelAccumX = 0;
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    z: -1
    enabled: !root.showLauncher && !root.showWallpaper && !root.showPower && !root.showClipboard && !root.showMixer && !root.showAuth && !root.showNotif && !root.showInbox && !root.showFileTray && !root.showAbout && !root.showReminderPrompt && !root.hoverReset
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: function(ev) {
      root.dismissLock = false;
      root._pressX = ev.x;
      root._pressY = ev.y;
      root._swiped = false;
    }

    // Plain click on the pill background dismisses sticky swipe views.
    // (A real swipe drag never triggers onClicked, so gestures are unaffected.)
    onClicked: function(ev) {
      // A swipe drag also ends with a release inside the pill: ignore that
      // release, otherwise every small swipe would be instantly undone and
      // only drags ending outside the card would stick. Plain taps dismiss.
      if (root._swiped) {
        root._swiped = false;
        return;
      }
      if (root.swipeOpen) {
        root.collapseAll();
        ev.accepted = true;
      }
    }

    onPositionChanged: function(ev) {
      // Swipe = press + drag. Ignore pure hover moves, otherwise merely
      // moving the mouse across the pill would open/close views.
      if (!mouse.pressed || root._swiped) {
        return;
      }
      var dx = ev.x - root._pressX;
      var dy = Math.abs(ev.y - root._pressY);

      // Left swipe: Clock -> Calendar -> Timer -> Reminders -> Clock
      // (ControlCenter -> Clock)
      if (dx < -14 && dy < 45) {
        root._swiped = true;
        root.triggerSwipeTransition();
        if (CalendarState.open) {
          CalendarState.close();
          root.isTimerView = true;
          TimerState.open = true;
        } else if (root.isControlCenterView || ScreenshotState.open || RecorderState.open) {
          root.isControlCenterView = false;
          CalendarState.close();
          ScreenshotState.close();
          RecorderState.close();
          ccResetTimer.restart();
        } else if (root.isTimerView) {
          root.isTimerView = false;
          TimerState.open = false;
          root.isReminderView = true;
        } else if (root.isReminderView) {
          root.isReminderView = false;
          if (ReminderState.editing) ReminderState.editing = false;
        } else {
          root.dismissLock = false;
          root.isTimerView = true;
          TimerState.open = true;
          root.isReminderView = false;
          CalendarState.close();
          ScreenshotState.close();
          RecorderState.close();
        }
      }
      // Right swipe: Reminders -> Timer -> Clock -> Control Center
      // (calendar lives inside control center;
      //  right swipe on the calendar returns to Clock)
      else if (dx > 14 && dy < 45) {
        root._swiped = true;
        root.triggerSwipeTransition();
        if (root.isReminderView) {
          root.isReminderView = false;
          if (ReminderState.editing) ReminderState.editing = false;
          root.isTimerView = true;
          TimerState.open = true;
        } else if (root.isTimerView) {
          // Right swipe from timer returns to Clock
          root.isTimerView = false;
          TimerState.open = false;
          root.isReminderView = false;
          CalendarState.close();
        } else if (CalendarState.open) {
          CalendarState.close();
          root.isControlCenterView = false;
        } else if (!root.isControlCenterView && !ScreenshotState.open && !RecorderState.open) {
          root.isControlCenterView = true;
          if (ccView) ccView.activePage = "main";
        }
      }
    }

    onWheel: wheel => {
      if (root._wheelCooldown) return;

      var dx = wheel.pixelDelta.x !== 0 ? wheel.pixelDelta.x : (wheel.angleDelta.x / 4.0);
      root._wheelAccumX += dx;

      // Touchpad horizontal swipe left: CC -> Clock, Clock -> Timer -> Reminders -> Clock
      if (root._wheelAccumX < -28) {
        root._wheelCooldown = true;
        wheelCooldownTimer.restart();
        root.triggerSwipeTransition();

        if (CalendarState.open) {
          CalendarState.close();
          root.isTimerView = true;
          TimerState.open = true;
        } else if (root.isControlCenterView || ScreenshotState.open || RecorderState.open) {
          root.isControlCenterView = false;
          CalendarState.close();
          ScreenshotState.close();
          RecorderState.close();
          ccResetTimer.restart();
        } else if (root.isTimerView) {
          root.isTimerView = false;
          TimerState.open = false;
          root.isReminderView = true;
        } else if (root.isReminderView) {
          root.isReminderView = false;
          if (ReminderState.editing) ReminderState.editing = false;
        } else {
          root.dismissLock = false;
          root.isTimerView = true;
          TimerState.open = true;
          root.isReminderView = false;
          CalendarState.close();
          ScreenshotState.close();
          RecorderState.close();
        }
      }
      // Touchpad horizontal swipe right: Reminders -> Timer -> Clock -> Control Center
      // (calendar -> Clock)
      else if (root._wheelAccumX > 28) {
        root._wheelCooldown = true;
        wheelCooldownTimer.restart();
        root.triggerSwipeTransition();

        if (root.isReminderView) {
          root.isReminderView = false;
          if (ReminderState.editing) ReminderState.editing = false;
          root.isTimerView = true;
          TimerState.open = true;
        } else if (root.isTimerView) {
          // Right swipe from timer returns to Clock
          root.isTimerView = false;
          TimerState.open = false;
          root.isReminderView = false;
          CalendarState.close();
        } else if (CalendarState.open) {
          CalendarState.close();
          root.isControlCenterView = false;
        } else if (!root.isControlCenterView && !ScreenshotState.open && !RecorderState.open) {
          root.isControlCenterView = true;
          if (ccView) ccView.activePage = "main";
        }
      }
      // Vertical scroll -> Workspace switch
      else if (Math.abs(wheel.angleDelta.y) > 40 && Math.abs(wheel.angleDelta.y) > Math.abs(wheel.angleDelta.x)) {
        if (wheel.angleDelta.y > 0) {
          Hyprland.dispatch("workspace e-1");
        } else if (wheel.angleDelta.y < 0) {
          Hyprland.dispatch("workspace e+1");
        }
      }
    }
  }

  // FILE SHELF DROP ZONE — covers the whole pill so files can be
  // dropped anywhere on the clock bar. Expands the bar on hover.
  DropArea {
    anchors.fill: parent
    z: 100
    onEntered: function(drag) {
      if (drag.hasUrls) {
        FileTrayState.dndHover = true;
      }
    }
    onExited: {
      FileTrayState.dndHover = false;
    }
    onDropped: function(drop) {
      FileTrayState.dndHover = false;
      if (drop.hasUrls && drop.urls.length > 0) {
        FileTrayState.addUrls(drop.urls);
        FileTrayState.openTray();
        drop.accept();
      }
    }
  }

}
