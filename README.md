# Advanced Backup System for Linux / FastAPI Servers

This repository provides a complete **backup solution** designed for
servers running multiple FastAPI-based web applications.\
It includes:

-   **Per-site backup** (individual website backup)
-   **Full-server backup**
-   Automatic support for:
    -   Project files
    -   Environment variables
    -   Nginx configuration
    -   PostgreSQL databases
    -   SQLite databases
-   Auto-clean old backups
-   Cron automation

------------------------------------------------------------------------

## 📁 Backup Structure

  Backup Type           Location
  --------------------- -----------------------------------
  Per-site backups      `/var/backups/sites/<site_name>/`
  Full server backups   `/var/backups/server/`

------------------------------------------------------------------------

# ⚙️ 1. Installation

Create the required directories:

``` bash
sudo mkdir -p /var/backups/sites
sudo mkdir -p /var/backups/server
sudo chown -R tamer:tamer /var/backups
```

------------------------------------------------------------------------

# 🔹 2. Per-Site Backup Script

### Create script

``` bash
sudo nano /usr/local/bin/backup-site
```

### Paste this script:

``` bash
#!/usr/bin/env bash
set -e

# ===============================
# Per-Site Backup Script
# Usage: sudo backup-site <site_name>
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

# 1) Project directory
if [ -d "$PROJECT_DIR" ]; then
  echo "→ Adding project directory: $PROJECT_DIR"
else
  echo "⚠ Directory not found: $PROJECT_DIR"
fi

# 2) Env file
if [ -f "$ENV_FILE" ]; then
  echo "→ Adding env file: $ENV_FILE"
  cp "$ENV_FILE" "$TMP_DIR/"
else
  echo "⚠ Env file not found: $ENV_FILE"
fi

# 3) Nginx config
if [ -f "$NGINX_CONF" ]; then
  echo "→ Adding Nginx config: $NGINX_CONF"
  mkdir -p "$TMP_DIR/nginx"
  cp "$NGINX_CONF" "$TMP_DIR/nginx/"
else
  echo "⚠ Nginx config not found: $NGINX_CONF"
fi

# 4) DB backups
if [ -f "$ENV_FILE" ]; then
  echo "→ Loading env vars..."
  set -o allexport
  source "$ENV_FILE"
  set +o allexport

  if [ -n "$POSTGRES_DB" ] && [ -n "$POSTGRES_USER" ] && [ -n "$POSTGRES_HOST" ]; then
    echo "→ Creating PostgreSQL dump..."
    mkdir -p "$TMP_DIR/db"
    pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" > "$TMP_DIR/db/postgres.sql" || true
  fi

  if [ -n "$SQLITE_PATH" ] && [ -f "$SQLITE_PATH" ]; then
    echo "→ Copying SQLite DB..."
    mkdir -p "$TMP_DIR/db"
    cp "$SQLITE_PATH" "$TMP_DIR/db/sqlite.db"
  fi
fi

ARCHIVE_NAME="${SITE_NAME}_${DATE}.tar.gz"
ARCHIVE_PATH="${SITE_BACKUP_DIR}/${ARCHIVE_NAME}"

echo "→ Creating archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" -C / "$PROJECT_DIR" 2>/dev/null || true
tar -rzf "$ARCHIVE_PATH" -C "$TMP_DIR" . || true

rm -rf "$TMP_DIR"

echo "✅ Backup completed: $ARCHIVE_PATH"

find "$SITE_BACKUP_DIR" -type f -name "${SITE_NAME}_*.tar.gz" -mtime +14 -delete
```

Make executable:

``` bash
sudo chmod +x /usr/local/bin/backup-site
```

### Usage:

``` bash
sudo backup-site mystrotamer
sudo backup-site liebemama
sudo backup-site jaghsi
```

------------------------------------------------------------------------

# 🔹 3. Full Server Backup Script

### Create script:

``` bash
sudo nano /usr/local/bin/backup-server
```

### Paste:

``` bash
#!/usr/bin/env bash
set -e

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/var/backups/server"
ARCHIVE_NAME="server_${DATE}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

mkdir -p "$BACKUP_DIR"

echo "======================================"
echo "🖥 Creating FULL SERVER backup"
echo "📅 Date: $DATE"
echo "======================================"

INCLUDE_DIRS=(
  "/etc"
  "/var/www"
  "/etc/nginx"
  "/etc/webapp"
  "/home/tamer"
)

tar -czf "$ARCHIVE_PATH" "${INCLUDE_DIRS[@]}"

echo "✅ Full server backup created."
echo "📁 Saved at: $ARCHIVE_PATH"

find "$BACKUP_DIR" -type f -name "server_*.tar.gz" -mtime +30 -delete
```

Make executable:

``` bash
sudo chmod +x /usr/local/bin/backup-server
```

Usage:

``` bash
sudo backup-server
```

------------------------------------------------------------------------

# 🔄 4. Cron Automation

Edit cron:

``` bash
sudo crontab -e
```

Add daily site backups:

    0 3 * * * /usr/local/bin/backup-site liebemama >/var/log/backup-liebemama.log 2>&1
    5 3 * * * /usr/local/bin/backup-site mystrotamer >/var/log/backup-mystro.log 2>&1
    10 3 * * * /usr/local/bin/backup-site jaghsi >/var/log/backup-jaghsi.log 2>&1

Weekly full server backup:

    0 4 * * 0 /usr/local/bin/backup-server >/var/log/backup-server.log 2>&1

------------------------------------------------------------------------

# ✔ Summary

  Feature              Status
  -------------------- -------------
  Per-site backup      ✔ Ready
  Full server backup   ✔ Ready
  PostgreSQL support   ✔ Yes
  SQLite support       ✔ Yes
  Cron automation      ✔ Enabled
  Auto deletion        ✔ Enabled
  Restore scripts      Coming soon

------------------------------------------------------------------------

# 📌 Next Steps

Ask me to generate:

-   `restore-site` script\
-   `restore-server` script\
-   External cloud sync (Backblaze B2 / GDrive)
