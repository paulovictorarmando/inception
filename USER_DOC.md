# USER_DOC.md — User documentation

This document explains, in clear and simple terms, how an end user or administrator can understand the provided services, start/stop the project, access the website/admin panel, manage credentials, and check that the services are running correctly.

## Services provided by the stack

The Inception project provides a complete WordPress web application stack with automated setup and secure HTTPS access:

- **NGINX container**: The only service exposed to the host on port 443. It terminates TLS/SSL connections and acts as a reverse proxy, forwarding requests to WordPress.
- **WordPress container (PHP-FPM)**: The CMS application engine. Handles web requests sent by NGINX and manages blog content, posts, pages, and users. Initialized automatically on first run using WP-CLI.
- **MariaDB container**: The relational database that stores all WordPress data (posts, users, settings, etc.). Initialized with a database and user on first run.

All inter-container communication (NGINX ↔ WordPress, WordPress ↔ MariaDB) occurs through an internal Docker network and is not exposed to the host.

## Start and stop the project

### First-time setup: Configure your local domain

Before starting, add an entry to your local DNS so your browser can resolve the project domain.

1. Edit `/etc/hosts` (may require `sudo`):
   ```bash
   sudo nano /etc/hosts
   ```

2. Add this line (use the domain configured in `srcs/.env`):
   ```
   127.0.0.1  parmando.42.fr
   ```

### Starting the project

From the repository root:

```bash
make
# or be explicit:
make all
```

This:
- Creates persistent data directories
- Builds custom Docker images for all three services
- Starts containers in the background
- Initializes WordPress and the database automatically

### Stopping the project

```bash
make down
```

This stops and removes containers, but your data persists (WordPress files and database remain).

### Restarting the project

```bash
make down
make up
```

Or in one command:

```bash
make re
```

## Access the website and administration panel

Once the stack is running:

- **Website**: `https://parmando.42.fr` (or your configured domain)
- **Admin panel**: `https://parmando.42.fr/wp-admin`
- **Admin user**: Use the credentials from `srcs/secrets/wp_admin_password.txt`

### Note about the security certificate

The NGINX server uses a self-signed TLS certificate. When you first visit the site, your browser will show a security warning like "Your connection is not private" or "Certificate is not valid." This is **expected and normal**—it does not mean the connection is unsafe. You can safely proceed by clicking "Advanced" and then "Proceed to the site" (exact wording varies by browser).

For production, you would use a certificate from a trusted Certificate Authority (e.g., Let's Encrypt).

## Locate and manage credentials

This project uses a hybrid approach to managing credentials:

### Non-sensitive configuration: `srcs/.env`

The file `srcs/.env` contains non-sensitive configuration loaded by Docker Compose:

- `SQL_DATABASE`: Name of the WordPress database
- `SQL_USER`: Username for WordPress database user
- `DOMAIN_NAME`: Domain name for the WordPress site
- `WP_ADMIN_USER`: WordPress admin account username
- `WP_ADMIN_EMAIL`: Email address for WordPress admin
- `WP_USER`: Standard WordPress user account username
- `WP_USER_EMAIL`: Email address for standard user

**Do not commit** `srcs/.env` to Git if it contains real passwords, but this file does not store sensitive passwords.

### Sensitive passwords: `srcs/secrets/`

Passwords are stored separately as plain text files in `srcs/secrets/`. This follows Docker's secrets pattern:

- `srcs/secrets/db_root_password.txt`: MariaDB root user password
- `srcs/secrets/db_user_password.txt`: MariaDB WordPress user password
- `srcs/secrets/wp_admin_password.txt`: WordPress admin account password
- `srcs/secrets/wp_user_password.txt`: WordPress standard user account password

Docker reads these files and mounts them inside containers at `/run/secrets/` instead of passing them as environment variables, reducing accidental exposure in logs.

**Do not commit** these files to Git. Add `srcs/secrets/` to `.gitignore`.

## Check that services are running correctly

### 1) Verify all containers are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

### 2) Check the website with HTTPS

```bash
curl -k https://parmando.42.fr
```

(The `-k` flag tells curl to ignore the self-signed certificate warning.)

### 3) Check container logs

If something isn't working, check the logs:

```bash
# All containers
docker compose -f srcs/docker-compose.yml logs
```

### 4) Check that your data persists

Create a test post or make a change in WordPress, then restart:

```bash
make down
make up
```

Reload `https://parmando.42.fr` in your browser. Your changes should still be there, confirming that data persists correctly.