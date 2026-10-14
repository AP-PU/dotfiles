hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 5,
    border_size = 1,
    col = {
      active_border = { colors = { "rgba(fec99dee)", "rgba(990c31ee)" }, angle = 45 },
      inactive_border = "rgba(18181bee)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },
  render = {
    direct_scanout = true,
    expand_undersized_textures = false,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_scale_notification = true,
    focus_on_activate = true,
  },
  decoration = {
    rounding = 8,

    -- Minimal aesthetic frosted glass opacity
    active_opacity = 0.96,
    inactive_opacity = 0.90,
    fullscreen_opacity = 1.0,

    -- Disabled shadows for zero memory bandwidth overhead & peak FPS
    shadow = {
      enabled = false,
    },

    -- Minimal single-pass frosted glass blur (almost zero GPU resource usage)
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      noise = 0.01,
      contrast = 1.0,
      brightness = 0.95,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
    },
  },
  animations = {
    enabled = true,
  },
  cursor = {
    no_hardware_cursors = false,
  },
})

-- Cursor matching the Cyber-Bunny 43 theme
hl.env("XCURSOR_THEME", "macOS")
hl.env("HYPRCURSOR_THEME", "macOS")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- 43PR inspired hyper-responsive cubic-bezier curves (instantaneous feel, zero lag)
hl.curve("easeOutCyber", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

-- Frosted glass layer blur for all UI elements
hl.layer_rule({ match = { namespace = "^(omarchy-bar|omarchy-clipboard|omarchy-notifications|omarchy-osd|omarchy-emojis|omarchy-image-selector|omarchy-keyboard-panel|omarchy-menu|quickshell|lockscreen)$" }, blur = true, ignore_alpha = 0.15 })

-- Snappy, low-latency animations
hl.animation({ leaf = "windows",    enabled = true, speed = 4.2, bezier = "easeOutCyber" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.0, bezier = "overshot", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "easeOutCyber", style = "popin 92%" })
hl.animation({ leaf = "border",     enabled = true, speed = 4.0, bezier = "easeOutCyber" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.0, bezier = "easeOutCyber" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "easeOutCyber", style = "slidefadevert" })
