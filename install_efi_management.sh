#!/bin/bash
# 2025-08-13 Christopher Long
# Install the files necessary to manage EFI partitions after a GRUB update.
# This script is licensed under the GNU General Public License v3.0 or later.

# SCRIPTS
SYNC_EFI_SCRIPT="sync-efi-auto.sh"
SYNC_ON_GRUB_UPDATE_SCRIPT="sync-efi-on-grub-update.sh"
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
