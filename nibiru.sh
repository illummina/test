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
#
sudo apt update
sudo apt upgrade --yes

NIBIRU_VERSION=$(curl -s "https://github.com/NibiruChain/nibiru/releases" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)

NIBIRU_INSTALL_SCRIPT="https://get.nibiru.fi/@${NIBIRU_VERSION}!"
curl -s "$NIBIRU_INSTALL_SCRIPT" | bash

NIBIRU_INSTALLED_VERSION=$(nibid version)
echo "$NIBIRU_INSTALLED_VERSION"
if [[ "v$NIBIRU_INSTALLED_VERSION" != "$NIBIRU_VERSION" ]]; then
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
    break
  else
    echo "Invalid moniker name. Please use ONLY letters and numbers"
  fi
done
