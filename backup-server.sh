#!/usr/bin/env bash
set -e

# ===============================
# Full Server Backup Script
# Usage: sudo backup-server
# ===============================

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/var/backups/server"
ARCHIVE_NAME="server_${DATE}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

mkdir -p "$BACKUP_DIR"

echo "======================================"
echo "🖥  Creating FULL SERVER backup"
echo "📅 Date: $DATE"
echo "======================================"

# Important directories to include
INCLUDE_DIRS=(
  "/etc"
  "/var/www"
  "/etc/nginx"
  "/etc/webapp"
  "/home/tamer"
)

# Create archive
tar -czf "$ARCHIVE_PATH" "${INCLUDE_DIRS[@]}"

echo "✅ Full server backup created."
echo "📁 Saved at: $ARCHIVE_PATH"

# Optional: delete full-server backups older than 30 days
find "$BACKUP_DIR" -type f -name "server_*.tar.gz" -mtime +30 -delete 2>/dev/null || true
echo "🧹 Old server backups (older than 30 days) cleaned."
