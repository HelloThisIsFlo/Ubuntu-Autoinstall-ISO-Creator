#!/bin/bash
set -eo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function run_sed_on_iso_script() {
  sed "$1" $CREATE_ISO_SCRIPT >$CREATE_ISO_SCRIPT-tmp
  mv $CREATE_ISO_SCRIPT-tmp $CREATE_ISO_SCRIPT # This is a workaround because 'sed -i' didn't work on my VM
}

function build_create_iso_script() {
  # Init 'create_iso.sh' file
  CREATE_ISO_SCRIPT="./TMP/create_iso.sh"
  cat <<EOF >$CREATE_ISO_SCRIPT
#!/bin/bash
xorriso -as mkisofs -r
EOF
  # Extract parameters from old ISO
  xorriso -indev "$ISO" -report_el_torito as_mkisofs 2>/dev/null >>$CREATE_ISO_SCRIPT
  run_sed_on_iso_script 's/^\([^#].*\)$/\1 \\/'

  ISO_FILENAME=$(basename "$ISO")
  ISO_FILENAME_ESCAPED=$(echo "$ISO_FILENAME" | sed 's/\//\\\//g')
  NEW_ISO="AUTOINSTALL-$ISO_FILENAME_ESCAPED"
  cat <<EOF >>$CREATE_ISO_SCRIPT
-o "$NEW_ISO" \\
./TMP
EOF

  # Make 'create_iso.sh' executable
  chmod +x $CREATE_ISO_SCRIPT
}

cd "$DIR"
# Check that this script is running on ubuntu
if [ ! -f /etc/os-release ]; then
  echo "This script must be run on Ubuntu"
  exit 1
fi

ISO="$1"
# Ensure ISO parameter is provided
if [ -z "$ISO" ]; then
  echo "Usage: $0 <iso>"
  exit 1
fi
# Check that the ISO parameter is a file
if [ ! -f "$ISO" ]; then
  echo "Error: $ISO is not a file"
  exit 1
fi

# Make sure the 'user-data' file exists
if [ ! -f ./user-data ]; then
  echo "Error: 'user-data' file does not exist. Make sure to copy 'user-data.example' to 'user-data' and edit it."
  exit 1
fi

# Install deps
sudo apt install p7zip-full >/dev/null 2>&1
sudo apt install xorriso >/dev/null 2>&1

# Create tmp folder
mkdir TMP

# Extract ISO
7z -y x "$ISO" -oTMP

#rm -rf "./TMP/[BOOT]" # Not sure => Maybe remove this line!

# Configure Grub to launch autoinstall automatically
cat <<EOF >./TMP/boot/grub/grub.cfg
set timeout=3
menuentry "AUTOINSTALL" {
	set gfxpayload=keep
	linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/autoinstall-config/  ---
	initrd  /casper/initrd
}
EOF

# Initialize autoinstall-config folder & move config
mkdir ./TMP/autoinstall-config
touch ./TMP/autoinstall-config/meta-data
cp ./user-data ./TMP/autoinstall-config/user-data

build_create_iso_script

# Create new ISO using 'create_iso.sh'
$CREATE_ISO_SCRIPT

# Clean up
rm -rf ./TMP

cd - >/dev/null
