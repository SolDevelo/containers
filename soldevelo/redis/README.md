# Redis packaged by SolDevelo

[Redis](https://redis.io/) is an open-source, in-memory data structure store used as a database, cache, and message broker.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami Redis](https://github.com/bitnami/containers/tree/main/bitnami/redis) container.

## TL;DR

```console
docker run --name redis docker.io/soldevelo/redis:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/redis/8.10/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Why SolDevelo images?

SolDevelo images are built on top of Bitnami's work, providing the same security-focused, non-root container approach while being maintained and published by SolDevelo for its infrastructure needs.

## Get this image

```console
docker pull docker.io/soldevelo/redis:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/redis/8.10/debian-12
docker build -t soldevelo/redis:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/redis/8.10/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

| Name                             | Description                                          | Default                                    |
|----------------------------------|------------------------------------------------------|--------------------------------------------|
| `ALLOW_EMPTY_PASSWORD`           | Allow password-less access                           | `no`                                       |
| `REDIS_PASSWORD`                 | Password for Redis                                   | `nil`                                      |
| `REDIS_PORT_NUMBER`              | Redis port number                                    | `6379`                                     |
| `REDIS_ALLOW_REMOTE_CONNECTIONS` | Allow remote connection to the service               | `yes`                                      |
| `REDIS_DISABLE_COMMANDS`         | Commands to disable in Redis                         | `nil`                                      |
| `REDIS_DATABASE`                 | Default Redis database                               | `redis`                                    |
| `REDIS_AOF_ENABLED`              | Enable AOF persistence                               | `yes`                                      |
| `REDIS_RDB_POLICY`               | Enable RDB policy persistence                        | `nil`                                      |
| `REDIS_RDB_POLICY_DISABLED`      | Allows to enable RDB policy persistence              | `no`                                       |
| `REDIS_EXTRA_FLAGS`              | Additional flags passed to `redis-server`            | `nil`                                      |
| `REDIS_ACLFILE`                  | Redis ACL file                                       | `nil`                                      |
| `REDIS_IO_THREADS`               | Number of I/O threads                                | `nil`                                      |
| `REDIS_IO_THREADS_DO_READS`      | Enable multithreading when reading socket            | `nil`                                      |
| `REDIS_DATA_DIR`                 | Redis data directory                                 | `${REDIS_VOLUME_DIR}/data`                 |
| `REDIS_OVERRIDES_FILE`           | Redis config overrides file                          | `${REDIS_MOUNTED_CONF_DIR}/overrides.conf` |
| `REDIS_REPLICATION_MODE`         | Replication mode (`master` or `slave`)               | `nil`                                      |
| `REDIS_REPLICA_IP`               | The replication announce IP                          | `nil`                                      |
| `REDIS_REPLICA_PORT`             | The replication announce port                        | `nil`                                      |
| `REDIS_MASTER_HOST`              | Redis master host (used by replicas)                 | `nil`                                      |
| `REDIS_MASTER_PORT_NUMBER`       | Redis master host port (used by replicas)            | `6379`                                     |
| `REDIS_MASTER_PASSWORD`          | Redis master node password                           | `nil`                                      |
| `REDIS_SENTINEL_MASTER_NAME`     | Redis Sentinel master name                           | `nil`                                      |
| `REDIS_SENTINEL_HOST`            | Redis Sentinel host                                  | `nil`                                      |
| `REDIS_SENTINEL_PORT_NUMBER`     | Redis Sentinel host port                             | `26379`                                    |
| `REDIS_SENTINEL_PASSWORD`        | Redis Sentinel password                              | `nil`                                      |
| `REDIS_TLS_ENABLED`              | Enable TLS                                           | `no`                                       |
| `REDIS_TLS_PORT_NUMBER`          | Redis TLS port (requires `REDIS_TLS_ENABLED=yes`)    | `6379`                                     |
| `REDIS_TLS_CERT_FILE`            | Redis TLS certificate file                           | `nil`                                      |
| `REDIS_TLS_KEY_FILE`             | Redis TLS key file                                   | `nil`                                      |
| `REDIS_TLS_KEY_FILE_PASS`        | Redis TLS key file passphrase                        | `nil`                                      |
| `REDIS_TLS_CA_FILE`              | Redis TLS CA file                                    | `nil`                                      |
| `REDIS_TLS_CA_DIR`               | Directory containing TLS CA certificates             | `nil`                                      |
| `REDIS_TLS_DH_PARAMS_FILE`       | Redis TLS DH parameter file                          | `nil`                                      |
| `REDIS_TLS_AUTH_CLIENTS`         | Enable Redis TLS client authentication               | `yes`                                      |

## Logging

The Redis container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami Redis © Broadcom, Inc.

Bitnami is a trademark of Broadcom Inc. This image is an independent build maintained by SolDevelo and is not affiliated with, endorsed or certified by Broadcom Inc. References to Bitnami describe where the packaging scripts come from.
