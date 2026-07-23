# User Documentation

This document explains how to use the Inception stack as an end user or administrator — no development knowledge required.

## What services are provided

- **NGINX** — serves the site over HTTPS and is the only service reachable from outside the stack.
- **WordPress** — the website itself, running on PHP-FPM.
- **MariaDB** — the database that stores WordPress's content, users, and settings.

## Starting and stopping the project

From the repository root:
- `make` — build the images (first run only) and start every service in the background.
- `make down` — stop and remove all the containers.
- `make re` — stop everything, wipe it, and start fresh.

## Accessing the website and the administration panel

- **Website:** `https://<login>.42.fr`
- **Admin panel:** `https://<login>.42.fr/wp-admin`

The certificate is self-signed, as required by the subject, so the browser will show a security warning on first visit — this is expected. Proceed past it (usually "Advanced" → "Proceed to site").

## Locating and managing credentials

- All passwords live in the `secrets/` folder at the repo root, one plain-text file per password. This folder is not committed to Git.
- The WordPress admin username and email are set in `srcs/.env`.
- To change a password: edit the relevant file in `secrets/`, then restart the stack with `make re` so the change takes effect.

## Checking that the services are running correctly

- `docker ps` — lists the running containers; `nginx`, `wordpress`, and `mariadb` should all show `Up`.
- `docker compose -f srcs/docker-compose.yml logs -f <service>` — follow a specific service's logs if something looks wrong.
- Simplest check of all: open `https://<login>.42.fr` in a browser — if the site loads, the stack is working.
