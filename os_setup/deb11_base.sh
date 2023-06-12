#!/bin/bash
# deb11_base.sh
# -------------
# 
# Installer / configuration for Debian 11 Bullseye... Wait isn't that what deb11_nonfree.sh does? 
# Yes! 
# this is the older one, but it still may be useful. 
# 
# @zudsniper

set -e
# ================================================================================ #
#     __          __         _     _           __                                 
#    /\ \        /\ \      /' \  /' \         /\ \                                
#    \_\ \     __\ \ \____/\_, \/\_, \        \ \ \____     __      ____     __   
#    /'_` \  /'__`\ \ '__`\/_/\ \/_/\ \        \ \ '__`\  /'__`\   /',__\  /'__`\ 
#   /\ \L\ \/\  __/\ \ \L\ \ \ \ \ \ \ \        \ \ \L\ \/\ \L\.\_/\__, `\/\  __/ 
#    \ \___,_\ \____\\ \_,__/  \ \_\ \ \_\        \ \_,__/\ \__/.\_\/\____/\ \____\
#     \/__,_ /\/____/ \/___/    \/_/  \/_/  _______\/___/  \/__/\/_/\/___/  \/____/
#                                          /\______\                               
#                                         \/______/                                                
# ================================================================================= #
usage() {
  echo -e "${A_LCYAN}USAGE:${A_RESET} $0 -r [main_user] -pw [main_password] -k [ssh_key] [-h]"
  echo ""
  echo "${A_LCYAN}deb11_base${A_RESETi}"
  echo ""
  echo "${A_LCYAN}OPTIONS:${A_RESET}"
  echo "  ${A_YELLOW}-r, --root${A_RESET}    ${A_LIGHTGRAY}MAIN USER username${A_RESET}"
  echo "  ${A_YELLOW}-pw, --root_password${A_RESET}    ${A_LIGHTGRAY}MAIN USER password${A_RESET}"
  echo "  ${A_YELLOW}-k, --ssh_key${A_RESET}            ${A_LIGHTGRAY}MAIN USER ssh key${A_RESET}"
  echo "  ${A_YELLOW}-h, --help${A_RESET}    ${A_LIGHTGRAY}Show this help message${A_RESET}"
  exit 1
}


# ============== parse_args ================ #
# Parse command line arguments
parse_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--root)
      MAIN_USER=$(echo "$2" | sed 's:/*$::') # Remove trailing slashes
      shift 2;;
    -pw|--root_password)
      MAIN_PASS=$(echo "$2" | sed 's:/*$::') # Remove trailing slashes
      shift 2;;
    -k|--ssh_key)
      MAIN_SSH_KEY=$(echo "$2" | sed 's:/*$::') # Remove trailing slashes
      shift 2;;
    --)
      parse_args+=("${@:2}")
      break;;
    -h|--help)
      usage;;
    *)
      usage;;
  esac
done
# ============ ANSI u cant see ============= # 
source ~/.ansi_colors.sh || curl -sSL https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh -o ~/.ansi_colors.sh && source ~/.ansi_colors.sh
# ============ update packages ============ #
apt-get update -y && apt-get upgrade -y
# ========== NETWORK SAFETY  =========== #
# disable `root` from ssh connection directly with server
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e "s/#PermitRootLogin no/PermitRootLogin no/" /etc/ssh/sshd_config
#  disable password ssh authentication 
sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i -e "s/#PasswordAuthentication no/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart ssh

#=========== NET-PREP FUNC ============= #
function user_add_sudo() {
  if [[ $# -ne 2 ]]; then
     echo -ne "${A_RED}${A_BOLD}Epic fail, no params${A_RESET}\n";
     exit;
  fi
  
  # add user and set password, then add to sudoers & docker
  sudo useradd -m -d "/home/${MAIN_USER}" "$MAIN_USER" || echo "${A_YELLOW}User already exists...${A_RESET}\n";
  sudo yes "$MAIN_PASS" | passwd "$MAIN_USER" 
  sudo usermod -aG sudo "$MAIN_USER"
}

function user_add_pubkey() {
  if [[ $# -ne 2 ]]; then
     echo -ne "${A_RED}${A_BOLD}Epic fail, no params${A_RESET}\n";
     exit;
  fi
   
   # add sshkey to authorized_keys
   echo "${MAIN_SSH_KEY}" >> .ssh/authorized_keys;
}

# ========= NETWORK SAFETY 2  ========== #
# set up the main user, disable SSH root access, enable sudo, and setup fail2ban
user_add_sudo "$MAIN_USER" "$MAIN_PASS"
user_add_pubkey "$MAIN_USER" "$MAIN_SSH_KEY"
# add the main user to the /etc/sudoers file for password-less sudo
echo "$MAIN_USER ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers 
# ========== DEPENDENCIES  =========== #
# install useful packages from aptitude
sudo apt-get -y install python3-dev python3-virtualenv build-essential libpq-dev gcc g++ htop \
  curl neovim libmagic1 make git cmake pkg-config gnupg2 unzip zip wget autoconf fail2ban \
  jq postgresql-client rsync bzip2 
# ==================================== #
# this is the point where we should really be a user that isn't root
# sudo su "${MAIN_USER}" || echo -ne "${A_RED}${A_BOLD}wtf no ${A_RESET}${A_INVERSE}${MAIN_USER}${A_RESET}?!\n";

# echo -ne "\n\n${A_GREEN}${A_INVERSE}${A_BOLD}SWITCHED TO MAIN_USER${A_RESET} ${A_YELLOW}${A_UNDERLINE}SETUP IS NOT FINISHED!${A_RESET}\n";


# install nvm (node version manager) 
# (this will be accomplished by the latest version of my `get_nvm.sh` gist. ) 
$("yes | curl -sL https://raw.githubusercontent.com/zudsniper/bashbits/master/get_nvm.sh | /bin/bash -s yes") || echo -ne "${A_RED}${A_BOLD}FAILED TO INSTALL ${A_RESET}${A_PURPLE}nvm${A_RESET}!!\n";
# install gh 
# (again, my installer)
$("yes | curl -sL https://raw.githubusercontent.com/zudsniper/bashbits/master/get_gh.sh | /bin/bash -s yes") || echo -ne "${A_RED}${A_BOLD}FAILED TO INSTALL ${A_RESET}${A_GREEN}gh${A_RESET}!!\n"; 

# install bashrc.zod.tf
# -- obviously this is my bashrc, and it may not be necessary for you.  
#    however, if you modify this script, MAKE SURE your ~/.bashrc already 
#    the necessary nvm sourcing code -- or simply run it yourself
curl -sL https://bashrc.zod.tf -o ~/.bashrc
chmod ugo+x ~/.bashrc
source ~/.bashrc
# ^^ VERY NECESSARY to initialize nvm for later.  
settitle "$(hostname -f)"
# ------------- install `docker` ----------------- #   
# TODO: remove that this doesn't install latest, but a version???  
apt-get -y install apt-transport-https ca-certificates lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt  install -y docker-ce docker-ce-cli containerd.io slirp4netns
# install `docker-compose`
curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# make docker non-sudoable
usermod -a -G docker "$MAIN_USER"
# update docker's daemon.json to add log-rotation using the local driver
echo '{"log-driver": "local"}' > /etc/docker/daemon.json
systemctl restart docker
## > This is gas? 
# configure `nvm`  
nvm install 18.15.1
nvm alias default 18.15.1
nvm use 18.15.1
# now npm & node are correct versions
npm i pm2 -g -y
## install nginx and certbot
sudo apt install -y nginx-full python3-certbot-nginx
## stop the web server
systemctl stop nginx
