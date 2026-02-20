#!/bin/bash

# --- Configuration ---
SERVICE_NAME="docker-ssh-agent.service"
USER_NAME="alejandro"
USER_HOME="/home/${USER_NAME}"
KEY_PATH="${USER_HOME}/.ssh/id_ed25519"
SOCKET_PATH="${USER_HOME}/.ssh/docker-ssh-agent.sock"
SYSTEMD_PATH="/etc/systemd/system/${SERVICE_NAME}"

# --- Security Check ---
if ! id "${USER_NAME}" &>/dev/null; then
    echo "❌ Error: User '${USER_NAME}' does not exist. Please check the USER_NAME variable."
    exit 1
fi

if [ ! -f "${KEY_PATH}" ]; then
    echo "⚠️ Warning: The SSH key '${KEY_PATH}' does not exist."
    echo "Please create it before running the script, or the 'ssh-add' step will fail."
    echo "To create the ssh key, run the following command:"
    echo "  ssh-keygen -t ed25519 -C \"my@mail.com\""
    exit 1
fi

# --- Systemd Unit Content ---
UNIT_CONTENT="[Unit]
Description=Persistent SSH Agent for Docker
Wants=network-online.target
After=network-online.target

[Service]
User=${USER_NAME}
Type=simple
# Fixed location for the socket
Environment=SSH_AUTH_SOCK=${SOCKET_PATH}

# Clean up any stale socket file
ExecStartPre=/usr/bin/rm -f ${SOCKET_PATH}

# Start ssh-agent in the foreground (-D) bound to our fixed socket (-a)
ExecStart=/usr/bin/ssh-agent -D -a ${SOCKET_PATH}

# Add the key to the agent immediately after startup
ExecStartPost=/bin/bash -c 'sleep 1; /usr/bin/ssh-add ${KEY_PATH}'

[Install]
WantedBy=multi-user.target
"

# --- Execution ---

echo "--- 1. Creating Systemd Service File: ${SYSTEMD_PATH} ---"
echo "${UNIT_CONTENT}" | sudo tee "${SYSTEMD_PATH}" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ File created successfully."
else
    echo "❌ Failed to create the service file. Check permissions."
    exit 1
fi

echo "--- 2. Reloading Systemd Daemon ---"
sudo systemctl daemon-reload
echo "✅ Systemd configuration reloaded."

echo "--- 3. Enabling Service (${SERVICE_NAME}) to start on boot ---"
sudo systemctl enable "${SERVICE_NAME}"
echo "✅ Service enabled."

echo "--- 4. Starting Service Now ---"
sudo systemctl start "${SERVICE_NAME}"

# Give it a moment to start
sleep 2

echo "--- 5. Verifying Status ---"
if sudo systemctl is-active "${SERVICE_NAME}" | grep -q "active"; then
    echo "✅ **SUCCESS!** The ${SERVICE_NAME} is active and running."
    echo ""
    echo "To view logs and ensure the key was added:"
    echo "  sudo journalctl -u ${SERVICE_NAME} --no-pager"
    echo ""
    echo "To configure Docker, remember to set this environment variable and volume mount:"
    echo "  SSH_AUTH_SOCK=${SOCKET_PATH}"
else
    echo "❌ **FAILURE!** The ${SERVICE_NAME} failed to start. Check logs for errors."
    echo "Run: sudo journalctl -xeu ${SERVICE_NAME}"
fi

exit 0
