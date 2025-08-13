# Scripts to auto-manage the syncing of the EFI folders and partitions when you have multiple drives (RAID setup)

sync-efi-auto.sh - This should be copied to /usr/local/sbin
sync-efi-manual.sh - This would have to be edited manually and run. Leave here.

install-efi-management.sh - Installs the scripts to maintain the EFI partitions.
install.sh - Better installation script.

99-sync-efi-on-grub-update - hook to run after a dpkg operation and check for changes to grub
99sync-efi-auto - hook to run after update-grub

I use this script when installing to a RAID setup. During installation I create identical EFI partitions on each
drive of the primary RAID drives. After installation, run the install script from this repo and your additional
partitions will be found, be updated with your mounted /boot/efi partition data, and added to the grub menu. In 
case of drive failure your system will still be able to boot normally. Tested on a 3 drive SATA SSD system (sdc,sde,sfd)

The simplest way to install is just to run the install.sh script. This will set up everything.