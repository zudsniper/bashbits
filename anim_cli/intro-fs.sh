#!/bin/bash
# intro-fs.sh v1.0.0
# -----------
# Created 04/29/2023
# 
# displays stupid fullscreen intro "rain" animation with set colors & emojis. Text is supplied as first argument. 
# USAGE
# ./intro-fs.sh "ZOD GAMING!!!!"
# 
# @zudsniper


# ANSI escape codes for colors
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Characters to use in the animation
CHARS=("🐳" "💧" "🌊" "🌌" "🐬" "❄" "🌬" "☄" "🧼" "🌃")

# message as first arg to script
message="$1"
# Function to create the animation
cli_animation() {
    clear
    local lines=$(tput lines)
    local cols=$(tput cols)
    local duration=0.1

    for i in $(seq 1 15); do
        clear

        # Randomly print characters on the screen
        for i in $(seq 1 ${#CHARS[@]}); do
            local row=$((1 + RANDOM % lines))
            local col=$((1 + RANDOM % cols))

            tput cup $row $col
            echo -e "${BLUE}${CHARS[$((RANDOM % ${#CHARS[@]}))]}${NC}"
        done

        sleep $duration
    done

    # Print the message
    tput cup $((lines / 2)) $(((cols / 2) - ( ${#message} / 2 )))
    echo -e "${CYAN}$message${NC}"
    sleep 1

    clear
}

# Call the animation function with your desired message
cli_animation
