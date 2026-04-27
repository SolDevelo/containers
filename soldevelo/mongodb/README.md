# MongoDB packaged by SolDevelo

[MongoDB](https://www.mongodb.com/) is a general-purpose, document-based, distributed database built for modern application developers.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami MongoDB](https://github.com/bitnami/containers/tree/main/bitnami/mongodb) container.

## TL;DR

```console
docker run --name mongodb docker.io/soldevelo/mongodb:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/mongodb/8.2/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Why SolDevelo images?

SolDevelo images are built on top of Bitnami's work, providing the same security-focused, non-root container approach while being maintained and published by SolDevelo for its infrastructure needs.

## Get this image

```console
docker pull docker.io/soldevelo/mongodb:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/mongodb/8.2/debian-12
docker build -t soldevelo/mongodb:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/mongodb/8.2/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

| Name                            | Description                                       | Default   |
|---------------------------------|---------------------------------------------------|-----------|
| `MONGODB_ROOT_USER`             | MongoDB root username                             | `root`    |
| `MONGODB_ROOT_PASSWORD`         | MongoDB root password                             | `nil`     |
| `MONGODB_USERNAME`              | MongoDB application username                      | `nil`     |
| `MONGODB_PASSWORD`              | MongoDB application password                      | `nil`     |
| `MONGODB_DATABASE`              | Database to create on first boot                  | `nil`     |
| `MONGODB_PORT_NUMBER`           | MongoDB server port                               | `27017`   |
| `ALLOW_EMPTY_PASSWORD`          | Allow access without a password (dev only)        | `no`      |
| `MONGODB_REPLICA_SET_MODE`      | Replica set mode (`primary`, `secondary`, `arbiter`) | `nil`  |
| `MONGODB_REPLICA_SET_NAME`      | Replica set name                                  | `rs0`     |
| `MONGODB_INITIAL_PRIMARY_HOST`  | Primary host for secondary/arbiter nodes          | `nil`     |
| `MONGODB_INITIAL_PRIMARY_PORT_NUMBER` | Primary port for secondary/arbiter nodes    | `27017`   |
| `MONGODB_REPLICA_SET_KEY`       | Replica set shared key                            | `nil`     |

## Logging

The MongoDB container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami MongoDB © Broadcom, Inc.
