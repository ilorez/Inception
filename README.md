*This project has been created as part of the 42 curriculum by znajdaou.*

# Inception

## Description
Inception is a system administration project that introduces Docker and container orchestration. The goal is to set up a small multi‑service infrastructure using Docker Compose, with each service running in its own container. The mandatory stack includes:

- **NGINX** as the only entry point (TLSv1.2/1.3, port 443)  
- **WordPress** with php-fpm (without its own web server)  
- **MariaDB** for the database  
- Two persistent **Docker named volumes** (database and website files), stored in `/home/<login>/data`  
- A custom **Docker network** linking the containers  

Bonus services were added to extend the infrastructure:  
- **Redis** object cache for WordPress  
- **FTP server** (vsftpd) pointing to the WordPress volume  
- **Static website** (a personal resume served by a custom C++ web server)  
- **Adminer** (database management via web UI)  
- **Uptime Kuma** (monitoring)

All images are built from Debian Bullseye using hand‑written Dockerfiles; no pre‑built images are pulled (except the base Debian). Secrets (passwords, credentials) are handled via Docker secrets and a `.env` file – nothing sensitive appears in the Dockerfiles or in the repository.

## Project Structure
```
.
├── Makefile
├── secrets/            # Sensitive files (ignored by Git)
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── ftp_password.txt
│   └── kuma_db_password.txt
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       ├── wordpress/
│       └── bonus/
│           ├── redis/
│           ├── ftp_server/
│           ├── static_page/
│           ├── adminer/
│           └── uptime_kuma/
```

## Design Choices
- **Base image:** Debian Bullseye (stable, lightweight).  
- **PHP:** Installed from `packages.sury.org` to get the required PHP 8.4 and its extensions.  
- **TLS:** Self‑signed certificate generated on first run inside the NGINX container.  
- **Database initialisation:** A custom script creates the WordPress database, two users (admin + normal), and secures the root account.  
- **Secrets:** Passwords are provided via Docker secrets (files mounted at `/run/secrets/`), never hard‑coded.  
- **Network separation:** The WordPress database and cache communicate on an internal `wp_network`; the FTP server and NGINX are on a separate bridge to control exposure.

## Comparisons (as required by the subject)

### Virtual Machines vs Docker
- **VM** virtualises an entire operating system (kernel + user space) and is resource‑heavy.  
- **Docker** containers share the host kernel, starting in seconds and using far less RAM/disk. Containers are isolated but not full OS instances.

### Secrets vs Environment Variables
- **Environment variables** can be leaked easily (e.g., in logs, `docker inspect`).  
- **Docker secrets** are mounted as read‑only files inside the container, are encrypted during transit, and are only visible to the service that needs them.

### Docker Network vs Host Network
- **Docker network** (bridge) provides isolation between containers and from the host. Containers communicate via service names, and ports are only exposed when explicitly mapped.  
- **Host network** removes network isolation; the container shares the host’s network stack, which can cause port conflicts and reduces security.

### Docker Volumes vs Bind Mounts
- **Named volumes** are managed by Docker and are portable. They can be backed up, and their data location is controlled by driver options.  
- **Bind mounts** directly link a host path to a container path. They are simpler but can cause permission issues and are tied to the host’s filesystem structure.

## Instructions

### Prerequisites
- A Linux virtual machine (or bare‑metal Linux) with **Docker**, **Docker Compose**, and **make** installed.  
- The domain `znajdaou.42.fr` (and optionally the bonus subdomains) must point to your local IP. Add to `/etc/hosts`:
  ```
  127.0.0.1   znajdaou.42.fr
  127.0.0.1   kuma.znajdaou.42.fr
  127.0.0.1   adminer.znajdaou.42.fr
  127.0.0.1   static.znajdaou.42.fr
  ```

### Build & Run
1. Clone the repository.
2. (Optional) Edit the password files inside `secrets/` if you want different credentials.
3. Run `make` (or `make up`).  
   This will:
   - Create the data directories `/home/znajdaou/data/wordpress_data` and `/home/znajdaou/data/mariadb_data`.
   - Build all Docker images and start the containers.
4. Wait a few seconds for the database and WordPress initialisation to complete.

### Accessing Services
- **WordPress:** `https://znajdaou.42.fr` (admin: `superuser` / password from `secrets/db_root_password.txt`; normal user: `znajdaou` / password from `secrets/db_password.txt`).  
- **Adminer:** `https://adminer.znajdaou.42.fr` (connect to `mariadb` server with credentials above).  
- **Uptime Kuma:** `https://kuma.znajdaou.42.fr` (first visit asks for an admin account).  
- **Static site:** `https://static.znajdaou.42.fr` (resume page).  
- **FTP:** connect to `ftp://znajdaou.42.fr` with user `ftpuser` and password from `secrets/ftp_password.txt`. Port 21 and passive ports 30000‑30009.

> **Note:** The TLS certificate is self‑signed – accept the browser warning.

### Makefile Targets
| Command          | Action |
|------------------|--------|
| `make` / `make up` | Build and start everything |
| `make start`     | Start stopped containers |
| `make stop`      | Stop containers |
| `make down`      | Stop and remove containers |
| `make clean`     | Remove containers + volumes |
| `make fclean`    | Remove containers, volumes, and images |
| `make re`        | Full rebuild from scratch |
| `make rebuild` | Rebuild images without removing volumes |
| `make logs` | Show logs of all containers |

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/)
- [WordPress Hosting Handbook](https://make.wordpress.org/hosting/handbook/server-environment/)
- [WP‑CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Official Documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX Beginner’s Guide](https://nginx.org/en/docs/beginners_guide.html)
- [PHP‑FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
- [Redis Documentation](https://redis.io/docs/)
- [vsftpd Community Help](https://help.ubuntu.com/community/vsftpd)
- [Uptime Kuma GitHub](https://github.com/louislam/uptime-kuma)
- Tutorial / reference used during development: [Docker NGINX WordPress MariaDB (dev.to)](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)

## AI Usage

AI was used as a learning assistant throughout the project.

It helped with:

* understanding Docker concepts
* debugging Docker Compose issues
* learning networking
* understanding Docker Secrets
* reviewing Bash scripts
* improving project documentation
* explaining MariaDB initialization
* explaining WordPress configuration
* comparing Docker concepts

All implementation decisions, debugging, testing, and final code were completed manually.

## License

This project was developed as part of the **42 Network** curriculum for educational purposes.