#
# ~/.zshrc
#

# Custom user PATH
export PATH="$HOME/.local/bin:$PATH"

# Rice Fetch aliases
alias mfetch="cmatrix-fastfetch"
alias fastmatrix="cmatrix-fastfetch --burst"

# Starship prompt initialization
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
