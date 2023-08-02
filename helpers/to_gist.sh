#!/bin/bash
# to_gist.sh v0.3.4
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

# Parse input string for repository URL and file/folder path
parse_input_string() {
    local input_string=$1
    local repo_url
    local file_or_folder_path

    if [[ $input_string =~ ^(https?://[^/]+/[^/]+)/(.+)$ ]]; then
        repo_url=${BASH_REMATCH[1]}
        file_or_folder_path=${BASH_REMATCH[2]}
    else
        log error "Invalid input string. Please provide a valid input string in the format: REPO_URL/FILE_OR_FOLDER_PATH"
        exit 1
    fi

    REPO_URL=$repo_url
    FILE_OR_FOLDER_PATH=$file_or_folder_path
}

# Check if git is installed
check_git_installed() {
    if ! command -v git >/dev/null 2>&1; then
        log error "git is not installed. Please install git."
        exit 1
    fi
}

# Check if gh is installed
check_gh_installed() {
    if ! command -v gh >/dev/null 2>&1; then
        log error "gh is not installed. Please install gh."
        exit 1
    fi
}

# Check if gh is installed
check_installed() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log error "$1 is not installed. Please install $1."
        exit 1
    fi
}

# Check if gh is authenticated
check_gh_authenticated() {
    if ! gh auth status >/dev/null 2>&1; then
        log info "gh is not authenticated. Authenticating..."
        gh auth login
    fi
}

# Setup git with gh
setup_git_with_gh() {
    gh auth setup-git
}

# Clone the repository
clone_repository() {
    local repo_url=$1
    local temp_dir=$(mktemp -d)

    log info "Cloning repository..."
    git clone "$repo_url" "$temp_dir"

    CLONE_DIR=$temp_dir
}

# Upload file/folder as gist
upload_as_gist() {
    local clone_dir=$1
    local file_or_folder_path=$2

    log info "Uploading file/folder as gist..."
    local gist_output=$(gh gist create "$clone_dir/$file_or_folder_path")

    # Extract the Gist ID from the output
    GIST_ID=$(echo "$gist_output" | grep -oP '(?<=Gist created: ).*')
}

# Function to get RAW URL of a file from Gist output
get_raw_url() {
    local gist_output=$1
    local file_name=$2
    local raw_url

    raw_url=$(echo "$gist_output" | grep -F "$file_name" | awk '{print $NF}')
    echo "$raw_url"
}

# Function to recursively list files with RAW URLs
list_files() {
    local gist_id=$1
    local directory="$2"
    local indent="$3"

    cd "$directory"

    local gist_output
    gist_output=$(gh gist view "$gist_id" -r)

    for file in *; do
        if [[ -d $file ]]; then
            folder_emojis=("📁" "📂" "🗂")
            folder_emoji=${folder_emojis[RANDOM % ${#folder_emojis[@]}]}
            log info "${indent}${folder_emoji} $file"
            list_files "$gist_id" "$file" "$indent  "
        else
            file_emojis=("📃" "📝" "📑" "📄")
            file_emoji=${file_emojis[RANDOM % ${#file_emojis[@]}]}
            raw_url=$(get_raw_url "$gist_output" "$file")
            log info "${indent}${file_emoji} $raw_url"
        fi
    done

    cd ..
}

# ========= MAIN ========== #  

# Check and parse input string
if [[ $# -eq 1 ]]; then
    parse_input_string "$1"
else
    log error "Invalid number of arguments. Please provide a single input string."
    exit 1
fi

# Check if git is installed
check_installed "git"

# Check if gh is installed
check_installed "gh"

# jq
check_installed "jq"

# Check if gh is authenticated
check_gh_authenticated

# Setup git with gh
setup_git_with_gh

# Clone the repository
clone_repository "$REPO_URL"

# Upload file/folder as gist
upload_as_gist "$CLONE_DIR" "$FILE_OR_FOLDER_PATH"

# Print link to the secret Gist
log info "Link to the secret Gist: $GIST_ID"

# Print hierarchical list of files with RAW URLs
log info "Hierarchical list of files in the Gist:"

list_files "$GIST_ID" "$CLONE_DIR" ""

# Clean up
log info "Cleaning up..."
rm -rf "$CLONE_DIR"

# Print author's GitHub handle
log info "Author's GitHub handle: ${Magenta}@zudsniper${Color_Off}"
