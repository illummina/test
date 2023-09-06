#!/bin/bash

sudo systemctl stop subspaced
sudo systemctl disable subspaced
sudo rm /etc/systemd/system/subspaced.service
sudo rm /usr/local/bin/pulsar
#rm -rf ~/.local/share/subspace*
#rm -rf /etc/systemd/system/subspaced*
#rm -rf /usr/local/bin/subspace*

echo "Pulsar and all associated files have been uninstalled."
