# ls colors
autoload -U colors && colors

# Enable ls colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"

# TODO organise this chaotic logic

if [[ "$DISABLE_LS_COLORS" != "true" ]]; then
  if [[ "$OSTYPE" == darwin* ]]; then
    # only use coreutils ls if there is a dircolors customization present ($LS_COLORS or .dircolors file)
    # otherwise, gls will use the default color scheme which is ugly af
    [[ -n "$LS_COLORS" || -f "$HOME/.dircolors" ]] && gls --color -d . &>/dev/null && alias ls='gls --color=tty'
  else
    # For GNU ls, we use the default ls color theme. They can later be overwritten by themes.
    if [[ -z "$LS_COLORS" ]]; then
      (( $+commands[dircolors] )) && eval "$(dircolors -b)"
    fi

    ls --color -d . &>/dev/null && alias ls='ls --color=tty' || { ls -G . &>/dev/null && alias ls='ls -G' }

    # Take advantage of $LS_COLORS for completion as well.
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  fi
fi

setopt auto_cd
setopt multios
setopt prompt_subst
