# Soldevelo package for Confluent Schema Registry

> Confluent Schema Registry provides a RESTful interface by adding a serving layer for your metadata on top of Kafka. It expands Kafka enabling support for Apache Avro, JSON, and Protobuf schemas.

[Overview of Confluent Schema Registry](https://www.confluent.io)
Trademarks: This Docker image is maintained by **SolDevelo** and is based on the Bitnami Schema Registry container. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

## TL;DR

Use this quick command to run the container.

```console
docker run --name schema-registry soldevelo/schema-registry:latest
```

## Get this image

## Using `docker-compose.yaml`

Please be aware this file has not undergone internal testing. Consequently, we advise its use exclusively for development or testing purposes. 

## Configuration

The following sections describe environment variables, Kafka and Zookeeper settings, security, and FIPS.

### Environment variables

The following tables list the main variables you can set.

#### Customizable environment variables

| Name                                                    | Description                                                                                                                            | Default Value                       |
|---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------|
| `SCHEMA_REGISTRY_MOUNTED_CONF_DIR`                      | Directory for including custom configuration files (that override the default generated ones)                                          | `${SCHEMA_REGISTRY_VOLUME_DIR}/etc` |
| `SCHEMA_REGISTRY_KAFKA_BROKERS`                         | List of Kafka brokers to connect to.                                                                                                   | `nil`                               |
| `SCHEMA_REGISTRY_ADVERTISED_HOSTNAME`                   | Advertised hostname in ZooKeeper.                                                                                                      | `nil`                               |
| `SCHEMA_REGISTRY_KAFKA_KEYSTORE_PASSWORD`               | Password to access the keystore.                                                                                                       | `nil`                               |
| `SCHEMA_REGISTRY_KAFKA_KEY_PASSWORD`                    | Password to be able to used ssl secured kafka broker with SR                                                                           | `nil`                               |
| `SCHEMA_REGISTRY_KAFKA_TRUSTSTORE_PASSWORD`             | Password to access the truststore.                                                                                                     | `nil`                               |
| `SCHEMA_REGISTRY_KAFKA_SASL_USER`                       | SASL user to authenticate with Kafka.                                                                                                  | `nil`                               |
| `SCHEMA_REGISTRY_KAFKA_SASL_PASSWORD`                   | SASL password to authenticate with Kafka.                                                                                              | `nil`                               |
| `SCHEMA_REGISTRY_LISTENERS`                             | Comma-separated list of listeners that listen for API requests over either HTTP or HTTPS.                                              | `nil`                               |
| `SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD`                 | Password to access the SSL keystore.                                                                                                   | `nil`                               |
| `SCHEMA_REGISTRY_SSL_KEY_PASSWORD`                      | Password to access the SSL key.                                                                                                        | `nil`                               |
| `SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD`               | Password to access the SSL truststore.                                                                                                 | `nil`                               |
| `SCHEMA_REGISTRY_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM` | Endpoint identification algorithm to validate the server hostname using the server certificate.                                        | `nil`                               |
| `SCHEMA_REGISTRY_CLIENT_AUTHENTICATION`                 | Client authentication configuration. Valid options: none, requested, over required.                                                    | `nil`                               |
| `SCHEMA_REGISTRY_AVRO_COMPATIBILY_LEVEL`                | The Avro compatibility type. Valid options: none, backward, backward_transitive, forward, forward_transitive, full, or full_transitive | `nil`                               |
| `SCHEMA_REGISTRY_DEBUG`                                 | Enable Schema Registry debug logs. Valid options: true or false                                                                        | `nil`                               |

#### Read-only environment variables

| Name                                    | Description                                                                               | Value                                                                    |
|-----------------------------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `SCHEMA_REGISTRY_BASE_DIR`              | Base path for SCHEMA REGISTRY files.                                                      | `${BITNAMI_ROOT_DIR}/schema-registry`                                    |
| `SCHEMA_REGISTRY_VOLUME_DIR`            | SCHEMA REGISTRY directory for persisted files.                                            | `${BITNAMI_VOLUME_DIR}/schema-registry`                                  |
| `SCHEMA_REGISTRY_BIN_DIR`               | SCHEMA REGISTRY certificates directory.                                                   | `${SCHEMA_REGISTRY_BASE_DIR}/bin`                                        |
| `SCHEMA_REGISTRY_CERTS_DIR`             | SCHEMA REGISTRY certificates directory.                                                   | `${SCHEMA_REGISTRY_BASE_DIR}/certs`                                      |
| `SCHEMA_REGISTRY_CONF_DIR`              | SCHEMA REGISTRY configuration directory.                                                  | `${SCHEMA_REGISTRY_BASE_DIR}/etc`                                        |
| `SCHEMA_REGISTRY_DEFAULT_CONF_DIR`      | SCHEMA REGISTRY configuration directory.                                                  | `${SCHEMA_REGISTRY_BASE_DIR}/etc.default`                                |
| `SCHEMA_REGISTRY_LOGS_DIR`              | SCHEMA REGISTRY logs directory.                                                           | `${SCHEMA_REGISTRY_BASE_DIR}/logs`                                       |
| `SCHEMA_REGISTRY_CONF_FILE`             | Main SCHEMA REGISTRY configuration file.                                                  | `${SCHEMA_REGISTRY_CONF_DIR}/schema-registry/schema-registry.properties` |
| `SCHEMA_REGISTRY_CONNECTION_TIMEOUT`    | SCHEMA REGISTRY connection attempt timeout.                                               | `10`                                                                     |
| `SCHEMA_REGISTRY_DAEMON_USER`           | Users that will execute the SCHEMA REGISTRY Server process.                               | `schema-registry`                                                        |
| `SCHEMA_REGISTRY_DAEMON_GROUP`          | Group that will execute the SCHEMA REGISTRY Server process.                               | `schema-registry`                                                        |
| `SCHEMA_REGISTRY_DEFAULT_LISTENERS`     | Comma-separated list of listeners that listen for API requests over either HTTP or HTTPS. | `http://0.0.0.0:8081`                                                    |
| `SCHEMA_REGISTRY_DEFAULT_KAFKA_BROKERS` | List of Kafka brokers to connect to.                                                      | `PLAINTEXT://localhost:9092`                                             |

When you start the Confluent Schema Registry image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the `docker run` command line. Please note that some variables are only considered when the container is started for the first time.

#### Kafka settings

Please check the configuration settings for the `kafka` service in the [Kafka's README file](https://github.com/soldevelo/containers/tree/main/soldevelo/kafka#configuration).

#### Zookeeper settings

Please check the configuration settings for the `zookeeper` service in the [Zookeeper's README file](https://github.com/soldevelo/containers/tree/main/soldevelo/zookeeper#configuration).

### Security

The Schema Registry container can be set up to serve clients securely using TLS. To do so, specify the listener protocol as **https** in the `SCHEMA_REGISTRY_LISTENERS` environment variable (e.g. SCHEMA_REGISTRY_LISTENERS=`http://0.0.0.0:8081`,`https://0.0.0.0:8082`).

The `keystore` and `truststore` **must** be mounted in the `/opt/bitnami/schema-registry/certs` directory as `ssl.keystore.jks` and `ssl.truststore.jks` respectively. Currently, only JKS formats are supported. Note that the environment variables `SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION` or `SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION` **will not** override the expected location or file names. Please follow the instructions provided or you will get this error at startup: *ERROR ==> In order to configure HTTPS access, you must mount your `ssl.keystore.jks` (and optionally the `ssl.truststore.jks`) to the /opt/bitnami/schema-registry/certs directory*.

Here is a `docker-compose.yml` example that exposes a TLS listener on port `8082`:

```yaml
schema-registry:
  image: soldevelo/schema-registry:latest
  ports:
    - 8081:8081
    - 8082:8082
  depends_on:
    - kafka
  environment:
    - SCHEMA_REGISTRY_KAFKA_BROKERS=PLAINTEXT://kafka:9092
    - SCHEMA_REGISTRY_HOST_NAME=schema-registry
    - SCHEMA_REGISTRY_LISTENERS=http://0.0.0.0:8081,https://0.0.0.0:8082
    - SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD=keystore
    - SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD=keystore
    - SCHEMA_REGISTRY_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM=none
    - SCHEMA_REGISTRY_CLIENT_AUTHENTICATION=REQUESTED
  volumes:
    - ./keystore.jks:/opt/bitnami/schema-registry/certs/keystore.jks:ro
    - ./truststore.jks:/opt/bitnami/schema-registry/certs/truststore.jks:ro
```


## License

Copyright &copy; 2026 Broadcom. The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
