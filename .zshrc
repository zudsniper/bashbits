# zod.tf .zshrc macOS 13.5.1 Ventura
# v2.0.1
# ------
#
# by @zudsniper

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
alias lsa="ls -lhrta"

# python3 bruh
# NOTE: this will break a lot of stuff on macOS versions below catalina (10.15.7)
alias python="python3"

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


# ======== image / video conversion automation ======== #

# video_to_gif
# ------------
# this is for quicktime mov -> gif
# from https://gist.github.com/SheldonWangRJT/8d3f44a35c8d1386a396b9b49b43c385
alias video_to_gif='function video_to_gif(){ ffmpeg -i "$1" "${1%.*}.gif" && gifsicle -O3 "${1%.*}.gif" -o "${1%.*}.gif" && osascript -e "display notification \"${1%.*}.gif successfully converted and saved\" with title \"MOV2GIF SUCCESS!\""};video_to_gif'


# ===================== nvm bindings ================== #

# node version manager (nvm) linking
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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