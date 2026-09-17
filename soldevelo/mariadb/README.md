# MariaDB packaged by SolDevelo

[MariaDB](https://mariadb.org/) is a community-developed, commercially supported fork of the MySQL relational database management system.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami MariaDB](https://github.com/bitnami/containers/tree/main/bitnami/mariadb) container.

## TL;DR

```console
docker run --name mariadb -e ALLOW_EMPTY_PASSWORD=yes docker.io/soldevelo/mariadb:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/mariadb/13.1/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Why SolDevelo images?

SolDevelo images are built on top of Bitnami's work, providing the same security-focused, non-root container approach while being maintained and published by SolDevelo for its infrastructure needs.

## Get this image

```console
docker pull docker.io/soldevelo/mariadb:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/mariadb/13.1/debian-12
docker build -t soldevelo/mariadb:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/mariadb/13.1/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

### General

| Name                              | Description                                                                 | Default   |
|-----------------------------------|-----------------------------------------------------------------------------|-----------|
| `ALLOW_EMPTY_PASSWORD`            | Allow access without a password (dev only)                                  | `no`      |
| `MARIADB_ROOT_USER`               | MariaDB root username                                                       | `root`    |
| `MARIADB_ROOT_PASSWORD`           | MariaDB root password                                                       | `nil`     |
| `MARIADB_AUTHENTICATION_PLUGIN`   | Authentication plugin to configure on first initialisation                  | `nil`     |
| `MARIADB_USER`                    | Application username to create on first initialisation                      | `nil`     |
| `MARIADB_PASSWORD`                | Password for the application user                                           | `nil`     |
| `MARIADB_DATABASE`                | Database to create on first initialisation                                  | `nil`     |
| `MARIADB_PORT_NUMBER`             | Port the MariaDB server listens on                                          | `3306`    |
| `MARIADB_CHARACTER_SET`           | Default character set                                                       | `utf8mb4` |
| `MARIADB_COLLATE`                 | Default collation                                                           | `utf8mb4_unicode_ci` |
| `MARIADB_BIND_ADDRESS`            | Address the server binds to                                                 | `0.0.0.0` |
| `MARIADB_SQL_MODE`                | SQL modes to enable                                                         | `nil`     |
| `MARIADB_UPGRADE`                 | Upgrade option passed to mariadbd on start                                  | `AUTO`    |
| `MARIADB_SKIP_TEST_DB`            | Skip creating the `test` database on first initialisation                   | `no`      |
| `MARIADB_EXTRA_FLAGS`             | Extra flags appended to the server startup command                          | `nil`     |
| `MARIADB_INIT_SLEEP_TIME`         | Seconds to sleep while waiting for init operations to finish                | `nil`     |
| `MARIADB_STARTUP_WAIT_RETRIES`    | Retries while waiting for the server to become available                    | `300`     |
| `MARIADB_STARTUP_WAIT_SLEEP_TIME` | Seconds between startup retries                                             | `2`       |
| `MARIADB_ENABLE_SLOW_QUERY`       | Enable slow-query logging (`1` to enable)                                   | `0`       |
| `MARIADB_LONG_QUERY_TIME`         | Threshold in seconds for slow-query logging                                 | `10.0`    |

### Replication

| Name                              | Description                                                                 | Default   |
|-----------------------------------|-----------------------------------------------------------------------------|-----------|
| `MARIADB_REPLICATION_MODE`        | Replication mode (`master` or `slave`)                                      | `nil`     |
| `MARIADB_REPLICATION_USER`        | Replication username                                                        | `nil`     |
| `MARIADB_REPLICATION_PASSWORD`    | Password for the replication user                                           | `nil`     |
| `MARIADB_REPLICATION_SLAVE_DUMP`  | Dump master and re-seed slave on setup                                      | `false`   |
| `MARIADB_MASTER_HOST`             | Hostname of the master node (slave mode)                                    | `nil`     |
| `MARIADB_MASTER_PORT_NUMBER`      | Port of the master node (slave mode)                                        | `3306`    |
| `MARIADB_MASTER_ROOT_USER`        | Root username on the master host                                            | `root`    |
| `MARIADB_MASTER_ROOT_PASSWORD`    | Root password on the master host                                            | `nil`     |
| `MARIADB_MASTER_DELAY`            | Replication delay in seconds                                                | `0`       |

### SSL / TLS

| Name                              | Description                                                                 | Default   |
|-----------------------------------|-----------------------------------------------------------------------------|-----------|
| `MARIADB_CLIENT_ENABLE_SSL`       | Force SSL for client connections                                            | `no`      |
| `MARIADB_REPLICATION_USE_SSL`     | Force SSL for replication connections                                       | `no`      |
| `MARIADB_CLIENT_SSL_CA_FILE`      | Path to the CA certificate for SSL                                          | `nil`     |
| `MARIADB_CLIENT_SSL_CERT_FILE`    | Path to the client public-key certificate for SSL                           | `nil`     |
| `MARIADB_CLIENT_SSL_KEY_FILE`     | Path to the client private key for SSL                                      | `nil`     |
| `MARIADB_CLIENT_EXTRA_FLAGS`      | Extra flags for the `mysql` CLI tool                                        | `nil`     |

## Logging

The MariaDB container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami MariaDB © Broadcom, Inc.
