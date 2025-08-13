#!/bin/bash
# Run sync-efi-auto.sh only when a GRUB package version changed since last run.

set -euo pipefail

STATE_DIR="/var/lib/sync-efi"
STATE_FILE="$STATE_DIR/grub-versions"
SYNC="/usr/local/sbin/sync-efi-auto.sh"
LOG="/var/log/sync-efi-auto.log"

mkdir -p "$STATE_DIR"

# Collect installed grub package versions (both EFI and PC just in case)
current_versions="$(dpkg-query -W -f='${Package} ${Version}\n' 'grub-*' 2>/dev/null | sort || true)"

# If we've never recorded versions, force a run
if [[ ! -s "$STATE_FILE" ]]; then
  changed=1
else
  if ! diff -q "$STATE_FILE" <(printf '%s\n' "$current_versions") >/dev/null; then
    changed=1
  else
    changed=0
  fi
fi

if [[ $changed -eq 1 ]]; then
  printf '%s\n' "$current_versions" >"$STATE_FILE"
  if [[ -x "$SYNC" ]]; then
    echo "[$(date -Is)] Detected GRUB version change, running sync..." | tee -a "$LOG"
    # Run the sync; don't kill the apt run on failure
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
