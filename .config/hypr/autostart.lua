-- Omarchy Autostart Services
o.launch_on_start("omarchy-live-wallpaper apply-theme")

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start omarchy-idle-inhibit.service")
end)
