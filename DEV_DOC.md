# Developer Documentation – Inception Project

This document explains how a developer can set up, build, and manage the Inception project from scratch.

## Prerequisites

- A Linux environment (virtual machine or bare metal) with **sudo** access.
- **Docker Engine** (version 24+ recommended) and **Docker Compose** (v2 or plugin).  
  Install instructions: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)  
- **make** (GNU Make).
- **git** (to clone the repository).
- The domain names must be resolved. Add the following lines to `/etc/hosts`:
  ```
  127.0.0.1   znajdaou.42.fr
  127.0.0.1   kuma.znajdaou.42.fr
  127.0.0.1   adminer.znajdaou.42.fr
  127.0.0.1   static.znajdaou.42.fr
  ```
  Replace `127.0.0.1` with your VM's local IP if you are accessing the services from another machine.

## Environment Setup

### 1. Clone and navigate
```bash
git clone <repository-url> inception
cd inception
```

### 2. Configuration files
All runtime parameters are in `srcs/.env`. Review and edit if needed (defaults work for local testing).  
The file contains:
- Database names, usernames, and the paths to password files (inside containers).
- WordPress admin user details.
- Domain name and host paths.
- Redis host, FTP home directory, and Uptime Kuma settings.

**Important:** The `USERNAME` variable in `.env` must match your system user (`znajdaou` by default) because the volume mount paths are `/home/$USERNAME/data/...`. If your username differs, change it accordingly.

### 3. Secrets (passwords)
Passwords are stored in plain‑text files inside the `secrets/` directory. These files are **not** committed to Git (they should be in `.gitignore`). The project expects the following files:

| File                       | Content example |
|----------------------------|-----------------|
| `secrets/db_root_password.txt` | `root123`       |
| `secrets/db_password.txt`       | `user123`       |
| `secrets/ftp_password.txt`      | `ftp123`        |
| `secrets/kuma_db_password.txt`  | `kuma123`       |

**Create them before the first build:**
```bash
mkdir -p secrets
echo "root123" > secrets/db_root_password.txt
echo "user123" > secrets/db_password.txt
echo "ftp123" > secrets/ftp_password.txt
echo "kuma123" > secrets/kuma_db_password.txt
```
(Use your own strong passwords.)

These files are mounted as Docker secrets into the containers at `/run/secrets/<name>`. Never hardcode passwords in Dockerfiles or environment files.

### 4. Required directories
The Makefile’s `prepare` target automatically creates the host directories for volumes:
```bash
/home/znajdaou/data/wordpress_data
/home/znajdaou/data/mariadb_data
```
Ensure your user has write permissions on `/home/znajdaou/data` (or whatever `$USERNAME` resolves to). If the path differs, adjust the `USERNAME` variable in `.env`.

## Build and Launch

The entire project is controlled by the **Makefile** at the repository root.

### First build
```bash
make up
```
This will:
- Run `prepare` (creates data directories).
- Execute `docker compose -f srcs/docker-compose.yml up --build`.
- Build all Docker images (mariadb, nginx, wordpress, and bonus services).
- Start all containers.

If you only want to build without running:
```bash
docker compose -f srcs/docker-compose.yml build
```

### Other useful targets
| Command        | Action |
|----------------|--------|
| `make start`   | Start all stopped containers (no rebuild) |
| `make stop`    | Stop all running containers |
| `make down`    | Stop and remove containers (preserves volumes and data directories) |
| `make clean`   | `docker compose down -v` – also removes anonymous volumes but **not** the named volumes (data persists) |
| `make fclean`  | Stop, remove containers, networks, and **all volumes**, and delete data directories (`/home/znajdaou/data/wordpress_data` and `mariadb_data`). This wipes everything. |
| `make restart` | stop + start |
| `make re`      | fclean + up (complete rebuild from scratch) |
| `make rebuild` | down + up (rebuild without deleting volumes) |

> **Note:** `make clean` only runs `docker compose down -v`; it does **not** remove the host data folders. Those must be manually deleted or use `make fclean`.

### Checking status
```bash
docker ps -a
docker compose -f srcs/docker-compose.yml logs -f
```

## Managing Containers and Volumes

### Containers
All containers are defined in `srcs/docker-compose.yml`. You can interact with individual containers using standard Docker commands:

```bash
# View logs
docker logs nginx
docker logs wordpress

# Access a shell inside a container
docker exec -it mariadb bash

# Restart a single service
docker compose -f srcs/docker-compose.yml restart wordpress
```

Health checks are defined for WordPress (checking for `wp-config.php`). The `depends_on` condition ensures services start in the correct order.

### Volumes
Two named volumes are used for persistent storage:
- `mariadb_data` → mounted at `/var/lib/mysql` in the `mariadb` container.
- `wordpress_data` → mounted at `/var/www/html` in both `wordpress` and `nginx` containers.

Both volumes are **local driver with bind options**, pointing to:
- `/home/znajdaou/data/mariadb_data`
- `/home/znajdaou/data/wordpress_data`

This means the data lives directly on the host filesystem, not inside Docker’s internal volume directory. As a developer, you can inspect, backup, or restore these folders directly.

To see volume details:
```bash
docker volume ls
docker volume inspect srcs_mariadb_data
```

To backup a volume:
```bash
sudo tar -czf backup-wordpress.tar.gz /home/znajdaou/data/wordpress_data
```

### Networks
Two Docker networks are created:
- `wp_network` (internal bridge) – used by mariadb, wordpress, nginx, redis, adminer, uptime_kuma, static_page. No outbound internet access except what you allow.
- `bridge` – connects nginx and ftp_server, allowing the FTP server to accept external connections while still being linked to the WordPress volume.

Containers can resolve each other by service name (e.g., `mariadb`, `redis`).

## Data Persistence

- **Database files:** stored in `/home/znajdaou/data/mariadb_data`. If you delete this folder, the WordPress database is lost. The MariaDB initialisation script (`init.sh`) will recreate the database when the container starts **only if the data directory is empty**. So after a data loss, a simple `make down && make up` will re‑initialise a fresh database and WordPress installation.

- **WordPress files:** stored in `/home/znajdaou/data/wordpress_data`. This includes plugins, themes, uploads, and `wp-config.php`. As long as this folder persists, your WordPress site state remains intact across container restarts or rebuilds.

The `make fclean` target removes these directories **irreversibly**. Use it only when you want a completely blank state.

## Additional Developer Notes

### Customising the Stack
- **Adding new services:** create a new folder under `srcs/requirements/bonus/` with a `Dockerfile`, any required config, and add the service definition to `docker-compose.yml`. Make sure to attach it to the appropriate network.
- **Changing PHP version:** update the PHP packages in `srcs/requirements/wordpress/Dockerfile` and adjust the socket configuration accordingly.
- **TLS certificates:** Currently a self‑signed certificate is generated inside the NGINX container at startup. For production, you might mount a real certificate using Docker secrets or a bind mount.

### Debugging
- View real‑time logs: `docker compose -f srcs/docker-compose.yml logs -f`
- Enter a running container: `docker exec -it <container_name> bash`
- If WordPress cannot connect to the database, check that `WP_DB_HOST` in `.env` matches the service name (`mariadb`) and that the MariaDB container is running.
- For permission issues on the host data folders, ensure the folders are owned by the user running Docker (or set appropriate permissions).

### AI Tools and Automation
During development, AI assistants were used to debugging configuration syntax, and generating initial documentation drafts. Every AI‑generated piece was reviewed, tested manually, and understood before integration.

---

For an overview of the project and its design choices, refer to `README.md`.  
For end‑user instructions, see `USER_DOC.md`.