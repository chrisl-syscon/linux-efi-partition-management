# install.sh
# 2025-08-13 Christopher Long
# Install the files necessary to manage EFI partitions after a GRUB update.
# This script is licensed under the GNU General Public License v3.0 or later.

# 1) Put your main sync script in place, the source is in the current directory
#    (you can also use the one from the repo, but this is more convenient)
sudo install -o root -g root -m 0755 sync-efi-auto.sh /usr/local/sbin/sync-efi-auto.sh

# 2) Add the self-install shim block near the top of /usr/local/sbin/sync-efi-auto.sh
#    (open it with your editor and paste the block)

# 3) Install the post-invoke runner + apt hook
sudo install -o root -g root -m 0755 /dev/stdin /usr/local/sbin/sync-efi-on-grub-update.sh <<'EOF'
#!/bin/bash
set -euo pipefail
STATE_DIR="/var/lib/sync-efi"
STATE_FILE="$STATE_DIR/grub-versions"
SYNC="/usr/local/sbin/sync-efi-auto.sh"
LOG="/var/log/sync-efi-auto.log"
mkdir -p "$STATE_DIR"
current_versions="$(dpkg-query -W -f='${Package} ${Version}\n' 'grub-*' 2>/dev/null | sort || true)"
if [[ ! -s "$STATE_FILE" ]]; then changed=1; else
  if ! diff -q "$STATE_FILE" <(printf '%s\n' "$current_versions") >/dev/null; then changed=1; else changed=0; fi
fi
if [[ $changed -eq 1 ]]; then
  printf '%s\n' "$current_versions" >"$STATE_FILE"
  if [[ -x "$SYNC" ]]; then
    echo "[$(date -Is)] Detected GRUB version change, running sync..." | tee -a "$LOG"
    if "$SYNC" >>"$LOG" 2>&1; then
      echo "[$(date -Is)] sync-efi-auto.sh finished OK" | tee -a "$LOG"
    else
      echo "[$(date -Is)] sync-efi-auto.sh failed (see log)" | tee -a "$LOG"
    fi
  else
    echo "[$(date -Is)] $SYNC not found or not executable, skipping" | tee -a "$LOG"
  fi
fi
exit 0
EOF

sudo tee /etc/apt/apt.conf.d/99-sync-efi-on-grub-update >/dev/null <<'EOF'
DPkg::Post-Invoke {
  "if [ -x /usr/local/sbin/sync-efi-on-grub-update.sh ]; then /usr/local/sbin/sync-efi-on-grub-update.sh || true; fi";
};
EOF

# 4) (Optional but recommended) Drop the grub.d shim right now so you’re covered immediately
sudo install -o root -g root -m 0755 /dev/stdin /etc/grub.d/09_sync_efi <<'EOF'
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
