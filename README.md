# *This project has been created as part of the 42 curriculum by znajdaou.*

# Inception

> A Docker-based infrastructure project that deploys a complete WordPress website using **NGINX**, **WordPress (PHP-FPM)**, and **MariaDB**, with each service running inside its own container.

---

# Description

**Inception** is a system administration project from the **42 Network** that introduces containerization with Docker.

The objective is to build a small infrastructure composed of multiple services communicating through Docker networks while following good practices such as:

* One process per container
* Container isolation
* Persistent data using Docker volumes
* Secure password management using Docker Secrets
* Automatic service initialization
* HTTPS support using NGINX

Instead of using pre-built images, every service is built from a custom Dockerfile based on **Debian Bullseye**.

---

# Project Architecture

```
                     Internet
                         │
                    HTTPS (443)
                         │
                   +-------------+
                   |    NGINX    |
                   | TLS Reverse |
                   |    Proxy    |
                   +-------------+
                         │
                  Internal Network
                         │
                   +-------------+
                   | WordPress   |
                   |  PHP-FPM    |
                   +-------------+
                         │
                  Internal Network
                         │
                   +-------------+
                   |  MariaDB    |
                   +-------------+

```

Only **NGINX** is exposed to the host.

WordPress and MariaDB communicate only through an internal Docker network.

---

# Services

## NGINX

* Reverse proxy
* Handles HTTPS connections
* Generates a self-signed TLS certificate on startup
* Serves the WordPress website
* Forwards PHP requests to PHP-FPM

---

## WordPress

* Runs with PHP-FPM 8.4
* Downloads the latest WordPress version automatically
* Installs WP-CLI
* Creates `wp-config.php`
* Automatically installs WordPress
* Creates the administrator account
* Creates a second WordPress user
* Waits until MariaDB is ready before starting

---

## MariaDB

* Initializes the database only on first startup
* Creates the WordPress database
* Creates the application user
* Sets the root password
* Removes anonymous users
* Stores all database files inside a persistent Docker volume

---

# Repository Structure

```
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
        ├── nginx/
        ├── wordpress/
        └── bonus/
```

---

# Instructions

## Clone the repository

```bash
git clone <repository_url>
cd inception
```

## Configure secrets

Create the required secret files inside:

```
secrets/
```

Example:

```
db_password.txt
db_root_password.txt
```

Update the `.env` file if necessary.

---

## Build and start

```bash
make
```

---

## Stop

```bash
make stop
```

---

## Start existing containers

```bash
make start
```

---

## Remove containers

```bash
make down
```

---

## Remove containers and volumes

```bash
make clean
```

---

## Complete cleanup

```bash
make fclean
```

---

# Design Choices

## Debian Bullseye

All containers are built from Debian Bullseye to comply with the project subject.

---

## Docker Secrets

Passwords are never hardcoded inside Docker images or Docker Compose.

Instead, sensitive information is stored inside Docker Secrets and read at runtime.

Example:

```
/run/secrets/db_password
```

This avoids exposing passwords through container inspection or environment variables.

---

## Internal Docker Network

MariaDB and WordPress communicate through an **internal bridge network**.

This means they cannot be accessed directly from outside Docker.

Only NGINX is connected to the public bridge network.

---

## Persistent Data

Database files and WordPress files are stored on the host machine using bind-mounted Docker volumes.

```
/home/$USERNAME/data/mariadb_data

/home/$USERNAME/data/wordpress_data
```

Containers can be recreated without losing website data.

---

## Automatic Initialization

Every container starts with its own initialization script.

### MariaDB

* initializes the database
* creates users
* creates database
* removes anonymous users

### WordPress

* waits for MariaDB
* creates wp-config.php
* installs WordPress
* creates administrator
* creates second user

### NGINX

* generates TLS certificate
* starts NGINX in foreground

---

# Docker Concepts

## Virtual Machines vs Docker

| Virtual Machine                   | Docker                            |
| --------------------------------- | --------------------------------- |
| Includes a complete guest OS      | Shares the host kernel            |
| Higher resource usage             | Lightweight                       |
| Slower startup                    | Starts in seconds                 |
| Larger disk usage                 | Smaller images                    |
| Better for full OS virtualization | Better for application deployment |

For this project Docker is the preferred choice because each service can run independently while sharing the same Linux kernel.

---

## Secrets vs Environment Variables

### Environment Variables

* Easy to configure
* Visible inside container metadata
* Better for non-sensitive configuration

Examples:

* database name
* hostname
* domain name

### Docker Secrets

* Designed for passwords
* Mounted as files
* More secure
* Not baked into Docker images

This project stores every password as a Docker Secret.

---

## Docker Network vs Host Network

### Bridge Network

* Containers communicate using Docker DNS.
* Services remain isolated.
* Only exposed ports are accessible.

### Host Network

* Shares the host network directly.
* No isolation.
* Greater security risks.

This project uses Docker bridge networks to isolate services.

---

## Docker Volumes vs Bind Mounts

### Docker Volume

Managed entirely by Docker.

Useful when Docker controls storage.

### Bind Mount

Maps a specific directory from the host into the container.

This project uses local host directories through Docker volumes configured with bind mounts:

```
device: /home/$USERNAME/data/...
```

This allows data to persist even if containers are removed.

---

# Technologies

* Docker
* Docker Compose
* Debian Bullseye
* NGINX
* MariaDB
* WordPress
* PHP-FPM
* OpenSSL
* WP-CLI
* Bash

---

# Resources

Official documentation

* Docker Documentation
* Docker Compose Documentation
* Debian Documentation
* NGINX Documentation
* MariaDB Documentation
* WordPress Documentation
* WP-CLI Documentation

Learning resources used during the project

* https://packages.sury.org/php/
* https://make.wordpress.org/hosting/handbook/server-environment/
* https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok
* https://make.wordpress.org/cli/handbook/guides/installing/
* https://developer.wordpress.org/cli/commands/core/install/
* https://developer.wordpress.org/cli/commands/config/
* https://www.youtube.com/watch?v=PrusdhS2lmo

---

# AI Usage

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

---

# Bonus

The bonus part has not yet been implemented.

It will be added before the final project submission.

---

# License

This project was developed as part of the **42 Network** curriculum for educational purposes.

