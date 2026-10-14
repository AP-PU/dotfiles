# † Tenebris / Gothic Omarchy & Hyprland Dotfiles

A meticulously crafted, dark aesthetic rice for **Arch Linux / Omarchy** with **Hyprland**, featuring a Gothic Crimson-Coral & Antique Bronze palette, frosted glass layer blur, hyper-responsive cubic-bezier animations, Quickshell status bar widgets, custom lockscreens, and a 4-panel terminal dashboard.

---

## ✦ Aesthetic & Architecture Overview

* **Window Manager**: [Hyprland](https://hypr.land/) (snappy cubic-bezier curves `easeOutCyber` / `overshot`, single-pass low-overhead frosted glass blur, dynamic layer rules)
* **Shell & Bar**: [Omarchy](https://omarchy.org/) Quickshell with custom plugins:
  * `lohith.bar`: Custom indicators, status modules, and workspace pill switcher
  * `lohith.lock` & `tenebris.lock`: Gothic lockscreens featuring live MPRIS album art, media playback controls, and crystal diamond password bullets (`◆`)
  * `lohith.wallpapers`: Interactive graphical wallpaper picker and live color palette extractor
  * `akshar.radio-atlas`: Live world internet radio streaming widget with dynamic track info and MPRIS controls
  * `lohith.clock` & `lohith.weather`: Minimalist date, time, and weather popouts
* **Rice Dashboard**: Accessible via `Super + D` — launches a 4-panel synchronized rice dashboard:
  * Top-Left: **Btop** (custom Harbordark system monitor)
  * Top-Right: **Cava** (audio spectrum visualizer in crimson-bronze gradient)
  * Bottom-Left: **Fastfetch** (custom system information display with ASCII & anime art)
  * Bottom-Right: **Cmatrix** (crimson matrix rain)
* **Terminal**: [Foot](https://codeberg.org/dnkl/foot) (primary), [Ghostty](https://ghostty.org/), [Kitty](https://sw.kovidgoyal.net/kitty/)
* **Shell Prompt**: [Starship](https://starship.rs/) configured with the `TENEBRIS` aesthetic
* **Color Themes**:
  * `Harbordark`: Obsidian Black (`#111114`), Crimson Coral (`#E75A50`), Antique Bronze (`#A99B7A`), Cream White (`#EFEBDC`)
  * `bunny-girl` & `bunny-girl-senpai`: High-resolution anime wallpapers, themed shell overlays, and custom lockscreen assets

---

## ✦ Repository Structure

```text
dotfiles/
├── .config/
│   ├── 43pr/             # Dynamic multi-target theme engine & templates
│   ├── btop/             # Btop system monitor config and color themes
│   ├── cava/             # Audio visualizer config with 8-step gradient
│   ├── fastfetch/        # Fastfetch configuration and custom art assets
│   ├── fontconfig/       # Default font aliases (JetBrainsMono Nerd Font)
│   ├── foot/             # Foot terminal configuration
│   ├── ghostty/          # Ghostty terminal configuration
│   ├── gtk-3.0/          # GTK3 color styling & dark theme settings
│   ├── gtk-4.0/          # GTK4 color styling & dark theme settings
│   ├── herdr/            # Terminal multiplexer settings
│   ├── hypr/             # Hyprland window rules, animations, keybindings, lockscreen
│   ├── kitty/            # Kitty terminal and matugen configuration
│   ├── nvim/             # Neovim configuration with Omarchy theme hotreload
│   ├── omarchy/          # Quickshell plugins, shell.json, themes, and hooks
│   ├── starship.toml     # Starship gothic prompt configuration
│   ├── systemd/user/     # User systemd daemons (idle inhibit, live wallpaper, auto-png)
│   └── tmux/             # Tmux terminal multiplexer keybindings and theme
├── .local/
│   ├── bin/              # Custom scripts (dashboard, fetch, wallpaper palette, cursor switcher)
│   └── share/fonts/      # Required custom gothic & UI fonts
├── .bashrc               # Clean shell startup file with aliases
├── .bash_profile         # Profile loader
├── .zshrc                # Zsh startup file
├── .gitconfig.example    # Git alias and preference template
├── install.sh            # One-step interactive installer & backup script
└── README.md
```

---

## ✦ Dependencies

### Arch Linux / Omarchy Packages

Install all required core packages using `pacman`:

```bash
sudo pacman -S --needed \
    hyprland \
    hyprpaper \
    hyprsunset \
    xdg-desktop-portal-hyprland \
    foot \
    starship \
    fastfetch \
    cava \
    btop \
    cmatrix \
    tmux \
    mpv \
    mpv-mpris \
    pipewire \
    wireplumber
```

### AUR Packages (Optional)

For the matching macOS cursor theme:

```bash
yay -S apple_cursor
```

---

## ✦ Quick Installation

1. **Clone this repository**:
   ```bash
   git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Preview changes (Dry Run)**:
   ```bash
   ./install.sh --dry-run
   ```

3. **Install**:
   ```bash
   ./install.sh
   ```
   * The installer will:
     * Check for all required package dependencies
     * Safely back up any existing conflicting configs to `~/.dotfiles_backup/<timestamp>`
     * Symlink configuration files into `~/.config/`, `~/.local/bin/`, and `~/.local/share/fonts/`
     * Install required custom fonts and rebuild font cache (`fc-cache`)
     * Reload Hyprland and Omarchy shell plugins live without rebooting

4. **Reload Shell**:
   ```bash
   source ~/.bashrc
   ```

---

## ✦ Keybindings Quick Reference

| Key Combination | Action | Description |
| :--- | :--- | :--- |
| <kbd>Super</kbd> + <kbd>D</kbd> | Gothic Rice Dashboard | Launches Btop, Cava, Fastfetch, and Cmatrix on Workspace 5 |
| <kbd>Super</kbd> + <kbd>Return</kbd> | Terminal | Opens the configured default terminal (`foot`) |
| <kbd>Super</kbd> + <kbd>Space</kbd> | Menu Launcher | Opens the Quickshell application & system launcher |
| <kbd>Super</kbd> + <kbd>Q</kbd> | Close Window | Closes the focused window |
| <kbd>Super</kbd> + <kbd>F</kbd> | Fullscreen | Toggles window fullscreen mode |
| <kbd>Super</kbd> + <kbd>1-9</kbd> | Workspaces | Switches between virtual workspaces |

---

## ✦ Included Custom Fonts

The following fonts are bundled under `.local/share/fonts/` and deployed automatically by `install.sh`:

* **Argor Flahm Scaqh** (`ArgFlahm.ttf`) — Gothic font used for lockscreen time display
* **Cinzel Decorative Bold** (`CinzelDecorative-Bold.ttf`) — Serif ornament font for lockscreen date & labels
* **UnifrakturMaguntia** (`UnifrakturMaguntia-Book.ttf`) — Classic gothic blackletter typeface
* **Outfit** (`Outfit-VariableFont_wght.ttf`) — Clean modern sans-serif for UI elements
* **Syne** (`Syne-VariableFont_wght.ttf`) — Elegant modern geometric font

---

## ✦ Included Themes

Switch themes anytime using the Omarchy CLI:

```bash
# Switch to Harbordark (default gothic theme)
omarchy theme set harbordark

# Switch to Bunny Girl Senpai theme
omarchy theme set bunny-girl-senpai

# Switch to Bunny Girl theme
omarchy theme set bunny-girl
```

---

## ✦ License

This configuration repository is released under the [MIT License](LICENSE). Feel free to customize, modify, and build upon it!
