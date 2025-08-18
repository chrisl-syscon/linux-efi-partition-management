# install.sh
# 2025-08-13 Christopher Long
# Install the files necessary to manage EFI partitions after a GRUB update.
# This script is licensed under the GNU General Public License v3.0 or later.

# Check and install efibootmgr and grub-efi-amd64
if ! command -v efibootmgr &>/dev/null; then
  echo "efibootmgr is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install -y efibootmgr
else
  echo "efibootmgr is already installed."
fi
if ! command -v grub-efi-amd64 &>/dev/null; then
  echo "grub-efi-amd64 is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install -y grub-efi-amd64
else
  echo "grub-efi-amd64 is already installed."
fi

# 1) Put your main sync script in place, the source is in the current directory
#    (you can also use the one from the repo, but this is more convenient)
sudo install -o root -g root -m 0755 sync-efi-auto.sh /usr/local/sbin/sync-efi-auto.sh

# 2) Add the self-install shim block near the top of /usr/local/sbin/sync-efi-auto.sh
#    (open it with your editor and paste the block)

# 3) Install the post-invoke runner + apt hook
sudo install -o root -g root -m 0755 sync-efi-on-grub-update.sh /usr/local/sbin/sync-efi-on-grub-update.sh

# 4) (Optional but recommended) Drop the grub.d shim right now so you’re covered immediately
sudo install -o root -g root -m 0755 /dev/stdin /etc/grub.d/99_sync_efi_auto <<'EOF'
#!/bin/sh
set -e
SYNC="/usr/local/sbin/sync-efi-auto.sh"
LOG="/var/log/sync-efi-auto.log"
if [ -x "$SYNC" ]; then
  "$SYNC" >>"$LOG" 2>&1 || true
fi
exit 0
EOF

# 5) Test:
sudo /usr/local/sbin/sync-efi-on-grub-update.sh
sudo update-grub  # should also run your sync via the shim
