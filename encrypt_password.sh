#!/bin/bash
set -eo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

cd "$DIR"

# Make sure we are running on ubuntu
if [ ! -f /etc/os-release ]; then
    echo "This script must be run on Ubuntu"
    exit 1
fi

# Install 'pwgen' cli tool
sudo apt install pwgen >/dev/null 2>&1

# Ask user to enter new password
echo "Enter password to encrypt:"
read -s PASSWORD

# Generate a random salt using the pwgen utility
salt=$(pwgen -s 8 1)
# Generate a password hash using the salt and the SHA-512 algorithm
password_hash=$(openssl passwd -6 -salt $salt "$PASSWORD")

echo "This is the encrypted password"
echo
echo "    $password_hash"
echo

cd - >/dev/null
