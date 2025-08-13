#!/bin/bash
# 2025-08-13 Christopher Long
# Install the files necessary to manage EFI partitions after a GRUB update.
# This script is licensed under the GNU General Public License v3.0 or later.

# SCRIPTS
SYNC_EFI_SCRIPT="sync-efi-auto.sh"
SYNC_ON_GRUB_UPDATE_SCRIPT="sync-efi-on-grub-update.sh"
SYNC_ON_DPKG_UPDATE_HOOK="99-sync-efi-on-grub-update"
UPDATE_GRUB_HOOK="99sync-efi-auto"
# INSTALL DIRECTORY
INSTALL_DIR="/usr/local/sbin"

# Ensure the install directory exists
if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -p "$INSTALL_DIR"
fi

# Copy the efi management scripts to the proper locations and set up.
# Check if the sync-efi-auto script already exists
if [[ -f "$INSTALL_DIR/$SYNC_EFI_SCRIPT" ]]; then
    echo "$SYNC_EFI_SCRIPT already exists in $INSTALL_DIR, skipping copy."
else
    echo "Copying $SYNC_EFI_SCRIPT to $INSTALL_DIR."
    # Copy the script to the install directory, preserving file information
    cp -p "$SYNC_EFI_SCRIPT" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$SYNC_EFI_SCRIPT"
fi

# Check if the sync-on-grub-update script already exists
if [[ -f "$INSTALL_DIR/$SYNC_ON_GRUB_UPDATE_SCRIPT" ]]; then
    echo "$SYNC_ON_GRUB_UPDATE_SCRIPT already exists in $INSTALL_DIR, skipping copy."
else
    echo "Copying $SYNC_ON_GRUB_UPDATE_SCRIPT to $INSTALL_DIR."
    # Copy the script to the install directory, preserving file information
    cp -p "$SYNC_ON_GRUB_UPDATE_SCRIPT" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$SYNC_ON_GRUB_UPDATE_SCRIPT"
fi

# Check if the grub.d hook already exists
if [[ -f "/etc/grub.d/$UPDATE_GRUB_HOOK" ]]; then
    echo "$UPDATE_GRUB_HOOK already exists in /etc/grub.d/, skipping creation."
else
    echo "Creating $UPDATE_GRUB_HOOK in /etc/grub.d/."
    # Create the grub.d hook script
    cp -p "${UPDATE_GRUB_HOOK}" "/etc/grub.d/"
    chmod +x "/etc/grub.d/$UPDATE_GRUB_HOOK"
fi

# Check if the dpkg hook already exists
if [[ -f "/etc/apt/apt.conf.d/$SYNC_ON_DPKG_UPDATE_HOOK" ]]; then
    echo "$SYNC_ON_DPKG_UPDATE_HOOK already exists in /etc/apt/apt.conf.d/, skipping creation."
else
    echo "Creating $SYNC_ON_DPKG_UPDATE_HOOK in /etc/apt/apt.conf.d/."
    # Create the dpkg hook script
    cp -p "${SYNC_ON_DPKG_UPDATE_HOOK}" "/etc/apt/apt.conf.d/"
    chmod 644 "/etc/apt/apt.conf.d/$SYNC_ON_DPKG_UPDATE_HOOK"
fi


