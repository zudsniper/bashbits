# zod.tf .zshrc macOS 14.5 Sonoma
# .zshrc v2.3.1
# ------------------
# 
# CHANGELOG
#
# v2.3.1 
# - adding pyenv support 
#
# v2.3.0 
# - Added internet connectivity check to auto-update function
# - Updated tested macOS version of deployment
#
# v2.2.2 - added pss() function to create file from current clipboard contents CREDIT: (https://apple.stackexchange.com/a/391795/497602)
# v2.2.1 - fix an oopsie (arg check in setTerminalText)
# v2.2.0 
# - added window / tab title changing functionality with SetTerminalText function & shortcuts
# 
# v2.1.4 - added NVM_SYMLINK_CURRENT true for nvm quality of life in IDE
# v2.1.3 
# - remove (?) bash-like bindings in favor of zsh & brew dependent binding style
#
# v2.1.2 - fix more bugs
# v2.1.1 - fix bugs
# v2.1.0
# - added update notifications for this file itself
# - added an autoupdate_zshrc alias which will do as the name suggests. 
#
# v2.0.5
# - remove redundant nvm bindings added in 2.0.3 (lol)
# - added imgurbash2 auto-download & update for imgur upload from CLI
# 
# v2.0.4
# - reformatted header
# 
# v2.0.3 
# - added nvm bindings (assumes `brew install nvm` has been run, idk if this is the default behavior I want)
# 
# by @zudsniper
# ------------------

####################################################
# UPDATE NOTIFICATIONS & AUTO-UPDATE FUNCTIONALITY #
#      -- written by chatgpt4o mostly --         # 
#################################################### 
# > use env var ZSHRC_CHECKUPDATE to disable the update notifications if desired. 

# Define a function to print messages with ANSI escape codes for color and italics
function print_msg() {
  local msg=$1
  local color=$2
  echo -e "\033[3;${color}m${msg}\033[0m"
}

# Auto-update .zshrc if a newer version is available
function update_zshrc() {
  # Check if ZSHRC_AUTOUPDATE is set to a truthy value
  if [[ "$ZSHRC_AUTOUPDATE" == "0" || "$ZSHRC_AUTOUPDATE" == "false" || "$ZSHRC_AUTOUPDATE" == "FALSE" ]]; then
    return
  fi

  # Check for network connectivity
  if ! ping -c 1 google.com &>/dev/null; then
    print_msg "No network connection. Autoupdate cannot be performed." "31"
    return
  fi

  local zshrc_path="$HOME/.zshrc"
  local github_url="https://gh.zod.tf/bashbits/raw/master/.zshrc"

  # Extract local version from the last occurrence of 'v' in the second line of .zshrc
  local local_version=$(sed -n '2p' "$zshrc_path" | awk -F'v' '{print $NF}')

  # Fetch remote version from GitHub
  local remote_version=$(curl -sSL "$github_url" | sed -n '2p' | awk -F'v' '{print $NF}')

  # Compare versions and prompt for update if necessary
  if [[ "$local_version" != "$remote_version" ]]; then
    echo -e "A new version of .zshrc is available. Current: \033[0;31m$local_version\033[0m -> New: \033[0;32m$remote_version\033[0m"
    echo "To update, run 'autoupdate_zshrc'"
  fi
}

# Alias to auto-update .zshrc
alias autoupdate_zshrc="curl -sSL -o $HOME/.zshrc https://gh.zod.tf/bashbits/raw/master/.zshrc && source $HOME/.zshrc && echo 'Updated and sourced .zshrc'"

# Add the check to your .zshrc
update_zshrc


#################################################### 

# enable CLI color for zsh
export CLICOLOR=1

# ======== silly terminal prompts ======== #

# add color prompt
function long_prompt() {
	export PROMPT='🐟%B%F{51}%n%f%b@%F{green}%m%f: %F{02}%F{light-gray}%~%f%f$ '
}

# toggleable short prompt
function short_prompt() {
    export PROMPT='🐳%B%F{51}%n%f%b@%F{green}%m%f: 📂/%F{04}%F{magenta}%1d%f%f$ '
}

short_prompt

# ============ simple aliases ============ #

# simple shortcuts
alias lsa="ls -lhrtaG"
alias ls="ls -G"

# python interpreter setup
# Check if pyenv is installed
if command -v pyenv 1>/dev/null 2>&1; then
  # If pyenv is installed, initialize pyenv and set up virtualenv integration
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"   # Initialize pyenv-virtualenv
  
  # Alias python and python3 to pyenv's global Python interpreter
  alias python="$(pyenv which python)"
  alias python3="$(pyenv which python3)"
else
  # If pyenv is not installed, alias python and python3 to Homebrew Python 3
  alias python="/usr/local/bin/python3"
  alias python3="/usr/local/bin/python3"
fi


# ====== gist convenience functions ====== #
# NOTE: development in gists helper functions

export GIST_ACTIVE=""

function save_gist() {
    if [ $# -lt 1 ]
    then
        export GIST_ACTIVE=""
        echo "❇️  Cleared active gist file URL."
        return
    fi

    export GIST_ACTIVE="$1"
    echo "✅ saved active gist file URL."
}

function refresh_gist() {
    if [ $# -lt 1 ]
    then
        if [ -z "${GIST_ACTIVE}" ]
        then
            echo "❌ provide an argument that is a gist raw file URL"
            return
        else
            echo "🔰 Using active gist url..."
            url="${GIST_ACTIVE}"

        fi
    else
        url="$1"
    fi

    local filename=$(basename ${url})
    echo "🔰 removing old $filename and pulling new..."
    rm -f "${filename}"
    curl -sL "${url}" -O
    chmod +x "${filename}"
    echo "✅ refreshed gist."

    # get version
    line=$(sed -n '2p' "${filename}")
    version=$(echo $line | awk '{for(i=1;i<=NF;i++){if($i ~ /^v/){print substr($0, index($0,$i)); exit}}}')

    echo "ℹ️  ${filename}"
    echo "ℹ️  ${version}"
    return
}

alias update_gist=refresh_gist


# ======== modify title text shortcut funcs ======= # 

# CREDIT: https://superuser.com/a/344397/1797735
# Thank you @Orangenhain on StackExchange! 
# > Somewhat modified for quality of life

# $1 = type; 0 - both, 1 - tab, 2 - title
# rest = text
setTerminalText () {
    if [ "$#" -eq 0 ]; then 
      echo "usage: setTerminalText [header-set-type] (any amount of text)"
      echo ""
      echo "    header-set-type [0-2]"
      echo "    0 - both"
      echo "    1 - tab"
      echo "    2 - title"
      echo ""
      echo "* if you're using zod's ~/.zshrc, here are shortcut functions you can use *"
      echo "    stt_both (text)"
      echo "    stt_tab (text)"
      echo "    stt_title (text)"
    fi 

    # echo works in bash & zsh
    local mode=$1 ; shift
    echo -ne "\033]$mode;$@\007"
}
stt_both  () { setTerminalText 0 $@; }
stt_tab   () { setTerminalText 1 $@; }
stt_title () { setTerminalText 2 $@; }


# ======== image / video conversion automation ======== #

# imgurbash2
# ------------
# https://github.com/ram-on/imgurbash2.git
# script to upload images to imgur easily without a client id or api key. 
# how God intended. 

# -- acquisition and update checking function below written by chatgpt4 + plugins -- # 
# Check for imgurbash2 script and update if necessary
function check_imgurbash2() {
  local imgurbash2_path="/usr/local/bin/imgurbash2"  # Change this to your desired path
  local github_url="https://raw.githubusercontent.com/ram-on/imgurbash2/master/imgurbash2"

  # Check if imgurbash2 exists locally
  if [[ -f "$imgurbash2_path" ]]; then
    local local_version=$(awk -F'"' '/readonly VERSION=/ {print $2}' "$imgurbash2_path")
  else
    local local_version=""
  fi

  # Fetch the latest version from GitHub
  local latest_version=$(curl -s "$github_url" | awk -F'"' '/readonly VERSION=/ {print $2}')

  # Compare versions and update if necessary
  if [[ "$local_version" != "$latest_version" ]]; then
    sudo curl -sSL -o "$imgurbash2_path" "$github_url" && sudo chmod +x "$imgurbash2_path"
  fi
}



# Add the check to your .zshrc
check_imgurbash2

# Add imgurbash2 to PATH (if it's not in a standard location already)
# export PATH="$PATH:/path/to/imgurbash2"  # Uncomment and modify this line if necessary
# ------------

# Paste Screen Shot to file (in folder provided as arg1)
# - only works with PNG encoded images! 
# 
# credit to https://apple.stackexchange.com/a/391795/497602 ! 
function pss() {
    folder=$(pwd)
    filename="clipboard_$(date +%Y-%m-%d-%H_%M_%S).png"

    if [ $# -ne 0 ]; then
        if [[ -d $1 ]]; then
            if [ "$1" != "." ]; then folder=$1; fi
        else
            a=$(dirname "$1")
            b=$(basename "$1" .png)

            if [ "$b" != "" ]; then filename=$b.png; fi

            if [ "$a" != "." ]; then folder=$a; fi
        fi
    fi

    osascript -e "tell application \"System Events\" to ¬
            write (the clipboard as «class PNGf») to ¬
            (make new file at folder \"$folder\" ¬
            with properties {name:\"$filename\"})"
}


# video_to_gif
# ------------
# this is for quicktime mov -> gif
# from https://gist.github.com/SheldonWangRJT/8d3f44a35c8d1386a396b9b49b43c385
alias video_to_gif='function video_to_gif(){ ffmpeg -i "$1" "${1%.*}.gif" && gifsicle -O3 "${1%.*}.gif" -o "${1%.*}.gif" && osascript -e "display notification \"${1%.*}.gif successfully converted and saved\" with title \"MOV2GIF SUCCESS!\""};video_to_gif'
# ------------

# ===================== nvm bindings ================== #

# ---------------------------------- # 
# THIS IS FOR BASH, WE ARE USING ZSH
# 
# node version manager (nvm) linking
# export NVM_DIR="$HOME/.nvm"
#   [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# ---------------------------------- # 

# add nvm env var to enable a symlink ~/.nvm/current for use with IDEs to make shit less annoying
# credit: https://medium.com/@danielzen/using-nvm-with-webstorm-or-other-ide-d7d374a84eb1

export NVM_SYMLINK_CURRENT=true

# appropriate zsh binding (assuming installation with homebrew)
# credit: https://gist.github.com/mike-casas/6d489bebf48d89f5109cd1395aabe150

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# ===================== miscellaneous ================= #

# test iterm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# fix capacitor open
export CAPACITOR_ANDROID_STUDIO_PATH="/usr/local/bin/scripts/studio"

# 🚫 removed because 13.5.1
# macOS 10.15 moment
# export PATH="/usr/local/sbin:$PATH"

# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

