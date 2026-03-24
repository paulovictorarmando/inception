*This project has been created as part of the 42 curriculum by parmando.*

# Inception

## Description

**Inception** is a 42 curriculum project focused on system administration and containerized infrastructure. The goal is to build a small, reproducible web stack using **Docker** and **Docker Compose** that runs:

- **NGINX** as the single HTTPS entrypoint (TLS 1.2/1.3)
- **WordPress** served through **PHP-FPM**
- **MariaDB** as the persistent database backend

Each service runs in its own isolated container, communicating through a dedicated Docker bridge network. The entire infrastructure is defined in code, making it reproducible across environments and easy to version control.

## What's included in this repository

- [srcs/docker-compose.yml](srcs/docker-compose.yml): services, networks, volumes, and secrets definitions
- [srcs/requirements/nginx](srcs/requirements/nginx): NGINX Dockerfile, TLS configuration, and tools
- [srcs/requirements/wordpress](srcs/requirements/wordpress): WordPress/PHP-FPM Dockerfile, configuration, and initialization scripts
- [srcs/requirements/mariadb](srcs/requirements/mariadb): MariaDB Dockerfile, configuration, and setup scripts
- [srcs/secrets](srcs/secrets): password files for database and WordPress admin/user accounts
- [srcs/.env](srcs/.env): non-sensitive environment variables (created during setup)
- [Makefile](Makefile): convenience targets for building, running, and cleaning the infrastructure
- [DEV_DOC.md](DEV_DOC.md): developer setup and configuration guide
- [USER_DOC.md](USER_DOC.md): end-user and administrator guide

## Architecture overview

```
Client (browser)
   │ HTTPS :443
   ▼
NGINX container (TLS termination + reverse proxy)
   │ FastCGI :9000 (internal)
   ▼
WordPress container (PHP-FPM engine)
   │ MySQL :3306 (internal)
   ▼
MariaDB container (persistent database)

Network: inception-network (isolated bridge)
Storage: /home/parmando/data/{wordpress,mariadb} (persistent bind mounts)
Secrets: srcs/secrets/{db_root_password,db_user_password,wp_admin_password,wp_user_password}.txt
```

## Project description (Docker design choices & comparisons)

### Why Docker / Docker Compose

This project uses Docker to package each service (NGINX, WordPress, MariaDB) with its dependencies in isolated, portable containers. Docker Compose orchestrates the entire stack—defining services, networking, storage, and secrets in a single declarative YAML file. This approach ensures reproducibility: the exact same `docker-compose.yml` produces identical infrastructure on any Linux host with Docker installed.

### Sources included in the project

The infrastructure is built entirely from source in this repository:

- **Compose orchestration**: [srcs/docker-compose.yml](srcs/docker-compose.yml) defines the full stack
- **Custom images**: One Dockerfile per service (NGINX, WordPress, MariaDB) under [srcs/requirements/](srcs/requirements), all based on Debian Bookworm
- **Service configuration**: NGINX, WordPress, and MariaDB configuration files under each service's `conf/`
- **Initialization scripts**: Automated setup scripts (`setup.sh`) under each service's `tools/` directory
- **Secrets storage**: Password files in [srcs/secrets/](srcs/secrets) referenced by Docker Compose

### Main design choices

- **One container per service**: NGINX, WordPress, and MariaDB each run in isolated containers built from custom Dockerfiles.
- **Minimal exposure**: Only NGINX port 443 is exposed to the host; WordPress and MariaDB communicate internally via the bridge network.
- **TLS at the edge**: NGINX terminates TLS with a self-signed certificate, enforcing TLS 1.2/1.3 minimum.
- **Automated initialization**: WordPress and MariaDB are configured automatically on first boot (idempotent setup via scripts and WP-CLI).
- **Persistent storage**: WordPress files and MariaDB data persist via bind-mounted volumes at `/home/parmando/data/`.
- **Private networking**: All inter-service communication goes through a custom Docker bridge network (`inception-network`), isolating it from the host.

### Required comparisons

#### Virtual Machines vs Docker

- **Virtual Machines (VMs)** virtualize the entire hardware stack and run a complete guest operating system. Each VM is heavyweight, consuming significant disk space and RAM, and has a slower boot time. However, VMs provide very strong isolation.
- **Docker Containers** share the host's Linux kernel and isolate processes using kernel namespaces (PID, network, filesystem, etc.) and cgroups (resource limits). Containers are lightweight, start in milliseconds, and have minimal overhead.
- **Choice in Inception**: Docker containers are used because each microservice (NGINX, WordPress, MariaDB) needs only its application and dependencies—not a full OS. This keeps deployments lean and startup fast, while providing sufficient isolation for a development/learning environment.

#### Secrets vs Environment Variables

- **Environment Variables** are simple to use (key=value pairs) and work across most platforms. They are straightforward to set in shell, Docker `.env` files, or Compose definitions. **However**, env vars can leak via:
  - Process listings (`ps aux`)
  - Container logs
  - Shell history
  - Accidental commits to version control
  - Debugging tools
- **Docker Secrets** are a Docker feature that keeps sensitive data separate: credentials are read from files on the host, never passed as environment variables, and mounted as read-only files inside containers at `/run/secrets/`. This reduces exposure in logs and process inspection.
- **Choice in Inception**: This project uses a **hybrid approach**:
  - **Non-sensitive configuration** (database name, usernames, domain) uses environment variables in [srcs/.env](srcs/.env) for convenience.
  - **Sensitive passwords** (database root/user passwords, WordPress admin/user passwords) are stored in [srcs/secrets/](srcs/secrets) as separate files and referenced in the Compose file under the `secrets:` section.
  - This balances simplicity (for learning) with good security practices (passwords are not in env vars or logs).

#### Docker Network vs Host Network

- **Bridge Network** (Docker default) creates an isolated virtual network. Containers get their own IP addresses and communicate via this network. Only explicitly ports-mapped or exposed services are accessible from the host.
  - **Pros**: Service discovery by name, internal traffic is hidden from host, reduced port collision risk.
  - **Cons**: Slight performance overhead due to network translation.
- **Host Network** removes the isolation layer; containers share the host's network stack directly. Services bind directly to host ports.
  - **Pros**: Minimal latency and networking overhead.
  - **Cons**: Loss of isolation, port conflicts with host processes, all container traffic is visible on the host.
- **Choice in Inception**: A custom **bridge network** (`inception-network`) is used. This allows NGINX, WordPress, and MariaDB to communicate internally by container name while only exposing port 443 (NGINX) to the host. Internal traffic (WordPress ↔ MariaDB) remains private.

#### Docker Volumes vs Bind Mounts

- **Docker Volumes** are managed by Docker, stored in `/var/lib/docker/volumes/` (or a custom driver's path). They are portable and can survive container removal. The host path is abstracted, making the Compose file portable across machines.
  - **Pros**: Portable, managed by Docker, cleaner logs, work with remote drivers.
  - **Cons**: Data location is opaque; inspection/backup requires Docker commands.
- **Bind Mounts** explicitly map a host directory into the container. They provide clear visibility: the host path is obvious in the Compose file. Inspection and backup are straightforward with regular filesystem tools.
  - **Pros**: Transparent, easy to inspect/backup, no abstraction.
  - **Cons**: Depends on host filesystem layout, permissions must be managed, less portable if paths differ across hosts.
- **Choice in Inception**: Named volumes are used (via `driver_opts: { type: none, o: bind, device: /home/parmando/data/... }`).

## Instructions

### Prerequisites

- **Linux host** with a user account
- **Docker Engine 20.10+** and **Docker Compose v2** (the `docker compose` command, not the older `docker-compose`)
- **make** (usually pre-installed on most Linux distributions)
- **sudo access** (to create persistent data directories)

### Environment configuration

Before building, you must set up the environment variables and secrets:

1. **Create the `.env` file** at `srcs/.env` with non-sensitive configuration:
   ```bash
   SQL_DATABASE=wordpress_db
   SQL_USER=parmando
   DOMAIN_NAME=parmando.42.fr
   WP_ADMIN_USER=elias
   WP_ADMIN_EMAIL=elias@example.com
   WP_USER=victor
   WP_USER_EMAIL=victor@example.com
   ```

2. **Create secret files** in `srcs/secrets/` with sensitive passwords (one password per file, no trailing newlines):
   ```bash
   mkdir -p srcs/secrets
   echo -n "YourSecureDBRootPassword" > srcs/secrets/db_root_password.txt
   echo -n "YourSecureDBUserPassword" > srcs/secrets/db_user_password.txt
   echo -n "YourSecureWPAdminPassword" > srcs/secrets/wp_admin_password.txt
   echo -n "YourSecureWPUserPassword" > srcs/secrets/wp_user_password.txt
   chmod 600 srcs/secrets/*.txt  # Restrict permissions to owner only
   ```
   **Important**: Do not commit these files to version control. Add `srcs/secrets/` to `.gitignore`.

3. **Configure your local domain** by editing `/etc/hosts`:
   ```
   127.0.0.1  parmando.42.fr
   ```
   (Replace with your actual domain from `DOMAIN_NAME`.)

### Building and running

From the repository root:

```bash
make        # Builds images and starts containers in background
# or explicitly:
make all
```

What happens:
- Directory `/home/parmando/data/` is created with appropriate permissions
- Docker Compose builds the three custom images (NGINX, WordPress, MariaDB)
- Containers start and initialize themselves automatically

### Stopping and restarting

```bash
make down   # Stop and remove containers (volumes and data persist)
make up     # Start containers again without rebuilding images
make re     # Rebuild images and restart everything
```

### Cleanup

```bash
make clean  # Remove stopped containers and dangling images
make fclean # Full cleanup: remove containers, volumes, and persistent data at /home/parmando/data
```

### Access the application

Once running, access the application at: `https://parmando.42.fr` (or your configured domain).

Note: The TLS certificate is self-signed, so your browser will display a security warning—this is expected and normal for a self-signed setup.

## Resources

### Docker and containerization

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose file specification](https://docs.docker.com/compose/compose-file/)
- [Docker Secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [Docker Networking guide](https://docs.docker.com/network/)
- [Docker Volumes vs Bind Mounts](https://docs.docker.com/storage/)

### WordPress and PHP

- [WordPress official documentation](https://wordpress.org/documentation/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.php)
- [WP-CLI documentation](https://wp-cli.org/)

### Web server and TLS

- [NGINX official documentation](https://nginx.org/en/docs/)
- [NGINX TLS/SSL configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [TLS 1.2 and 1.3 specifications](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- [Self-signed certificates with OpenSSL](https://www.openssl.org/docs/)

### Database

- [MariaDB Server documentation](https://mariadb.com/kb/en/mariadb-server/)
- [MySQL command line interface](https://dev.mysql.com/doc/refman/8.0/en/mysql.html)

### How AI was used in this project

- Explanations: summarizing Docker networking/volumes concepts into the Project.
- Consultation on Docker best practices, NGINX and MariaDB configurations
- Error analysis during container configuration
- Improvements to configuration scripts (setup.sh)
- Documentation refactor: structure and English rewrite of this README.
- Correct syntax for docker-compose.yml and service configuration
