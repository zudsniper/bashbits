#!/bin/bash
# install_disable-keyboard.sh
# ------------------
# by @zudsniper on github
# 
# create and then install a very specific script which utilizes `xinput` to disable the 
# built-in laptop keyboard of a specific laptop being used as a server here 
# 
# TESTED only on DEBIAN 12 (which I hate, should just go back to 11, sound harder than dealing with this)
# DEPENDS on `xinput` so `sudo apt install xinput -y` before you use this, ya hear.
# 
# WARNING this creates and installs a systemctl service, then enables it. 
#
# happy halloween 🎃
# ---------------


# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    if [ "$1" == "success" ]; then
        echo -e "${GREEN}$2${NC}"
    else
        echo -e "${RED}$2${NC}"
    fi
}

# Step 1: Create disable-keyboard.sh
print_status "success" "Creating disable-keyboard.sh..."
cat << 'EOF' > /tmp/disable-keyboard.sh
#!/bin/bash

export DISABLE_NAME=${DISABLE_NAME:-"AT Translated Set 2 keyboard"}

log_to_systemd() {
    echo "$1"
    logger -t disable-keyboard "$1"
}

if ! command -v xinput &> /dev/null; then
    log_to_systemd "xinput could not be found. Please install xinput."
    exit 1
fi

device_info=$(xinput list --name-only --id-only "$DISABLE_NAME")
if [[ -z "$device_info" ]]; then
    log_to_systemd "Device '$DISABLE_NAME' not found."
    exit 1
fi

device_id=$(echo "$device_info" | awk 'NR==1{print $1}')
master_id=$(echo "$device_info" | awk 'NR==2{print $1}')

xinput float "$device_id"
if [[ $? -ne 0 ]]; then
    log_to_systemd "Failed to disable device '$DISABLE_NAME'."
    exit 1
fi

log_to_systemd "Successfully disabled device '$DISABLE_NAME'."
EOF

chmod +x /tmp/disable-keyboard.sh
print_status "success" "Created disable-keyboard.sh"

# Step 2: Create systemd service file
print_status "success" "Creating systemd service file..."
cat << EOF > /tmp/disable-keyboard.service
[Unit]
Description=Disable Internal Keyboard

[Service]
Type=simple
ExecStart=/bin/bash /tmp/disable-keyboard.sh
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/$USER/.Xauthority"

[Install]
WantedBy=multi-user.target
EOF

print_status "success" "Created systemd service file"

# Step 3: Install and enable the service
print_status "success" "Installing and enabling systemd service..."
sudo cp /tmp/disable-keyboard.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable disable-keyboard.service
if [[ $? -eq 0 ]]; then
    print_status "success" "Successfully installed and enabled the systemd service"
else
    print_status "failure" "Failed to install and enable the systemd service"
fi

# Step 4: Cleanup
rm /tmp/disable-keyboard.sh
rm /tmp/disable-keyboard.service

print_status "success" "Cleanup complete. You're all set!"
