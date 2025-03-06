# Spaceship prompt configuration

# Display time
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR="yellow"
SPACESHIP_TIME_FORMAT="%T"
SPACESHIP_TIME_PREFIX="at "
SPACESHIP_TIME_SUFFIX=" "

# Display username
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR="green"
SPACESHIP_USER_SUFFIX=" "

# Display hostname
SPACESHIP_HOST_SHOW=always
SPACESHIP_HOST_COLOR="blue"
SPACESHIP_HOST_PREFIX="@ "
SPACESHIP_HOST_SUFFIX=" "

# Display current directory
SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_TRUNC_REPO=true
SPACESHIP_DIR_COLOR="cyan"

# Git settings
SPACESHIP_GIT_SYMBOL=" "  # Using a Nerd Font icon for git
SPACESHIP_GIT_BRANCH_COLOR="green"
SPACESHIP_GIT_STATUS_COLOR="red"

# Execution time
SPACESHIP_EXEC_TIME_SHOW=true
SPACESHIP_EXEC_TIME_PREFIX="took "
SPACESHIP_EXEC_TIME_SUFFIX=" "
SPACESHIP_EXEC_TIME_COLOR="yellow"
SPACESHIP_EXEC_TIME_THRESHOLD=5000

# Prompt character - using a Nerd Font icon
SPACESHIP_CHAR_SYMBOL="❯ "
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_CHAR_COLOR_FAILURE="red"

# Prompt order
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  exec_time     # Execution time
  line_sep      # Line break
  char          # Prompt character
)

# Right prompt order
SPACESHIP_RPROMPT_ORDER=(
  time          # Time stamps section
)