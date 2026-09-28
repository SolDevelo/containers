# Object Storage based on MinIO® packaged by SolDevelo

[MinIO](https://github.com/minio/minio) is a high-performance, S3-compatible object storage server.

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami Object Storage based on MinIO](https://github.com/bitnami/containers/tree/main/bitnami/minio) container. It is a drop-in replacement for `bitnami/minio` and `bitnamilegacy/minio`, with the same environment variables, data directory (`/bitnami/minio/data`) and non-root user.

> **Upstream status:** the MinIO community edition is archived upstream, and neither MinIO nor Bitnami publishes community images on Docker Hub any more. The images here are built from Bitnami's final published builds of each release line and are provided as-is, for workloads that still depend on the Bitnami MinIO image layout.

## Source code and license

MinIO is licensed under the [GNU AGPLv3](https://www.gnu.org/licenses/agpl-3.0.html). The images contain unmodified MinIO builds. Each image lists the exact source it was built from in `/opt/bitnami/minio/licenses/agpl-source-links.txt`:

- 2024.x and 2025.x: [minio/minio](https://github.com/minio/minio) release tags, e.g. `RELEASE.2025-10-15T17-29-55Z`.
- 2026.7: [chainguard-forks/minio](https://github.com/chainguard-forks/minio), a maintained fork of the archived upstream, tag `RELEASE.2026-07-17T12-07-51Z`.

```console
docker run --rm --entrypoint cat docker.io/soldevelo/minio:latest /opt/bitnami/minio/licenses/agpl-source-links.txt
```

MinIO® is a registered trademark of MinIO, Inc. Bitnami is a trademark of Broadcom Inc. This image is an independent, unofficial build: it is not affiliated with, endorsed or certified by MinIO, Inc. or Broadcom Inc. References to Bitnami describe where the packaging scripts come from.

## TL;DR

```console
docker run --name minio -e MINIO_ROOT_USER=admin -e MINIO_ROOT_PASSWORD=change-me-please docker.io/soldevelo/minio:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/minio/2026.7/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Why SolDevelo images?

SolDevelo images are built on top of Bitnami's work, providing the same security-focused, non-root container approach while being maintained and published by SolDevelo for its infrastructure needs.

## Supported tags

Each release line has its own tag, so a pinned `bitnami/minio:<version>` can be switched to the same line here:

| Tag | MinIO release |
|---|---|
| `2026.7`, `2026.7.17`, `latest` | 2026.7.17 |
| `2025.10`, `2025.10.15` | 2025.10.15 |
| `2025.7`, `2025.7.23` | 2025.7.23 |
| `2025.4`, `2025.4.22` | 2025.4.22 |
| `2024.12`, `2024.12.18` | 2024.12.18 |
| `2024.11`, `2024.11.7` | 2024.11.7 |

Every tag is also published as `<version>-debian-12-r<revision>`, e.g. `2025.7.23-debian-12-r0`.

## Get this image

```console
docker pull docker.io/soldevelo/minio:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/minio/2026.7/debian-12
docker build -t soldevelo/minio:latest .
```

## Non-root container

This image runs as a non-root user (UID `1001`), following the same security model as Bitnami images.

## Persisting your data

Mount a volume at `/bitnami/minio/data`:

```console
docker run --name minio -v /path/to/minio-persistence:/bitnami/minio/data -e MINIO_ROOT_USER=admin -e MINIO_ROOT_PASSWORD=change-me-please docker.io/soldevelo/minio:latest
```

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/minio/2026.7/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

`docker-compose-distributed.yml` and `docker-compose-distributed-multidrive.yml` in the same directory show a four-node distributed setup.

## Environment variables

### Customizable environment variables

| Name | Description | Default Value |
|---|---|---|
| `MINIO_DATA_DIR` | MinIO directory for data. | `/bitnami/minio/data` |
| `MINIO_API_PORT_NUMBER` | MinIO API port number. | `9000` |
| `MINIO_BROWSER` | Enable / disable the embedded MinIO Console (2025.7 and newer). | `off` |
| `MINIO_CONSOLE_PORT_NUMBER` | MinIO Console port number. | `9001` |
| `MINIO_SCHEME` | MinIO web scheme. | `http` |
| `MINIO_SKIP_CLIENT` | Skip MinIO client configuration. | `no` |
| `MINIO_DISTRIBUTED_MODE_ENABLED` | Enable MinIO distributed mode. | `no` |
| `MINIO_DEFAULT_BUCKETS` | MinIO default buckets. | `nil` |
| `MINIO_STARTUP_TIMEOUT` | MinIO startup timeout. | `10` |
| `MINIO_SERVER_URL` | MinIO server external URL. | `$MINIO_SCHEME://localhost:$MINIO_API_PORT_NUMBER` |
| `MINIO_APACHE_CONSOLE_HTTP_PORT_NUMBER` | MinIO Console UI HTTP port, exposed via Apache with basic authentication. | `80` |
| `MINIO_APACHE_CONSOLE_HTTPS_PORT_NUMBER` | MinIO Console UI HTTPS port, exposed via Apache with basic authentication. | `443` |
| `MINIO_APACHE_API_HTTP_PORT_NUMBER` | MinIO API HTTP port, exposed via Apache with basic authentication. | `9000` |
| `MINIO_APACHE_API_HTTPS_PORT_NUMBER` | MinIO API HTTPS port, exposed via Apache with basic authentication. | `9443` |
| `MINIO_FORCE_NEW_KEYS` | Force recreating MinIO keys. | `no` |
| `MINIO_ROOT_USER` | MinIO root user name. | `minio` |
| `MINIO_ROOT_PASSWORD` | Password for MinIO root user. | `nil` |

MinIO itself can also be configured through its own environment variables, as described in the [MinIO server configuration guide](https://github.com/minio/minio/tree/master/docs/config).

The MinIO Client (`mc`) is included in the image, for example:

```console
docker exec minio mc admin info local
```

### Creating default buckets

Set `MINIO_DEFAULT_BUCKETS` to a comma-separated list of bucket names to create them during the first initialization of the container.

### Securing access with TLS

Set `MINIO_SCHEME` to `https` and mount your key and certificate files at `/certs`.

### Distributed mode

To set up a highly-available distributed deployment, set these variables on every node:

- `MINIO_DISTRIBUTED_MODE_ENABLED`: set to `yes`.
- `MINIO_DISTRIBUTED_NODES`: list of MinIO node hosts. Available separators are ' ', ',' and ';'. Ellipsis syntax (`{1..n}`) is supported for nodes and for drives per node.
- `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`: must be the same on every node.

### Reconfiguring keys on container restarts

MinIO sets the access and secret key during the first initialization, from `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`. With persistence enabled, later restarts reuse those keys and ignore the variables. Set `MINIO_FORCE_NEW_KEYS=yes` to reconfigure them from the current values.

## Logging

The MinIO container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami Object Storage based on MinIO © Broadcom, Inc. MinIO itself is licensed under the GNU AGPLv3.
