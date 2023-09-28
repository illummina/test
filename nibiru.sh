#!/bin/bash

is_valid_moniker() {
    local moniker="$1"
    if [[ "$moniker" =~ ^[A-Z][A-Za-z0-9]*$ && ${#moniker} -le 15 ]]; then
        return 0  # Valid moniker
    else
        return 1  # Invalid moniker
    fi
}

sudo apt update && sudo apt upgrade --yes

NIBIRU_VERSION=$(curl -s "https://github.com/NibiruChain/nibiru/releases" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
curl -s "https://get.nibiru.fi/@${NIBIRU_VERSION}!" | bash

nibid version

while true; do
    read -p "Enter a moniker name (starts with an uppercase letter, contains only letters and numbers, not longer than 15 characters): " moniker

    if is_valid_moniker "$moniker"; then
        nibid init "$moniker" --chain-id=nibiru-itn-2 --home $HOME/.nibid
        break
    else
        echo "Invalid moniker name. Please follow the naming rules."
    fi
done

## 5. Create a local key pair (Change <key-name> as needed)
#nibid keys add <key-name>
#
## 6. Fetch and copy the genesis file
#NETWORK=nibiru-itn-2
#curl -s "https://networks.itn2.nibiru.fi/$NETWORK/genesis" > $HOME/.nibid/config/genesis.json
#
## 7. (Optional) Verify Genesis File Checksum
#shasum -a 256 $HOME/.nibid/config/genesis.json
#
## 8. Update seeds list in the configuration file
#sed -i 's|seeds =.*|seeds = "'$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/seeds)'"|g' $HOME/.nibid/config/config.toml
#
## 9. Set minimum gas prices
#sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025unibi"/g' $HOME/.nibid/config/app.toml
#
## 10. Setup state-sync parameters
#config_file="$HOME/.nibid/config/config.toml"
#sed -i "s|enable =.*|enable = true|g" "$config_file"
#sed -i "s|rpc_servers =.*|rpc_servers = \"$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/rpc_servers)\"|g" "$config_file"
#sed -i "s|trust_height =.*|trust_height = \"$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/trust_height)\"|g" "$config_file"
#sed -i "s|trust_hash =.*|trust_hash = \"$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/trust_hash)\"|g" "$config_file"
#
## 11. Create and enable the systemd service unit file
#SERVICE_UNIT_FILE="/etc/systemd/system/nibiru.service"
#sudo bash -c "cat > $SERVICE_UNIT_FILE" <<EOL
#[Unit]
#Description=Nibiru Node
#
#[Service]
#ExecStart=$(which nibid) start
#Restart=on-failure
#User=$USER
#Group=$USER
#
#[Install]
#WantedBy=multi-user.target
#EOL
#
## Reload systemd configuration
#sudo systemctl daemon-reload
#
## Enable and start the Nibiru service
#sudo systemctl enable nibiru.service
#sudo systemctl start nibiru.service

echo "Nibiru setup completed."