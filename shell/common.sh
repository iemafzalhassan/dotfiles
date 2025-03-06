#!/bin/bash
# Common shell configuration for all shells
# Created automatically by install.sh

# Aliases
# Replace standard ls commands with eza + icons
alias ls="eza --icons=always"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Magic Enter function - shows ls and git status when pressing Enter on empty line
magic_enter() {
  if [[ -z $BUFFER ]]; then
    echo ""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      echo "$(eza --icons=always -la)"
      echo ""
      echo "$(git status -u .)"
    else
      echo "$(eza --icons=always -la)"
    fi
    echo ""
    return 0
  fi
  return 1
}