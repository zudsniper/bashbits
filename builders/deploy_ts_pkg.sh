#!/bin/bash
# deploy_pkg.sh v1.0.0
# -------------
# 
# Deploy a nodeJS TypeScript package to 1. aptitude and/or 2. homebrew. 
# 🔴 NOT ERROR HANDLED YET
#
# @zudsniper

# Source the ANSI color codes
source ~/.ansi_colors.sh

# Define the progress icon
progress_icon=("🕐" "🕑" "🕒" "🕓" "🕔" "🕕" "🕖" "🕗" "🕘" "🕙" "🕚" "🕛")
progress_icon_index=0

# Function to show the progress icon
show_progress_icon() {
  printf "\r${progress_icon[$progress_icon_index]}"
  progress_icon_index=$(( (progress_icon_index + 1) % ${#progress_icon[@]} ))
}

# Function to log messages
log() {
  printf "\n${ANSI_GREEN}$1${ANSI_RESET}\n"
}

# Install nexe
log "📦 Installing nexe..."
npm install -g nexe
show_progress_icon

# Compile TypeScript to JavaScript
log "🔨 Compiling TypeScript to JavaScript..."
npx tsc
show_progress_icon

# Package the application
log "📦 Packaging the application..."
read -p "Enter the entry point of your application (e.g., dist/index.js): " entry_point
read -p "Enter the output name for your executable: " output_name
nexe $entry_point -o $output_name
show_progress_icon

# Publish to GitHub Packages
log "🚀 Publishing to GitHub Packages..."
read -p "Enter your GitHub username: " github_username
read -s -p "Enter your GitHub token: " github_token
read -p "Enter the name of your package: " package_name

echo "//npm.pkg.github.com/:_authToken=$github_token" > .npmrc
echo "@$github_username:registry=https://npm.pkg.github.com" >> .npmrc

npm publish
show_progress_icon

# Ask if the user wants to create a Homebrew formula
read -p "❓Generate Homebrew Formula? (y/n): " generate_homebrew_formula
if [ "$generate_homebrew_formula" = "y" ]; then
  log "🍺 Creating a Homebrew formula..."
  read -p "Enter the URL of the tarball of your application: " tarball_url
  read -p "Enter the SHA256 checksum of the tarball: " sha256_checksum
  read -p "Enter the description of your application: " description
  read -p "Enter the homepage of your application: " homepage

  cat <<EOF > $output_name.rb
  class $(echo $output_name | tr '-' '_') < Formula
    desc "$description"
    homepage "$homepage"
    url "$tarball_url"
    sha256 "$sha256_checksum"

    depends_on "node"

    def install
      bin.install "$output_name"
    end
  end
  EOF
  show_progress_icon

  # Push the Homebrew formula to your tap repository
  log "🚀 Pushing the Homebrew formula to your tap repository..."
  read -p "Enter the path to your local clone of your tap repository: " tap_path

  cp $output_name.rb $tap_path/Formula/
  cd $tap_path
  git add .
  git commit -m "Add $output_name formula"
  git push
  show_progress_icon
fi

log "🎉 Done!"
