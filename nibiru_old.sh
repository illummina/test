#!/bin/bash

is_valid_moniker() {
  local moniker="$1"
  if [[ "$moniker" =~ ^[A-Z][A-Za-z0-9]*$ && ${#moniker} -le 15 ]]; then
    return 0
  else
    return 1
  fi
}

sudo apt update && sudo apt upgrade --yes

NIBIRU_VERSION=$(curl -s "https://github.com/NibiruChain/nibiru/releases" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)

curl -s "https://get.nibiru.fi/@${NIBIRU_VERSION}!" | bash

#TODO Make version selectable
#NIBIRU_INSTALLED_VERSION=$(nibid version)
#echo "$NIBIRU_INSTALLED_VERSION"
#if [[ "v$NIBIRU_INSTALLED_VERSION" != "$NIBIRU_VERSION" ]]; then
#    echo "WARNING: Nibiru version ($NIBIRU_INSTALLED_VERSION) does not match the installed version ($NIBIRU_VERSION)"
#fi
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

# TODO: selectable from existing wallet or create new
nibid keys add wallet --recover
##Команда запросит указать пароль, а затем выдаст мнемоник фразу, которую нужно будет обязательно сохранить в безопасное место.
##nibid keys add <key-name>


NETWORK=nibiru-itn-2
curl -s "https://networks.itn2.nibiru.fi/$NETWORK/genesis" > $HOME/.nibid/config/genesis.json

shasum -a 256 $HOME/.nibid/config/genesis.json

sed -i 's|seeds =.*|seeds = "'$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/seeds)'"|g' $HOME/.nibid/config/config.toml

sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025unibi"/g' $HOME/.nibid/config/app.toml

config_file="$HOME/.nibid/config/config.toml"
sed -i "s|enable =.*|enable = true|g" "$config_file"
sed -i "s|rpc_servers =.*|rpc_servers = \"$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/rpc_servers)\"|g" "$config_file"
sed -i "s|trust_height =.*|trust_height = \"$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/trust_height)\"|g" "$config_file"
sed -i "s|trust_hash =.*|trust_hash = \"$(curl -s https://networks.itn2.nibiru.fi/$NETWORK/trust_hash)\"|g" "$config_file"

sudo systemctl start nibiru

echo "Nibiru setup completed."




