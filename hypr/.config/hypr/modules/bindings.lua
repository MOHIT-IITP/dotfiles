
local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local terminal    = "kitty"
local fileManager = "nautilus"
local browser = "google-chrome-stable"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + SHIFT + CTRL + ALT  + K  ", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + CTRL + ALT +  E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + CTRL + ALT + R", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. "+ SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. "+ SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + SHIFT + CTRL + ALT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + ALT + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + CTRL + R ", hl.dsp.exec_cmd("/home/mohiitp/.config/waybar/launch.sh"))
hl.bind(mainMod .. " + CTRL + T ", hl.dsp.exec_cmd("qs ipc call mohiitp wallpaper"))
hl.bind(mainMod .. " + CTRL + W ", hl.dsp.exec_cmd("qs ipc call mohiitp power"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call mohiitp launcher"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("qs ipc call mohiitp files"))
hl.bind(mainMod .. " + CTRL + R ", hl.dsp.exec_cmd("qs ipc call mohiitp recorderCard"))
hl.bind(mainMod .. " + CTRL + V ", hl.dsp.exec_cmd("qs ipc call mohiitp mixer "))
hl.bind(mainMod .. " + CTRL + C ", hl.dsp.exec_cmd("qs ipc call mohiitp clipboard  "))
hl.bind(mainMod .. " + CTRL + A ", hl.dsp.exec_cmd("qs ipc call mohiitp about"))
hl.bind(mainMod .. " + CTRL + N ", hl.dsp.exec_cmd("qs ipc call mohiitp notifInbox"))
hl.bind(mainMod .. " + R ", hl.dsp.exec_cmd("qs ipc call mohiitp reminder"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotCard"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("qs ipc call mohiitp cc"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotDisplay"))

-- Super+C / Super+V as Copy / Paste (terminal-aware)
-- Sends CTRL+C/V normally, CTRL+SHIFT+C/V in terminals where CTRL+C = interrupt
local terminal_classes = {
    "kitty",
    "ghostty",
    "alacritty",
    "foot",
    "wezterm",
    "terminal",
    "konsole",
}

local function is_terminal_window()
    local w   = hl.get_active_window()
    local cls = (w and w.class or ""):lower()

    for _, name in ipairs(terminal_classes) do
        if cls:find(name, 1, true) then
            return true
        end
    end

    return false
end

-- Hyprland 0.55+ can leave the synthetic modifier state stuck after
-- send_shortcut, which makes Super+C/V only work every few presses.
-- Sending an explicit key down/up pair keeps the keyboard state in sync.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_key_combo(mods, key)
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))

    hl.timer(function()
        hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
    end, { timeout = 50, type = "oneshot" })
end

hl.bind(mainMod .. " + C", function()
    if is_terminal_window() then
        send_key_combo("CTRL SHIFT", "C")
    else
        send_key_combo("CTRL", "C")
    end
end, { description = "Copy (Super+C)" })

hl.bind(mainMod .. " + V", function()
    if is_terminal_window() then
        send_key_combo("CTRL SHIFT", "V")
    else
        send_key_combo("CTRL", "V")
    end
end, { description = "Paste (Super+V)" })



-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j",  hl.dsp.focus({ direction = "down" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + SHIFT + h",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j",  hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true }, { description = "Increase window width with keyboard" })
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true }, { description = "Reduce window width with keyboard" })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true }, { description = "Increase window height with keyboard" })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true }, { description = "Reduce window height with keyboard" })



-- Toggle between dwindle and scrolling layout globally
hl.bind(mainMod.. " + ALT + L", function()
    local current_layout = hl.get_config("general.layout")
    
    if current_layout == "dwindle" then
        hl.config({ general = { layout = "scrolling" } })
    else
        hl.config({ general = { layout = "dwindle" } })
    end
end, { description = "Toggle Scrolling Layout globally" })

