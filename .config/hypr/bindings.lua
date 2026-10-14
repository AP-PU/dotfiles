-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Gothic 4-Panel Rice Dashboard (Btop, Cava, Fastfetch, Cmatrix)
o.bind("SUPER + D", "Gothic Dashboard", (os.getenv("HOME") or "") .. "/.local/bin/gothic-dashboard")
