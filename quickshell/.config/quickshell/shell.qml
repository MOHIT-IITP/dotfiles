import Quickshell
import Quickshell.Io
import "modules/bar"
import "modules/services"

Scope {
  Bar {}

  // Hyprland keybinds IPC:
  // Super+Space: toggle launcher (apps)
  // Super+F: toggle file search launcher
  // Super+W: toggle wallpaper selector
  // Super+Ctrl+V: toggle clipboard history
  // Super+Ctrl+M: toggle hardware mixer
  // Super+Ctrl+N: toggle notification inbox
  // Super+Esc: toggle power menu
  IpcHandler {
    target: "mohiitp"

    function launcher(): void {
      if (LauncherState.open && LauncherState.mode === "apps")
        LauncherState.close();
      else
        LauncherState.openApps();
    }

    function files(): void {
      LauncherState.toggleFiles();
    }

    function fileSearch(): void {
      LauncherState.toggleFiles();
    }

    function wallpaper(): void {
      WallpaperState.toggle();
    }

    function power(): void {
      PowerState.toggle();
    }

    function clipboard(): void {
      ClipboardState.toggle();
    }

    function filetray(): void {
      FileTrayState.toggle();
    }

    function shelf(): void {
      FileTrayState.toggle();
    }

    function nightlight(): void {
      NightlightState.toggle();
    }

    function mixer(): void {
      MixerState.toggle();
    }

    function notifInbox(): void {
      NotifCenter.toggleInbox();
    }

    function notifications(): void {
      NotifCenter.toggleInbox();
    }

    function about(): void {
      AboutState.toggle();
    }

    function recorder(): void {
      RecorderState.toggle();
    }

    function calendar(): void {
      CalendarState.toggle();
    }

    function screenshot(): void {
      ScreenshotState.capture(ScreenshotState.mode);
    }

    function screenshotArea(): void {
      ScreenshotState.capture("area");
    }

    function screenshotWindow(): void {
      ScreenshotState.capture("window");
    }

    function screenshotDisplay(): void {
      ScreenshotState.capture("display");
    }

    function wifiAuth(ssid: string): void {
      AuthState.prompt(ssid);
    }

    function notifDebug(): string {
      try {
        var list = NotifCenter.trackedList || [];
        var out = [];
        for (var i = 0; i < list.length; ++i) {
          var n = list[i];
          out.push({
            appName: n ? n.appName : null,
            appIcon: n ? n.appIcon : null,
            summary: n ? n.summary : null,
            body: n ? n.body : null,
            hasImage: !!(n && n.image)
          });
        }
        return JSON.stringify({ count: NotifCenter.count, items: out });
      } catch (e) {
        return "ERR: " + e;
      }
    }
  }
}
