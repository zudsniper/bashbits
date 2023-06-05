#!/bin/bash
# to_gist.sh
# ----------
# 
# Simple script to upload a secret gist of a private repository subfile or 
# subdirectory that the authenticated user has access to.  
# 
# @zudsniper

# ANSI color schema
ANSI_COLORS_FILE="$HOME/.ansi_colors.sh"
ANSI_COLORS_URL="https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh"

# Check and install ANSI color schema if necessary
if [[ ! -f "$ANSI_COLORS_FILE" ]]; then
    echo "Installing ANSI color schema..."
    curl -o "$ANSI_COLORS_FILE" "$ANSI_COLORS_URL"
fi

# Load ANSI color schema
source "$ANSI_COLORS_FILE"

# Logging function
log() {
    local level=$1
    local message=$2

    case $level in
        "silly")
            echo -e "${Cyan}[$level]${Color_Off} $message"
            ;;
        "verbose")
            echo -e "${Green}[$level]${Color_Off} $message"
            ;;
        "debug")
            echo -e "${Yellow}[$level]${Color_Off} $message"
            ;;
        "http")
            echo -e "${Blue}[$level]${Color_Off} $message"
            ;;
        "info")
            echo -e "${White}[$level]${Color_Off} $message"
            ;;
        "warn")
            echo -e "${Purple}[$level]${Color_Off} $message"
            ;;
        "error")
            echo -e "${Red}[$level]${Color_Off} $message"
            ;;
        "critical")
            echo -e "${Red}${Bold}[$level]${Color_Off} $message"
            ;;
        *)
            echo "Unknown log level: $level"
            ;;
    esac
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
            log info "Usage: ./script.sh [options] <repository_url> <file_or_folder_path>"
            log info "Options:"
            log info "  --help, -h     Show usage message with color."
            log info "  --version, -V  Display VERSION variable, if undefined, print \"None\"."
            log info "  --verbose, -v  Set logging to verbose, excluding \"silly\" level."
            log info "  --log_level, -l [level]  Set log level (7=silly, 0=critical)."
            exit 0
            ;;
        -V|--version)
            if [[ -z ${VERSION+x} ]]; then
                log info "VERSION: None"
            else
                log info "VERSION: $VERSION"
            fi
            exit 0
            ;;
        -v|--verbose)
            export LOG_LEVEL="verbose"
            ;;
        -l|--log_level)
            shift
            export LOG_LEVEL="$1"
            ;;
        *)
            REPO_URL="$1"
            FILE_OR_FOLDER_PATH="$2"
            break
            ;;
    esac

    shift
done

# Check if repository URL and file/folder path are provided
if [[ -z $REPO_URL || -z $FILE_OR_FOLDER_PATH ]]; then
    log error "Repository URL and file/folder path are required."
    exit 1
fi

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    log error "git is not installed. Please install git."
    exit 1
fi

# Check if gh is installed
if ! command -v gh >/dev/null 2>&1; then
    log error "gh is not installed. Please install gh."
    exit 1
fi

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
    log info "gh is not authenticated. Authenticating..."
    gh auth login
fi

# Setup git with gh
gh auth setup-git

# Clone the repository
TEMP_DIR=$(mktemp -d)
log info "Cloning repository..."
git clone "$REPO_URL" "$TEMP_DIR"

# Upload file/folder as gist
log info "Uploading file/folder as gist..."
gh gist create "$TEMP_DIR/$FILE_OR_FOLDER_PATH"

# Clean up
log info "Cleaning up..."
rm -rf "$TEMP_DIR"

# Print author's GitHub handle
log info "Author's GitHub handle: ${Magenta}@zudsniper${Color_Off}"
