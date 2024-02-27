# zod's ~/.bashrc for most linux distros using bash
# .bashrc v4.4.0
# --------------- 
#
#################################################################
#                    __       __               __             
#   ____  ____  ____/ /____  / /_  ____ ______/ /_  __________
#  /_  / / __ \/ __  / ___/ / __ \/ __ `/ ___/ __ \/ ___/ ___/
#   / /_/ /_/ / /_/ (__  ) / /_/ / /_/ (__  ) / / / /  / /__  
#  /___/\____/\__,_/____(_)_.___/\__,_/____/_/ /_/_/   \___/  
# 
#################################################################
# /bin/bash configs by @zudsniper, or "zod"
# 
# available at https://bashrc.zod.tf
# 
# TODO
# (make sure to check for `TODO` within the text of this file if you are updating it, in case something isn't listed here.)    
# - add self-updating (at least version checks and warnings if out of date)
# - add smart-merging text files
# - clean up the first lines of this script, taken from a Bullseye 11.6 Debian installation arbitrarily. Assess value & necessity. 
# - standardize function header comments -- simply document more of the functionality of each addition
# - add a Glossary to elucidate the additions of this script and how to get started with it.  
# - [MAJOR] create a `~/.zshrc` much like this file, but for (mostly MacOS) `~/.zshrc` users
# ---------------  
#
# CHANGELOG
# 
# v4.4.0
# - retooled for handling of sudo requirements / authorization for silent sourceing whether or not the 
#   executing user is a member of sudo or docker group or not. 
# - moving around some comments such as figfont header
# 
# v4.3.2 - finally added check for `.nvm` directory before sourcing so that nvm doesn't 'need' to be installed to use this .bashrc
# v4.3.1
# - reformatting header
# 
# v4.3.0
# Gonna start keeping an update log here until it gets too long
# - Adding `rmerge` alias for merging with rsync (check alias definition for source attribution)
# - Updating the strategy information in this long comment header
# - Added explanation of functionality of self-updater
# - Updating a lot of function headers
# - Adding TODO items throughout the file
# - Adding TODO section in this header  
# - Better differentiated between default debian ~/.bashrc and my own work 
# 
# v4.2.1
# (this is the version before adding this changelog, but you can check the github commits to see)
# 
# 
# 
# by @zudsniper 
# --------------- 

#################################################################
# FROM DEBIAN BULLSEYE 11.6 DEFAULT ~/.bashrc
#################################################################

#   executed by bash(1) for non-login shells. & fools. 
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
#case $- in
#    *i*) ;;
#      *) return;;
#esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

#################################################################
# this bit is written by @zudsniper, but is just a short snippet that must be here for color reasons. 
#     After the next delimiter bar (like the one above & below this text), we return to the base ~/.bashrc as described earlier.
#################################################################

# ----------------------------- #
## ANSI COLOR ENVIRONMENT VARS

# Check if .ansi_colors.sh exists, and if not, download it from Github
if [ ! -f "$HOME/.ansi_colors.sh" ]; then
  echo "${A_LIGHTGREY}Downloading ${A_BOLD}.ansi_colors.sh${A_RESET}${A_LIGHTGRAY}...${A_RESET}"
  curl -sSf "https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh" > "$HOME/.ansi_colors.sh"
fi

# source the colors
. "$HOME/.ansi_colors.sh"
# ----------------------------- #

#################################################################
# FROM DEBIAN BULLSEYE 11.6 DEFAULT ~/.bashrc
#################################################################

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

#################################################################
# END FROM DEBIAN BULLSEYE 11.6 DEFAULT ~/.bashrc
#################################################################

# ----------------------------- #
# check executing operating system of this bash instance
# TODO: This script needs an update to handle WSL2 better as well as other virtualized environments like docker containers 
checkOS() {
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        export opersys="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
	export opersys="mac"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
	export opersys="linux"
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
	export opersys="linux"
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
	export opersys="win32"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
	export opersys="freebsd"
else
        export opersys="unknown"
	# Unknown.
fi
}

# > Not sure this is necessary, but it may be depending on the other functions in this file.
## _______ OS DETERMINED _______ ##
# "${opersys}"
checkOS;
# ----------------------------- #
#           system
alias lsa="ls -lhrta" # convenience alias for listing stuff in current dir in human readable format

## hibernation
# > this is a bit of a hack, but it works. On Debian. Debian Bullseye. Sometimes.
# FUNCTIONALITY
#  sleepy - makes the system able to sleep, hibernate, or suspend
#  noSleepy - makes the system unable to sleep, hibernate, or suspend
alias sleepy="sudo systemctl mask sleep.target suspend.target hibernate.target hibernate-hybrid.target"
alias noSleepy="sudo systemctl mask sleep.target suspend.target hibernate.target hibernate-hybrid.target"

# ----------------------------- #
# TF2Autobot management aliases

# TODO
# - add a function to check if the current directory is a TF2Autobot instance, and if so, set the BOT_ECOSYSTEM_FILE env var to the appropriate file name.
# - fix the way ecosystem file is set / recognized.

# first, set BOT_ECOSYSTEM_FILE if this is our first run
if alias autobotDir >/dev/null 2>&1; then
	export BOT_ECOSYSTEM_FILE="ecosystem.json"
fi

alias autobotDir="cd ." 
#export BOT_ECOSYSTEM_FILE="ecosystem.json"
alias startAutobot="autobotDir; pm2 start ./${BOT_ECOSYSTEM_FILE} --update-env && pm2 save"
alias stopAutobot="autobotDir; pm2 stop ./${BOT_ECOSYSTEM_FILE} --update-env && pm2 save"
alias fStopAutobot="autobotDir; sudo pm2 stop ./${BOT_ECOSYSTEM_FILE} --update-env --force && pm2 save --force"
alias restartAutobot="autobotDir; pm2 restart ./${BOT_ECOSYSTEM_FILE} --update-env && pm2 save"

# ----------------------------- #
#            docker 

# v4.4.0 
# retooled for handling of sudo requirements / authorization for silent sourceing whether or not the 
# executing user is a member of sudo or docker group or not. 

# Checks if the user has permission to run Docker without sudo.
can_run_docker() {
    docker info > /dev/null 2>&1
}

# Function to run Docker with or without sudo based on permission.
run_docker() {
    if can_run_docker; then
        docker "$@"
    else
        sudo docker "$@"
    fi
}

# if docker installed
if [ -x "$(command -v docker)" ]; then

    # Check if we can run Docker without sudo or not.
    if can_run_docker; then
        alias dockerLS="docker container ls -q"
        alias dockerGenocide="docker container kill \$(docker container ls -q)"
        alias startPortainer="docker volume create portainer_data; docker run -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -itd portainer/portainer"
        attachBashTo() {
            if [[ "$#" -eq 0 ]]; then
                echo -ne "Please provide argument: container id\n"
                return
            fi
            docker exec -it "$1" /bin/bash
        }
    else
        alias dockerLS="sudo docker container ls -q"
        alias dockerGenocide="sudo docker container kill \$(sudo docker container ls -q)"
        alias startPortainer="sudo docker volume create portainer_data; sudo docker run -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -itd portainer/portainer"
        attachBashTo() {
            if [[ "$#" -eq 0 ]]; then
                echo -ne "Please provide argument: container id\n"
                return
            fi
            sudo docker exec -it "$1" /bin/bash
        }
    fi

fi


# ------------------------------ #
# TF2Autobot management functions
initAutobotFuncs() {

	echo -ne "${A_YELLOW}${A_ITALIC}determining autobot instance...${A_RESET}";
        if [[ "$#" -eq 0 ]]; then
                echo -ne "\n${A_BOLD}${A_LGREEN}Using current dir as autobot root.${RESET} \n";
                alias autobotDir="cd .";
        else
                alias autobotDir="cd $1";
        fi

        echo -ne " ${A_BOLD}${A_GREEN}Done.${A_RESET}\n";
	echo -ne "${A_BOLD}${A_ITALIC}determining configuration file...${A_RESET}";
	if ! [[ -f "./$BOT_ECOSYSTEM_FILE" ]]; then 
		# assuming that BOT_ECOSYSTEM_FILE has not been changed from default 'ecosystem.json' 
	
                echo -ne "\n${A_BOLD}Didn't find ${A_RED}${BOT_ECOSYSTEM_FILE}${A_RESET}${A_BOLD}... ${A_RESET}${A_YELLOW}${A_ITALIC}looking for alternatives... ${RESET} \n";

		if [[ -f "./ecosystem.config.js" ]]; then 

			export BOT_ECOSYSTEM_FILE="ecosystem.config.js"
                	echo -ne "\n${A_BOLD}Found ${A_GREEN}${BOT_ECOSYSTEM_FILE}${A_RESET}${A_BOLD}... ${A_RESET}${A_ITALIC}set env var ${BOT_ECOSYSTEM_FILE}. ${RESET} \n";
		else 
			export BOT_ECOSYSTEM_FILE="ecosystem.json"
			echo ne "\n${A_BOLD}Set ${A_GREEN}${BOT_ECOSYSTEM_FILE}${A_RESET} to default.\n";
		fi
	fi

        echo -ne " ${A_BOLD}${A_GREEN}Done.${A_RESET}\n";
}

runBotInstance() {
        initAutobotFuncs $#;
        startAutobot;
}

stopBotInstance() {
        initAutobotFuncs $#;
        stopAutobot;
	if [[ ${BOT_ECOSYSTEM_FILE} -eq ecosystem.config.js ]]; then
	       npm run pm2-delete;
	fi	       
}

# ----------------------------- #
#            utility

# FUNC => simple analysis size function with normally installed linux CLI stuff
# @param 1 - path: string - root path from which to search
# @param 2 - n: number - the nth highest sized files will be displayed.
findLargestNFiles() {
        if [[ ( $# -eq 0 ) || ( $# -gt 2 ) ]]; then
                echo -ne "${A_RED}${A_BOLD}FORMAT: ${RESET} findLargestNFiles( path: string, n: number )\n";
                exit 1;
        fi

        ROOT_PATH="/";
        if [[ -z ${1} ]]; then
                ROOT_PATH="${1}";
        fi

        NUM_SHOWN=10;
        if [[ -z ${2} ]]; then
                NUM_SHOWN="${2}";
        fi


        # go to provided directory, or `/` if none specified
        cd "${ROOT_PATH}";

        echo -ne "${A_RED}${A_BOLD}[TOP FILES BY SIZE]${A_RESET}\n"; 

        # this line written by ChatGPT on 12/9/22. Skynet moment
        find . -type f -exec du -h {} \; | sort -hr | head -${NUM_SHOWN};

        exit 0;
}

# FUNC => Merge two folders intelligently using rsync, of format `rmerge src/ dest/`
# source: https://superuser.com/questions/547282/which-is-the-rsync-command-to-smartly-merge-two-folders
# NOTE -- this will override any previous backup created via the -b option 
alias rmerge="rsync -abviuzP"

# ----------------------------- #
#     find and kill process
#           by PORT

# FUNC => Kills the process which is detected as running on the provided port
# @param $1 the port in question
# 
# NOTE -- Internal/Lighter version of dispatchPort() -- only handles a single argument and expects it to be provided. 
kPort() {
	echo -ne "${A_PURPLE}${A_BOLD}netstat'in${A_RESET}...\n";
	sudo netstat -tulpn | grep ':${1}}';
	
	echo -ne "${A_YELLOW}${A_INVERSE}REMOVING PROCESS ON${A_RESET} + '$1'\n"
	sudo fuser -k "$1";
}

# FUNC => Kills the process which is detected as running on the provided port
# @param $1 the port in question
dispatchPort() {
	if [ $# -eq 0 ]; then
		echo -ne "${A_RED}${A_BOLD}No port provided as argument -- please do so. ${A_RESET}\n";
		exit 1;
	fi

	echo "${A_RED}${A_BOLD}${A_UNDERLINE}KILLING EVERYTHING ON PORT${A_RESET}" + "$1" + "\n"
	# assume an arg is given
	for PORT in $#
	do 
		kPort "$1";
	done

}

# ----------------------------- # 
#         my installers
# 
# TODO: add these installers 
#    	- docker
# 		- docker-compose 
#       (utilize my `get_dock.sh` script **for debian based Linux**): https://gist.github.com/zudsniper/d79549fef48daeef1749757a850d12a6
# 		- docker-engine 
# 		
# Installs gh via my installer script
alias get_gh="curl -sL https://gh.zod.tf/bashbits/raw/master/installers/get_gh.sh | /bin/bash";
# Installs nvm via my installer script
alias get_nvm="curl -sL https://gh.zod.tf/bashbits/master/installers/get_nvm.sh | /bin/bash";



# ----------------------------- #
#        set shell title

# Set the title of your current terminal window to the provided string 
# @param $1 the title text you want to set 
#
# TODO: Add a check for a parameter, as it is required here... kinda? choose if it is. 
settitle() {
                export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
                echo -ne "\e]0;$1\a"
}
# Set the title of your current terminal window to the current path or working directory of executing user.
settitlepath() {
        export PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
}

# ----------------------------- #
#     git convenience funcs

## REMOVED function git_int_install & git_auth
## > USELESS & BROKEN

# adds all files in current dir to staged changes, commits with the message @params, and pushes the resulting commit 
# to the current branch upstream.
# @param $* all used as the argument passed to `git commit -k {your_parameters_go_here}`
# 
# TODO: add some actual status printing in here sheesh
git_acpush() {

if [[ -z "$#" ]]; then
    echo -ne "${A_RED}${A_BOLD}Please provide a commit message to perform this operation.${A_RESET}\n"
fi

# add all files in current working directory
git add .

# commit with provided message 
git commit -m "$#"

# TODO: support 'main' or some other branch name if this function is called with an option -b|--branch <branch> as a set of 2 parameters which directly follow one another. 
# make sure the branch is called master
# git branch -M master

# push 
git push -u origin master;

}

# ----------------------------- #
#      AUTO-UPDATE APT, Kurtosis, Brew
#     (debian / ubuntu) & (mac)

# updates & upgrades aptitude packages 
#    - changed to use apt-get alias because... idk linux is weird
function autoupdate_apt() {
	# Update and upgrade Ubuntu packages
	sudo apt-get update -y && sudo apt-get upgrade -y
}

# Install `kurtosis`, an environment manager by `https://github.com/kurtosis-tech` which I respect
# 	- An enclave-based approach to isolation / imaging
# 
# this will install/update kurtosis client. 
#    REQUIRES docker
#    REQUIRES debian/ubuntu Linux
function autoupdate_kurtosis() {
	if [ -x "$(command -v kurtosis)" ]; then
		# Install Kurtosis CLI
		echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
		sudo apt update
		sudo apt install kurtosis-cli
	fi
}

# A function to aggregate other installer functions and call the appropriate functions based on operating system. 
# 
# NOTE -- if you want automatic updates on ~/.bashrc source (every time you open a terminal) then add `update_all` to this file below this definition
function update_all {
	if [[ ${opersys} == "linux" ]]; then
		autoupdate_apt
		autoupdate_kurtosis
	elif [[ ${opersys} == "mac" ]]; then
		brew update
	fi
}

# ----------------------------- #
#         self-updates 

# TODO: ADD THIS FEATURE
# 		1. Check the version of this file via the new convention of keeping the current version number on the second line of every script file, 
# 			always proceeded by a 'v' or 'V' and followed immediately with the version information. 
#       2. Check the version of the file available at the upstream, "https://gh.zod.tf/bashbits/raw/master/.bashrc/"
# 		3. If LOCAL_VERSION < CURRENT_VERSION, show an appropriately colored message which explains that your version is outdated,
# 			 as well as showing both versions, local & current (local version in grey & italic if the minor versions is the same as the web file (current) version; in yellow if its within 1 minor version of the web upstream, in bold yellow if it is within 3 minor versions of web, and red if the difference is greater than 3 minor versions.)
#            also print the number of versions behind (in the most meaningful terms: for instance, if you are 4 major versions old, then this should be stated: but if you are 1 minor version old, that should be printed. Both ignore the patch value, which should only be shown if major & minor are updated to the latest.)


# ----------------------------- #
#          nvm sourcing

# enable the "~/.nvm/current" symlink
NVM_SYMLINK_CURRENT=true

# Check if .nvm directory exists
if [ -d "$HOME/.nvm" ]; then
  # if nvm dir is not empty, source nvm 
  if [ "$(ls -A "$HOME/.nvm")" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  fi
fi
# 98% chance this ^^^^ will be added again to the file by something. Even my script for installing nvm does it lmao 


# ===================== #
#        *~end~*
# ===================== #

no=0 # this used to be necessary, but now i'm just leaving it
