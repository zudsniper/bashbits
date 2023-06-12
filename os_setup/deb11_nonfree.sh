#!/bin/bash
# deb11_nonfree.sh 
# ----------------
# 
# Configure debian 11 bullseye (iso link below) with firmware + nonfree + contrib included
# ISO: https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/archive/bullseye_di_rc3+nonfree/amd64/iso-cd/
#
# @zudsniper

# Define version
VERSION="1.0.2"

# Define author
AUTHOR="@zudsniper"

# Define ANSI color codes
source ~/.ansi_colors.sh || curl -sSL https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh -o ~/.ansi_colors.sh && source ~/.ansi_colors.sh

# Define log levels
declare -A LOG_LEVELS
LOG_LEVELS=([7]="silly" [6]="verbose" [5]="debug" [4]="http" [3]="info" [2]="warn" [1]="error" [0]="critical")

# Define default log level
LOG_LEVEL="5"

# Define system package manager
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SYS_PKG_MGR="apt-get"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SYS_PKG_MGR="brew"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    while true; do echo -ne "\r😛"; sleep 0.2; echo -ne "\r "; sleep 0.2; done
    exit 1
else
    echo "Unsupported operating system."
    exit 1
fi

# Define log function
function log {
    level=$1
    shift
    message=$@
    echo -e "${A_GREEN}${LOG_LEVELS[$level]}${A_RESET}: $message"
}

# Define usage function
function usage {
    echo -e "${A_GREEN}Usage:${A_RESET} $0 [options]"
    echo -e "${A_GREEN}Options:${A_RESET}"
    echo -e "  --help, -h        Show this help message"
    echo -e "  --version, -V     Display script version"
    echo -e "  --verbose, -v     Set logging to verbose"
    echo -e "  --log_level, -l   Set log level (7=silly, 0=critical)"
}

# Parse command line arguments
while (( "$#" )); do
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        --version|-V)
            echo $VERSION
            exit 0
            ;;
        --verbose|-v)
            LOG_LEVEL="6"
            shift
            ;;
        --log_level|-l)
            if [ -n "$2" ] && [ "$2" -ge 0 ] && [ "$2" -le 7 ]; then
                LOG_LEVEL="$2"
                shift 2
            else
                echo "Error: Argument for --log_level is missing or out of range" >&2
                exit 1
            fi
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done

# Check for and install necessary packages
REQUIRED_PACKAGES=("curl" "git" "gh" "jq" "certbot" "nginx" "ufw" "net-tools" "snap" "btop" "tmux" "vim" "build-essential" "tree" "zip" "unzip" "terminator" "vim" "openssh" "letsencrypt" "python3" "python-is-python3" "pipx" )
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! command -v $pkg &> /dev/null; then
        log 3 "$pkg not found, attempting to install..."
        if ! $SYS_PKG_MGR install $pkg -y; then
            log 1 "Failed to install $pkg. Please install it manually."
            exit 1
        fi
    fi
done

# Check for and install necessary snap packages
REQUIRED_SNAP_PACKAGES=("docker" "docker-compose" "portainer" "nordvpn")
for pkg in "${REQUIRED_SNAP_PACKAGES[@]}"; do
    if ! snap list | grep $pkg &> /dev/null; then
        log 3 "$pkg not found, attempting to install..."
        if ! snap install $pkg; then
            log 1 "Failed to install $pkg. Please install it manually."
            exit 1
        fi
    fi
done

# Print author's tag
echo -e "${A_GREEN}Done.${A_RESET}\nby ${A_MAGENTA}$AUTHOR${A_RESET}\n"
