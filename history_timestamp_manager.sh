#!/usr/bin/env bash

set -euo pipefail

# Color definitions
COLOR_RESET='\033[0m'
COLOR_INFO='\033[1;34m'    # Blue
COLOR_WARN='\033[1;33m'    # Yellow
COLOR_ERROR='\033[1;31m'   # Red

info()    { echo -e "${COLOR_INFO}[INFO]${COLOR_RESET} $*"; }
warn()    { echo -e "${COLOR_WARN}[WARNING]${COLOR_RESET} $*"; }
error()   { echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $*" >&2; }
die()     { error "$*"; exit 1; }

HIST_CFG="$HOME/.history_config"
BASH_RC="$HOME/.bashrc"
ZSH_RC="$HOME/.zshrc"

HIST_TAG="# >>> history timestamp config <<<"
HIST_TAG_END="# <<< history timestamp config >>>"

usage() {
    echo "Usage: $0 [install|uninstall]"
    exit 1
}

ensure_sourced() {
    local rcfile=$1
    if [ ! -f "$rcfile" ]; then
        warn "$rcfile not found, skipping."
        return
    fi
    if ! grep -Fxq "source ~/.history_config $HIST_TAG" "$rcfile"; then
        # Backup if first time editing
        if ! grep -q "$HIST_TAG" "$rcfile"; then
            cp "$rcfile" "$rcfile.bak_histcfg" || warn "Failed to backup $rcfile"
        fi
        if ! printf "\n$HIST_TAG\n[ -f ~/.history_config ] && source ~/.history_config\n$HIST_TAG_END\n" >> "$rcfile"; then
            error "Could not write to $rcfile. Check permissions."
            return 1
        fi
        info "Added sourcing line to $rcfile"
    else
        info "$rcfile already sources .history_config"
    fi
}

remove_sourced() {
    local rcfile=$1
    if [ ! -f "$rcfile" ]; then
        warn "$rcfile not found, skipping."
        return
    fi
    # Remove the config block between tags
    if grep -q "$HIST_TAG" "$rcfile"; then
        if ! awk "/$HIST_TAG/{flag=1;next}/$HIST_TAG_END/{flag=0;next}!flag" "$rcfile" > "$rcfile.tmp_hist"; then
            error "Failed to process $rcfile for cleanup."
            return 1
        fi
        mv "$rcfile.tmp_hist" "$rcfile"
        info "Removed sourcing line from $rcfile"
    else
        info "No sourcing block found in $rcfile"
    fi
}

install_histcfg() {
    if [ ! -f "$HIST_CFG" ]; then
        if ! cat > "$HIST_CFG" <<EOF
# Shell history timestamp configuration

# Bash support
if [ -n "\$BASH_VERSION" ]; then
    export HISTTIMEFORMAT="%F %T "
    export PROMPT_COMMAND="history -a; \$PROMPT_COMMAND"
    shopt -s histappend
fi

# Zsh support
if [ -n "\$ZSH_VERSION" ]; then
    setopt EXTENDED_HISTORY
fi
EOF
        then
            die "Failed to create $HIST_CFG"
        fi
        chmod 644 "$HIST_CFG" || warn "Could not set permissions on $HIST_CFG"
        info "Created $HIST_CFG"
    else
        info "$HIST_CFG already exists; not overwriting"
    fi
}

remove_histcfg() {
    if [ -f "$HIST_CFG" ]; then
        rm -f "$HIST_CFG" && info "Removed $HIST_CFG" || warn "Could not remove $HIST_CFG"
    else
        info "$HIST_CFG does not exist"
    fi
}

is_installed() {
    ( grep -q "$HIST_TAG" "$BASH_RC" 2>/dev/null || grep -q "$HIST_TAG" "$ZSH_RC" 2>/dev/null ) && [ -f "$HIST_CFG" ]
}

# MAIN
if [ $# -ne 1 ]; then usage; fi

case "$1" in
    install)
        if is_installed; then
            info "Already installed."
            info "To apply changes, restart your shell or run: source ~/.bashrc  or  source ~/.zshrc"
            exit 0
        fi
        install_histcfg
        ensure_sourced "$BASH_RC"
        ensure_sourced "$ZSH_RC"
        info "Installation complete."
        info "To apply changes, restart your shell or run: source ~/.bashrc  or  source ~/.zshrc"
        ;;
    uninstall)
        remove_sourced "$BASH_RC"
        remove_sourced "$ZSH_RC"
        remove_histcfg
        info "Uninstallation complete."
        info "To apply changes, restart your shell or run: source ~/.bashrc  or  source ~/.zshrc"
        ;;
    *)
        usage
        ;;
esac
