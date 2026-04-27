# Prometheus packaged by SolDevelo

[Prometheus](https://prometheus.io/) is an open-source systems monitoring and alerting toolkit with a dimensional data model and a powerful query language (PromQL).

This Docker image is maintained by **SolDevelo** and is based on the [Bitnami Prometheus](https://github.com/bitnami/containers/tree/main/bitnami/prometheus) container.

## TL;DR

```console
docker run --name prometheus docker.io/soldevelo/prometheus:latest
```

## Get this image

```console
docker pull docker.io/soldevelo/prometheus:latest
```

Or build it yourself:

```console
git clone https://github.com/soldevelo/containers.git
cd containers/soldevelo/prometheus/3.11/debian-12
docker build -t soldevelo/prometheus:latest .
```

## Configuration

Prometheus exposes no environment variables for configuration — it is controlled entirely via its YAML configuration file and command-line flags.

The default configuration file is at `/opt/bitnami/prometheus/conf/prometheus.yml`. Mount your own to override it:

```console
docker run --name prometheus \
  -v /path/to/prometheus.yml:/opt/bitnami/prometheus/conf/prometheus.yml \
  docker.io/soldevelo/prometheus:latest
```

Pass additional CLI flags via `docker run` arguments:

```console
docker run --name prometheus docker.io/soldevelo/prometheus:latest \
  --web.listen-address=:9090 \
  --storage.tsdb.retention.time=15d
```

See the [Prometheus documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/) for the full list of configuration options.

## Logging

The Prometheus container sends logs to stdout/stderr. Use `docker logs` or your log aggregation solution to collect them.

## License

Apache-2.0. Based on Bitnami Prometheus © Broadcom, Inc.
