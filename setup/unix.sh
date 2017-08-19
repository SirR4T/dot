#!/bin/bash -e

# Installs things that I use on all Unix systems (e.g. macOS and Linux).

. $(dirname $0)/../helpers/setup.sh # Load helper script from gcfg/helpers.

# Set default shell to zsh
# $SHELL isn't updated until we logout, so check whether chsh was already run.
shell=$(cat /etc/passwd | grep $USER | awk -F: '{print $NF}' | awk -F/ '{print $NF}')
if [ "$shell" != zsh ]; then
  if [ -e /bin/zsh ]; then
    echo "❯❯❯ Current shell is $shell, changing to /bin/zsh"
    chsh -s /bin/zsh
  else
    echo "❯❯❯ Current shell is $shell ($SHELL) but /bin/zsh doesn't exist
    Install zsh and then run chsh -s /bin/zsh"
  fi
else
    echo "❯❯❯ zsh is already the default shell"
fi

# Set up autocompletions:
if no zfunc; then mkdir -p "$XDG_DATA_HOME/zfunc"; fi

# Set up zsh scripts:
if no zsh; then mkdir -p "$XDG_DATA_HOME/zsh"; fi

if no zsh/zsh-syntax-highlighting; then
  gitClone zsh-users/zsh-syntax-highlighting "$XDG_DATA_HOME/zsh/zsh-syntax-highlighting"
fi

# Install nvm:
if no nvm; then
  # No install scripts as path update isn't required, it's done in gibrc.
  gitClone creationix/nvm "$XDG_DATA_HOME/nvm"
  . "$XDG_DATA_HOME"/nvm/nvm.sh # Load nvm so we can use it below.
  nvm install stable # Install the latest LTS version of node.

  # Autocompletion for npm (probably needed)
  npm completion > "$XDG_DATA_HOME/.zfunc/_npm"
fi

# Install vim-plug (vim plugin manager):
if no nvim/site/autoload/plug.vim; then
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  exists() { type "$1" >/dev/null 2>&1; } # Check if command exists (is in path).
  unset VIM
  { exists nvim && VIM=nvim; } || { exists vim && VIM=vim; } # Take what you can get.
  [ "$VIM" = vim ] && mkdir -p ~/.vim && ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload
  exists $VIM && $VIM +PlugInstall +qall # Install/update vim plugins.
fi

# If you don't use rust just choose the cancel option.
if no rustup || no cargo; then
  if [ ! -d "$HOME/.rustup" ]; then
    # Install rustup. Don't modify path as that's already in gibrc.
    curl https://sh.rustup.rs -sSf | bash -s -- --no-modify-path
    # Install stable and nightly
    rustup install nightly
    rustup install stable
    # Download zsh completion
    curl https://raw.githubusercontent.com/rust-lang-nursery/rustup.rs/master/src/rustup-cli/zsh/_rustup >"$XDG_DAATA_HOME/zfunc/_rustup"

    # Download docs and src
    rustup component add rust-src
    rustup component add rust-docs || true
  fi

  # Move to proper directories
  mv "$HOME/.rustup" "$XDG_DATA_HOME/rustup"
  mv "$HOME/.cargo" "$XDG_DATA_HOME/cargo"
fi
