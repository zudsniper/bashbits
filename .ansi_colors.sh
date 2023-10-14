#!/bin/bash
# .ansi_colors.sh v2.2.1
# -------------- 
#
# Updated 2023-10-14
# 
# This small script exports all ANSI color codes as variables prepended with "A_". It also offers convenience functions
# ansi, colorize, and cecho. 
#
# @zudsniper

# V2.2.1
# - fixed a single "EXPORT" by replacing it with "export" 

# V2.2.0
# - adding changelogs in file until its too long
# - adding the A_* variables that are referenced in this file, as many, especially the BG variables, were not defined. 

# ----------------------------- #
#  ANSI COLOR ENVIRONMENT VARS

# -----+-----+-----+-----+----- #
# NEW, SORTED DEFINITIONS (default ANSI xterm colors only)
# STYLE
export A_RESET="\033[0m"
export A_BOLD="\033[1m"
export A_DIM="\033[2m"
export A_UNDERLINE="\033[4m"
export A_BLINK="\033[5m"
export A_REVERSE="\033[7m"
export A_HIDDEN="\033[8m"

# FOREGROUND
export A_BLACK="\033[30m"
export A_RED="\033[31m"
export A_GREEN="\033[32m"
export A_YELLOW="\033[33m"
export A_BLUE="\033[34m"
export A_MAGENTA="\033[35m"
export A_CYAN="\033[36m"
export A_WHITE="\033[37m"
export A_BRIGHT_BLACK="\033[90m"
export A_BRIGHT_RED="\033[91m"
export A_BRIGHT_GREEN="\033[92m"
export A_BRIGHT_YELLOW="\033[93m"
export A_BRIGHT_BLUE="\033[94m"
export A_BRIGHT_MAGENTA="\033[95m"
export A_BRIGHT_CYAN="\033[96m"
export A_BRIGHT_WHITE="\033[97m"

# BACKGROUND
export A_BG_BLACK="\033[40m"
export A_BG_RED="\033[41m"
export A_BG_GREEN="\033[42m"
export A_BG_YELLOW="\033[43m"
export A_BG_BLUE="\033[44m"
export A_BG_MAGENTA="\033[45m"
export A_BG_CYAN="\033[46m"
export A_BG_WHITE="\033[47m"

# -----+-----+-----+-----+----- #

# Handle other names which people might use for the same colors
export A_RESTORE="${A_RESET}"
export A_INVERSE="${A_REVERSE}"

# -----+-----+-----+-----+----- #
# SIMPLE VARIABLE NAMES
# These are the same as the above, but without the "A_" prefix.
# CAUTION => Only some colors are exported this way in order to avoid conflicts. These aren't the best way to use these variables.
# Also includes NC, which is a common alias for RESET.
export NC="${A_RESET}"
export RED="${A_RED}"
export YELLOW="${A_YELLOW}"
export GREEN="${A_GREEN}"
export BLUE="${A_BLUE}"

# -----X-----X-----X-----X----- # 
# @DEPRECATED
# These are the old definitions, including many colors which only some shells could render. 
# TODO: To add these colors back, the script will need to be updated to detect what type 
#       of shell instance is being utilized, then define variables intelligently based on
#       that determination. 
# Some definitions are still allowed to be exported as they are used. 

# export A_RESET="\033[0m"
# export A_BOLD="\033[1m"
# export A_DIM="\033[2m"
# export A_UNDERLINE="\033[4m"
# export A_BLINK="\033[5m"
# export A_REVERSE="\033[7m"
# export A_HIDDEN="\033[8m"
# export A_BLACK="\033[30m"
# export A_RED="\033[31m"
# export A_GREEN="\033[32m"
# export A_YELLOW="\033[33m"
# export A_BLUE="\033[34m"
# export A_MAGENTA="\033[35m"
# export A_CYAN="\033[36m"
# export A_WHITE="\033[37m"
export A_LIGHT_GRAY="\033[37;1m"
export A_DARK_GRAY="\033[90m"
export A_PURPLE="\033[35m"
export A_ORANGE="\033[38;5;208m"
# export A_LIGHT_BLUE="\033[94m"
# export A_NAVY="\033[34m"
# export A_SKY="\033[38;5;39m"
# export A_GOLD="\033[38;5;220m"
# export A_SILVER="\033[38;5;7m"
# export A_BRONZE="\033[38;5;137m"
# export A_TURQUOISE="\033[38;5;45m"
# export A_CHARTREUSE="\033[38;5;118m"
# export A_BROWN="\033[38;5;130m"
# export A_FOREST_GREEN="\033[38;5;28m"
# export A_LIME_GREEN="\033[38;5;76m"
# export A_LIGHT_GREEN="\033[38;5;157m"
# export A_MINT="\033[38;5;121m"
# export A_PINK="\033[38;5;218m"
# export A_HOT_PINK="\033[38;5;205m"
# export A_LAVENDER="\033[38;5;183m"
# export A_LILAC="\033[38;5;177m"
# export A_TEAL="\033[38;5;31m"
# export A_MAROON="\033[38;5;52m"
# export A_BEIGE="\033[38;5;230m"
# export A_MAUVE="\033[38;5;179m"
# export A_OLIVE="\033[38;5;142m"
# export A_CORAL="\033[38;5;203m"
# export A_SALMON="\033[38;5;209m"
# export A_PEACH="\033[38;5;224m"
# export A_TAN="\033[38;5;180m"
# export A_SKIN="\033[38;5;223m"
# export A_AQUAMARINE="\033[38;5;86m"
# export A_FOREST="\033[38;5;22m"
# export A_SEAFOAM="\033[38;5;122m"
# export A_ROSE="\033[38;5;211m"
# export A_MELON="\033[38;5;208m"
# export A_INDIGO="\033[38;5;93m"
# export A_LIGHT_CYAN="\033[38;5;159m"
# export A_LIGHT_RED="\033[38;5;203m"
# export A_LIGHT_YELLOW="\033[38;5;227m"
# export A_LIGHT_GREEN2="\033[38;5;120m"
# export A_LIGHT_PURPLE="\033[38;5;141m"
# export A_LIGHT_ORANGE="\033[38;5;215m"
# export A_LIGHT_PINK="\033[38;5;218m"
# export A_LIGHT_BLUE2="\033[38;5;33m"
# export A_YELLOW_GREEN="\033[38;5;154m"
# export A_ROYAL_BLUE="\033[38;5;62m"
# export A_CORNFLOWER_BLUE="\033[38;5;69m"
# export A_LIGHT_SKY_BLUE="\033[38;5;153m"
# export A_MEDIUM_BLUE="\033[38;5;27m"
# export A_MEDIUM_GREY="\033[38;5;246m"
# export A_MIDNIGHT_BLUE="\033[38;5;17m"
# export A_SPRING_GREEN="\033[38;5;48m"
# export A_MEDIUM_SPRING_GREEN="\033[38;5;49m"
# export A_DARK_KHAKI="\033[38;5;143m"
# export A_KHAKI="\033[38;5;179m"
# export A_DARK_TURQUOISE="\033[38;5;44m"
# export A_DARK_SLATE_BLUE="\033[38;5;61m"
# export A_MEDIUM_PURPLE="\033[38;5;141m"
# export A_MEDIUM_SEA_GREEN="\033[38;5;70m"
# export A_DARK_SEA_GREEN="\033[38;5;108m"
# export A_LIGHT_SEA_GREEN="\033[38;5;39m"
# export A_LIGHT_GREY2="\033[38;5;250m"
# export A_MEDIUM_GREY2="\033[38;5;241m"
# -----X-----X-----X-----X----- # 


##################################################

# recognize ANSI escape codes
# @param $1 the text to recognize a color or style name from
# Define function to recognize ANSI color codes
function ansi() {
  local color="${1^^}"
  case "${color}" in
    BLACK) echo -n "${A_BLACK}" ;;
    RED) echo -n "${A_RED}" ;;
    GREEN) echo -n "${A_GREEN}" ;;
    YELLOW) echo -n "${A_YELLOW}" ;;
    BLUE) echo -n "${A_BLUE}" ;;
    PURPLE|VIOLET) echo -n "${A_PURPLE}" ;;
    CYAN|TURQUOISE) echo -n "${A_CYAN}" ;;
    WHITE) echo -n "${A_WHITE}" ;;
    GRAY|GREY|LIGHTGRAY|LIGHTGREY) echo -n "${A_LIGHTGRAY}" ;;
    DARKGRAY|DARKGREY) echo -n "${A_DARKGRAY}" ;;
    ORANGE) echo -n "${A_ORANGE}" ;;
    NAVY|DARKBLUE) echo -n "${A_NAVY}" ;;
    SKY|LIGHTBLUE) echo -n "${A_SKY}" ;;
    GOLD) echo -n "${A_GOLD}" ;;
    SILVER) echo -n "${A_SILVER}" ;;
    BRONZE) echo -n "${A_BRONZE}" ;;
    CHARTREUSE) echo -n "${A_CHARTREUSE}" ;;
    BROWN) echo -n "${A_BROWN}" ;;
    FORESTGREEN|DARKGREEN) echo -n "${A_FORESTGREEN}" ;;
    LIMEGREEN) echo -n "${A_LIMEGREEN}" ;;
    LIGHTGREEN) echo -n "${A_LIGHTGREEN}" ;;
    MINT) echo -n "${A_MINT}" ;;
    PINK|LIGHTPINK) echo -n "${A_PINK}" ;;
    HOTPINK|DARKPINK) echo -n "${A_HOTPINK}" ;;
    BG_BLACK) echo -n "${A_BG_BLACK}" ;;
    BG_RED) echo -n "${A_BG_RED}" ;;
    BG_GREEN) echo -n "${A_BG_GREEN}" ;;
    BG_YELLOW) echo -n "${A_BG_YELLOW}" ;;
    BG_BLUE) echo -n "${A_BG_BLUE}" ;;
    BG_PURPLE|BG_VIOLET) echo -n "${A_BG_PURPLE}" ;;
    BG_CYAN|BG_TURQUOISE) echo -n "${A_BG_CYAN}" ;;
    BG_WHITE) echo -n "${A_BG_WHITE}" ;;
    BG_GRAY|BG_GREY|BG_LIGHTGRAY|BG_LIGHTGREY) echo -n "${A_BG_LIGHTGRAY}" ;;
    BG_DARKGRAY|BG_DARKGREY) echo -n "${A_BG_DARKGRAY}" ;;
    BG_ORANGE) echo -n "${A_BG_ORANGE}" ;;
    BG_NAVY|BG_DARKBLUE) echo -n "${A_BG_NAVY}" ;;
    BG_SKY|BG_LIGHTBLUE) echo -n "${A_BG_SKY}" ;;
    BG_GOLD) echo -n "${A_BG_GOLD}" ;;
    BG_SILVER) echo -n "${A_BG_SILVER}" ;;
    BG_BRONZE) echo -n "${A_BG_BRONZE}" ;;
    BG_CHARTREUSE) echo -n "${A_BG_CHARTREUSE}" ;;
    BG_BROWN) echo -n "${A_BG_BROWN}" ;;
    BG_FORESTGREEN|BG_DARKGREEN) echo -n "${A_BG_FORESTGREEN}" ;;
    BG_LIMEGREEN) echo -n "${A_BG_LIMEGREEN}" ;;
    BG_LIGHTGREEN) echo -n "${A_BG_LIGHTGREEN}" ;;
    BG_MINT) echo -n "${A_BG_MINT}" ;;
    BG_PINK|BG_LIGHTPINK) echo -n "${A_BG_PINK}" ;;
    BG_HOTPINK|BG_DARKPINK) echo -n "${A_BG_HOTPINK}" ;;
    *) echo -n "${A_RED}" && echo "Error: Invalid color '${color}'." >&2 && echo -n "${A_RESET}" && return 1 ;;
  esac
  return 0
}

# colorizes & styles text, then ECHOs it 
# @param $1 The text to be colorized. Must be a string. 
# @params the other parameters are all modifiers, which are translated from text to ANSI color codes. 
# 
# the only unique feature is that of the "background" or "bg" parameter, which will take the following color name
# and use it to try and find a background color instead of the normal foreground color. 
function colorize() {
  local result=""
  local color=""
  local style=""
  for arg in "$@"; do
    if [[ -n "${arg}" && "${arg}" == [a-zA-Z]* ]]; then
      local uc_arg="${arg^^}"
      if [[ "${uc_arg}" == BOLD ]]; then
        style+=";${A_BOLD}"
      elif [[ "${uc_arg}" == UNDERLINE ]]; then
        style+=";${A_UNDERLINE}"
      elif [[ "${uc_arg}" == BG_* ]]; then
        local bg_color=$(echo "${arg#BG_}" | tr '[:lower:]' '[:upper:]')
        local ansi_bg_color="$(ansi "${bg_color}" | sed 's/\033\[/\033\[4/')"
        if [[ $? -ne 0 ]]; then
          echo -n "${ansi_bg_color}"
          return 1
        fi
        style+=";${ansi_bg_color}"
      else
        local ansi_color="$(ansi "${uc_arg}")"
        if [[ $? -ne 0 ]]; then
          echo -n "${ansi_color}"
          return 1
        fi
        color="${ansi_color}"
      fi
    fi
  done
  result+="$(echo -n "${1}")"
  result+="$(echo -n "${color}${style}")"
  result+="$(echo -n "${A_RESET}")"
  echo -n "${result}"
  return 0
}

function cecho() {
  local result="$(colorize "$@")"
  if [[ "$?" -ne 0 ]]; then
    echo "${result}" >&2
  else
    echo "${result}"
  fi
}

# EXPORT ALL FUNCTIONS AS BASH GLOBAL IF EXECUTED
export -f ansi
export -f colorize
export -f cecho
