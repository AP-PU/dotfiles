#!/usr/bin/env bash
#
# Dotfiles Installer & System Rebuild Script
# Gothic / Cyber-Bunny Omarchy & Hyprland Rice
#

set -euo pipefail

# Colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[38;2;231;90;80m"
C_GOLD="\033[38;2;169;155;122m"
C_CREAM="\033[38;2;239;235;220m"
C_GREEN="\033[38;2;120;180;120m"
C_BLUE="\033[38;2;120;150;210m"
C_GRAY="\033[38;2;100;100;100m"

log_info()    { echo -e "  ${C_BLUE}ℹ${C_RESET}  $*"; }
log_ok()      { echo -e "  ${C_GREEN}✓${C_RESET}  $*"; }
log_warn()    { echo -e "  ${C_GOLD}⚠${C_RESET}  $*"; }
log_error()   { echo -e "  ${C_RED}✖${C_RESET}  $*"; }
log_step()    { echo -e "\n${C_BOLD}${C_GOLD}▸ $*${C_RESET}"; }

banner() {
  cat << "EOF"
  ┌───────────────────────────────────────────────────────────────┐
  │   †  T E N E B R I S  /  O M A R C H Y   D O T F I L E S  †   │
  │     Gothic Hyprland Rice & Custom Quickshell Environment      │
  └───────────────────────────────────────────────────────────────┘
EOF
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
MODE="symlink"  # default: symlink (use --copy for hard copy)
DRY_RUN=false

show_help() {
  cat << EOF
Usage: ./install.sh [OPTIONS]

Options:
  --symlink        Symlink dotfiles into \$HOME (default)
  --copy           Copy dotfiles instead of symlinking
  --dry-run        Show what would be installed without making changes
  --no-backup      Skip creating backups of existing files
  -h, --help       Show this help message
EOF
}

SKIP_BACKUP=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --symlink)   MODE="symlink"; shift ;;
    --copy)      MODE="copy"; shift ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --no-backup) SKIP_BACKUP=true; shift ;;
    -h|--help)   show_help; exit 0 ;;
    *) log_error "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

echo -e "${C_RED}"
banner
echo -e "${C_RESET}"

log_info "Dotfiles Source : ${C_CREAM}${DOTFILES_DIR}${C_RESET}"
log_info "Target Directory: ${C_CREAM}${TARGET_DIR}${C_RESET}"
log_info "Install Mode    : ${C_CREAM}${MODE}${C_RESET}"
if $DRY_RUN; then
  log_warn "DRY RUN MODE ENABLED - no changes will be written."
fi

# 1. Dependency Checks
log_step "Checking System Dependencies"

CORE_PKGS=("hyprland" "foot" "fastfetch" "cava" "btop" "starship" "cmatrix" "tmux")
OPTIONAL_PKGS=("apple_cursor" "mpv" "mpv-mpris" "hyprpaper" "hyprsunset")

missing_core=()
for pkg in "${CORE_PKGS[@]}"; do
  if ! command -v "$pkg" >/dev/null 2>&1; then
    missing_core+=("$pkg")
  fi
done

if [[ ${#missing_core[@]} -gt 0 ]]; then
  log_warn "Missing core tools: ${missing_core[*]}"
  log_info "Install on Arch/Omarchy via pacman:"
  echo -e "      ${C_BOLD}sudo pacman -S --needed ${missing_core[*]}${C_RESET}"
else
  log_ok "All core command-line tools are installed."
fi

# 2. Deploy Function
deploy_item() {
  local src="$1"
  local dest="$2"

  local dest_dir
  dest_dir="$(dirname "$dest")"

  if $DRY_RUN; then
    echo -e "    ${C_GRAY}[DRY-RUN]${C_RESET} ${src#$DOTFILES_DIR/} -> ${dest}"
    return 0
  fi

  mkdir -p "$dest_dir"

  # If destination already exists and differs from source
  if [[ -e "$dest" || -L "$dest" ]]; then
    # If symlink points to exactly src, skip
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
      log_ok "Already linked: ${dest#$HOME/}"
      return 0
    fi

    # Backup existing
    if ! $SKIP_BACKUP; then
      local rel_dest="${dest#$HOME/}"
      local bkp_path="${BACKUP_DIR}/${rel_dest}"
      mkdir -p "$(dirname "$bkp_path")"
      mv "$dest" "$bkp_path"
      log_warn "Backed up existing ${dest#$HOME/} -> ${bkp_path#$HOME/}"
    else
      rm -rf "$dest"
    fi
  fi

  if [[ "$MODE" == "symlink" ]]; then
    ln -sfn "$src" "$dest"
    log_ok "Linked: ${dest#$HOME/} -> ${src#$DOTFILES_DIR/}"
  else
    cp -r "$src" "$dest"
    log_ok "Copied: ${dest#$HOME/}"
  fi
}

# 3. Deploy Configurations (.config)
log_step "Deploying Configuration Files (.config/)"

CONFIG_ITEMS=(
  "43pr"
  "btop"
  "cava"
  "fastfetch"
  "fontconfig"
  "foot"
  "ghostty"
  "gtk-3.0"
  "gtk-4.0"
  "herdr"
  "hypr"
  "kitty"
  "nvim"
  "omarchy"
  "starship.toml"
  "systemd/user"
  "tmux"
)

for item in "${CONFIG_ITEMS[@]}"; do
  src="${DOTFILES_DIR}/.config/${item}"
  dest="${TARGET_DIR}/.config/${item}"
  if [[ -e "$src" ]]; then
    deploy_item "$src" "$dest"
  fi
done

# 4. Deploy Custom Binaries (.local/bin)
log_step "Deploying Custom User Scripts (.local/bin/)"
mkdir -p "${TARGET_DIR}/.local/bin"

if [[ -d "${DOTFILES_DIR}/.local/bin" ]]; then
  for bin_file in "${DOTFILES_DIR}/.local/bin"/*; do
    fname="$(basename "$bin_file")"
    deploy_item "$bin_file" "${TARGET_DIR}/.local/bin/${fname}"
    if ! $DRY_RUN && [[ -f "${TARGET_DIR}/.local/bin/${fname}" ]]; then
      chmod +x "${TARGET_DIR}/.local/bin/${fname}"
    fi
  done
fi

# 5. Deploy Custom Fonts (.local/share/fonts)
log_step "Deploying Custom Fonts (.local/share/fonts/)"
mkdir -p "${TARGET_DIR}/.local/share/fonts"

if [[ -d "${DOTFILES_DIR}/.local/share/fonts" ]]; then
  for font_file in "${DOTFILES_DIR}/.local/share/fonts"/*; do
    font_name="$(basename "$font_file")"
    deploy_item "$font_file" "${TARGET_DIR}/.local/share/fonts/${font_name}"
  done

  if ! $DRY_RUN && command -v fc-cache >/dev/null 2>&1; then
    log_info "Updating font cache..."
    fc-cache -f "${TARGET_DIR}/.local/share/fonts" >/dev/null 2>&1 || true
    log_ok "Font cache refreshed."
  fi
fi

# 6. Deploy Shell Startup Files
log_step "Deploying Shell Configurations"
SHELL_FILES=(".bashrc" ".bash_profile" ".zshrc")
for sh_file in "${SHELL_FILES[@]}"; do
  src="${DOTFILES_DIR}/${sh_file}"
  dest="${TARGET_DIR}/${sh_file}"
  if [[ -f "$src" ]]; then
    deploy_item "$src" "$dest"
  fi
done

# 7. Systemd User Units
if command -v systemctl >/dev/null 2>&1 && ! $DRY_RUN; then
  log_step "Configuring Systemd User Services"
  systemctl --user daemon-reload || true
  log_ok "Systemd user daemon reloaded."
  log_info "You can enable background rice services via:"
  echo -e "      ${C_BOLD}systemctl --user enable --now omarchy-idle-inhibit.service omarchy-live-wallpaper.service${C_RESET}"
fi

# 8. Live Session Reload
if ! $DRY_RUN; then
  log_step "Reloading Active Desktop Sessions"

  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
    log_info "Hyprland detected: reloading configuration..."
    hyprctl reload >/dev/null 2>&1 || true
    log_ok "Hyprland reloaded."
  fi

  if command -v omarchy-shell >/dev/null 2>&1; then
    log_info "Omarchy shell detected: refreshing shell plugins..."
    omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
    log_ok "Omarchy shell updated."
  fi
fi

# Finished!
echo -e "\n${C_GREEN}${C_BOLD}✓ Installation Complete!${C_RESET}"
if [[ -d "$BACKUP_DIR" ]]; then
  echo -e "  Backups saved to: ${C_GOLD}${BACKUP_DIR}${C_RESET}"
fi
echo -e "  To apply shell changes immediately in current terminal: ${C_CREAM}source ~/.bashrc${C_RESET}\n"
