# Redis packaged by SolDevelo

[Redis](https://redis.io/) is an open-source, in-memory data structure store used as a database, cache, and message broker.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami Redis](https://github.com/bitnami/containers/tree/main/bitnami/redis) container.

## TL;DR

```console
docker run --name redis docker.io/soldevelo/redis:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/redis/8.6/debian-12/docker-compose.yml > docker-compose.yml
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
cd containers/soldevelo/redis/8.6/debian-12
docker build -t soldevelo/redis:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/redis/8.6/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

| Name                         | Description                                    | Default |
|------------------------------|------------------------------------------------|---------|
| `ALLOW_EMPTY_PASSWORD`       | Allow access without a password (dev only)     | `no`    |
| `REDIS_PASSWORD`             | Password for the Redis server                  | `nil`   |
| `REDIS_PORT_NUMBER`          | Redis server port                              | `6379`  |
| `REDIS_DISABLE_COMMANDS`     | Comma-separated list of disabled commands      | `nil`   |
| `REDIS_AOF_ENABLED`          | Enable AOF persistence                         | `yes`   |
| `REDIS_REPLICATION_MODE`     | Replication mode (`master` or `slave`)         | `nil`   |
| `REDIS_MASTER_HOST`          | Master host (slave mode)                       | `nil`   |
| `REDIS_MASTER_PORT_NUMBER`   | Master port (slave mode)                       | `6379`  |
| `REDIS_MASTER_PASSWORD`      | Master password (slave mode)                   | `nil`   |

## Logging

The Redis container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami Redis © Broadcom, Inc.
