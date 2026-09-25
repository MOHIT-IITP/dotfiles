
local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local terminal    = "kitty"
local fileManager = "thunar"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN  ", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "+ SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. "+ SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + CTRL + ALT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + ALT + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + CTRL + R ", hl.dsp.exec_cmd("/home/mohiitp/.config/waybar/launch.sh"))
hl.bind(mainMod .. " + CTRL + T ", hl.dsp.exec_cmd("qs ipc call mohiitp wallpaper"))
hl.bind(mainMod .. " + CTRL + W ", hl.dsp.exec_cmd("qs ipc call mohiitp power"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call mohiitp launcher"))
hl.bind(mainMod .. " + CTRL + R ", hl.dsp.exec_cmd("qs ipc call mohiitp recorder"))
hl.bind(mainMod .. " + CTRL + V ", hl.dsp.exec_cmd("qs ipc call mohiitp mixer "))
hl.bind(mainMod .. " + CTRL + C ", hl.dsp.exec_cmd("qs ipc call mohiitp clipboard  "))

-- Super+C / Super+V as Copy / Paste (terminal-aware)
-- Sends CTRL+C/V normally, CTRL+SHIFT+C/V in terminals where CTRL+C = interrupt
local function super_copy()
    local w = hl.get_active_window()
    local cls = (w and w.class or ""):lower()
    if cls:match("kitty") or cls:match("ghostty") or cls:match("alacritty") or cls:match("foot") or cls:match("wezterm") or cls:match("terminal") or cls:match("konsole") then
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "C" }))
    else
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }))
    end
end

local function super_paste()
    local w = hl.get_active_window()
    local cls = (w and w.class or ""):lower()
    if cls:match("kitty") or cls:match("ghostty") or cls:match("alacritty") or cls:match("foot") or cls:match("wezterm") or cls:match("terminal") or cls:match("konsole") then
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "V" }))
    else
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }))
    end
end

hl.bind(mainMod .. " + C", super_copy, { description = "Copy (Super+C)" })
hl.bind(mainMod .. " + V", super_paste, { description = "Paste (Super+V)" })

-- Screenshot keybindings:
-- Print / Super+Shift+S: Area capture (drag to select)
-- hl.bind("Print", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotArea"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotArea"))
-- Super+Alt+S / Alt+Print: Window capture (click window)
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotWindow"))
-- hl.bind("ALT + Print", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotWindow"))
-- Super+Ctrl+S / Ctrl+Print: Full Display capture
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotDisplay"))
-- hl.bind("CTRL + Print", hl.dsp.exec_cmd("qs ipc call mohiitp screenshotDisplay"))
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

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

