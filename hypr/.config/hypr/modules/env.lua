-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER","wayland")
hl.env("CLUTTER_BACKEND","wayland")
hl.env("QT_QPA_PLATFORM","wayland;xcb")

hl.env(" XDG_CURRENT_DESKTOP","Hyprland")
hl.env("XDG_SESSION_TYPE","wayland")
hl.env("XDG_SESSION_DESKTOP","Hyprland")

hl.env("QT_QPA_PLATFORMTHEME","qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION","1")


hl.env("LIBVA_DRIVER_NAME","nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME","nvidia")
