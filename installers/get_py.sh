#!/bin/bash
# get_py.sh
# ---------
# 
# This script installs and builds python from the official site from source based on the provided argument version. 
# version 0.1.1
#
# @zudsniper

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
# Emojis
ROCKET="🚀"
CHECK_MARK="✅"
# Get Python versions
echo -e "${YELLOW}Fetching Python versions...${NC}"
VERSIONS=$(curl -s https://www.python.org/ftp/python | grep -oP '(?<=Python-)[0-9]+\.[0-9]+\.[0-9]+' | sort -V)
echo -e "${GREEN}${CHECK_MARK} Fetching Python versions complete!${NC}"
# Get the latest patch version for a given major and minor version
get_latest_patch_version() {
 MAJOR_MINOR=$1
 echo "${VERSIONS}" | grep "^${MAJOR_MINOR}" | tail -1
}
# Print the last 10 Python versions
echo -e "${YELLOW}The last 10 Python versions are:${NC}"
echo "${VERSIONS}" | tail -10 | awk '{printf "%-10s %s\n", $0, "🐍"}'
# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
 echo -e "${RED}This script must be run as root${NC}" 1>&2
 exit 1
fi
# Check if python version is provided
if [ -z "$1" ]; then
 echo -e "${RED}No Python version provided. Usage: sudo ./install_python.sh <version>${NC}"
 exit 1
fi
# Define version
PYTHON_VERSION=$(get_latest_patch_version $1)
# If no version found, use the provided version
if [ -z "$PYTHON_VERSION" ]; then
 PYTHON_VERSION=$1
fi
# Update package list
echo -e "${YELLOW}Updating package list...${NC}"
apt update
# Prerequisites
echo -e "${YELLOW}Installing prerequisites...${NC}"
apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev
# Download Python
echo -e "${YELLOW}Downloading Python ${PYTHON_VERSION}...${NC}"
cd /tmp
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
# Extract Python
echo -e "${YELLOW}Extracting Python...${NC}"
tar -xf Python-${PYTHON_VERSION}.tar.xz
cd Python-${PYTHON_VERSION}
# Compile Python source
echo -e "${YELLOW}Compiling Python source...${NC}"
./configure --enable-optimizations
make -j $(nproc)
make altinstall
# Verify Installation
echo -e "${YELLOW}Verifying Installation...${NC}"
python${PYTHON_VERSION:0:1}.${PYTHON_VERSION:2} --version
# Ask for alias update
read -p "Do you want to replace the default python alias to python${PYTHON_VERSION:0:1}.${PYTHON_VERSION:2}? [Y/n]: " yn
case $yn in
 [Yy]* ) echo "alias python=python${PYTHON_VERSION:0:1}.${PYTHON_VERSION:2}" >> ~/.bash_aliases && source ~/.bash_aliases && echo -e "${GREEN}Python alias updated.${NC}";;
 [Nn]* ) exit;;
 * ) echo "Please answer yes or no.";;
esac
echo -e "${GREEN}Installation completed!${NC}"
