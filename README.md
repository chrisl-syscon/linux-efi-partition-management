# Scripts to auto-manage the syncing of the EFI folders and partitions when you have multiple drives (RAID setup)

sync-efi-auto.sh - This should be copied to /usr/local/sbin
sync-efi-manual.sh - This would have to be edited manually and run. Leave here.

install-efi-management.sh - Installs the scripts to maintain the EFI partitions.
install.sh - Better installation script.

99-sync-efi-on-grub-update - hook to run after a dpkg operation and check for changes to grub
99sync-efi-auto - hook to run after update-grub

The simplest way to install is just to run the install.sh script. This will set up everything.