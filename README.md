# Ubuntu Autoinstall ISO Creator

> Inspiration: [Puget Systems - Ubuntu 22.04 Server Autoinstall ISO](https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/)

## How to use?
1. Download the Ubuntu ISO from the official website
2. Rename `user-data.example` to `user-data`
3. Customize `user-data` (See [official doc](https://ubuntu.com/server/docs/install/autoinstall-reference))
4. Run:
   ```
   ./create_iso.sh UBUNTU_ISO_FILE.iso
   ```