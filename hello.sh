#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo 'curl exists'
else
  echo 'curl not exists'
fi
