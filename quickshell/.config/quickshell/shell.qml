import Quickshell
import Quickshell.Io
import "modules/bar"
import "modules/services"

Scope {
  Bar {}

  // Hyprland keybinds IPC:
  // Super+Space: toggle launcher
  // Super+W: toggle wallpaper selector
  // Super+Ctrl+V: toggle clipboard history
  // Super+Ctrl+M: toggle hardware mixer
  // Super+Esc: toggle power menu
  IpcHandler {
    target: "mohiitp"

    function launcher(): void {
      LauncherState.toggle();
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

    function nightlight(): void {
      NightlightState.toggle();
    }

    function mixer(): void {
      MixerState.toggle();
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
  }
}
