#!/bin/bash

sudo apt update && sudo apt full-upgrade && sudo apt-get install -y curl docker.io

read -p "Enter ADDRESS: " ADDRESS
read -p "Enter PRIVATE_KEY: " PRIVATE_KEY
read -p "Enter VALIDATOR_NAME: " VALIDATOR_NAME

echo "FROM elixirprotocol/validator:testnet-2
ENV ADDRESS=$ADDRESS
ENV PRIVATE_KEY=$PRIVATE_KEY
ENV VALIDATOR_NAME=$VALIDATOR_NAME" > Dockerfile

docker build . -f Dockerfile -t elixir-validator
docker run -it --name ev elixir-validator
