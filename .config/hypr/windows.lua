-- Hyprland window rules for idle and media playback.

-- Inhibit idle when any window is fullscreen (watching videos, movies, gaming, etc.)
o.window(".*", { idle_inhibit = "fullscreen" })

-- Inhibit idle when watching Picture-in-Picture video
o.window({ tag = "pip" }, { idle_inhibit = "always" })
o.window({ title = "(Picture.?in.?[Pp]icture)" }, { idle_inhibit = "always" })



-- Utility floating window rules from 43PR dotfiles
o.window("^(pavucontrol)$", { float = true })
o.window("^(nm-connection-editor)$", { float = true })
o.window("^(blueman-manager)$", { float = true })
o.window({ title = "^(Open File)$" }, { float = true })
o.window({ title = "^(Save File)$" }, { float = true })

-- Eliminate distractions during video calls & meetings (Google Meet, Zoom, Teams, Webex)
o.window({ title = ".*([Mm]eet|[Zz]oom|[Tt]eams|[Ww]ebex).*" }, { opacity = "1.0 1.0", tag = "-default-opacity" })

-- Keep browsers solid so documents and web reading have zero wallpaper bleed
o.window("([fF]irefox|zen|librewolf|(google-)?[cC]hrom(e|ium)|[bB]rave-browser)", { opacity = "1.0 1.0", tag = "-default-opacity" })
