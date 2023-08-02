#!/bin/bash
# build_py3.sh v1.0.0
# ------------
#
# ℹ️ Currently supports MacOS & Debian/Ubuntu
# NOT WINDOWS
#
# installs requirements and creates a setuptools based Python3 project where
# script is executed or wherever path is supplied as the single command line
# argument.
# MOSTLY WRITTEN BY ChatGPT4 (May 24 version)
#     + Plugins {Link Reader, Metaphor, Perfect Prompt}
#
# @zudsniper

# ANSI color schema
if [ -f ~/.ansi_colors.sh ]; then
    source ~/.ansi_colors.sh
else
    curl -o ~/.ansi_colors.sh https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh
    source ~/.ansi_colors.sh
fi

# Logging function
log() {
    local level=$1
    shift
    local message=$@

    case $level in
        "silly")
            echo -e "${BBlack}${message}${Color_Off}"
            ;;
        "verbose")
            echo -e "${BBlue}${message}${Color_Off}"
            ;;
        "debug")
            echo -e "${BPurple}${message}${Color_Off}"
            ;;
        "http")
            echo -e "${BCyan}${message}${Color_Off}"
            ;;
        "info")
            echo -e "${BGreen}${message}${Color_Off}"
            ;;
        "warn")
            echo -e "${BYellow}${message}${Color_Off}"
            ;;
        "error")
            echo -e "${BRed}${message}${Color_Off}"
            ;;
        "critical")
            echo -e "${BRed}${On_IBlack}${message}${Color_Off}"
            ;;
    esac
}

# Print the author's GitHub handle
log "info" "@zudsniper"

# Check for and install required dependencies
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    for pkg in python3 pip3 git; do
        if ! dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -q "ok installed"; then
            log "info" "Installing $pkg..."
            sudo apt-get install -y $pkg
        fi
    done
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &>/dev/null; then
        log "error" "Homebrew is not installed. Please install it first."
        exit 1
    fi
    for pkg in python3 pipx git; do
        if ! brew list $pkg &>/dev/null; then
            log "info" "Installing $pkg..."
            brew install $pkg
        fi
    done
else
    log "error" "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Check Python and pip versions
python_version=$(python3 --version 2>&1 | cut -d ' ' -f 2 | cut -d '.' -f 1)
pip_version=$(pip --version 2>&1 | cut -d ' ' -f 2 | cut -d '.' -f 1)

if [[ $python_version -lt 3 ]]; then
    log "error" "Python 3 or higher is required."
    exit 1
fi

if [[ $pip_version -lt 17 ]]; then
    log "error" "pip 17 or higher is required."
    exit 1
fi

# Check for and install required Python packages
for pkg in pipreqs setuptools; do
    if ! pip show $pkg &>/dev/null; then
        log "info" "Installing $pkg..."
        pip install $pkg
    fi
done

# Print figfont text
echo -e "${BPurple}d8888b. db    db d888888b db      d8888b.         d8888b. db    db d8888b. ${Color_Off}"
echo -e "${BBlue}88  \`8D 88    88   \`88'   88      88  \`${Color_Off}"
echo -e "${BPurple}88  \`8D 88    88   \`88'   88      88  \`8D         88  \`8D 88    88 VP  \`8D ${Color_Off}"
echo -e "${BGreen}88oooY' 88    88    88    88      88   88         88oodD\' 88    88 oooY' ${Color_Off}"
echo -e "${BCyan}88~~~b. 88    88    88    88      88   88         88~~~   88    88 ~~~b. ${Color_Off}"
echo -e "${BWhite}88   8D 88b  d88   .88.   88booo. 88  .8D         88      88b  d88 db   8D ${Color_Off}"
echo -e "${BPink}Y8888P' ~Y8888P' Y888888P Y88888P Y8888D' C88888D 88      ~Y8888P' Y8888P'${Color_Off}"
echo -e "${BWhite}#################################################################################################${Color_Off}"

# Main function
main() {
    local script=$1

    if [ ! -f $script ]; then
        log "error" "The script $script does not exist."
        exit 1
    fi

    local dir=$(dirname $script)
    local name=$(basename $script .py)

    # Check if the script has a main function
    if ! grep -q "if __name__ == '__main__':" $script; then
        log "warn" "The script does not have a main function. Adding one..."
        echo "
if __name__ == '__main__':
    main()" >> $script
    fi

    cd $dir

    # Initialize a Git repository
    log "info" "Initializing a Git repository..."
    git init

    # Create the necessary files for a setuptools project
    log "info" "Creating the necessary files for a setuptools project..."
    echo "from setuptools import setup

    setup(
        name='$name',
        version='0.1',
        packages=['$name'],
        entry_points={
            'console_scripts': [
                '$name = $name.__main__:main'
            ]
        }
    )" > setup.py

    mkdir $name
    mv $script $name/__main__.py

    # Generate requirements.txt
    log "info" "Generating requirements.txt..."
    pip3 freeze > requirements.txt

    log "info" "Done."
}

# Call main function
main $@

