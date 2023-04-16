#!/bin/bash
set -e
# get_nvm.sh   
# `VERSION` 2.0.0
# -------------------
# by zudsniper@github
# & ChatGPT 3.5
# 
# I MAKE NO GUARANTEES THAT THIS SHIT EVEN WORKS, MUCH LESS THAT IT'S UP TO DATE.  
# USE AT YOUR OWN RISK.  
# 
##########################
#       `SOURCES`        |
# =======================|
# Header help & argparse | https://medium.com/@brotandgames/build-a-custom-cli-with-bash-e3ce60cfb9a4
# NVM installation guide |  https://github.com/nvm-sh/nvm#git-install
# How to add multi-line  | https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
#                        |
# ====================== #

# Accept 'yes' command as an argument to avoid user input
if command -v yes >/dev/null 2>&1; then
  YES_FLAG="-y"
elif [ "$1" == "yes" ]; then
  YES_FLAG="-y"
else
  YES_FLAG=""
fi

# COLORS 
# ----------------------------- #
## ANSI COLOR ENVIRONMENT VARS

if [[ ! -f "~/.ansi_colors.sh" ]]; then 
	#echo -ne "NO COLORS FILE FOUND, DOWNLOADING\n" can't print in .bashrc root
	curl -sL https://gist.githubusercontent.com/zudsniper/e5bbdb7d3384a2b5f76277b52d103e59/raw/ansi_colors.sh -o ~/.ansi_colors.sh
fi

source ~/.ansi_colors.sh
# ----------------------------- #

echo -ne "${A_GREEN}${A_INVERSE}${A_BOLD}get_gnvm.sh${A_RESET} by zudsniper\n"
echo -ne "${A_BOLD}DEPENDENCIES${A_RESET}\n"
echo -ne "${A_GRAY}${A_ITALIC}    ${A_UNDERLINE}https://bashrc.zod.tf/${A_RESET}\n\n"

# PARSE ARGS
case "$1" in
  deploy|d)
    tee -ia "/deploy_${2}.log"
    ;;
  *)
    echo -ne "USAGE: $0 [-y]\n";
    ;;
esac

if [ "$EUID" -ne 0 ]; then
    echo -ne "${A_RED}${A_BOLD}${A_INVERT}caution: you are NOT root!${A_RESET}\n";
    echo -ne "${A_YELLOW}${A_ITALIC}tread carefully! continuing...${A_RESET}\n\n";
    sleep 3s;
else
    echo -ne "${A_GREEN}${A_BOLD}${A_INVERT}USER IS ROOT! continuing...${A_RESET}\n\n";
fi

echo -ne "--------------------------------------------------------\n";
echo -ne "${A_BLUE}${A_BOLD}Installing essentials... you should probably already have these ${A_RESET}\n";
apt-get $YES_FLAG install git curl build-essential sudo;
echo -ne "--------------------------------------------------------\n";
echo -ne "${A_PURPLE}${A_BOLD}Cloning current nvm release from git...${A_RESET}\n";

export NVM_DIR="$HOME/.nvm" && (git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"; cd "$NVM_DIR"; git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`;) && \. "$NVM_DIR/nvm.sh"

echo -ne "--------------------------------------------------------\n";
echo -ne "${A_YELLOW}${A_BOLD}ADD THE FOLLOWING TO ${A_RESET}${A_INVERT}/etc/profile${A_RESET}\n";
# echo -ne "${A_GRAY}${A_INVERT}${A_ITALIC}or call${A_RESET}${A_BOLD}${A_PURPLE} get_nvm${A_RESET} ${A_GRAY}${A_INVERT}${A_ITALIC}again to install these lines into your.${A_RESET}${A_BOLD}${A_PURPLE} ~/.bash_profile${A_RESET}\n\n";

NVM_ADDITIONS=$(cat <<-END
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
END
)

echo -ne "${NVM_ADDITIONS}\n";
echo -ne "--------------------------------------------------------\n";

if [ "$YES_FLAG" == "-y" ]; then
  echo -ne "\n${A_ITALIC}${A_GRAY}installing...${A_RESET}\n";
  echo "${NVM_ADDITIONS}" >> ~/.bashrc;
  echo -ne "\n${A_BOLD}${A_GREEN}Done!${A_RESET}\n\n";
else
  echo -ne "Press ${A_YELLOW}${A_INVERT}[ENTER]${A_RESET} to ${A_BOLD}${A_RED}INSTALL${A_RESET} into ${A_INVERT}~/.bashrc${A_RESET}...\n";

  while : ; do
    read -s -N 1 -t 1 key <&1
    if [[ $key == $'\x0a' ]]; then  # ENTER key
      echo -ne "\n${A_ITALIC}${A_GRAY}installing...${A_RESET}\n";
      echo "${NVM_ADDITIONS}" >> ~/.bashrc;
      echo -ne "\n${A_BOLD}${A_GREEN}Done!${A_RESET}\n\n";
      break;
    elif [[ $key == $'\x1b' ]]; then # ESCAPE key
      echo -ne "${A_YELLOW}${A_INVERT}${A_BLACK}DO NOT FORGET TO ADD THIS TO A TERMINAL FILE! ${A_RESET}\n\n";
      sleep 3s;
      break;
    fi
  done
fi
