# ============================================================
#  Spaceship prompt configuration
#  Loaded from .zshrc (before `source $ZSH/oh-my-zsh.sh`) via:
#    ~/.config/spaceship/config.zsh  (symlinked by setup.sh)
# ============================================================

# Section order
SPACESHIP_PROMPT_ORDER=(
  time
  user
  dir
  git
  docker
  exec_time
  line_sep
  char
)

# Time section
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=cyan

# User & host
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR=green
SPACESHIP_HOST_SHOW=always
SPACESHIP_HOST_COLOR=red

# Directory & git
SPACESHIP_DIR_COLOR=blue
SPACESHIP_GIT_COLOR=yellow
SPACESHIP_GIT_STATUS_COLOR=red

# Exit code
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_EXIT_CODE_COLOR=red

# Prompt character
SPACESHIP_CHAR_COLOR_SUCCESS=green
SPACESHIP_CHAR_COLOR_FAILURE=red
SPACESHIP_CHAR_SYMBOL="➜ "
SPACESHIP_CHAR_SYMBOL_ROOT="# "
SPACESHIP_CHAR_SYMBOL_SECONDARY="➜ "

# Disable unused sections for a fast prompt
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_NODE_SHOW=false
SPACESHIP_GOLANG_SHOW=false
SPACESHIP_DOCKER_SHOW=true
SPACESHIP_VENV_SHOW=false
SPACESHIP_KUBECTL_SHOW=false
SPACESHIP_TERRAFORM_SHOW=false
SPACESHIP_PYTHON_SHOW=false
SPACESHIP_EMBER_SHOW=false
SPACESHIP_VI_MODE_SHOW=false
