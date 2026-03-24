# DEV_DOC.md — Developer documentation

This document describes how a developer can set up the project from scratch, build and launch it using the Makefile and Docker Compose, manage containers and volumes, and understand where data is stored and how it persists.

## 1) Set up the environment from scratch

### Prerequisites

- **Linux host** (any mainstream distribution)
- **Docker Engine 20.10+** (check with `docker --version`)
- **Docker Compose v2** (the `docker compose` subcommand; check with `docker compose version`)
- **GNU Make** (check with `make --version`)
- **sudo access** (required to create persistent data directories)

### Configuration: Environment variables and secrets

#### 1. Non-sensitive configuration in `srcs/.env`

Create `srcs/.env` with configuration that doesn't require secrecy:

```bash
# Database configuration
SQL_DATABASE=wordpress_db
SQL_USER=parmando

# Site configuration
DOMAIN_NAME=parmando.42.fr

# WordPress admin account
WP_ADMIN_USER=elias
WP_ADMIN_EMAIL=elias@example.com

# WordPress regular user account
WP_USER=victor
WP_USER_EMAIL=victor@example.com
```

These variables are:
- Loaded by `docker compose` via the `env_file` directive
- Passed as environment variables to containers
- Used by initialization scripts (`setup.sh`) to configure services

#### 2. Sensitive passwords in `srcs/secrets/`

Create the `srcs/secrets/` directory and add individual password files:

```bash
mkdir -p srcs/secrets
echo -n "SecureDBRootPassword123!" > srcs/secrets/db_root_password.txt
echo -n "SecureDBUserPassword456!" > srcs/secrets/db_user_password.txt
echo -n "SecureAdminPassword789!" > srcs/secrets/wp_admin_password.txt
echo -n "SecureUserPassword000!" > srcs/secrets/wp_user_password.txt
chmod 600 srcs/secrets/*.txt
```

### Local domain setup

Add the project domain to your system's DNS resolution:

```bash
sudo nano /etc/hosts  # or your preferred editor
```

Add:
```
127.0.0.1  parmando.42.fr
```

## 2) Build and launch (Makefile + Docker Compose)

All commands are executed from the repository root.

### The Makefile targets

The [Makefile](Makefile) provides convenience wrappers around `docker compose` commands:

```makefile
LOGIN = parmando

all: build up       # Default (build + run)
build:              # Create /home/parmando/data/* and docker build
up:                 # Start services in background
down:               # Stop and remove containers
clean:              # docker system prune -a (dangling images only)
fclean:             # clean + remove all volumes + delete /home/parmando/data
re:                 # fclean + all (full rebuild)
```

The `build` target specifically:
1. Creates `/home/parmando/data/mariadb` and `/home/parmando/data/wordpress`
2. Sets ownership to the current user (avoiding permission issues)
3. Runs `docker compose build` to build all images

### Building and starting

```bash
make        # Equivalent to: make build && make up
# or explicitly:
make all
```

This:
- Creates persistent data directories on the host
- Builds three custom Docker images (one per service)
- Starts containers
- Services initialize automatically


### Service lifecycle

```bash
# View status
docker compose -f srcs/docker-compose.yml ps

# View logs
docker compose -f srcs/docker-compose.yml logs

# Stop containers (keep data)
make down

# Start containers (without rebuilding images)
make up

# Rebuild images from scratch (expensive, keeps data)
make re

# Full reset: remove containers, images, volumes, and data
make fclean
```

### Typical workflows

**Development (iterate on files)**:
```bash
make re    # Rebuild after changing Dockerfile, config files, scripts
```

**Testing (preserve data between restarts)**:
```bash
make down  # Stop but keep database, WordPress files
# ... make changes ...
make up    # Restart
```

**Clean slate**:
```bash
make fclean  # Delete everything
make         # Start fresh
```

## 3) Manage containers and volumes

### Essential Docker Compose commands

```bash
# View running services
docker compose -f srcs/docker-compose.yml ps

# View all logs (or -f to follow)
docker compose -f srcs/docker-compose.yml logs

### Understanding volumes in this project

The `docker-compose.yml` defines two named volumes configured

#### Inspecting volume data

```bash
# List volumes
docker volume ls

# Inspect volume details
docker volume inspect inception_wp-data
```

## 4) Where project data is stored and how it persists

### Storage locations

**WordPress application files and uploads**:
```
/home/parmando/data/wordpress/
  ├── wp-content/       # Plugins, themes, uploads
  ├── wp-admin/         # Admin interface code
  ├── wp-includes/      # Core WordPress code
  └── wp-config.php     # WordPress configuration

Mounted into container at: /var/www/html
```

**MariaDB database files**:
```
/home/parmando/data/mariadb/
  ├── wordpress_db/     # Database tables (InnoDB files)
  └── mysql/            # System databases

Mounted into container at: /var/lib/mysql
```

### Persistence guarantees

| Command | Containers | Images | Volumes | Data | Effect |
|---------|------------|--------|---------|------|--------|
| `make down` | ✗ Removed | ✓ Kept | ✓ Kept | ✓ Kept | Stop; keep all data |
| `make up` | ✓ Created | ✓ Kept | ✓ Kept | ✓ Kept | Restart from saved state |
| `make re` | ✗ Removed | ✗ Rebuilt | ✓ Kept | ✓ Kept | Full rebuild; data survives |
| `make clean` | ✗ Removed | ✗ Pruned | ✓ Kept | ✓ Kept | Clean; data untouched |
| `make fclean` | ✗ Removed | ✗ Pruned | ✗ Removed | ✗ Deleted | **Destructive**: everything gone |

### Data persistence workflow

1. **Create content** (posts, pages, uploads) in WordPress via the web interface
2. **Restart the stack**:
   ```bash
   make down
   make up
   ```
3. **Verify persistence**: Reload `https://parmando.42.fr` and confirm content is still there

This works because:
- Data is written to `/home/parmando/data/` (host filesystem)
- Data directories are mounted into containers
- `make down` stops containers but doesn't delete mounted data
- `make up` restarts containers with the same mounts pointing to existing data


### Verifying data persistence

```bash
# Check WordPress files exist
ls /home/parmando/data/wordpress/wp-config.php

# Check MariaDB data exists
ls /home/parmando/data/mariadb/wordpress_db/
```
