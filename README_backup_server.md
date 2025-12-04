# backup-server Script

This script creates a **full backup of the entire server**, including configuration files, websites, user home directory, and essential system settings.

Backups are stored as compressed `.tar.gz` archives inside:

```
/var/backups/server/
```

---

## Features

- Backs up all critical server directories:
  - `/etc`
  - `/var/www` (all FastAPI apps)
  - `/etc/nginx`
  - `/etc/webapp`
  - `/home/tamer`
- Automatically names the backup using a timestamp.
- Automatically removes full-server backups older than **30 days**.
- Safe and lightweight — uses built‑in `tar` only.

---

## Usage

Create a full backup:

```bash
sudo backup-server
```

This will generate:

```
/var/backups/server/server_YYYY-MM-DD_HH-MM-SS.tar.gz
```

Example:

```
server_2025-12-04_03-37-55.tar.gz
```

---

## Installation

1. Create the script:

```bash
sudo nano /usr/local/bin/backup-server
```

2. Paste the script content.

3. Save and exit, then make it executable:

```bash
sudo chmod +x /usr/local/bin/backup-server
```

Now you can run it at any time with:

```bash
sudo backup-server
```

---

## What is included in the backup?

| Directory | Purpose |
|----------|----------|
| `/etc` | All system configurations |
| `/etc/nginx` | Webserver configs |
| `/etc/webapp` | Environment files for every FastAPI site |
| `/var/www` | All website project folders |
| `/home/tamer` | Your user files, scripts, tools |
| (optional) cron jobs | Included automatically via `/etc` |

---

## Automatic cleanup

The script deletes full-server backup archives older than **30 days**:

```bash
find /var/backups/server -type f -name "server_*.tar.gz" -mtime +30 -delete
```

This prevents backups from consuming too much disk space.

---

## Example Output

```
🖥  Creating FULL SERVER backup
📅 Date: 2025-12-04_03-37-55
======================================
✅ Full server backup created.
📁 Saved at: /var/backups/server/server_2025-12-04_03-37-55.tar.gz
🧹 Old server backups (older than 30 days) cleaned.
```

---

## Restore

To restore a full server backup, use:

```bash
sudo restore-server <backup_file>
```

---

## Safety Notes

- The archive may be large depending on your `/var/www` size.
- This script backs up **everything needed** to rebuild the server from scratch.

