# User Documentation – Inception Project

This document explains how an administrator or end user can work with the Inception infrastructure.

## Services Provided
The stack runs the following services, each in its own Docker container:

| Service       | Purpose                                                      |
|---------------|--------------------------------------------------------------|
| **NGINX**     | HTTPS reverse proxy – the only public entry point (port 443) |
| **WordPress** | The content management system (PHP-FPM, no own web server)   |
| **MariaDB**   | Database for WordPress                                       |
| **Redis**     | In‑memory cache to speed up WordPress (bonus)                |
| **FTP server**| vsftpd – provides file access to the WordPress website files |
| **Adminer**   | Web‑based database manager (bonus)                           |
| **Uptime Kuma** | Monitoring tool for the stack (bonus)                       |
| **Static page** | A simple resume/portfolio site (bonus)                     |

All services are containerized and connected through Docker networks.

## Starting and Stopping the Project
Use the `Makefile` at the root of the repository.

- **Start everything for the first time (build + run):**
  ```
  make
  ```
  or
  ```
  make up
  ```
  This builds the Docker images and starts all containers. The first run may take a minute while the database and WordPress are initialized.

- **Start previously stopped containers:**
  ```
  make start
  ```

- **Stop all running containers:**
  ```
  make stop
  ```

- **Stop and remove containers (volumes preserved):**
  ```
  make down
  ```

- **Full cleanup (containers, volumes, images, data folders):**
  ```
  make fclean
  ```

> **Note:** The data folders `/home/znajdaou/data/wordpress_data` and `/home/znajdaou/data/mariadb_data` are created automatically by `make up`. They persist even after `make down`. Use `make fclean` only if you want to delete all data.

## Accessing the Website and Administration Panel

### WordPress
- **Website:** [https://znajdaou.42.fr](https://znajdaou.42.fr)  
  (accept the self‑signed certificate warning)
- **Administrator login:**
  - Username: `superuser`
  - Password: stored in `secrets/db_root_password.txt` (see below)

- **Second user (Author role):**
  - Username: `znajdaou`
  - Password: stored in `secrets/db_password.txt`

You can manage WordPress (write posts, install themes, etc.) from the admin panel at:
`https://znajdaou.42.fr/wp-admin`

### Adminer (Database Manager)
- **URL:** [https://adminer.znajdaou.42.fr](https://adminer.znajdaou.42.fr)
- **Connection details:**
  - System: MySQL
  - Server: `mariadb`
  - Username: `znajdaou`
  - Password: stored in `secrets/db_password.txt`

### Uptime Kuma (Monitoring)
- **URL:** [https://kuma.znajdaou.42.fr](https://kuma.znajdaou.42.fr)
  On first visit you will be prompted to create an admin account.

### Static Website
- **URL:** [https://static.znajdaou.42.fr](https://static.znajdaou.42.fr)  
  Displays a personal resume page.

### FTP Server
- **Host:** `znajdaou.42.fr`
- **Port:** 21 (passive ports 30000–30009)
- **Username:** `ftpuser`
- **Password:** stored in `secrets/ftp_password.txt`
- The FTP server points directly to the WordPress website files (the `/var/www/html` volume). Use it to upload or manage files.

## Credentials – Where to Find and Manage Them

All passwords are stored in the `secrets/` directory (outside the `srcs/` folder):

| File                       | Purpose                                    |
|----------------------------|--------------------------------------------|
| `secrets/db_root_password.txt`  | MariaDB root password, WordPress admin password |
| `secrets/db_password.txt`       | MariaDB user password, second WordPress user password |
| `secrets/ftp_password.txt`      | FTP server password                         |
| `secrets/kuma_db_password.txt`  | Database password for Uptime Kuma           |

### Changing Credentials
1. Edit the corresponding file (e.g., `db_password.txt`).
2. Run `make re` to fully rebuild the project with the new passwords.  
   ⚠️ **Important:** Changing passwords after the database has been initialized will break existing WordPress logins unless you also update the database. For a fresh start, use `make fclean` first.

> **Security note:** These files are **not** pushed to the Git repository (they are ignored via `.gitignore`). They are mounted into containers as Docker secrets, never appearing in Dockerfiles or environment variables directly.

## Checking That Services Are Running Correctly

### Quick Check (Docker)
```
docker ps
```
All containers should show `Up` status. The important ones are `nginx`, `wordpress`, `mariadb`, `redis`, `adminer`, `uptime_kuma`, `ftp_server`, and `static_page`.

### View Logs
```
docker logs nginx
docker logs wordpress
docker logs mariadb
```
Replace with other container names as needed. Use `docker logs -f <name>` to follow the log output.

### Test Web Services
- Open the WordPress site in a browser. If it loads and you can log in, the stack is healthy.
- Use `curl` on the server:
  ```
  curl -k https://znajdaou.42.fr
  ```
  (the `-k` flag ignores the self‑signed certificate)
- Check Adminer or Uptime Kuma in the browser similarly.

### Inside Containers
You can also check internal processes:
```
docker exec mariadb mysqladmin -u root -p<password> status
```
(but normally Docker’s health checks handle this automatically – failing containers are restarted).

## Additional Notes
- The infrastructure uses **only HTTPS** (TLS 1.2/1.3). All HTTP traffic is forwarded or rejected.
- Containers are configured to **restart automatically** if they crash.
- The data directories on the host are located at `/home/znajdaou/data/`. Backup these directories to preserve your database and website files.
- If you need to add custom domains, modify the `.env` file and the `/etc/hosts` file, then rebuild.

For further technical details, refer to the `README.md` or the developer documentation (`DEV_DOC.md`).