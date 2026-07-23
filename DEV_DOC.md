# Developer Documentation

This document explains how to set up, build, and maintain the project as a developer.

## Setting up the environment from scratch

**Prerequisites:** Docker Engine, the Docker Compose plugin, and `make`. The subject requires developing inside a Debian 12 VM; any Debian-based Linux host with Docker works the same way.

1. Clone the repository.
2. Copy `srcs/.env.example` to `srcs/.env` and fill in the non-sensitive configuration: domain name, database name/user, WordPress site title, admin email, etc. Nothing secret goes in this file.
3. Create the secret files under `secrets/`, one value per file, plain text, no trailing newline: `db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt`. This folder is gitignored.
4. Point the project domain at your machine: add `127.0.0.1  <login>.42.fr` to `/etc/hosts`.

> Tip: on a school machine with a tight home-directory quota, point Docker's data-root at `goinfre` before building — otherwise image builds can fail on disk space.

## Building and launching with the Makefile / Docker Compose

| Command | What it does |
|---|---|
| `make` / `make up` | Builds every image and starts the stack (`docker compose -f srcs/docker-compose.yml up -d --build`) |
| `make down` | Stops and removes the containers |
| `make clean` | `down`, plus removes the built images and the Docker network |
| `make fclean` | `clean`, plus wipes the persisted data under `~/data` |
| `make re` | `fclean` followed by `make` — a full rebuild from scratch |

## Managing containers and volumes

- `docker compose -f srcs/docker-compose.yml ps` — status of every service
- `docker compose -f srcs/docker-compose.yml logs -f <service>` — follow one service's logs
- `docker compose -f srcs/docker-compose.yml exec <service> sh` — shell into a running container
- `docker compose -f srcs/docker-compose.yml restart <service>` — restart a single service without touching the others
- `docker volume ls` / `docker network ls` — inspect what Compose created
- `docker system df` — check how much disk space images and volumes are using

## Where project data is stored and how it persists

- WordPress files: bind-mounted from `~/data/wordpress` on the host to `/var/www/html` in the container.
- MariaDB data: bind-mounted from `~/data/mariadb` on the host to `/var/lib/mysql` in the container.

Because both are bind mounts to real folders on the host filesystem, the data survives `docker compose down`, container removal, and rebuilds — it's only gone if the folder itself is deleted, which is exactly what `make fclean` does on purpose.
