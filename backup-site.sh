#!/usr/bin/env bash
set -e

# ===============================
# Per-Site Backup Script
# Usage: sudo backup-site <site_name>
# Example: sudo backup-site liebemama
# ===============================

SITE_NAME="$1"

if [ -z "$SITE_NAME" ]; then
  echo "Usage: sudo backup-site <site_name>"
  exit 1
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_ROOT="/var/backups/sites"
SITE_BACKUP_DIR="$BACKUP_ROOT/$SITE_NAME"
TMP_DIR="/tmp/backup-${SITE_NAME}-${DATE}"

PROJECT_DIR="/var/www/$SITE_NAME"
ENV_FILE="/etc/webapp/${SITE_NAME}.env"
NGINX_CONF="/etc/nginx/sites-available/${SITE_NAME}.conf"

mkdir -p "$SITE_BACKUP_DIR"
mkdir -p "$TMP_DIR"

echo "======================================"
echo "📦 Creating backup for site: $SITE_NAME"
echo "📅 Date: $DATE"
echo "======================================"

# 1) Copy project files
if [ -d "$PROJECT_DIR" ]; then
  echo "→ Adding project directory: $PROJECT_DIR"
else
  echo "⚠ Warning: Project directory not found: $PROJECT_DIR"
fi

# 2) Copy env file
if [ -f "$ENV_FILE" ]; then
  echo "→ Adding env file: $ENV_FILE"
  cp "$ENV_FILE" "$TMP_DIR/"
else
  echo "⚠ Warning: Env file not found: $ENV_FILE"
fi

# 3) Copy Nginx config
if [ -f "$NGINX_CONF" ]; then
  echo "→ Adding Nginx config: $NGINX_CONF"
  mkdir -p "$TMP_DIR/nginx"
  cp "$NGINX_CONF" "$TMP_DIR/nginx/"
else
  echo "⚠ Warning: Nginx config not found: $NGINX_CONF"
fi

# 4) Optional: Database backup using env variables
# If you set POSTGRES_HOST, POSTGRES_DB, POSTGRES_USER, PGPASSWORD in the env file,
# the script will create a postgres.sql dump.
if [ -f "$ENV_FILE" ]; then
  echo "→ Loading env vars from $ENV_FILE for DB backup (if configured)..."
  set -o allexport
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +o allexport

  # PostgreSQL
  if [ -n "$POSTGRES_DB" ] && [ -n "$POSTGRES_USER" ] && [ -n "$POSTGRES_HOST" ]; then
    echo "→ Detected PostgreSQL config, creating dump..."
    mkdir -p "$TMP_DIR/db"
    pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" > "$TMP_DIR/db/postgres.sql" || {
      echo "⚠ PostgreSQL dump failed. Check credentials / PGPASSWORD."
    }
  fi

  # SQLite (if you have SQLITE_PATH in env)
  if [ -n "$SQLITE_PATH" ] && [ -f "$SQLITE_PATH" ]; then
    echo "→ Detected SQLite DB at $SQLITE_PATH, copying..."
    mkdir -p "$TMP_DIR/db"
    cp "$SQLITE_PATH" "$TMP_DIR/db/sqlite.db"
  fi
fi

# 5) Create final tar.gz archive
ARCHIVE_NAME="${SITE_NAME}_${DATE}.tar.gz"
ARCHIVE_PATH="${SITE_BACKUP_DIR}/${ARCHIVE_NAME}"

echo "→ Creating archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" \
  -C / "$PROJECT_DIR" 2>/dev/null || true

tar -rzf "$ARCHIVE_PATH" \
  -C "$TMP_DIR" . 2>/dev/null || true

# 6) Cleanup temp directory
rm -rf "$TMP_DIR"

echo "✅ Backup completed for site: $SITE_NAME"
echo "📁 Saved at: $ARCHIVE_PATH"

# 7) Optional: delete backups older than 14 days
find "$SITE_BACKUP_DIR" -type f -name "${SITE_NAME}_*.tar.gz" -mtime +14 -delete 2>/dev/null || true
echo "🧹 Old backups (older than 14 days) cleaned."
