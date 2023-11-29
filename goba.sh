#!/bin/bash
# goba.sh v1.0.0
# -------------------
# 
# Simple installation script for ~/.bashrc at https://bashrc.zod.tf 
#     - handles non-interactive execution, assuming defaults
#     - adds source of ~/.bashrc to ~/.bash_profile
# 
# @zudsniper


# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function for error handling
error_exit() {
    echo -e "${RED}${BOLD}Error: $1${NC}" >&2
    exit 1
}

echo -e "${GREEN}${BOLD}Downloading the new ~/.bashrc...${NC}"
curl -sSL https://bashrc.zod.tf -o ~/.bashrc || error_exit "Failed to download ~/.bashrc."

echo -e "${GREEN}Download complete.${NC}"

# Function to add source command to .bash_profile
update_bash_profile() {
    echo -e "\n# Source .bashrc if it exists" > ~/.bash_profile
    echo -e "if [ -f ~/.bashrc ]; then\n    source ~/.bashrc\nfi" >> ~/.bash_profile
    echo -e "${GREEN}${BOLD}Updated ~/.bash_profile to source ~/.bashrc.${NC}"
}

# Check if the script is running in an interactive mode
if [ -t 0 ]; then
    # Interactive mode
    echo -e "${GREEN}Would you like to override & source ~/.bashrc from ~/.bash_profile? (Y/n)${NC}"
    read -r -p "" response
    case "$response" in
        [nN][oO]|[nN])
            echo -e "${YELLOW}Skipping update of ~/.bash_profile.${NC}"
            ;;
        *)
            update_bash_profile
            ;;
    esac
else
    # Non-interactive mode, assume 'yes' for all prompts
    update_bash_profile
fi

echo -e "${GREEN}${BOLD}Installation successful!${NC}"
