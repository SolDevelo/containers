# Copyright 2026 SolDevelo
# Based on Bitnami kubectl © Broadcom, Inc. (Apache-2.0)
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/bitnami/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2024-12-04T00:34:38Z" \
      org.opencontainers.image.description="kubectl container image packaged by SolDevelo, based on Bitnami's work" \
      org.opencontainers.image.documentation="https://github.com/soldevelo/containers/tree/main/soldevelo/kubectl/README.md" \
      org.opencontainers.image.source="https://github.com/soldevelo/containers/tree/main/soldevelo/kubectl" \
      org.opencontainers.image.title="kubectl" \
      org.opencontainers.image.url="https://hub.docker.com/r/soldevelo/kubectl" \
      org.opencontainers.image.vendor="SolDevelo" \
      org.opencontainers.image.version="1.30.7"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl gettext git jq procps
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ ; \
    COMPONENTS=( \
      "yq-4.44.5-0-linux-${OS_ARCH}-debian-12" \
      "kubectl-1.30.7-1-linux-${OS_ARCH}-debian-12" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done
RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN mkdir /.kube && chmod g+rwX /.kube
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

ENV APP_VERSION="1.30.7" \
    BITNAMI_APP_NAME="kubectl" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/kubectl/bin:$PATH"

USER 1001
ENTRYPOINT [ "kubectl" ]
CMD [ "--help" ]
