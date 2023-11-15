#!/bin/bash
# piavpnx.sh v0.0.3
# -----------------
# 
# automated configuration of PIA VPN using openvpn for use with Tails Linux
# - installs any uninstalled tools 
# - guides user on steps to obtain the Netherlands SOCKS5 proxy credentials (this is provided with your PIA purchase, but the credentials differ)
# - downloads the relevant `.ovpn` file, defaulting to the Netherlands
# - configures the system to use this SOCKS5 proxy & the VPN server via openvpn
# 
# -----------------
# Shoutout the Netherlands

# Exit on any error
set -e

# ANSI color code variables
FG_RED="\033[0;31m"
FG_GREEN="\033[0;32m"
FG_YELLOW="\033[0;33m"
FG_MAGENTA="\033[0;35m"
BG_BLACK="\033[40m"
RESET="\033[0m"

# Constants and configurations
DEFAULT_REGION="Netherlands"
LOG_LEVEL=3  # 0: None, 1: Error, 2: Warning, 3: Info, 4: Debug

# Logging function
log() {
    local level=$1
    local message=$2

    if [ $level -le $LOG_LEVEL ]; then
        case $level in
            1) echo -e "${FG_RED}[ERROR] $message${RESET}" ;;
            2) echo -e "${FG_YELLOW}${BG_BLACK}[WARNING] $message${RESET}" ;;
            3) echo -e "[INFO] $message" ;;
            4) echo -e "${FG_MAGENTA}[DEBUG] $message${RESET}" ;;
            5) echo -e "${FG_GREEN}[SUCCESS] $message${RESET}" ;;
        esac
    fi
}

# Function to display guide for obtaining SOCKS5 credentials
display_socks5_guide() {
    echo -e "${FG_GREEN}If you already have your SOCKS5 proxy credentials, please enter them when prompted.${RESET}"
    echo -e "${FG_GREEN}This guide is for users who need to obtain or generate new credentials.${RESET}\n"

    log 3 "${FG_YELLOW}Guide to Obtain New SOCKS5 Proxy Credentials from PIA:${RESET}"
    echo -e "${FG_GREEN}1. Visit the PIA Client Control Panel on your web browser.${RESET}"
    echo -e "${FG_GREEN}2. Log in to your PIA account.${RESET}"
    echo -e "${FG_GREEN}3. Navigate to the 'Generate SOCKS Password' section.${RESET}"
    echo -e "${FG_GREEN}4. Click the 'Generate Password' button under the 'Generate SOCKS Download' section.${RESET}"
    echo -e "${FG_GREEN}5. Note down the Username starting with 'x' and the randomly generated Password.${RESET}"
    echo -e "${FG_GREEN}6. Return to this terminal and enter these credentials when prompted.${RESET}"
    echo -e "${FG_GREEN}Search query suggestion: 'PIA Client Control Panel SOCKS5'${RESET}"
}

# Checking and installing necessary utilities
check_and_install_dependencies() {
    # Check if OpenVPN is installed
    if ! command -v openvpn &> /dev/null; then
        log 3 "OpenVPN is not installed. Installing OpenVPN..."
        sudo apt-get update
        sudo apt-get install -y openvpn
    else
        log 4 "OpenVPN is already installed."
    fi

    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        log 3 "Neither curl nor wget is installed. Installing curl..."
        sudo apt-get install -y curl
    else
        log 4 "Required utilities are already installed."
    fi
}



# Placeholder function for downloading OpenVPN configuration files
download_openvpn_configs() {
    log 4 "Downloading OpenVPN configuration files..."

    local config_url="https://www.privateinternetaccess.com/openvpn/openvpn.zip"
    local config_dir="/etc/openvpn"

    # Creating configuration directory if it doesn't exist
    sudo mkdir -p "$config_dir"

    # Downloading and extracting the configuration files
    curl -L "$config_url" | sudo unzip -d "$config_dir" -
}

# Function to configure OpenVPN with the downloaded files
configure_openvpn() {
    log 4 "Configuring OpenVPN..."

    local config_file="/etc/openvpn/${REGION}.ovpn"

    # Check if the configuration file exists
    if [[ ! -f "$config_file" ]]; then
        log 1 "OpenVPN configuration file for the selected region not found."
        exit 1
    fi

    # Additional configuration can be added here if needed
}

# Function to configure SOCKS5 proxy
configure_socks5_proxy() {
    log 4 "Configuring SOCKS5 proxy..."

    local proxy_ip=$(ping -c 1 proxy-nl.privateinternetaccess.com | grep PING | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')

    if [[ -z "$proxy_ip" ]]; then
        log 1 "Failed to obtain IP for SOCKS5 proxy."
        exit 1
    fi

    # Assuming OpenVPN configuration includes proxy settings
    echo "socks-proxy $proxy_ip 1080" >> "/etc/openvpn/${REGION}.ovpn"
    echo "socks-proxy-retry" >> "/etc/openvpn/${REGION}.ovpn"
    echo "socks-proxy $socks5_username $socks5_password" >> "/etc/openvpn/${REGION}.ovpn"
}

# Function to configure TOR/ONION routing
configure_tor_routing() {
    log 4 "Configuring TOR/ONION routing..."

    # Assuming TOR is already installed and configured on Tails
    # Modifying TOR configuration to route through VPN
    local tor_config="/etc/tor/torrc"

    sudo sed -i '/#UseBridges/ a UseBridges 1\nClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy\nBridge obfs4 [VPN_IP:PORT] [FINGERPRINT]' "$tor_config"

    # Restarting TOR service to apply changes
    sudo systemctl restart tor
}

# Check if OpenVPN is installed
if ! command -v openvpn &> /dev/null; then
    log 3 "OpenVPN is not installed. Installing OpenVPN..."
    sudo apt-get update
    sudo apt-get install -y openvpn
else
    log 4 "OpenVPN is already installed."
fi

# Check for other necessary utilities like curl or wget
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    log 3 "Neither curl nor wget is installed. Installing curl..."
    sudo apt-get install -y curl
else
    log 4 "Required utilities are already installed."
fi

# Handle command-line arguments for region selection
REGION=${1:-$DEFAULT_REGION}
log 3 "Selected region: $REGION"

# Display SOCKS5 guide and prompt for credentials
display_socks5_guide
read -p "Enter your SOCKS5 proxy username: " socks5_username
read -s -p "Enter your SOCKS5 proxy password: " socks5_password
echo

# Main execution flow
download_openvpn_configs
configure_openvpn
configure_socks5_proxy
configure_tor_routing

log 5 "VPN and proxy setup completed successfully."


# Main execution flow
check_and_install_dependencies

# Handle command-line arguments for region selection
REGION=${1:-$DEFAULT_REGION}
log 3 "Selected region: $REGION"

# Display SOCKS5 guide and prompt for credentials
display_socks5_guide
read -p "Enter your SOCKS5 proxy username: " socks5_username
read -s -p "Enter your SOCKS5 proxy password: " socks5_password
echo

download_openvpn_configs
configure_openvpn
configure_socks5_proxy
configure_tor_routing

log 5 "VPN and proxy setup completed successfully."

# Teardown and enabling guide
log 3 "To enable the configured VPN and routing:"
echo -e "${FG_GREEN}1. Start OpenVPN with the selected configuration.${RESET}"
echo -e "${FG_GREEN}2. Verify the VPN connection is active and stable.${RESET}"
echo -e "${FG_GREEN}3. Ensure TOR/ONION services are correctly routing through the VPN.${RESET}"
echo -e "${FG_GREEN}4. Regularly check for any updates to OpenVPN and PIA configurations.${RESET}"
