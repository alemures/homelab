#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Step 1: Creating configuration directory for systemd-resolved..."
mkdir -p /etc/systemd/resolved.conf.d

echo "Step 2: Creating adguardhome.conf to disable DNSStubListener..."
# This disables the listener on port 53 and sets the DNS to localhost
cat <<EOF > /etc/systemd/resolved.conf.d/adguardhome.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF

echo "Step 3: Updating /etc/resolv.conf symlink..."
# Backup the current resolv.conf just in case
if [ -f /etc/resolv.conf ] && [ ! -L /etc/resolv.conf ]; then
    mv /etc/resolv.conf /etc/resolv.conf.backup
    echo "Current /etc/resolv.conf backed up to /etc/resolv.conf.backup"
fi

# Link to the version managed by systemd-resolved that doesn't use the stub
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo "Step 4: Restarting systemd-resolved..."
systemctl reload-or-restart systemd-resolved

echo "-------------------------------------------------------"
echo "Success! Port 53 should now be free for AdGuard Home."
echo "You can verify this by running: sudo lsof -i :53"
echo "-------------------------------------------------------"
