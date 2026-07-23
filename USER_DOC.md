# User Documentation

This document explains how to use the Inception project after cloning the repository.

---

# Services

The project deploys three services:

| Service       | Description                                          |
| ------------- | ---------------------------------------------------- |
| **NGINX**     | Reverse proxy that serves the website over HTTPS     |
| **WordPress** | Content Management System (CMS) running with PHP-FPM |
| **MariaDB**   | Database used by WordPress                           |

---

# Requirements

Before starting the project, make sure you have:

* Docker installed
* Docker Compose installed
* GNU Make installed

---

# First Setup

## 1. Clone the repository

```bash
git clone <repository_url>
cd inception
```

---

## 2. Create the secret files

Inside the `secrets/` directory create the required password files.

```
secrets/
├── db_password.txt
└── db_root_password.txt
```

Example:

```text
db_password.txt
----------------
your_database_password

db_root_password.txt
--------------------
your_root_password
```

---

## 3. Configure the environment

Edit:

```text
srcs/.env
```

Configure the values that match your environment.

Important variables include:

* database name
* database user
* WordPress administrator
* domain name
* username

Passwords are **not** stored inside this file.

---

# Starting the Project

Build and start all containers:

```bash
make
```

The first build may take several minutes because Docker must build every image.

---

# Opening the Website

After the containers start successfully, open:

```
https://<DOMAIN_NAME>
```

Example:

```
https://znajdaou.42.fr
```

Because the project generates a self-signed certificate, your browser will display a security warning.

This is expected.

Choose **Advanced → Continue** to access the website.

---

# WordPress Administration

Open:

```
https://<DOMAIN_NAME>/wp-admin
```

Log in using the administrator credentials configured in the `.env` file.

Example:

```
Username:
superuser

Password:
(read from db_root_password.txt)
```

---

# WordPress Users

The initialization script automatically creates:

* one administrator
* one author user

The author account can create and manage posts but has limited administrative permissions.

---

# Stopping the Project

Stop all running containers:

```bash
make stop
```

---

# Starting Existing Containers

```bash
make start
```

---

# Restarting Everything

```bash
make restart
```

---

# Removing Containers

```bash
make down
```

This removes the containers but keeps all persistent data.

---

# Cleaning Volumes

To remove containers and persistent data:

```bash
make clean
```

To completely remove containers, images, networks, and volumes:

```bash
make fclean
```

> **Warning:** This permanently deletes the WordPress files and database.

---

# Credentials

Passwords are stored using **Docker Secrets**.

Secret files:

```
secrets/
├── db_password.txt
└── db_root_password.txt
```

Other configuration values are stored in:

```
srcs/.env
```

---

# Checking Running Services

Show running containers:

```bash
docker ps
```

You should see:

* nginx
* wordpress
* mariadb

---

# Viewing Logs

NGINX

```bash
docker logs nginx
```

WordPress

```bash
docker logs wordpress
```

MariaDB

```bash
docker logs mariadb
```

---

# Verifying the Website

To verify that the stack is working correctly:

* All containers are running.
* The website opens over HTTPS.
* The WordPress installation page does not appear.
* You can log into `/wp-admin`.
* Posts can be created successfully.
* Data remains after restarting the containers.

---

# Persistent Data

The project stores data outside the containers.

WordPress files:

```
/home/<USERNAME>/data/wordpress_data
```

MariaDB database:

```
/home/<USERNAME>/data/mariadb_data
```

Because these directories are mounted into Docker volumes, removing containers does **not** delete your website or database.

---

# Common Problems

## Website does not open

Check that NGINX is running:

```bash
docker ps
```

---

## WordPress cannot connect to the database

Verify that the MariaDB container is running.

Then check its logs:

```bash
docker logs mariadb
```

---

## Browser reports an insecure connection

This is expected because the project uses a self-signed TLS certificate generated during container startup.

---

## Password does not work

Verify the contents of:

```
secrets/db_password.txt
secrets/db_root_password.txt
```

If the database has already been initialized, changing the secret files alone will not update existing passwords. Remove the persistent database volume and rebuild the project if you want to recreate the database with new credentials.

---

# Useful Commands

```bash
make            # Build and start the project

make stop       # Stop containers

make start      # Start containers

make restart    # Restart containers

make down       # Remove containers

make clean      # Remove containers and volumes

make fclean     # Full cleanup

docker ps       # Running containers

docker logs <container>

docker exec -it <container> bash
```
