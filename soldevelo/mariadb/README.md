# MariaDB packaged by SolDevelo

[MariaDB](https://mariadb.org/) is a community-developed, commercially supported fork of the MySQL relational database management system.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami MariaDB](https://github.com/bitnami/containers/tree/main/bitnami/mariadb) container.

## TL;DR

```console
docker run --name mariadb -e ALLOW_EMPTY_PASSWORD=yes docker.io/soldevelo/mariadb:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/mariadb/12.2/debian-12/docker-compose.yml > docker-compose.yml
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
cd containers/soldevelo/mariadb/12.2/debian-12
docker build -t soldevelo/mariadb:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/mariadb/12.2/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

| Name                          | Description                                       | Default   |
|-------------------------------|---------------------------------------------------|-----------|
| `ALLOW_EMPTY_PASSWORD`        | Allow access without a password (dev only)        | `no`      |
| `MARIADB_ROOT_PASSWORD`       | MariaDB root password                             | `nil`     |
| `MARIADB_USER`                | MariaDB application username                      | `nil`     |
| `MARIADB_PASSWORD`            | MariaDB application password                      | `nil`     |
| `MARIADB_DATABASE`            | Database to create on first boot                  | `nil`     |
| `MARIADB_PORT_NUMBER`         | MariaDB server port                               | `3306`    |
| `MARIADB_CHARACTER_SET`       | MariaDB default character set                     | `utf8mb4` |
| `MARIADB_COLLATE`             | MariaDB default collation                         | `utf8mb4_unicode_ci` |
| `MARIADB_REPLICATION_MODE`    | Replication mode (`master` or `slave`)            | `nil`     |
| `MARIADB_REPLICATION_USER`    | MariaDB replication user                          | `nil`     |
| `MARIADB_REPLICATION_PASSWORD`| Password for the replication user                 | `nil`     |
| `MARIADB_MASTER_HOST`         | Master host for slave replication                 | `nil`     |
| `MARIADB_MASTER_PORT_NUMBER`  | Master port for slave replication                 | `3306`    |

## Logging

The MariaDB container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami MariaDB © Broadcom, Inc.
