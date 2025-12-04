# backup-site Script

This script creates a complete backup of a specific FastAPI site, including:

- The website project folder (`/var/www/<site>`)
- The site's environment variables file (`/etc/webapp/<site>.env`)
- The Nginx configuration file (`/etc/nginx/sites-available/<site>.conf`)

The backup is stored as a timestamped `.tar.gz` file inside:

```
/var/backups/sites/<site>/
```

---

## Features

- Automatically creates a backup directory for each site.
- Stores backups with full timestamps:
  - Example: `mystrotamer_2025-12-04_03-22-15.tar.gz`
- Bundles all important components into **one archive**.
- Warns if any expected files or directories are missing.
- Works for any site managed under the standard FastAPI hosting system.

---

## Usage

Run the script:

```bash
sudo backup-site <site_name>
```

Example:

```bash
sudo backup-site mystrotamer
```

The generated file will be located here:

```
/var/backups/sites/mystrotamer/mystrotamer_YYYY-MM-DD_HH-MM-SS.tar.gz
```

---

## Installation

Create the script:

```bash
sudo nano /usr/local/bin/backup-site
```

Paste the script content.

Make it executable:

```bash
sudo chmod +x /usr/local/bin/backup-site
```

---

## What gets backed up?

| Path | Description |
|------|-------------|
| `/var/www/<site>` | Full project directory |
| `/etc/webapp/<site>.env` | Environment variables for the app |
| `/etc/nginx/sites-available/<site>.conf` | Full Nginx reverse-proxy configuration |

---

## Backup Storage Path

Backups are saved under:

```
/var/backups/sites/<site>/
```

You can list all backups:

```bash
ls -lh /var/backups/sites/<site>
```

---

## Example Output

```
📦 Creating backup for site: mystrotamer
📅 Date: 2025-12-04_03-22-15
→ Adding project directory: /var/www/mystrotamer
→ Adding env file: /etc/webapp/mystrotamer.env
→ Adding nginx config: /etc/nginx/sites-available/mystrotamer.conf
✅ Backup completed: /var/backups/sites/mystrotamer/mystrotamer_2025-12-04_03-22-15.tar.gz
```

---

## Restore

The backup archive can be restored using the `restore-site` script:

```bash
sudo restore-site <site_name> <backup_file>
```

---

## Notes

- Make sure each site has a correct Nginx `.conf` file; otherwise, it will be skipped.
- If a site does not have an environment file, the script will continue but notify you.

