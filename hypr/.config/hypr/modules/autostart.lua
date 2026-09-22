-- auto start
hl.on("hyprland.start", function () 
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("quickshell --config ~/.config/quickshell")
  hl.exec_cmd("hyprsunset")
  hl.exec_cmd("pidof hypridle || hypridle")
end)
