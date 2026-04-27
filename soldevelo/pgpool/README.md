# Pgpool-II packaged by SolDevelo

## What is Pgpool-II?

> Pgpool-II is a middleware that works between PostgreSQL servers and a PostgreSQL database client. It provides connection pooling, load balancing, automated failover, and replication features.

[Overview of Pgpool-II](https://www.pgpool.net/)  
Trademarks: This Docker image is maintained by **SolDevelo** and is based on the Bitnami Pgpool-II container. The respective trademarks mentioned (e.g., Pgpool-II) are owned by their respective companies. Use of these trademarks does not imply any affiliation or endorsement by those companies.

## TL;DR

```console
docker run --name pgpool docker.io/soldevelo/pgpool:latest
```

You can find the default credentials and available configuration options in the [Environment Variables](#environment-variables) section.

## Why use SolDevelo images?

These images are produced by SolDevelo and are based on Bitnami's excellent container images. They are published independently to reduce dependency on a single upstream registry and allow customization where needed.

## Get this image

The recommended way to get the SolDevelo Pgpool-II Docker image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/soldevelo/pgpool).

```console
docker pull docker.io/soldevelo/pgpool:latest
```

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://hub.docker.com/r/soldevelo/pgpool/tags/) in the Docker Hub Registry.

```console
docker pull docker.io/soldevelo/pgpool:[TAG]
```

If you wish, you can also build the image yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/pgpool/4/debian-12
docker build -t soldevelo/pgpool:latest .
```

## Why use a non-root container?

Non-root container images add an extra layer of security and are generally recommended for production environments. However, because they run as a non-root user, privileged tasks are typically off-limits.

## Connecting to other containers

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), Pgpool-II running inside a container can easily be accessed by your application containers and vice-versa. Containers attached to the same network can communicate with each other using the container name as the hostname.

## Usage with docker-compose

The included [`docker-compose.yml`](4/debian-12/docker-compose.yml) sets up a high-availability PostgreSQL cluster with two repmgr nodes and a Pgpool-II load balancer:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/pgpool/4/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Configuration

### Initializing with custom scripts

Every time the container is started, it will execute files with extension `.sh` located at `/docker-entrypoint-initdb.d`.

### Securing Pgpool-II traffic (TLS)

| Variable | Description | Default |
|---|---|---|
| `PGPOOL_ENABLE_TLS` | Enable TLS for traffic | `no` |
| `PGPOOL_TLS_CERT_FILE` | Certificate file for TLS | — |
| `PGPOOL_TLS_KEY_FILE` | Key for the certificate | — |
| `PGPOOL_TLS_CA_FILE` | CA file (enables mTLS) | — |
| `PGPOOL_TLS_PREFER_SERVER_CIPHERS` | Prefer server cipher list | `yes` |

### Re-attaching nodes

Pgpool-II does not reattach nodes automatically. To reattach a down node:

```console
# Find the node id
docker exec -it pgpool bash
PGPASSWORD=$PGPOOL_POSTGRES_PASSWORD psql -U $PGPOOL_POSTGRES_USERNAME -h localhost -c "show pool_nodes;"

# Reattach node 0
pcp_attach_node -h localhost -U $PGPOOL_ADMIN_USERNAME 0
```

## Environment variables

### Customizable environment variables

| Name | Description | Default |
|---|---|---|
| `PGPOOL_BACKEND_NODES` | Comma/semi-colon/space separated list of backend nodes (`id:host:port`) | Required |
| `PGPOOL_SR_CHECK_USER` | Streaming replication check username | — |
| `PGPOOL_SR_CHECK_PASSWORD` | Streaming replication check password | — |
| `PGPOOL_SR_CHECK_DATABASE` | Streaming replication check database | `postgres` |
| `PGPOOL_SR_CHECK_PERIOD` | Streaming replication check period (seconds) | `30` |
| `PGPOOL_POSTGRES_USERNAME` | PostgreSQL backend admin username | `postgres` |
| `PGPOOL_POSTGRES_PASSWORD` | PostgreSQL backend admin password | — |
| `PGPOOL_POSTGRES_CUSTOM_USERS` | Comma-separated list of custom users | — |
| `PGPOOL_POSTGRES_CUSTOM_PASSWORDS` | Comma-separated passwords for custom users | — |
| `PGPOOL_ADMIN_USERNAME` | Pgpool-II PCP admin username | — |
| `PGPOOL_ADMIN_PASSWORD` | Pgpool-II PCP admin password | — |
| `PGPOOL_ENABLE_LOAD_BALANCING` | Enable load balancing | `yes` |
| `PGPOOL_ENABLE_STATEMENT_LOAD_BALANCING` | Enable statement-level load balancing | `no` |
| `PGPOOL_DISABLE_LOAD_BALANCE_ON_WRITE` | Disable load balancing on write queries | `transaction` |
| `PGPOOL_ENABLE_POOL_HBA` | Enable host-based authentication | `yes` |
| `PGPOOL_ENABLE_POOL_PASSWD` | Enable pool password file | `yes` |
| `PGPOOL_ENABLE_CONNECTION_CACHE` | Enable connection cache | `yes` |
| `PGPOOL_AUTHENTICATION_METHOD` | Authentication method | `scram-sha-256` |
| `PGPOOL_PORT_NUMBER` | Pgpool-II port | `5432` |
| `PGPOOL_MAX_POOL` | Maximum cached connections | `15` |
| `PGPOOL_TIMEOUT` | Timeout (seconds) | `360` |
| `PGPOOL_CONNECT_TIMEOUT` | Connection timeout (milliseconds) | `10000` |
| `PGPOOL_HEALTH_CHECK_PERIOD` | Health check period (seconds) | `30` |
| `PGPOOL_HEALTH_CHECK_TIMEOUT` | Health check timeout (seconds) | `10` |
| `PGPOOL_HEALTH_CHECK_MAX_RETRIES` | Health check max retries | `5` |
| `PGPOOL_HEALTH_CHECK_RETRY_DELAY` | Health check retry delay (seconds) | `5` |
| `PGPOOL_HEALTH_CHECK_USER` | Health check username | `$PGPOOL_SR_CHECK_USER` |
| `PGPOOL_HEALTH_CHECK_PASSWORD` | Health check password | `$PGPOOL_SR_CHECK_PASSWORD` |
| `PGPOOL_ENABLE_LDAP` | Enable LDAP authentication | `no` |
| `PGPOOL_ENABLE_TLS` | Enable TLS | `no` |
| `PGPOOL_ENABLE_LOG_CONNECTIONS` | Log connections | `no` |
| `PGPOOL_ENABLE_LOG_HOSTNAME` | Show client hostnames in logs | `no` |
| `PGPOOL_ENABLE_LOG_PCP_PROCESSES` | Log PCP processes | `yes` |
| `PGPOOL_ENABLE_LOG_PER_NODE_STATEMENT` | Log SQL per DB node | `no` |
| `PGPOOL_USER_CONF_FILE` | Custom config file path to append | — |
| `PGPOOL_USER_HBA_FILE` | Custom HBA file path (overwrites default) | — |
| `PGPOOL_AUTO_FAILBACK` | Enable auto-failback | `no` |
| `PGPOOL_DISCARD_STATUS` | Discard status file on restart | `yes` |
| `PGPOOL_FAILOVER_ON_BACKEND_SHUTDOWN` | Failover on backend shutdown | `on` |
| `PGPOOL_FAILOVER_ON_BACKEND_ERROR` | Failover on backend error | `off` |
| `PGPOOL_BACKEND_APPLICATION_NAMES` | Backend application names | — |
| `PGPOOL_AES_KEY` | AES key | random |

## Logging

The container sends logs to `stdout`. To view the logs:

```console
docker logs pgpool
```

## License

Copyright &copy; 2026 SolDevelo. Based on work by Broadcom, Inc.

Licensed under the Apache License, Version 2.0. See [LICENSE.md](../../LICENSE.md).

Based on [Bitnami Pgpool](https://github.com/bitnami/containers/tree/main/bitnami/pgpool) © Broadcom, Inc.
