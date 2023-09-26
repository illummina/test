#!/bin/bash

# name validator
is_valid_moniker() {
    local moniker="$1"
    if [[ "$moniker" =~ ^[A-Z][A-Za-z0-9]*$ && ${#moniker} -le 15 ]]; then
        return 0
    else
        return 1
    fi
}

sudo apt update
sudo apt upgrade --yes

NIBIRU_VERSION=$(curl -s https://get.nibiru.fi/latest)
if [ -z "$NIBIRU_VERSION" ]; then
    echo "Failed to fetch the latest Nibiru version"
    exit 1
fi

curl -s "https://get.nibiru.fi/@${NIBIRU_VERSION}!" | bash

NIBIRU_INSTALLED_VERSION=$(nibid version)
if [[ "$NIBIRU_INSTALLED_VERSION" != "$NIBIRU_VERSION" ]]; then
    echo "WARNING: Nibiru version ($NIBIRU_INSTALLED_VERSION) does not match the installed version ($NIBIRU_VERSION)"
fi
while true; do
  read -p "Enter the moniker name (starts with an uppercase letter, contains only letters and numbers, not longer than 15 characters): " moniker

  if is_valid_moniker "$moniker"; then
      nibid init "$moniker" --chain-id=nibiru-itn-2 --home $HOME/.nibid
      nibid keys add wallet

      NETWORK=nibiru-itn-2
      curl -s https://networks.itn2.nibiru.fi/$NETWORK/genesis > $HOME/.nibid/config/genesis.json

      # verify checksum
      shasum -a 256 $HOME/.nibid/config/genesis.json

      config_file="$HOME/.nibid/config/config.toml"
      sed -i 's|seeds =.*|seeds = "'$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/seeds)'"|g' $config_file

      cat <<EOF | sudo tee /etc/systemd/system/nibiru.service
[Unit]
Description=Nibiru Node
After=network-online.target

[Service]
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl start nibiru
    systemctl enable nibiru
  else
    echo "Invalid moniker name. Please use ONLY letters and numbers"
  fi
done
