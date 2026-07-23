*This project has been created as part of the 42 curriculum by znajdaou.*

# Inception

## Description

Inception is a System Administration project from the 42 core curriculum. The goal is to build a small, containerized infrastructure with Docker Compose: every service runs in its own container, built from a custom Dockerfile — no pre-built service images, no `latest` tags — and the whole stack comes up with a single command.

The infrastructure serves a WordPress site backed by a MariaDB database, exposed over HTTPS through an NGINX reverse proxy, the only container reachable from outside. Passwords never live in the images, the compose file, or version control — they're injected through Docker secrets — and both the WordPress files and the database are persisted on the host so no data is lost when a container restarts.

## Instructions

### Prerequisites
- Docker Engine and the Docker Compose plugin
- `make`
- Developed and evaluated inside a Debian 12 VM, as required by the subject — any Linux host with Docker works the same way

### Setup
1. Clone the repository.
2. Copy `srcs/.env.example` to `srcs/.env` and fill in the non-sensitive values (domain, DB name/user, WordPress site title, admin email, etc.).
3. Create the secret files expected under `secrets/` — one value per file, plain text, no trailing newline (`db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt`).
4. Add the domain to your hosts file: `127.0.0.1  znajdaou.42.fr` in `/etc/hosts`.

### Build and run
```
make
```
This builds every image and starts the stack in the background. Then visit:
```
https://znajdaou.42.fr
```

### Stop and clean up
- `make down` — stop and remove the containers
- `make clean` — `down`, plus remove the built images and the Docker network
- `make fclean` — full clean, also wipes the persisted data under `~/data`
- `make re` — `fclean` followed by a full rebuild
- `make restart` — stop and start the stack again, without rebuilding
- `make clean_volumes` — remove the persisted data under `~/data` without touching the containers or images
- `make start` — start the stack again after a `make stop`
- `make stop` — stop the stack without removing the containers

## Architecture & Design Choices

All the infrastructure lives under `srcs/`: a `docker-compose.yml` and one subfolder per service under `srcs/requirements/` (`nginx/`, `wordpress/`, `mariadb/`), each with its own `Dockerfile`, config files, and entrypoint script. Every image is built from scratch — no pre-built service images and no `latest` tag anywhere — and each container runs a single foreground process, restarting automatically if it crashes.

Main design choices:
- NGINX is the only container exposed to the host, on port 443, TLSv1.2/1.3 only — the single entry point to the whole stack.
- WordPress runs as PHP-FPM only, with no bundled web server; NGINX proxies PHP requests to it over the internal Docker network.
- WordPress's install and configuration (database connection, admin account, site URL) are automated with WP-CLI in the entrypoint, so the site is ready as soon as the stack starts — no manual setup wizard.
- MariaDB only initializes the database on first boot; on every later start it detects the existing data and skips straight to serving it.

### Virtual Machines vs Docker
A VM virtualizes a whole machine — its own kernel, drivers, OS — through a hypervisor: fully isolated, but heavy, with a boot time measured in minutes and gigabytes of overhead per instance. A Docker container shares the host's kernel and only packages the application and its dependencies, so it starts in milliseconds and uses a fraction of the resources. That's why this project runs NGINX, WordPress, and MariaDB as three containers rather than three VMs: they need to be isolated from each other, not isolated from the hardware.

### Secrets vs Environment Variables
Environment variables set in `docker-compose.yml` or `.env` are readable by anyone with access to `docker inspect`, the container's process list, or the compose file itself — fine for non-sensitive config like a domain name, not for passwords. Docker secrets are instead mounted as files under `/run/secrets/` inside the container, held only in memory, and never show up in `docker inspect` or an image layer. This project keeps the database root/user passwords and the WordPress admin password as secrets, and everything else — domain, DB name, WordPress title — as plain environment variables.

### Docker Network vs Host Network
Host networking drops a container straight onto the host's own network stack: no isolation, and every port the container opens is a port opened on the host. This project instead defines its own bridge network in `docker-compose.yml`. Containers reach each other by service name over an internal DNS — `wordpress` resolves to the WordPress container from inside the network — and only NGINX's port 443 is actually published to the host. MariaDB and PHP-FPM are never reachable from outside the Docker network.

### Docker Volumes vs Bind Mounts
A named Docker volume is created and managed by Docker itself, typically under `/var/lib/docker/volumes/`. A bind mount instead maps a specific, known folder on the host straight into the container. This project uses bind mounts — `~/data/wordpress` and `~/data/mariadb` — so the data sits in a predictable, inspectable location on the host rather than wherever Docker decides to put a volume, while behaving the same way otherwise: it survives `docker compose down` and container recreation, and disappears only if that folder is deleted.

## Resources

### Documentation & tutorials
- [PHP packages — Sury APT repository](https://packages.sury.org/php/)
- [WordPress Hosting Handbook — Server Environment](https://make.wordpress.org/hosting/handbook/server-environment/)
- [Docker NGINX + WordPress + MariaDB Tutorial (Inception42) — DEV Community](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
- [WP-CLI — Installation guide](https://make.wordpress.org/cli/handbook/guides/installing/)
- [WP-CLI — `wp core install`](https://developer.wordpress.org/cli/commands/core/install/)
- [WP-CLI — `wp config`](https://developer.wordpress.org/cli/commands/config/)
- [Inception walkthrough (YouTube)](https://www.youtube.com/watch?v=PrusdhS2lmo&t=25492s)

### AI usage
- **Documentation** — Claude (Anthropic) helped draft and structure this README, `USER_DOC.md`, and `DEV_DOC.md`.
