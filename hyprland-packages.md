# Hyprland Fresh-Install Packages (Arch)

Generated from this dotfiles repo (`hypr/`, `quickshell/`, `swaync/`, `matugen/`, `fontconfig/`).
Package manager: `pacman` (official repos) + `yay`/`paru` (AUR).
`install` script in repo root already covers base CLI tools — this file covers **Hyprland + Quickshell**.

## 0. AUR helper (once)

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
```

## 1. Hyprland core

```bash
sudo pacman -S --needed \
  hyprland \
  hyprpaper \
  hyprlock \
  hypridle \
  hyprsunset \
  hyprshot \
  hyprpicker \
  hyprcursor \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  xdg-utils \
  xdg-user-dirs xdg-user-dirs-gtk \
  uwsm
```

Why: `autostart.lua` starts `hypridle`/`hyprsunset`; `hyprlock.conf`/`hypridle.conf` need `hyprlock`/`hypridle` + `brightnessctl`; `screenshot.sh` uses `hyprshot`; portals needed for screen-share/file-picker.

## 2. Quickshell (the bar / widgets)

You have `quickshell-git` installed. Either works:

```bash
# AUR (what you run now)
yay -S --needed quickshell-git

# OR official repo build
# sudo pacman -S --needed quickshell
```

Qt / runtime deps (pulled automatically, listed for completeness):

```bash
sudo pacman -S --needed \
  qt6-base qt6-declarative qt6-svg qt6-multimedia qt6-multimedia-ffmpeg \
  qt6-wayland qt6-5compat qt6-positioning qt6-shadertools \
  qt5-base qt5-declarative qt5-wayland \
  polkit qt6-svg libpipewire
```

Custom polkit agent (`modules/services/polkit_agent.py`) needs:

```bash
sudo pacman -S --needed polkit python-gobject python-dbus
# optional fallback agent:
sudo pacman -S --needed polkit-kde-agent
```

## 3. Wallpaper + theming (used by Quickshell)

`autostart.lua` runs `awww-daemon`; `scripts/apply_wallpaper.sh` runs `awww img ... && wal -i ... && matugen image ...` then restarts `swaync` + `notify-send`.

```bash
sudo pacman -S --needed awww matugen swaync libnotify
yay -S --needed python-pywal bibata-cursor-theme-bin
```

Optional live wallpapers (`mpvpaper`, used with `scan_wallpapers.sh` `.mp4` support):

```bash
yay -S --needed mpvpaper
```

## 4. Quickshell feature dependencies

| Quickshell feature | Files | Package |
|---|---|---|
| Audio devices (sinks/sources, set-default) | `scripts/audio_devices.sh`, `AudioState.qml` | `pipewire`, `wireplumber`, `pipewire-pulse` (provides `pactl` compat), `libpulse`, `pipewire-alsa`, `pipewire-jack` |
| Volume keys in Hyprland | `modules/bindings.lua` (`wpctl`) | same as above |
| Volume GUI | bar mixer | `pavucontrol` (GUI), optional `helvum`/`easyeffects` |
| Brightness (+ `hypridle.conf` resume/save) | `services/BrightnessState.qml`, `bindings.lua` (`brightnessctl`), `hypridle.conf` | `brightnessctl` |
| Night light | `services/NightlightState.qml` (`pgrep/pkill hyprsunset`) + `autostart.lua` | `hyprsunset` (see §1) |
| Network / Wi-Fi | `services/NetworkState.qml` (Quickshell.Networking), `AuthState.qml` (`nmcli`) | `networkmanager`, `network-manager-applet`, `nm-connection-editor` |
| Bluetooth | `services/BluetoothState.qml` (Quickshell.Bluetooth) | `bluez`, `bluez-utils`, `blueman` |
| Media (MPRIS) + media keys | `services/MediaState.qml`, `bindings.lua` (`playerctl`) | `playerctl` |
| Audio visualizer | `services/CavaState.qml`, `ClockPill.qml` (`cava -p ...`) | `cava` |
| Clipboard history + thumbs | `scripts/cliphist.sh`, `services/ClipboardState.qml` (`cliphist`, `wl-paste`/`wl-copy`, `magick`) | `cliphist`, `wl-clipboard`, `imagemagick` |
| Screenshots | `scripts/screenshot.sh` (`hyprshot`), shutter sound (`canberra-gtk-play`/`paplay`/`pw-play`) | `hyprshot`, `libcanberra`, `sound-theme-freedesktop`, `pipewire-pulse` (for `paplay`/`pw-play`) |
| Screen recorder | `scripts/recorder.sh` (prefers `gpu-screen-recorder`, falls back to `wf-recorder`/`wl-screenrec`), playback via `mpv`, open folder via `xdg-open` | `gpu-screen-recorder`, `wf-recorder`, `mpv`, `xdg-utils` |
| Notifications | `services/NotifCenter.qml` (`swaync`), `apply_wallpaper.sh` (`notify-send`) | `swaync`, `libnotify` |
| Weather / calendar | `services/CalendarState.qml` (`curl wttr.in`) | `curl` |
| Power menu (`poweroff/reboot/suspend`, `hyprlock`, `hyprctl dispatch exit`) | `PowerMenu*.qml`, `NetworkCircle.qml` | `systemd` (built-in `systemctl`/`loginctl`), `hyprlock`, `upower` |
| Battery / power profiles | `services/PowerState.qml` | `upower`, `power-profiles-daemon` |

One-shot install for all of §4:

```bash
sudo pacman -S --needed \
  pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack libpulse \
  pavucontrol \
  brightnessctl \
  networkmanager network-manager-applet nm-connection-editor \
  bluez bluez-utils blueman \
  playerctl \
  cava \
  cliphist wl-clipboard imagemagick \
  grim slurp \
  libcanberra sound-theme-freedesktop \
  gpu-screen-recorder wf-recorder mpv \
  curl jq python \
  upower power-profiles-daemon
sudo systemctl enable --now NetworkManager bluetooth
```

## 5. Launcher / app-integration (from `bindings.lua`)

```bash
sudo pacman -S --needed rofi thunar tumbler gvfs udisks2 udiskie kitty
```

Why: `terminal = "kitty"`, `fileManager = "thunar"`, `menu = "~/.config/rofi/type-2/launcher.sh"`. `gvfs`/`tumbler`/`udisks2`/`udiskie` give Thunar trash/thumbnails/auto-mount. Swap `thunar`→`nautilus` if you prefer GNOME files (your old `install` script used `nautilus`).

## 6. Cursor (Bibata)

`modules/env.lua` sets:

```
XCURSOR_THEME=Bibata-Modern-Classic  HYPRCURSOR_THEME=Bibata-Modern-Classic
XCURSOR_SIZE=28  HYPRCURSOR_SIZE=28
```

```bash
yay -S --needed bibata-cursor-theme-bin
sudo pacman -S --needed hyprcursor libxcursor xcb-util-cursor nwg-look
```

Use `nwg-look` (or `hyprctl setcursor`) to apply after install.

## 7. Fonts

`fontconfig/fonts.conf` maps `sans-serif→Liberation Sans`, `serif→Liberation Serif`, `monospace→DankMono Nerd Font`. Kitty uses `IosevkaTerm Nerd Font`, Ghostty uses `SF Mono`, Quickshell/bar uses Nerd Symbols + Font Awesome + Noto Emoji.

```bash
sudo pacman -S --needed \
  ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd ttf-iosevka-nerd ttf-iosevkaterm-nerd \
  ttf-cascadia-code-nerd ttf-firacode-nerd ttf-fira-code ttf-fira-mono \
  ttf-dejavu ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono \
  woff2-font-awesome \
  fontconfig
```

Bundled in repo (`my-goto-fonts/fonts/`): CaskaydiaCove Nerd Font — copy to `~/.local/share/fonts/` + `fc-cache -fv`.

Manual (licensed, copy yourself):
- `DankMono Nerd Font` (monospace default in `fonts.conf`)
- `SF Mono` (Ghostty `font-family`)

## 8. Base CLI / TUI (already in `install` script, keep for fresh install)

```bash
sudo pacman -S --needed \
  neovim vim fd ripgrep tmux grim slurp xclip wl-clipboard zoxide eza starship \
  nautilus yazi btop bat zsh kitty fzf emacs udiskie curl unzip 7zip zip \
  pavucontrol blueman bluez bluez-utils tree nodejs npm python gcc cmake stow
```

## Full copy-paste (official-repo part)

```bash
sudo pacman -S --needed hyprland hyprpaper hyprlock hypridle hyprsunset hyprshot hyprpicker hyprcursor \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils xdg-user-dirs xdg-user-dirs-gtk uwsm \
  quickshell qt6-base qt6-declarative qt6-svg qt6-multimedia qt6-multimedia-ffmpeg qt6-wayland qt6-5compat \
  qt5-base qt5-declarative qt5-wayland polkit python-gobject python-dbus polkit-kde-agent \
  awww matugen swaync libnotify \
  pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack libpulse pavucontrol \
  brightnessctl networkmanager network-manager-applet nm-connection-editor bluez bluez-utils blueman \
  playerctl cava cliphist wl-clipboard imagemagick grim slurp libcanberra sound-theme-freedesktop \
  gpu-screen-recorder wf-recorder mpv curl jq python upower power-profiles-daemon \
  rofi thunar tumbler gvfs udisks2 udiskie kitty ghostty alacritty \
  ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd \
  ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-cascadia-code-nerd ttf-firacode-nerd \
  ttf-nerd-fonts-symbols woff2-font-awesome fontconfig nwg-look

yay -S --needed quickshell-git python-pywal bibata-cursor-theme-bin mpvpaper
sudo systemctl enable --now NetworkManager bluetooth
```

> Nvidia (you set `LIBVA_DRIVER_NAME=nvidia`, `__GLX_VENDOR_LIBRARY_NAME=nvidia` in `env.lua`): add `nvidia-open nvidia-utils libva-nvidia-driver linux-firmware-nvidia` as needed.
