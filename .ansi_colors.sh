#!/bin/bash
# .ansi_colors.sh 
# --------------
# V2.1.0 FIX2 
# 
# This small script exports all ANSI color codes as variables prepended with "A_". It also offers convenience functions
# ansi, colorize, and cecho. 
#
# by @zudsniper 
# updated 05/03/2023

# ----------------------------- #
#  ANSI COLOR ENVIRONMENT VARS

export A_RESET="\033[0m"
export A_BOLD="\033[1m"
export A_DIM="\033[2m"
export A_UNDERLINE="\033[4m"
export A_BLINK="\033[5m"
export A_REVERSE="\033[7m"
export A_HIDDEN="\033[8m"
export A_BLACK="\033[30m"
export A_RED="\033[31m"
export A_GREEN="\033[32m"
export A_YELLOW="\033[33m"
export A_BLUE="\033[34m"
export A_MAGENTA="\033[35m"
export A_CYAN="\033[36m"
export A_WHITE="\033[37m"
export A_LIGHT_GRAY="\033[37;1m"
export A_DARK_GRAY="\033[90m"
export A_PURPLE="\033[35m"
export A_ORANGE="\033[38;5;208m"
export A_LIGHT_BLUE="\033[94m"
export A_NAVY="\033[34m"
export A_SKY="\033[38;5;39m"
export A_GOLD="\033[38;5;220m"
export A_SILVER="\033[38;5;7m"
export A_BRONZE="\033[38;5;137m"
export A_TURQUOISE="\033[38;5;45m"
export A_CHARTREUSE="\033[38;5;118m"
export A_BROWN="\033[38;5;130m"
export A_FOREST_GREEN="\033[38;5;28m"
export A_LIME_GREEN="\033[38;5;76m"
export A_LIGHT_GREEN="\033[38;5;157m"
export A_MINT="\033[38;5;121m"
export A_PINK="\033[38;5;218m"
export A_HOT_PINK="\033[38;5;205m"
export A_LAVENDER="\033[38;5;183m"
export A_LILAC="\033[38;5;177m"
export A_TEAL="\033[38;5;31m"
export A_MAROON="\033[38;5;52m"
export A_BEIGE="\033[38;5;230m"
export A_MAUVE="\033[38;5;179m"
export A_OLIVE="\033[38;5;142m"
export A_CORAL="\033[38;5;203m"
export A_SALMON="\033[38;5;209m"
export A_PEACH="\033[38;5;224m"
export A_TAN="\033[38;5;180m"
export A_SKIN="\033[38;5;223m"
export A_AQUAMARINE="\033[38;5;86m"
export A_FOREST="\033[38;5;22m"
export A_SEAFOAM="\033[38;5;122m"
export A_ROSE="\033[38;5;211m"
export A_MELON="\033[38;5;208m"
export A_INDIGO="\033[38;5;93m"
export A_LIGHT_CYAN="\033[38;5;159m"
export A_LIGHT_RED="\033[38;5;203m"
export A_LIGHT_YELLOW="\033[38;5;227m"
export A_LIGHT_GREEN2="\033[38;5;120m"
export A_LIGHT_PURPLE="\033[38;5;141m"
export A_LIGHT_ORANGE="\033[38;5;215m"
export A_LIGHT_PINK="\033[38;5;218m"
export A_LIGHT_BLUE2="\033[38;5;33m"
export A_YELLOW_GREEN="\033[38;5;154m"
export A_ROYAL_BLUE="\033[38;5;62m"
export A_CORNFLOWER_BLUE="\033[38;5;69m"
export A_LIGHT_SKY_BLUE="\033[38;5;153m"
export A_MEDIUM_BLUE="\033[38;5;27m"
export A_MEDIUM_GREY="\033[38;5;246m"
export A_MIDNIGHT_BLUE="\033[38;5;17m"
export A_SPRING_GREEN="\033[38;5;48m"
export A_MEDIUM_SPRING_GREEN="\033[38;5;49m"
export A_DARK_KHAKI="\033[38;5;143m"
export A_KHAKI="\033[38;5;179m"
export A_DARK_TURQUOISE="\033[38;5;44m"
export A_DARK_SLATE_BLUE="\033[38;5;61m"
export A_MEDIUM_PURPLE="\033[38;5;141m"
export A_MEDIUM_SEA_GREEN="\033[38;5;70m"
export A_DARK_SEA_GREEN="\033[38;5;108m"
export A_LIGHT_SEA_GREEN="\033[38;5;39m"
export A_LIGHT_GREY2="\033[38;5;250m"
export A_MEDIUM_GREY2="\033[38;5;241m"

# Handle other names which people might use for the same colors
export A_RESTORE="${A_RESET}"
export A_INVERSE="${A_REVERSE}"

# recognize ANSI escape codes
# @param $1 the text to recognize a color or style name from
function ansi() {
  local color="${1^^}"  # Capitalize color name
  if [[ "${color}" =~ ^(BG|BACKGROUND)_ ]]; then
    echo "$(ansi "${color#*_}")" | sed "s/^/$(ansi "BG_")/"
  elif [[ -v "A_${color}" ]]; then
    echo "${!A_${color}}"  # Return escape code
  else
    echo "${A_RED}Error: Invalid color '${color}'.${A_RESET}" >&2
    return 1
  fi
}

# colorizes & styles text, then ECHOs it 
# @param $1 The text to be colorized. Must be a string. 
# @params the other parameters are all modifiers, which are translated from text to ANSI color codes. 
# 
# the only unique feature is that of the "background" or "bg" parameter, which will take the following color name
# and use it to try and find a background color instead of the normal foreground color. 
colorize() {
  local text="$1"
  shift  # Remove first argument
  local color_args=()
  local bg_color=""
  while [[ "$#" -gt 0 ]]; do
    local arg="$1"
    if [[ -z "${arg}" ]]; then
      shift  # Skip over empty argument
      continue
    elif [[ "${arg^^}" =~ ^(BG|BACKGROUND)$ ]]; then
      if [[ "$#" -lt 2 ]]; then
        echo "${A_RED}Error: No color specified after '${arg}'.${A_RESET}" >&2
        return 1
      fi
      local next_arg="${2^^}"
      if [[ -v "A_BG_${next_arg}" ]]; then
        bg_color="${next_arg}"
        shift 2  # Remove the color argument and its value
      else
        echo "${A_RED}Error: Invalid color '${next_arg}' after '${arg}'.${A_RESET}" >&2
        return 1
      fi
    elif [[ "${arg}" =~ ^[A-Za-z_]+$ && -v "A_${arg^^}" ]]; then
      color_args+=("$(ansi "${arg}")")
      shift  # Remove color argument
    else
      echo "${A_RED}Error: Invalid argument '${arg}'.${A_RESET}" >&2
      shift  # Remove non-string argument
    fi
  done
  local colors="${color_args[*]}"
  local bg_colors="$(ansi "BG_${bg_color}")"
  echo -ne "${bg_colors}${colors}${text}${A_RESET}\n"
}

# EXPORT ALL FUNCTIONS AS BASH GLOBAL IF EXECUTED
export -f ansi
export -f colorize
