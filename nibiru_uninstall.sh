#!/bin/bash

sudo systemctl stop nibiru
sudo systemctl disable nibiru

rm -rf /etc/systemd/system/nibiru.service
rm -rf /usr/bin/nibid
rm -rf nibiru
rm -rf .nibid

echo "Done"