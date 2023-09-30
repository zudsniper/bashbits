#!/bin/bash
# get_gh.sh v1.2.1
# -------------------
# 
# I DO NOT GUARANTEE THAT THIS IS UP TO DATE
# OR WORKS AT ALL
#
# IT PROBABLY DOESN'T
# -------------------
# [2023-09-30] It works to install gh 2.22.1 on Debian 11. That is all I can say with any dignity.
#
# 
# @zudsniper

set -e

YES_FLAG="$1"

sudo apt install -y gnupg2;

echo -ne "${A_GREEN}${A_INVERSE}${A_BOLD}get_gh.sh${A_RESET} by zudsniper\n"
echo -ne "${A_RED}${A_BOLD}DEPENDENCIES${A_RESET}\n"
echo -ne "${A_BOLD}    gnupg2${A_RESET}\n"
# echo -ne "${A_RED}${A_BOLD}    https://zod.tf/bashrc${A_RESET}\n\n"

addAPTExtensionsAndKeys() {
echo -ne "${A_BLUE}${A_BOLD}Installing GitHub Keys & expanding APT to contrib & non-free. ${A_RESET}\n";

  # first, add GPG keys for NEWEST
  # 02/01/2023
  sudo apt-key adv --keyserver hkp://keyring.debian.org --recv-keys 23E7166788B63E1E
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 23F3D4EA75716059

  sudo apt install -y software-properties-common --allow-unauthenticated;

  sudo apt-add-repository contrib;
  sudo apt-add-repository non-free;
}

# TODO: add support for other architectures
# TODO: add a interactive warning for non-amd64 architectures
# TODO: add support for downloading the latest version
# this script sucks and is a mess it does like nothing right
installGH_binary_debamd64() {
   echo -ne "${A_GREEN}${A_ITALIC}Installing gh${A_RESET} by ${A_RED}direct file download.${A_RESET}\n";
   curl -sL https://github.com/cli/cli/releases/latest/download/gh_2.22.1_linux_amd64.deb -o ./gh_for_debamd64.deb;
   wait "$(jobs -p)";
   chmod ugo+x ./gh_for_debamd64.deb;
   sudo apt install ./gh_for_debamd64.deb;
   rm ./gh_for_debamd64.deb;
}

installGH_binary_debamd64;

installGH_old() {
  yes | sudo apt update --allow-unauthenticated;
  yes | sudo apt upgrade --allow-unauthenticated;
  # installing gh... 
  echo -ne "${A_UNDERLINE}${A_YELLOW}ATTEMPTING TO INSTALL${A_RESET} ${A_GREEN}${A_BOLD}gh${A_RESET}\n";
  yes | sudo apt install -y gh --allow-unauthenticated;
}

if [ "$YES_FLAG" == "-y" ]; then
  addAPTExtensionsAndKeys;
  installGH_old;
else
  addAPTExtensionsAndKeys;
  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
fi
