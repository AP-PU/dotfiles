# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
[[ -n "$OMARCHY_PATH" && -r "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"

# Custom user PATH
export PATH="$HOME/.local/bin:$PATH"

# Rice Fetch aliases
alias mfetch="cmatrix-fastfetch"
alias fastmatrix="cmatrix-fastfetch --burst"

# Starship prompt initialization
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
