#!/bin/bash

SITE_NAME="$1"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BASE_DIR="/var/backups/sites/$SITE_NAME"
ARCHIVE="$BASE_DIR/${SITE_NAME}_${DATE}.tar.gz"

PROJECT_DIR="/var/www/$SITE_NAME"
ENV_FILE="/etc/webapp/$SITE_NAME.env"
NGINX_CONF="/etc/nginx/sites-available/$SITE_NAME.conf"

mkdir -p "$BASE_DIR"

echo "======================================"
echo "📦 Creating backup for site: $SITE_NAME"
echo "📅 Date: $DATE"
echo "======================================"

# Check project dir
if [ -d "$PROJECT_DIR" ]; then
    echo "→ Adding project directory: $PROJECT_DIR"
else
    echo "⚠ Project directory not found: $PROJECT_DIR"
fi

# Check env file
if [ -f "$ENV_FILE" ]; then
    echo "→ Adding env file: $ENV_FILE"
else
    echo "⚠ Env file not found: $ENV_FILE"
fi

# Check nginx config
if [ -f "$NGINX_CONF" ]; then
    echo "→ Adding nginx config: $NGINX_CONF"
else
    echo "⚠ Nginx config not found: $NGINX_CONF"
fi

# Create tar.gz in one shot
tar -czf "$ARCHIVE" \
    "$PROJECT_DIR" \
    "$ENV_FILE" \
    "$NGINX_CONF" 2>/dev/null

echo "✅ Backup completed: $ARCHIVE"
