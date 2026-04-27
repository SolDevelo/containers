# RabbitMQ packaged by SolDevelo

[RabbitMQ](https://www.rabbitmq.com/) is an open-source message broker that implements the Advanced Message Queuing Protocol (AMQP).

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami RabbitMQ](https://github.com/bitnami/containers/tree/main/bitnami/rabbitmq) container.

## TL;DR

```console
docker run --name rabbitmq docker.io/soldevelo/rabbitmq:latest
```

Using Docker Compose:

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/rabbitmq/4.3/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Get this image

```console
docker pull docker.io/soldevelo/rabbitmq:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/rabbitmq/4.3/debian-12
docker build -t soldevelo/rabbitmq:latest .
```

## Using docker-compose

```console
curl -sSL https://raw.githubusercontent.com/soldevelo/containers/main/soldevelo/rabbitmq/4.3/debian-12/docker-compose.yml > docker-compose.yml
docker compose up -d
```

## Environment variables

### Core settings

| Name                                   | Description                                                                                      | Default                |
|----------------------------------------|--------------------------------------------------------------------------------------------------|------------------------|
| `RABBITMQ_USERNAME`                    | RabbitMQ user name.                                                                              | `user`                 |
| `RABBITMQ_PASSWORD`                    | RabbitMQ user password.                                                                          | `bitnami`              |
| `RABBITMQ_SECURE_PASSWORD`             | Whether to set the RabbitMQ password securely. Incompatible with loading external definitions.   | `no`                   |
| `RABBITMQ_UPDATE_PASSWORD`             | Whether to update the password on container restart.                                             | `no`                   |
| `RABBITMQ_NODE_NAME`                   | RabbitMQ node name.                                                                              | `rabbit@localhost`     |
| `RABBITMQ_NODE_PORT_NUMBER`            | RabbitMQ node port number.                                                                       | `5672`                 |
| `RABBITMQ_NODE_TYPE`                   | RabbitMQ node type.                                                                              | `stats`                |
| `RABBITMQ_NODE_DEFAULT_QUEUE_TYPE`     | RabbitMQ default queue type node-wide.                                                           | `nil`                  |
| `RABBITMQ_USE_LONGNAME`                | Whether to use fully qualified names to identify nodes.                                          | `false`                |
| `RABBITMQ_FORCE_BOOT`                  | Force a node to start even if it was not the last to shut down.                                  | `no`                   |
| `RABBITMQ_VHOST`                       | RabbitMQ vhost.                                                                                  | `/`                    |
| `RABBITMQ_VHOSTS`                      | List of additional virtual hosts. Default queue type can be set via colon separator.             | `nil`                  |
| `RABBITMQ_ERL_COOKIE`                  | Erlang cookie to determine whether different nodes are allowed to communicate with each other.   | `nil`                  |
| `RABBITMQ_CONF_FILE`                   | RabbitMQ configuration file.                                                                     | `${RABBITMQ_CONF_DIR}/rabbitmq.conf` |
| `RABBITMQ_DEFINITIONS_FILE`            | External RabbitMQ definitions file to load. Incompatible with secure password.                   | `/app/load_definition.json` |
| `RABBITMQ_LOAD_DEFINITIONS`            | Whether to load external RabbitMQ definitions.                                                   | `no`                   |

### Management

| Name                                         | Description                                                              | Default   |
|----------------------------------------------|--------------------------------------------------------------------------|-----------|
| `RABBITMQ_MANAGEMENT_PORT_NUMBER`            | RabbitMQ management server port number.                                  | `15672`   |
| `RABBITMQ_MANAGEMENT_BIND_IP`               | RabbitMQ management server bind IP address.                              | `0.0.0.0` |
| `RABBITMQ_MANAGEMENT_ALLOW_WEB_ACCESS`      | Allow web access to the management portal for `RABBITMQ_USERNAME`.       | `false`   |

### Clustering

| Name                                         | Description                                                              | Default   |
|----------------------------------------------|--------------------------------------------------------------------------|-----------|
| `RABBITMQ_CLUSTER_NODE_NAME`                 | RabbitMQ cluster node name. Ensure a valid hostname is also set.         | `nil`     |
| `RABBITMQ_CLUSTER_PARTITION_HANDLING`        | RabbitMQ cluster partition recovery mechanism.                           | `ignore`  |
| `RABBITMQ_CLUSTER_REBALANCE`                 | Rebalance the RabbitMQ cluster.                                          | `false`   |
| `RABBITMQ_CLUSTER_REBALANCE_ATTEMPTS`        | Max attempts for the rebalance check to run.                             | `100`     |

### Resource limits

| Name                                         | Description                                                                                        | Default   |
|----------------------------------------------|----------------------------------------------------------------------------------------------------|--------|
| `RABBITMQ_DISK_FREE_RELATIVE_LIMIT`          | Disk relative free space limit of the partition on which RabbitMQ is storing data.                 | `1.0`  |
| `RABBITMQ_DISK_FREE_ABSOLUTE_LIMIT`          | Disk absolute free space limit (takes precedence over the relative limit).                         | `nil`  |
| `RABBITMQ_VM_MEMORY_HIGH_WATERMARK`          | High memory watermark. Can be an absolute value or a relative value (e.g. `0.4` or `40%`).        | `nil`  |

### TLS / SSL

| Name                                            | Description                                                                                      | Default         |
|-------------------------------------------------|--------------------------------------------------------------------------------------------------|-----------------|
| `RABBITMQ_NODE_SSL_PORT_NUMBER`                 | RabbitMQ node port number for SSL connections.                                                   | `5671`          |
| `RABBITMQ_SSL_CACERTFILE`                       | Path to the RabbitMQ server SSL CA certificate file.                                             | `nil`           |
| `RABBITMQ_SSL_CERTFILE`                         | Path to the RabbitMQ server SSL certificate file.                                                | `nil`           |
| `RABBITMQ_SSL_KEYFILE`                          | Path to the RabbitMQ server SSL certificate key file.                                            | `nil`           |
| `RABBITMQ_SSL_PASSWORD`                         | RabbitMQ server SSL certificate key password.                                                    | `nil`           |
| `RABBITMQ_SSL_DEPTH`                            | Maximum number of non-self-issued intermediate certificates in a valid certification path.        | `nil`           |
| `RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT`             | Whether to reject TLS connections if client fails to provide a certificate.                      | `no`            |
| `RABBITMQ_SSL_VERIFY`                           | Whether to enable peer SSL certificate verification. Valid: `verify_none`, `verify_peer`.        | `verify_none`   |
| `RABBITMQ_MANAGEMENT_SSL_PORT_NUMBER`           | RabbitMQ management server port for SSL/TLS connections.                                         | `15671`         |
| `RABBITMQ_MANAGEMENT_SSL_CACERTFILE`            | Path to the management server SSL CA certificate file.                                           | `$RABBITMQ_SSL_CACERTFILE` |
| `RABBITMQ_MANAGEMENT_SSL_CERTFILE`              | Path to the management server SSL certificate file.                                              | `$RABBITMQ_SSL_CERTFILE`   |
| `RABBITMQ_MANAGEMENT_SSL_KEYFILE`               | Path to the management server SSL certificate key file.                                          | `$RABBITMQ_SSL_KEYFILE`    |
| `RABBITMQ_MANAGEMENT_SSL_PASSWORD`              | Management server SSL certificate key password.                                                  | `$RABBITMQ_SSL_PASSWORD`   |
| `RABBITMQ_MANAGEMENT_SSL_DEPTH`                 | Maximum number of non-self-issued intermediate certificates for the management server.            | `nil`           |
| `RABBITMQ_MANAGEMENT_SSL_FAIL_IF_NO_PEER_CERT`  | Whether to reject TLS connections if client fails to provide a certificate for management.       | `yes`           |
| `RABBITMQ_MANAGEMENT_SSL_VERIFY`                | Whether to enable peer SSL certificate verification for management. Valid: `verify_none`, `verify_peer`. | `verify_peer` |

### LDAP

| Name                           | Description                                                                   | Default |
|--------------------------------|-------------------------------------------------------------------------------|---------|
| `RABBITMQ_ENABLE_LDAP`         | Enable the LDAP configuration.                                                | `no`    |
| `RABBITMQ_LDAP_TLS`            | Enable secure LDAP configuration.                                             | `no`    |
| `RABBITMQ_LDAP_SERVERS`        | Comma, semi-colon or space separated list of LDAP server hostnames.           | `nil`   |
| `RABBITMQ_LDAP_SERVERS_PORT`   | LDAP servers port.                                                            | `389`   |
| `RABBITMQ_LDAP_USER_DN_PATTERN`| DN used to bind to LDAP in the form `cn=$${username},dc=example,dc=org`.     | `nil`   |

## Logging

The RabbitMQ container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami RabbitMQ © Broadcom, Inc.
