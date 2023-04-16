#!/bin/bash
# .ansi_colors.sh 
# --------------
# @zudsniper 
# some ansi colors as bash variables 

# ----------------------------- #
## ANSI COLOR ENVIRONMENT VARS

export A_RESTORE='\033[0m'
export A_RESET='\033[0m'

export A_BOLD='\033[1m'
export A_UNDERLINE='\033[4m'
export A_INVERSE='\033[7m'
export A_ITALIC='\033[3m'  #not always supported...

export A_RED='\033[00;31m'
export A_GREEN='\033[00;32m'
export A_YELLOW='\033[00;33m'
export A_BLUE='\033[00;34m'
export A_PURPLE='\033[00;35m'
export A_CYAN='\033[00;36m'
export A_LIGHTGRAY='\033[00;37m'

export A_LRED='\033[01;31m'
export A_LGREEN='\033[01;32m'
export A_LYELLOW='\033[01;33m'
export A_LBLUE='\033[01;34m'
export A_LPURPLE='\033[01;35m'
export A_LCYAN='\033[01;36m'
export A_WHITE='\033[01;37m'
# ----------------------------- #
