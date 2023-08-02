#!/bin/bash
# build_tsnode.sh v1.0.0
# ---------------
# 
# Take your current typescript + nodejs project and complete the construction of a git repository and key files. 
# 🔴 NOT ERROR HANDLED YET
#
# @zudsniper

# Source the ANSI color codes
source ~/.ansi_colors.sh

# Function to log messages
log() {
  printf "\n${ANSI_GREEN}$1${ANSI_RESET}\n"
}

# Get the project name
read -p "📝 Enter the name of your project: " project_name

# Check if the project directory already exists
if [ -d "$project_name" ]; then
  log "⚠️  The directory $project_name already exists. Checking the state of the project..."

  cd $project_name

  # Check for package.json, tsconfig.json, and src/index.ts
  if [ -f "package.json" ] && [ -f "tsconfig.json" ] && [ -f "src/index.ts" ]; then
    log "✅  Found package.json, tsconfig.json, and src/index.ts."

    # Check for a Git repository
    if [ -d ".git" ]; then
      log "✅  Found a Git repository."

      # Check the remote origin
      git_remote_origin=$(git config --get remote.origin.url)
      if [ -n "$git_remote_origin" ]; then
        log "✅  Found a remote origin: $git_remote_origin"
      else
        log "❌  No remote origin found."
      fi
    else
      log "❌  No Git repository found."
    fi

    # Ask if the user wants to run and test the program
    read -p "❓ Do you want to run and test the program? (y/n): " run_and_test
    if [ "$run_and_test" = "y" ]; then
      # Install dependencies
      log "📦 Installing dependencies..."
      npm install

      # Build the program
      log "🔨 Building the program..."
      npx tsc

      # Run the program
      log "🚀 Running the program..."
      node dist/index.js
    fi
  else
    log "❌  The necessary files for a TypeScript + Node.js project are not found."
  fi

  # Ask if the user wants to continue
  read -p "❓ Do you want to continue? (y/n): " continue
  if [ "$continue" != "y" ]; then
    exit 1
  fi
else
  # Create the project directory
  log "📂 Creating the project directory..."
  mkdir $project_name
  cd $project_name
fi

# Initialize a new Node.js project
log "📦 Initializing a new Node.js project..."
npm init -y

# Install TypeScript and ts-node
log "📦 Installing TypeScript and ts-node..."
npm install --save-dev typescript ts-node

# Create a tsconfig.json file
log "📝 Creating a tsconfig.json file..."
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "dist"
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
EOF

# Create the source directory and a sample TypeScript file
log "📂 Creating the source directory and a sample TypeScript file..."
mkdir src
echo 'console.log("Hello, world!");' > src/index.ts

# Initialize a new Git repository
log "🔨 Initializinga new Git repository..."
git init
git add .
git commit -m "🎉 Initial commit"

# Ask if the user wants to push changes to the remote origin
if [ -n "$git_remote_origin" ]; then
  read -p "❓ Do you want to push changes to the remote origin? (y/n): " push_changes
  if [ "$push_changes" = "y" ]; then
    git push -f origin master
  fi
fi

log "🎉 Done!"

# Print a cute little bunny rabbit
echo -e "${ANSI_GREEN}"
cat << "EOF"
 (\(\ 
 ( -.-)
 o_(")(")
EOF
echo -e "${ANSI_RESET}"
