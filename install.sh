#!/bin/bash

GITHUB_REPO="subspace/pulsar"
GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

SERVICE_NAME="subspaced"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
SERVICE_EXEC="/usr/local/bin/pulsar farm --verbose"
USER="$USER"

LATEST_RELEASE_URL=$(curl -s "$GITHUB_API_URL" | grep -o 'https://github.com/[^"]*pulsar-ubuntu-x86_64[^"]*')
wget -O pulsar "$LATEST_RELEASE_URL"

chmod +x pulsar

sudo mv pulsar /usr/local/bin/

cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$SERVICE_EXEC
Restart=on-failure
LimitNOFILE=1024000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"
