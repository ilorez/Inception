# Developer Documentation

This document explains how the project is implemented and how developers can build, modify, debug, and maintain the infrastructure.

---

# Project Overview

The project consists of three Docker containers working together to host a WordPress website.

```text
                HTTPS (443)
                     │
               +-------------+
               |    NGINX    |
               +-------------+
                     │
               wp_network
                     │
               +-------------+
               | WordPress   |
               |  PHP-FPM    |
               +-------------+
                     │
               wp_network
                     │
               +-------------+
               |  MariaDB    |
               +-------------+
```

Each service is built from its own Dockerfile based on **Debian Bullseye**.

---

# Repository Layout

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│
└── srcs/
    ├── docker-compose.yml
    ├── .env
    │
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/
        │
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │
        └── bonus/
```

---

# Prerequisites

Install:

* Docker
* Docker Compose
* GNU Make

Clone the repository:

```bash
git clone <repository_url>
cd inception
```

---

# Required Configuration

## Environment Variables

Configuration values are stored in:

```text
srcs/.env
```

This file contains values such as:

* database name
* database user
* WordPress administrator
* domain name
* username

Sensitive information is intentionally excluded.

---

## Docker Secrets

Passwords are stored separately.

```text
secrets/
├── db_password.txt
└── db_root_password.txt
```

Inside the containers they become available as:

```text
/run/secrets/db_password

/run/secrets/db_root_password
```

---

# Building the Project

Everything is managed through the Makefile.

Build and start:

```bash
make
```

This command:

1. Creates local data directories.
2. Builds all Docker images.
3. Creates Docker networks.
4. Creates Docker volumes.
5. Starts every container.

---

# Docker Compose

The stack contains three services.

## MariaDB

Responsibilities:

* database server
* database initialization
* user creation
* persistent storage

Connected to:

* wp_network

Volumes:

* mariadb_data

Secrets:

* db_password
* db_root_password

---

## WordPress

Responsibilities:

* PHP-FPM
* WordPress installation
* WP-CLI
* automatic configuration

Connected to:

* wp_network

Volumes:

* wordpress_data

Depends on:

* MariaDB

---

## NGINX

Responsibilities:

* HTTPS termination
* reverse proxy
* serving static files

Connected to:

* wp_network
* bridge

Only NGINX publishes a port to the host:

```text
443:443
```

---

# Networks

The project uses two bridge networks.

## wp_network

```yaml
internal: true
```

Purpose:

* communication between containers
* completely isolated from the host

Services:

* MariaDB
* WordPress
* NGINX

---

## bridge

Purpose:

Provides access from the host machine.

Only NGINX is connected to this network.

This makes NGINX the single entry point into the infrastructure.

---

# Volumes

Two persistent volumes are created.

```text
wordpress_data

mariadb_data
```

Both use bind mounts.

Host directories:

```text
/home/$USERNAME/data/wordpress_data

/home/$USERNAME/data/mariadb_data
```

Data remains available even if containers are removed.

---

# Service Initialization

Each container has its own startup script.

---

## MariaDB

Initialization script:

```text
requirements/mariadb/tools/init.sh
```

On the first startup it:

* creates the database directory
* initializes MariaDB
* starts a temporary server
* creates the WordPress database
* creates the database user
* sets the root password
* removes anonymous users
* shuts down the temporary server
* starts MariaDB normally

The script checks whether:

```text
/var/lib/mysql/mysql
```

already exists.

If it exists, initialization is skipped.

---

## WordPress

Initialization script:

```text
requirements/wordpress/tools/init.sh
```

The script first waits until MariaDB is accepting TCP connections.

After that it:

* creates wp-config.php
* installs WordPress
* creates the administrator account
* creates the second WordPress user
* starts PHP-FPM

Everything is performed automatically using WP-CLI.

---

## NGINX

Initialization script:

```text
requirements/nginx/tools/init.sh
```

The script:

* generates a self-signed TLS certificate
* creates the SSL directory
* starts NGINX in the foreground

NGINX must remain in the foreground because Docker expects the main process to stay running.

---

# Data Persistence

Persistent data is stored outside containers.

WordPress:

```text
/home/$USERNAME/data/wordpress_data
```

MariaDB:

```text
/home/$USERNAME/data/mariadb_data
```

Deleting a container does not delete the website.

Removing the volumes does.

---

# Useful Docker Commands

Running containers:

```bash
docker ps
```

All containers:

```bash
docker ps -a
```

View logs:

```bash
docker logs nginx

docker logs wordpress

docker logs mariadb
```

Open a shell:

```bash
docker exec -it nginx bash

docker exec -it wordpress bash

docker exec -it mariadb bash
```

Inspect networks:

```bash
docker network ls

docker network inspect wp_network
```

Inspect volumes:

```bash
docker volume ls
```

Inspect a container:

```bash
docker inspect wordpress
```

---

# Makefile Commands

```bash
make
```

Build and start everything.

```bash
make start
```

Start existing containers.

```bash
make stop
```

Stop containers.

```bash
make restart
```

Restart containers.

```bash
make down
```

Remove containers.

```bash
make clean
```

Remove containers and volumes.

```bash
make fclean
```

Remove containers, images, networks, and volumes.

---

# Extending the Project

The repository already contains:

```text
requirements/bonus/
```

Additional services required by the bonus part can be added here and integrated into `docker-compose.yml` without changing the existing architecture.

---

# Troubleshooting

## MariaDB does not start

Check:

```bash
docker logs mariadb
```

Verify:

* secret files exist
* passwords are valid
* data directory permissions are correct

---

## WordPress waits forever

Check that MariaDB is accepting connections.

```bash
docker logs mariadb
```

Then verify:

```bash
docker logs wordpress
```

---

## NGINX returns 502

Usually indicates PHP-FPM is unavailable.

Verify that:

* the WordPress container is running
* PHP-FPM started successfully
* both containers share the same network

---

## Database password changed

Changing the password inside the secret file does not modify an existing database.

To recreate the database:

```bash
make fclean

make
```

---

# Development Notes

Some implementation decisions made during this project:

* Every image is built from Debian Bullseye.
* No pre-built service images are used.
* One service runs per container.
* Passwords are managed with Docker Secrets.
* WordPress installation is fully automated using WP-CLI.
* MariaDB initializes only once.
* WordPress waits until MariaDB is ready before continuing.
* NGINX is the only service exposed to the host.
* PHP-FPM communicates with NGINX over the internal Docker network.
* Website and database data persist through bind-mounted Docker volumes.

These choices keep the infrastructure modular, secure, and compliant with the project requirements.
