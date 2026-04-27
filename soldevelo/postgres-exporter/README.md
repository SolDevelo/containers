# PostgreSQL Exporter packaged by SolDevelo

## What is PostgreSQL Exporter?

> PostgreSQL Exporter gathers PostgreSQL metrics for Prometheus consumption.

[Overview of PostgreSQL Exporter](https://github.com/prometheus-community/postgres_exporter)  
Trademarks: This Docker image is maintained by **SolDevelo** and is based on the Bitnami PostgreSQL Exporter container. The respective trademarks mentioned (e.g., PostgreSQL) are owned by their respective companies. Use of these trademarks does not imply any affiliation or endorsement by those companies.

## TL;DR

```console
docker run --name postgres-exporter \
  -e DATA_SOURCE_NAME="postgresql://user:password@host:5432/dbname?sslmode=disable" \
  docker.io/soldevelo/postgres-exporter:latest
```

## Why use SolDevelo images?

These images are produced by SolDevelo and are based on Bitnami's excellent container images. They are published independently to reduce dependency on a single upstream registry and allow customization where needed.

## Get this image

The recommended way to get the SolDevelo PostgreSQL Exporter Docker image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/soldevelo/postgres-exporter).

```console
docker pull docker.io/soldevelo/postgres-exporter:latest
```

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://hub.docker.com/r/soldevelo/postgres-exporter/tags/) in the Docker Hub Registry.

```console
docker pull docker.io/soldevelo/postgres-exporter:[TAG]
```

If you wish, you can also build the image yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/postgres-exporter/0/debian-12
docker build -t soldevelo/postgres-exporter:latest .
```

## Why use a non-root container?

Non-root container images add an extra layer of security and are generally recommended for production environments. However, because they run as a non-root user, privileged tasks are typically off-limits.

## Connecting to other containers

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), the PostgreSQL Exporter running inside a container can easily be connected to a PostgreSQL instance running in another container.

### Step 1: Create a network

```console
docker network create monitoring-network --driver bridge
```

### Step 2: Start PostgreSQL

```console
docker run -d --name postgresql \
  --network monitoring-network \
  -e POSTGRESQL_PASSWORD=mypassword \
  docker.io/soldevelo/postgresql-repmgr:17
```

### Step 3: Start the exporter

```console
docker run -d --name postgres-exporter \
  --network monitoring-network \
  -p 9187:9187 \
  -e DATA_SOURCE_NAME="postgresql://postgres:mypassword@postgresql:5432/postgres?sslmode=disable" \
  docker.io/soldevelo/postgres-exporter:latest
```

Metrics will be available at `http://localhost:9187/metrics`.

## Using docker-compose

The included [`docker-compose.yml`](0/debian-12/docker-compose.yml) starts a PostgreSQL instance and the exporter side by side:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/postgres-exporter/0/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Configuration

All configuration is done via environment variables or command-line flags. Find the full flag reference in the [postgres_exporter documentation](https://github.com/prometheus-community/postgres_exporter#flags).

### Key environment variables

| Variable | Description | Default |
|---|---|---|
| `DATA_SOURCE_NAME` | PostgreSQL DSN, e.g. `postgresql://user:pass@host:5432/db?sslmode=disable` | Required |
| `DATA_SOURCE_URI` | Alternative: host:port/dbname without scheme | — |
| `DATA_SOURCE_USER` | PostgreSQL username (used with `DATA_SOURCE_URI`) | — |
| `DATA_SOURCE_PASS` | PostgreSQL password (used with `DATA_SOURCE_URI`) | — |
| `PG_EXPORTER_WEB_LISTEN_ADDRESS` | Address and port to listen on | `:9187` |
| `PG_EXPORTER_WEB_TELEMETRY_PATH` | Path under which to expose metrics | `/metrics` |
| `PG_EXPORTER_DISABLE_DEFAULT_METRICS` | Disable built-in default metrics | `false` |
| `PG_EXPORTER_DISABLE_SETTINGS_METRICS` | Disable `pg_settings` metrics | `false` |
| `PG_EXPORTER_AUTO_DISCOVER_DATABASES` | Discover and scrape all databases | `false` |
| `PG_EXPORTER_EXTEND_QUERY_PATH` | Path to a YAML file with additional queries | — |
| `PG_EXPORTER_CONSTANT_LABELS` | Comma-separated `label=value` pairs added to all metrics | — |
| `PG_EXPORTER_INCLUDE_DATABASES` | Comma-separated list of databases to include (with auto-discover) | — |
| `PG_EXPORTER_EXCLUDE_DATABASES` | Comma-separated list of databases to exclude (with auto-discover) | — |

## Logging

The container sends logs to `stdout`. To view the logs:

```console
docker logs postgres-exporter
```

## License

Copyright &copy; 2026 SolDevelo. Based on work by Broadcom, Inc.

Licensed under the Apache License, Version 2.0. See [LICENSE.md](../../LICENSE.md).

Based on [Bitnami PostgreSQL Exporter](https://github.com/bitnami/containers/tree/main/bitnami/postgres-exporter) © Broadcom, Inc.
