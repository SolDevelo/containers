# ZooKeeper packaged by SolDevelo

## What is Apache ZooKeeper?

> Apache ZooKeeper provides a reliable, centralised register of configuration data and services for distributed applications.

[Overview of Apache ZooKeeper](https://zookeeper.apache.org/)  
Trademarks: This Docker image is maintained by **SolDevelo** and is based on the [Bitnami ZooKeeper](https://github.com/bitnami/containers/tree/main/bitnami/zookeeper) container. The respective trademarks mentioned (e.g., Apache ZooKeeper) are owned by their respective companies. Use of these trademarks does not imply any affiliation or endorsement by those companies.

## TL;DR

```console
docker run --name zookeeper -e ALLOW_EMPTY_PASSWORD=yes docker.io/soldevelo/zookeeper:latest
```

## Get this image

```console
docker pull docker.io/soldevelo/zookeeper:latest
```

To use a specific version:

```console
docker pull docker.io/soldevelo/zookeeper:[TAG]
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/zookeeper/3.9/debian-12
docker build -t soldevelo/zookeeper:latest .
```

## Using docker-compose

```console
cd containers/soldevelo/zookeeper/3.9/debian-12
docker compose up
```

## Persisting your data

Mount a volume at `/bitnami/zookeeper` to persist data across container restarts:

```yaml
services:
  zookeeper:
    image: docker.io/soldevelo/zookeeper:3.9
    volumes:
      - /path/to/zookeeper-persistence:/bitnami/zookeeper
    environment:
      - ALLOW_EMPTY_PASSWORD=yes
```

> **Note:** As this is a non-root container, the mounted directory must be writable by UID `1001`.

## Configuration

ZooKeeper is configured via environment variables. Key variables:

| Variable | Default | Description |
|---|---|---|
| `ALLOW_EMPTY_PASSWORD` | `no` | Allow unauthenticated access (set `yes` for dev) |
| `ZOO_SERVER_ID` | `1` | Unique server ID in a cluster |
| `ZOO_PORT_NUMBER` | `2181` | Client port |
| `ZOO_TICK_TIME` | `2000` | ZooKeeper tick time in milliseconds |
| `ZOO_MAX_CLIENT_CNXNS` | `60` | Max concurrent client connections |
| `ZOO_SERVERS` | _(unset)_ | Cluster server list (e.g. `server1:2888:3888`) |
| `ZOO_HEAP_SIZE` | `1024` | JVM heap size in MB |
| `ZOO_LOG_LEVEL` | `ERROR` | Log level (`INFO`, `WARN`, `ERROR`) |
| `ZOO_ENABLE_AUTH` | `no` | Enable SASL authentication |
| `ZOO_CLIENT_USER` | _(unset)_ | SASL client username |
| `ZOO_CLIENT_PASSWORD` | _(unset)_ | SASL client password |
| `ZOO_SERVER_USERS` | _(unset)_ | Comma-separated SASL server usernames |
| `ZOO_SERVER_PASSWORDS` | _(unset)_ | Comma-separated SASL server passwords |

See the [Bitnami ZooKeeper documentation](https://github.com/bitnami/containers/tree/main/bitnami/zookeeper) for the full list.

## Ports

| Port | Description |
|---|---|
| `2181` | Client connections |
| `2888` | Peer connections (cluster) |
| `3888` | Leader election (cluster) |
| `8080` | AdminServer HTTP port |

## License

Apache-2.0. Based on Bitnami ZooKeeper © Broadcom, Inc.
