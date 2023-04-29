#!/bin/bash
# bubbles-fs.sh
# -----------
# by @zudsniper
# > 04/29/2023
# 
# displays stupid fullscreen intro "BUBBLES" animation with set colors & emojis. Text is supplied as first argument. 
# USAGE
# ./bubbles-fs.sh "ZOD GAMING!!!!"
# ------------


# ANSI escape codes for colors
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Characters to use in the animation
CHARS=("🐳" "💧" "🌊" "🌌" "🐬" "❄" "🌬" "☄" "🧼" "🌃")

# Function to create the animation
cli_animation() {
    local message="$1"
    local lines=5
    local cols=$(tput cols)
    local duration=0.1

    # Save the current cursor position
    tput sc

    # Get the current cursor position
    local start_row=$(tput lines)
    local start_col=$(tput cols)

    # Create a small window for the animation
    for i in $(seq 1 15); do
        # Clear the small window
        for l in $(seq 0 $((lines - 1))); do
            tput cup $((start_row + l)) $((start_col / 4))
            tput el
        done

        # Randomly print characters in the small window
        for i in $(seq 1 ${#CHARS[@]}); do
            local row=$((start_row + RANDOM % lines))
            local col=$((start_col / 4 + RANDOM % (cols / 2)))

            tput cup $row $col
            echo -e "${BLUE}${CHARS[$((RANDOM % ${#CHARS[@]}))]}${NC}"
        done

        sleep $duration
    done

    # Print the message
    tput cup $((start_row + lines / 2)) $(((start_col / 2) - (${#message} / 2)))
    echo -e "${CYAN}$message${NC}"
    sleep 1

    # Clear the small window and restore the cursor position
    tput clear
    tput rc
}

# Call the animation function with your desired message
cli_animation "$1"