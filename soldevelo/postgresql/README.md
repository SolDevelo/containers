# PostgreSQL packaged by SolDevelo

[PostgreSQL](https://www.postgresql.org/) is a powerful, open-source object-relational database system with over 35 years of active development.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami PostgreSQL](https://github.com/bitnami/containers/tree/main/bitnami/postgresql) container.

## TL;DR

```console
docker run --name postgresql -e ALLOW_EMPTY_PASSWORD=yes docker.io/soldevelo/postgresql:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/postgresql/18/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Why SolDevelo images?

SolDevelo images are built on top of Bitnami's work, providing the same security-focused, non-root container approach while being maintained and published by SolDevelo for its infrastructure needs.

## Get this image

```console
docker pull docker.io/soldevelo/postgresql:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/postgresql/18/debian-12
docker build -t soldevelo/postgresql:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/postgresql/18/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

| Name                            | Description                                           | Default      |
|---------------------------------|-------------------------------------------------------|--------------|
| `ALLOW_EMPTY_PASSWORD`          | Allow access without a password (dev only)            | `no`         |
| `POSTGRESQL_USERNAME`           | PostgreSQL admin username                             | `postgres`   |
| `POSTGRESQL_PASSWORD`           | PostgreSQL admin password                             | `nil`        |
| `POSTGRESQL_DATABASE`           | Database to create on first boot                      | `nil`        |
| `POSTGRESQL_PORT_NUMBER`        | PostgreSQL server port                                | `5432`       |
| `POSTGRESQL_POSTGRES_PASSWORD`  | Password for the `postgres` superuser                 | `nil`        |
| `POSTGRESQL_REPLICATION_MODE`   | Replication mode (`master` or `slave`)                | `nil`        |
| `POSTGRESQL_REPLICATION_USER`   | PostgreSQL replication user                           | `nil`        |
| `POSTGRESQL_REPLICATION_PASSWORD` | Password for the replication user                   | `nil`        |
| `POSTGRESQL_INITDB_ARGS`        | Extra arguments for `initdb`                          | `nil`        |

## Logging

The PostgreSQL container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami PostgreSQL © Broadcom, Inc.
