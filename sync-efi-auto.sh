#!/bin/bash
# 2025-08-13 Christopher Long
# Sync EFI partitions from the main ESP (/boot/efi) to others and reinstall GRUB.
# This script is intended to be run automatically after a GRUB update, after an apt/dpkg operation or manually.
# It can be run automatically via a post-install hook in /etc/grub.d/99sync-efi-auto
# to ensure EFI partitions are kept in sync with the main ESP.
# This script is licensed under the GNU General Public License v3.0 or later.
set -euo pipefail

# --- self-install grub.d shim if missing ---
ensure_grubd_hook() {
  local hook="/etc/grub.d/99sync-efi-auto"
  if [ ! -x "$hook" ]; then
    echo "Installing $hook shim..."
    install -o root -g root -m 0755 /dev/stdin "$hook" <<'EOF'
#!/bin/sh
set -e
SYNC="/usr/local/sbin/sync-efi-auto.sh"
LOG="/var/log/sync-efi-auto.log"
if [ -x "$SYNC" ]; then
  "$SYNC" >>"$LOG" 2>&1 || true
fi
exit 0
EOF
  fi
}
ensure_grubd_hook
# --- end shim ---

# Ensure that the temporary mount point is cleaned up on exit
trap 'umount "$TMP_MOUNT" 2>/dev/null || true' EXIT

SRC_MOUNT="/boot/efi"
TMP_MOUNT="/mnt/esp-sync"
mkdir -p "$TMP_MOUNT"

# Find the source EFI partition device
SRC_DEV=$(findmnt -no SOURCE "$SRC_MOUNT")

# Find all other EFI partitions (vfat, size between 100M and 10G)
mapfile -t TARGETS < <(
    lsblk -brno NAME,FSTYPE,SIZE,TYPE |
    awk -v src="$SRC_DEV" '
        $2=="vfat" && $4=="part" && "/dev/"$1 != src {
            size_mb = $3 / (1024*1024)
            if (size_mb > 100 && size_mb < 10000) print "/dev/"$1
        }
    '
)

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "No other EFI partitions found."
    exit 0
fi

echo "Source EFI partition: $SRC_DEV"
echo "Target EFI partitions: ${TARGETS[*]}"

# Step 1: Sync EFI files
for target in "${TARGETS[@]}"; do
    echo "=== Syncing to $target ==="
    mount "$target" "$TMP_MOUNT"

    rsync -avh --delete \
        --exclude 'System Volume Information' \
        --exclude '.Trash-*' \
        "$SRC_MOUNT/" "$TMP_MOUNT/"

    sync
    umount "$TMP_MOUNT"
    echo "=== Done with $target ==="
done

echo "All EFI partitions synchronized."

# Step 2: Install GRUB and create NVRAM boot entries
for target in "${TARGETS[@]}"; do
    # Get the disk containing the target partition
    disk="/dev/$(lsblk -no PKNAME "$target")"
    # Get the short name of the disk (e.g., sda, sdb, nvme0n1)
    shortname=$(basename "$disk")
    
    boot_label="Debian Backup EFI ($shortname)"
    boot_loader='\\EFI\\debian\\grubx64.efi'
    
    echo "Ensuring EFI flag on $disk partition 1"
    parted "$disk" set 1 boot on || true

    mount "$target" "$TMP_MOUNT"
    echo "Installing GRUB to $target"
    grub-install --target=x86_64-efi --efi-directory="$TMP_MOUNT" --bootloader-id=debian --recheck
    umount "$TMP_MOUNT"

    # Check if an entry for this loader+disk already exists
    if efibootmgr -v | grep -F "$boot_loader" | grep -Fq "$shortname"; then
        echo "Boot entry for $disk already exists. Skipping."
    else
        echo "Creating EFI boot entry: $boot_label"
        efibootmgr --create --disk "$disk" --part 1 --label "$boot_label" --loader "$boot_loader"
    fi
done

efibootmgr -v
echo "EFI synchronization and GRUB update complete."
# --- end of script ---

