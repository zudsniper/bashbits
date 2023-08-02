#!/bin/bash
# shellwash-fs.sh v1.0.0
# ---------------
# Created 04/29/2023
# 
# SCUFFED WASH OF SCREEN (dirty!)
# 
# @zudsniper

cli_animation() {
  local wave_chars=("." "o" "O" "@" "*" "🌊" "🧼" "💧" "🚿" "🧺" "🐳")
  local bg_image=("*------------------------------------------------------------------------------------*" " _______  ______  _____  _______      _____  _     _  ______      ______ _______ __   _" " |_____| |  ____ |_____]    |    ___ |_____] |____/  |  ____ ___ |  ____ |______ | \\  |" " |     | |_____| |          |        |       |    \\_ |_____|     |_____| |______ |  \\_|" "*------------------------------------------------------------------------------------*")
  local frame_count=${1:-5}
  local frame_delay=0.1

  # Get the terminal width and height
  local terminal_width=$(tput cols)
  local terminal_height=$(tput lines)

  # Calculate the offset to center the background image
  local image_offset=$(( (terminal_width - ${#bg_image[0]}) / 2 ))

  # Print the background image
  for i in "${bg_image[@]}"; do
    tput cup 0 $image_offset
    echo -e "\e[37m$i\e[0m"
  done

  # Loop through each frame of the animation
  for ((i=0; i<$frame_count; i++)); do
    # Generate a random number to determine the height of the wave
    local wave_height=$(($RANDOM % 4 + 3))

    # Loop through each row of the terminal
    for ((j=0; j<$terminal_height; j++)); do
      local line=""
      # Loop through each character of the row
      for ((k=0; k<$terminal_width; k++)); do
        # Check if the current character is part of the background image
        if (( k >= image_offset && k < image_offset + ${#bg_image[0]} && j < ${#bg_image[@]} )); then
          line="${line}${bg_image[j]:k-image_offset:1}"
        else
          # Generate a random character for the wave animation
          local char_index=$(($RANDOM % ${#wave_chars[@]}))
          local char="${wave_chars[$char_index]}"
          # Check if the current character is part of the wave
          if (( k >= j - wave_height && k <= j + wave_height )); then
            line="${line}\e[34m$char\e[0m"
          else
            line="${line}\e[37m$char\e[0m"
          fi
        fi
      done
      # Print the current row with the correct offset
      tput cup $j 0
      echo -ne "${line}\r"
    done
  done
}

# call that mfer
cli_animation