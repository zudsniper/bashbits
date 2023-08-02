#!/bin/bash
# install_gum.sh v0.1.0
# --------------
# 
# written by ChatGPT3.5, almost entirely
# SOURCE OF ALL INSTALLATION INFORMATION
# https://github.com/charmbracelet/gum#installation
# 
# @zudsniper

set -e

# Import gum
if ! command -v gum &> /dev/null; then
  case $(uname -s) in
    Darwin)
      echo "Installing gum..."
      brew install gum
      ;;
    Linux)
      if command -v pacman &> /dev/null; then
        echo "Installing gum..."
        sudo pacman -S gum
      elif command -v nix-env &> /dev/null; then
        echo "Installing gum..."
        nix-env -iA nixpkgs.gum
      elif command -v apt-get &> /dev/null; then
        echo "Installing gum..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install gum
      elif command -v yum &> /dev/null; then
        echo "Installing gum..."
        echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
        sudo yum install gum
      elif command -v apk &> /dev/null; then
        echo "Installing gum..."
        sudo apk add gum
      else
        echo "ERROR: Unsupported platform."
        exit 1
      fi
      ;;
    *)
      echo "ERROR: Unsupported platform."
      exit 1
      ;;
  esac
fi

echo "gum installation complete."
