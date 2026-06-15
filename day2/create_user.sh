#!/bin/bash

read -p "enter username: " username

sudo useradd -m $username

echo "the user is added"
