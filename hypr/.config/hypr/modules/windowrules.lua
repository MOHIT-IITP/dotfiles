---------------------
---WINDOW RULES----
---------------------

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})


hl.layer_rule({
    name = "rofi-dropdown",
    match = { namespace = "rofi"},
    animation = "slide bottom",
    dim_around = true
})


hl.layer_rule({
    name="notification-animation",
    match = { namespace = "swaync-control-center"},
    animation = "slide top"
})

--------------------------
--- FLOATING DIALOGS -----
--------------------------
-- Main Chrome / Spotify stay tiled, only dialogs / login / PiP float

hl.window_rule({
    name = "chrome-dialogs-float",
    match = { class = "google-chrome", title = ".*(Open File|Save File|Save As|File Chooser|Dialog|Popup|Authentication|Login|Sign [Ii]n|OAuth|Print|Pay|Payment|Choose|Upload|Download|Save|Open).*" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "chrome-pip-float",
    match = { class = "google-chrome", title = ".*(Picture.?in.?Picture|Picture in picture|PiP).*" },
    float = true,
    center = true,
    size = "480 270",
    pin = true,
})

hl.window_rule({
    name = "spotify-dialogs-float",
    match = { class = "[Ss]potify.*", title = ".*(Login|Sign [Ii]n|Authentication|OAuth|Dialog|Popup|Open File|Save File|Choose|Settings|Preferences).*" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "spotify-pip-float",
    match = { class = "[Ss]potify.*", title = ".*(Picture.?in.?Picture|Mini player|Now Playing).*" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "portal-filechooser-float",
    match = { class = "xdg-desktop-portal-.*", title = ".*(Open File|Save File|.*File Chooser.*|Dialog|Authentication|Login).*" },
    float = true,
    center = true,
    size = "900 600",
})
