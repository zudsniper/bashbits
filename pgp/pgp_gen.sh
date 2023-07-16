#!/bin/bash
# pgp_gen.sh v0.2.0
# -----------------
# 
# NOTE: See the in-development version with more features in this gist
#       https://gist.github.com/zudsniper/119b29db06a9576aec11a8d063f9912c
# 
# TODO: 
#   - [x] Support expiration dates (prompt, CLI flag)
#   - [ ] Add more danger warnings that this is super unsafe and stupid
# 
# @zudsniper

# ANSI color schema
source ~/.ansi_colors.sh 2>/dev/null || curl -fsSL https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh -o ~/.ansi_colors.sh && source ~/.ansi_colors.sh

echo -e "===================================================" 
# print FIGFONT startup
cat << 'EOF'
 ____   ___  ____       ___  ____  __ _     ____  _  _ 
(  _ \ / __)(  _ \     / __)(  __)(  ( \   / ___)/ )( \
 ) __/( (_ \ ) __/____( (_ \ ) _) /    / _ \___ \) __ (
(__)   \___/(__) (____)\___/(____)\_)__)(_)(____/\_)(_/
EOF
echo -e "${A_BOLD}${A_RED}$0${A_RESET}"
echo -e "===================================================" 
echo -e "${A_RED}${A_BOLD}THIS IS EXTREMELY UNSAFE AND THESE KEYS WILL IMMEDIATELY BE VULNERABLE HOWEVER YOU SHARE THEM.${A_RESET}"
echo -ne "\n"

# Determine operating system and package manager
case "$(uname -s)" in
    Darwin)
        SYS_PKG_MGR="brew"
        ;;
    Linux)
        if [ -x "$(command -v apt-get)" ]; then
            SYS_PKG_MGR="apt-get"
        elif [ -x "$(command -v apt)" ]; then
            SYS_PKG_MGR="apt"
        else
            echo -e "${A_BOLD}💀 How did you get here?${A_RESET}"
            exit 1
        fi
        ;;
    *)
        echo -e "${A_BOLD}💀 How did you get here?${A_RESET}"
        exit 1
        ;;
esac

# Check if GnuPG is installed
if ! [ -x "$(command -v gpg)" ]; then
    echo -e "${A_BOLD}${A_RED}ERROR: GnuPG is not installed.${A_RESET}"
    echo -e "${A_BOLD}Installing GnuPG...${A_RESET}"
    if [ "$SYS_PKG_MGR" = "brew" ]; then
        brew install gnupg
    else
        sudo $SYS_PKG_MGR install gnupg -y || sudo snap install gnupg
    fi
    if ! [ -x "$(command -v gpg)" ]; then
        echo -e "${A_BOLD}${A_RED}ERROR: Failed to install GnuPG.${A_RESET}"
        exit 1
    fi
fi

# Parse command-line arguments
while (( "$#" )); do
    case "$1" in
        --username|-u)
            USERNAME="$2"
            shift 2
            ;;
        --password|-pw)
            PASSWORD="$2"
            shift 2
            ;;
        --email|-e)
            EMAIL="$2"
            shift 2
            ;;
        --encryption|-x)
            IFS=',' read -ra ENCRYPTION <<< "$2"
            shift 2
            ;;
        --expiry|-t)
            EXPIRY="$2"
            shift 2
            ;;
        --delete|-d)
            DELETE=true
            shift
            ;;
        *)
            echo -e "${A_BOLD}${A_RED}ERROR: Unknown argument: $1${A_RESET}"
            exit 1
            ;;
    esac
done

# If arguments are not provided, prompt for them
if [ -z "$USERNAME" ]; then
    echo -en "${A_BOLD}Enter username: ${A_RESET}"
    read USERNAME
fi
if [ -z "$PASSWORD" ]; then
    echo -en "${A_BOLD}Enter password: ${A_RESET}"
    read -s PASSWORD
    echo
fi
if [ -z "$EMAIL" ]; then
    echo -en "${A_BOLD}Enter email: ${A_RESET}"
    read EMAIL
fi
if [ -z "${ENCRYPTION[0]}" ]; then
    ENCRYPTION=("RSA" "RSA")
fi
if [ -z "$EXPIRY" ]; then
    echo -en "${A_BOLD}Enter expiry date (0 for no expiry): ${A_RESET}"
    read EXPIRY
fi

# Generate key pair
echo -e "${A_BOLD}Generating PGP key pair...${A_RESET}"
{
    echo "Key-Type: ${ENCRYPTION[0]}"
    echo "Subkey-Type: ${ENCRYPTION[1]}"
    echo "Name-Real: $USERNAME"
    echo "Name-Email: $EMAIL"
    echo "Expire-Date: $EXPIRY"
    echo "Passphrase: $PASSWORD"
    echo "%commit"
} | gpg --batch --gen-key

# Output keys
echo -e "${A_BOLD}Public key:${A_RESET}"
echo "========================================"
gpg --armor --export "$EMAIL"
echo "========================================"
echo -e "${A_BOLD}Private key:${A_RESET}"
echo "========================================"
echo "$PASSWORD" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 --armor --export-secret-keys "$EMAIL"
echo "========================================"

# Reprint the input email, username, and password
echo -e "${A_BOLD}Email:${A_RESET} $EMAIL"
echo -e "${A_BOLD}Username:${A_RESET} $USERNAME"
echo -e "${A_BOLD}Password:${A_RESET} $PASSWORD"

# Prompt to delete key pair
if [ "$DELETE" != true ]; then
    echo -en "${A_BOLD}Do you want to delete the key pair? (y/N): ${A_RESET}"
    read DELETE
    if [[ "$DELETE" =~ ^[Yy]$ ]]; then
        DELETE=true
    fi
fi
if [ "$DELETE" = true ]; then
    yes | gpg --batch --yes --delete-secret-key "$EMAIL"
    yes | gpg --batch --yes --delete-key "$EMAIL"
fi

echo -e "${A_BOLD}${A_GREEN}Done.${A_RESET}"