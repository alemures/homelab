#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)."
  exit 1
fi

CONFIG_FILE="/etc/systemd/logind.conf"

echo "Configuring lid switch settings in $CONFIG_FILE..."

# 1. Update HandleLidSwitch
# This regex looks for lines starting with #HandleLidSwitch or HandleLidSwitch
sed -i 's/^#\?HandleLidSwitch=.*/HandleLidSwitch=ignore/' "$CONFIG_FILE"

# 2. Update HandleLidSwitchExternalPower
sed -i 's/^#\?HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' "$CONFIG_FILE"

# 3. Handle Docked state (Optional but recommended)
sed -i 's/^#\?HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' "$CONFIG_FILE"

echo "Restarting systemd-logind to apply changes..."
systemctl restart systemd-logind

echo "Done! Your laptop should now stay awake when the lid is closed."
