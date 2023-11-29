#!/bin/bash
# gitget.sh v1.0.2
# -------------------
# CAUTION => THIS IS UNTESTED
# (2023-09-30)
# -------------------
#
# TODO
#   - allow version specification to actually do something, currently the value is unused
#   - make script actually work lol
#   - add support for yay, snap, and flatpak
#
# a script to download and install the latest release of a GitHub repository
# on various Linux distributions and macOS, using appropriate package managers
# or direct file downloads.
# PACKAGE MANAGERS => apt, brew, pacman, (~~yay, snap, flatpak~~)
#                                        # TODO: add support for yay, snap, and flatpak
#
# by @zudsniper
# -------------------

# display errors and exit on failure, but do not close the terminal window
set -o pipefail

# Check for ~/.ansi_colors.sh, download if not found
if [[ ! -f ~/.ansi_colors.sh ]]; then
    curl -sSL https://gh.zod.tf/bashbits/raw/master/.ansi_colors.sh -o ~/.ansi_colors.sh
fi
source ~/.ansi_colors.sh

check_prerequisites() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}jq not found. Installing...${NC}"
        case $os in
            Linux)
                sudo apt-get install jq
                ;;
            Darwin)
                brew install jq
                ;;
            *)
                echo -e "${RED}Unsupported OS for automatic jq installation. Please install jq manually.${NC}"
                exit 1
                ;;
        esac
    fi
}

detect_env() {
    echo -ne "${YELLOW}Detecting environment...${NC}"
    arch=$(uname -m)
    case $arch in
        x86_64)
            alias=amd64
            ;;
        arm*)
            alias=arm
            ;;
        aarch64)
            alias=arm64
            ;;
        *)
            echo -e "\r${RED}Unknown architecture: ${arch}. Exiting.${NC}"
            exit 1
            ;;
    esac

    os=$(uname -s)
    case $os in
        Linux)
            os_alias=linux
            ;;
        Darwin)
            os_alias=macos
            ;;
        *)
            echo -e "\r${RED}Unsupported OS: ${os}. Exiting.${NC}"
            exit 1
            ;;
    esac
    echo -e "\r${GREEN}Detecting environment... Successful.${NC}"
}

usage() {
    echo "Usage:"
    echo "  gitget [-i|--install] (STABLE|LATEST)? <url>"
    echo "  gitget [-i|--install] <author> <repo> (STABLE|LATEST)?"
    echo "  gitget [-i|--install] <author> <repo> <release_version>"
    echo
    echo "Parameters:"
    echo "  -i, --install        - Toggle automatic installation (if applicable)"
    echo "  STABLE|LATEST        - Specify whether to fetch the latest stable or the latest overall release."
    echo "  <url>                - URL of the GitHub repository."
    echo "  <author>             - Author/owner of the GitHub repository."
    echo "  <repo>               - Name of the GitHub repository."
    echo "  <release_version>    - Specific release version to fetch."
    echo
    echo "Examples:"
    echo "  gitget -i STABLE https://github.com/Artemis-RGB/Artemis"
    echo "  gitget -i Artemis-RGB Artemis LATEST"
    echo "  gitget -i Artemis-RGB Artemis v2.0.0"
    exit 1
}

gitget() {
    detect_env
    check_prerequisites

    install=false
    while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
        -i | --install )
            install=true
            shift ;;
    esac; shift; done
    if [[ $# -eq 0 && $install == true ]]; then
        usage
    fi

     # Parse arguments
    if [[ $# -eq 2 ]]; then
        mode=STABLE
        url=$1
        IFS='/' read -a ADDR <<< "$url" # this should never contain backslashes anyway so it's fine
        repo_info=("${ADDR[-2]}" "${ADDR[-1]}")
        author=${repo_info[0]}
        repo=${repo_info[1]}
    elif [[ $# -eq 3 ]]; then
        if [[ $1 =~ ^(STABLE|LATEST)$ ]]; then
            mode=$1
            author=$2
            repo=$3
        else
            mode=STABLE
            author=$1
            repo=$2
            version=$3
        fi
    else
        echo -e "Invalid number of arguments. Exiting."
        exit 1
    fi

    api_url="https://api.github.com/repos/${author}/${repo}/releases"

    echo -ne "Fetching release info..."
    if [[ $mode == "LATEST" ]]; then
        # Fetch latest release
        release_info=$(curl -s $api_url/latest)
    else
        # Fetch all releases, filter out pre-releases, and get the latest stable release
        release_info=$(curl -s $api_url | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -1)
        release_info=$(curl -s "${api_url}/tags/${release_info}")
    fi

    if [[ $release_info == *"Not Found"* ]]; then
        echo -e "\rFetching release info... \e[31mFailed.\e[0m"
        exit 1
    else
        echo -e "\rFetching release info... \e[32mSuccessful.\e[0m"
    fi

    download_url=$(echo $release_info | jq -r ".assets[] | select(.name | contains(\"${os_alias}\") and contains(\"${alias}\")) | .browser_download_url")

    if [[ -z $download_url ]]; then
        echo -e "Compatible asset \e[31mnot found\e[0m. Exiting."
        exit 1
    fi

    # Downloading the asset
    echo -ne "Downloading ${download_url}..."
    curl -LO $download_url
    if [[ $? -eq 0 ]]; then
        echo -e "\rDownloading ${download_url}... \e[32mSuccessful.\e[0m"
    else
        echo -e "\rDownloading ${download_url}... \e[31mFailed.\e[0m"
        exit 1
    fi


    # Determine the type of file and take action
    file_type=$(file --mime-type -b $tar_file)
    case $file_type in
        application/x-tar | application/gzip)
            echo -ne "${YELLOW}Extracting ${tar_file}...${NC}"
            tar -xf $tar_file
            if [[ $? -eq 0 ]]; then
                echo -e "\r${GREEN}Extracting ${tar_file}... Successful.${NC}"
            else
                echo -e "\r${RED}Extracting ${tar_file}... Failed.${NC}"
                exit 1
            fi
            ;;
        application/vnd.debian.binary-package)
            if [[ $install == true ]]; then
                echo -ne "${YELLOW}Installing ${tar_file}...${NC}"
                sudo dpkg -i $tar_file
                if [[ $? -eq 0 ]]; then
                    echo -e "\r${GREEN}Installing ${tar_file}... Successful.${NC}"
                else
                    echo -e "\r${RED}Installing ${tar_file}... Failed.${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}Downloaded Debian package. Use dpkg or apt to install it manually.${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Unsupported file type. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Usage: gitget [-i|--install] (STABLE|LATEST)? <url> or gitget [-i|--install] <author> <repo> (STABLE|LATEST)? or gitget [-i|--install] <author> <repo> <release_version>
