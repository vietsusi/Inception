# User Documentation

## 1. What this project provides

### Services in the stack

- **NGINX (TLS reverse proxy)**
  - Web server serving WordPress via HTTPS
  - Exposed ports: 443 (HTTPS)

- **WordPress (PHP-FPM)**
  - WordPress application backend (PHP execution layer)
  - Exposed ports: 9000 (internal only — not accessible from outside)

- **MariaDB**
  - Database backend for WordPress data
  - Exposed ports: 3306 (internal only — not accessible from outside)

### How services connect
- Browser → NGINX → PHP-FPM (WordPress) → MariaDB
- Docker network: internal bridge network (`inception`)

## 2. Start / Stop
```sh
make all     # create data directories + start all services
make down    # stop and remove containers
make clean   # remove containers, volumes, and images
make fclean  # wipe everything including host data folders
```

## 3. Access

### Website
- URL: `https://vinguyen.42.fr`
- Note: A self-signed certificate warning is expected — click "Accept the Risk and Continue" in your browser.

### WordPress Administration Panel
- URL: `https://vinguyen.42.fr/wp-admin`
- Username: value from `secrets/wp_admin.txt`
- Password: value from `secrets/wp_admin_password.txt`

## 4. Configuration

### Non-sensitive configuration — `.env`

Located at `srcs/.env`. Edit these values before running the project:

| Variable | Description | Default |
|---|---|---|
| `DOMAIN_NAME` | Your site domain | `vinguyen.42.fr` |
| `WORDPRESS_TITLE` | Title shown on the WordPress site | `Inception` |
| `LOGIN` | Your Linux username (used for data paths) | `${USER}` |

### Sensitive configuration — `secrets/`

Located at `secrets/` (project root). Each file contains exactly one value — no quotes, no extra spaces.

| File | Description |
|---|---|
| `db_name.txt` | Name of the WordPress database |
| `db_user.txt` | MariaDB user for WordPress |
| `db_password.txt` | Password for the MariaDB user |
| `db_root_password.txt` | MariaDB root password |
| `wp_admin.txt` | WordPress admin username (must NOT contain "admin") |
| `wp_admin_password.txt` | WordPress admin password |
| `wp_admin_email.txt` | WordPress admin email |
| `wp_user.txt` | WordPress regular user username |
| `wp_user_password.txt` | WordPress regular user password |
| `wp_user_email.txt` | WordPress regular user email |

## 5. Check everything is running correctly

### Container status
```sh
make status
docker compose ps
```

### Healthchecks
- **MariaDB**: database is ready to accept connections
- **WordPress (PHP-FPM)**: `wp-login.php` file exists on the volume
- **NGINX**: serves WordPress over HTTPS on port 443

### Logs
```sh
make logs              # all services
make logs nginx        # nginx only
make logs wordpress    # wordpress only
make logs mariadb      # mariadb only
```

### Basic functional checks
```sh
# Test HTTPS is responding (-k ignores self-signed cert warning)
curl -k https://vinguyen.42.fr

# Visit the admin panel in browser
https://vinguyen.42.fr/wp-admin
```

## 6 How to change port:
1. Change Nginx Port: 443 -> 8443
 - docker-compose.yml: 443:443 to 8443:443
 - nginx-entrypoint.sh: 443 -> 8443

2. Change WordPres PHP-FPM Port: 9000 -> 9001
 - wordpress-entrypoint.sh: sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' 
        -> sed -i 's/listen = 127.0.0.1:9000/listen = 9001/g'
 - nginx-etrypoint.sh: fastcgi_pass wordpress:9000; -> fastcgi_pass wordpress:9001;

3. Change MariaDB Port: 3306 -> 3307
 - mariadb-entrypoint.sh:
    [mysqld]
    bind-address=0.0.0.0
    skip-networking=0
    -> [mysqld]
        port=3307 #(add here)
        bind-address=0.0.0.0
        skip-networking=0

 - wordpress-entrypoint.sh:
    wp config create --allow-root \
            --dbhost=mariadb \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbname="$MYSQL_DATABASE"
    -> change to 
    wp config create --allow-root \
            --dbhost=mariadb:3307 \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbname="$MYSQL_DATABASE"
     # Wait for MariaDB to be ready
    mariadb-admin ping --protocol=tcp --host=mariadb -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>/dev/null
    -> change to
    mariadb-admin ping --protocol=tcp --host=mariadb --port=3307 -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>/dev/null