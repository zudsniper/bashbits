# zod's ~/.bashrc 
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

# &========================================& # 

# ===================== #
#     linux configs
# ===================== #
# by @zudsniper 
# (or zod#1626)
# ------------- #
# available at https://bashrc.zod.tf

# ----------------------------- #
# check OS
checkOS() {
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        export opersys="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
	export opersys="mac"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
	export opersys="win-gitbash"
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
	export opersys="win-msys"
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

## _______ OS DETERMINED _______ ##
# "${opersys}"
checkOS;
# ----------------------------- #
#           system
alias lsa="ls -lhrta"

## hibernation
alias sleepy="sudo systemctl mask sleep.target suspend.target hibernate.target hibernate-hybrid.target"
alias noSleepy="sudo systemctl mask sleep.target suspend.target hibernate.target hibernate-hybrid.target"

# ----------------------------- #
# TF2Autobot management aliases

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

# if docker installed
if [ -x "$(command -v docker)" ]; then
    
	# docker aliases
	alias dockerLS="docker container ls -q"
	alias dockerGenocide="docker container kill $(docker container ls -q)"

	alias startPortainer="docker volume create portainer_data; docker run -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -itd portainer/portainer";

	# attach with Bash to a container by id. Helpful for pterodactyl containers 
	attachBashTo() {
		if [[ "$#" -eq 0 ]]; then
		       echo -ne "${A_RED}Please provide argument: container id${A_RESET}\n";
		       return;
		fi
 		docker exec -it	"$1" /bin/bash;	
	}

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

# simple analysis size function with normally installed linux CLI stuff
# @param 1 - path: string - root path from which to search
# @param 2 - n: number - the nth highest sized files will be displayed.
findLargestNFiles() {
        if [[ ( $# -eq 0 ) || ( $# -gt 2 ) ]]; then
                echo -ne "${A_RED}${A_BOLD}FORMAT: ${RESET} findLargestNFiles( path: string, n: number )\n";
                exit 1;
        fi

        ROOT_PATH = "/";
        if [[ -z ${1} ]]; then
                ROOT_PATH = "${1}";
        fi

        NUM_SHOWN = 10;
        if [[ -z ${2} ]]; then
                NUM_SHOWN = "${2}";
        fi


        # go to provided directory, or `/` if none specified
        cd "${ROOT_PATH}";

        echo -ne "${A_RED}${A_BOLD}[TOP FILES BY SIZE]${A_RESET}\n"; 

        # this line written by ChatGPT on 12/9/22. Skynet moment
        find . -type f -exec du -h {} \; | sort -hr | head -${NUM_SHOWN};

        exit 0;
}

# ----------------------------- #
#     find and kill process
#           by PORT



# Lighter version of the following -- only handles a single argument and expects it to be provided. 
kPort() {
	echo -ne "${A_PURPLE}${A_BOLD}netstat'in${A_RESET}...\n";
	sudo netstat -tulpn | grep ':${1}}';
	
	echo -ne "${A_YELLOW}${A_INVERSE}REMOVING PROCESS ON${A_RESET} + '$1'\n"
	sudo fuser -k "$1";
}

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
alias get_gh="curl -sL https://raw.githubusercontent.com/zudsniper/bashbits/master/get_gh.sh | /bin/bash";
alias get_nvm="curl -sL https://raw.githubusercontent.com/zudsniper/bashbits/master/get_nvm.sh | /bin/bash";

# ----------------------------- #
#        set shell title

# xterm title funcs
settitle() {
                export PS1="\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
                echo -ne "\e]0;$1\a"
}
settitlepath() {
        export PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$ "
}

# ----------------------------- #
#     git convenience funcs

# INTERNAL FUNCTION to install gh correctly based on installed platforms' OS
git_int_install() {
   checkOS;
   echo -ne "${A_CYAN}${A_INVERSE}operating system: ${opersys}${A_RESET}\n";

	
    if [[ ${opersys} == "mac" ]]; then
	brew install gh;
	gh auth login;
	return;
    fi
   
    if [[ ${opersys} == "linux" ]]; then
	
	# from my gists!
	# date 02/02/2023
	# ================================================= # 
	sudo curl -L https://gist.githubusercontent.com/zudsniper/0ba53973f9e3fe6222ffd1763bc80055/raw/get_gh.sh | bash;
    	#yes | sudo apt upgrade --allow-unauthenticated;
    	#yes | sudo apt install gh --allow-unauthenticated; 
	# ================================================= # 
    fi
}

# avoid having to remember to install gh
# i am lazy
git_auth() {
    checkOS;
	if ! command -v gh >/dev/null 2>&1; then
    		# echo "Install gh first"
    		# installing gh...
		git_int_install;
	fi
	
	if ! gh auth status >/dev/null 2>&1; then
    	    # echo "You need to login: gh auth login"
	    # prompting user for gh authorization
	    gh auth login;
	fi
	
}


# adds all files in current dir to staged changes, commits with the message @params, and pushes the resulting commit 
# to the current branch upstream.
git_acpush() {

if [[ -z "$#" ]]; then
    echo -ne "${A_RED}${A_BOLD}Please provide a commit message to perform this operation.${A_RESET}\n"
fi

# add all files in current working directory
git add .;

# commit with provided message 
git commit -m "$#";

# push 
git push;

}

# ----------------------------- #
#         AUTO-UPDATING
# (pushing updates IF gh auth user = zudsniper)

updateGistInfo() {

# Check if the local version of the file exists
if [ ! -f "$2" ]; then
  echo "Error: Local file does not exist"
  exit 1
fi

# Download the latest version of the file from the URL
curl -L "$1" -o "temp.txt"

# Compare the local version to the downloaded version
if ! cmp -s "$2" "temp.txt"; then
  # Save the local version to a temporary file
  cp "$2" "$2.bak"
  # Overwrite the local version with the newer version
  mv "temp.txt" "$2"
  # Print a red alert message
  echo -e "\033[0;31mA newer version of your gist has been downloaded: $2\033[0m"
else
  # If the local version is the same as the online version, delete the temporary file
  rm "temp.txt"
fi

}
# THIS IS NO LONGER A GIST SO THIS DOESN'T WORK
updateMyself() {
	return
	me=`basename "$0"`;
	export dirr=$(pwd);
	cd "$(dirname "$0")";
	gh gist edit https://gist.github.com/zudsniper/e5bbdb7d3384a2b5f76277b52d103e59 -f "${me}" .bashrc;
	echo -ne "${A_LGREEN}${A_INVERSE}${A_BOLD}Updated live gist!${A_RESET}\n\n";
	cd "${dirr}"; 
}


# THIS IS NO LONGER A GIST SO THIS DOESN'T WORK

# update myself if out of date & push is not selected
#if [[ $1 -ne gpush ]]; then
#    updateGistInfo https://gist.github.com/zudsniper/e5bbdb7d3384a2b5f76277b52d103e59 .bashrc
#fi

# THIS IS NO LONGER A GIST SO THIS DOESN'T WORK

#if [[ $# -eq 0 ]]; then
	# do nothing
	# echo -ne "${A_BOLD}Hi! ${A_RESET} i'm zudsniper.\n\n"
#	no=1
#elif [[ $1 -eq gpush ]]; then
#	updateMyself
#fi

# REMOVED SHITTY INSTALL SCRIPT FOR NVM, USE get_nvm ALIAS

# ----------------------------- #
#          nvm related

# if nvm dir is not empty, source nvm 
if [ "$(ls -A "$HOME/.nvm")" ]; then
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# ===================== #
#        *~end~*
# ===================== #

no=0
