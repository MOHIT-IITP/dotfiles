#!/usr/bin/env bash
# install.sh — install every package this Quickshell bar depends on (Arch Linux).
#
# Usage:
#   ./install.sh [--yes] [--no-aur] [--no-fonts] [--aur-helper=yay|paru]
#
# Official repo packages go through pacman, AUR packages through yay/paru,
# and the CommitMono Nerd Font (icon font, not packaged) is fetched from the
# upstream nerd-fonts GitHub release.

set -u

YES=""
NO_AUR=""
NO_FONTS=""
AUR_HELPER=""

for arg in "$@"; do
    case "$arg" in
        --yes) YES="--noconfirm" ;;
        --no-aur) NO_AUR="1" ;;
        --no-fonts) NO_FONTS="1" ;;
        --aur-helper=*) AUR_HELPER="${arg#*=}" ;;
        -h|--help)
            echo "Usage: $0 [--yes] [--no-aur] [--no-fonts] [--aur-helper=yay|paru]"
            exit 0
            ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run as root; sudo is used where needed." >&2
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found — this script targets Arch Linux." >&2
    exit 1
fi

# --- Official repo packages -------------------------------------------------
# shell itself ......... quickshell
# compositor ........... hyprland (+ hyprctl), hyprsunset (nightlight)
# screenshots .......... hyprshot, slurp (region picker)
# screen recording ..... gpu-screen-recorder (primary), wf-recorder (fallback)
# clipboard ............ wl-clipboard (wl-copy/wl-paste), cliphist
# image thumbs ......... imagemagick (magick)
# audio ................ pipewire, wireplumber (wpctl), libpulse (pactl),
#                        libcanberra + sound theme (screenshot shutter sound)
# desktop integration .. libnotify (notify-send), xdg-utils (xdg-open),
#                        curl (weather via wttr.in), polkit + python-gobject
#                        (polkit agent), python (helper scripts)
# media/files .......... mpv (play recordings), thunar (reveal in folder),
#                        gthumb (open photos), fd (launcher file search)
# connectivity ......... networkmanager (nmcli), bluez + bluez-utils (bluetooth)
# brightness ........... brightnessctl (laptops), ddcutil (desktop monitors)
# extras ............... cava (audio visualizer), awww (wallpaper daemon),
#                        matugen (theme colors), swaync (notifications)
# fonts ................ nerd fonts passthrough (icons) + emoji fallback
OFFICIAL_PKGS=(
    quickshell
    hyprland hyprsunset
    hyprshot slurp
    gpu-screen-recorder wf-recorder
    wl-clipboard cliphist
    imagemagick
    pipewire wireplumber libpulse libcanberra sound-theme-freedesktop
    libnotify xdg-utils curl polkit python-gobject python
    mpv thunar gthumb
    fd
    networkmanager bluez bluez-utils
    brightnessctl ddcutil
    cava
    awww matugen swaync
    ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-cascadia-code-nerd
    ttf-iosevka-nerd ttf-nerd-fonts-symbols
    noto-fonts noto-fonts-emoji
)

# --- AUR packages ------------------------------------------------------------
# python-pywal ......... `wal` (wallpaper colors, used by apply_wallpaper.sh)
# wl-screenrec ......... optional 2nd-fallback screen recorder
AUR_PKGS=(
    python-pywal
    wl-screenrec
)

echo "==> Installing official packages (pacman)…"
# shellcheck disable=SC2086
sudo pacman -S --needed $YES "${OFFICIAL_PKGS[@]}"

if [ -z "$NO_AUR" ]; then
    if [ -z "$AUR_HELPER" ]; then
        if command -v yay >/dev/null 2>&1; then
            AUR_HELPER="yay"
        elif command -v paru >/dev/null 2>&1; then
            AUR_HELPER="paru"
        fi
    fi
    if [ -n "$AUR_HELPER" ] && command -v "$AUR_HELPER" >/dev/null 2>&1; then
        echo "==> Installing AUR packages ($AUR_HELPER)…"
        # shellcheck disable=SC2086
        "$AUR_HELPER" -S --needed $YES "${AUR_PKGS[@]}"
    else
        echo "==> No AUR helper (yay/paru) found — install these manually:"
        printf '      %s\n' "${AUR_PKGS[@]}"
    fi
else
    echo "==> Skipping AUR packages (--no-aur)."
fi

if [ -z "$NO_FONTS" ]; then
    echo "==> Installing CommitMono Nerd Font Propo (bar icon font)…"
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    TMP_ZIP="$(mktemp --suffix=.zip)"
    if curl -sSL --max-time 120 \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/CommitMono.zip" \
        -o "$TMP_ZIP" \
        && unzip -o -j "$TMP_ZIP" 'CommitMonoNerdFontPropo-*' -d "$FONT_DIR" >/dev/null; then
        fc-cache -f "$FONT_DIR" >/dev/null
        echo "    CommitMono Nerd Font Propo installed."
    else
        echo "    WARNING: font download failed — grab CommitMono.zip from" >&2
        echo "    https://github.com/ryanoasis/nerd-fonts/releases and unzip the" >&2
        echo "    CommitMonoNerdFontPropo-* files into $FONT_DIR" >&2
    fi
    rm -f "$TMP_ZIP"
else
    echo "==> Skipping manual fonts (--no-fonts)."
fi

echo "==> Making helper scripts executable…"
chmod +x "$(dirname "$0")"/scripts/*.sh

echo "==> Enabling bluetooth service…"
sudo systemctl enable --now bluetooth 2>/dev/null || true

echo
echo "Done. Optional extras (not required):"
echo "  - dunst ............ alternative notification daemon (swaync is default)"
echo "  - quickshell-git ... bleeding-edge shell instead of stable 'quickshell'"
echo
echo "Then reload the shell (qs -c ~/.config/quickshell) or log out/in."
