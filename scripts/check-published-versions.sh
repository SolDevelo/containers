#!/usr/bin/env bash
# check-published-versions.sh
# Pulls each published soldevelo container from Docker Hub and verifies
# the APP_VERSION env var and (where possible) the actual binary version output.
#
# Version matching is prefix-tolerant: "16.9" matches "16.9.0" and vice-versa.
#
# Usage:
#   bash check-published-versions.sh           # check all images
#   bash check-published-versions.sh kafka      # check only images matching "kafka"
set -euo pipefail
cd /home/praca/containers

REGISTRY="docker.io/soldevelo"
FILTER="${1:-}"
PASS=0
FAIL=0
SKIP=0
RESULTS=()

log()  { echo "[$(date +%H:%M:%S)] $*"; }
ok()   { echo "  ✔ $*"; }
err()  { echo "  ✘ $*"; }

# Version match: prefix-tolerant ("16.9" == "16.9.0", "8.8" == "8.8.0")
version_match() {
  local got="$1" expected="$2"
  [[ "$got" == "$expected" ]] && return 0
  # Strip common trailing ".0" once from each side
  local g="${got%.0}" e="${expected%.0}"
  [[ "$g" == "$e" ]] && return 0
  [[ "$got" == "$expected."* ]] && return 0   # got=16.9 expected=16.9.0
  [[ "$expected" == "$got."* ]] && return 0   # got=16.9.0 expected=16.9
  return 1
}

# Pull image (suppressed output) and run a version check.
# Args: <image> <tag> <expected_ver> [docker run args...] -- <cmd> [cmd args...]
# The "--" separator divides docker run flags from the container command.
check() {
  local image="$1" tag="$2" expected_ver="$3"
  shift 3
  [[ -n "$FILTER" && "$image" != *"$FILTER"* ]] && return 0
  local full="${REGISTRY}/${image}:${tag}"

  # Collect docker run args and container command
  local -a run_args=() cmd_args=()
  local past_sep=0
  for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then past_sep=1; continue; fi
    if [[ $past_sep -eq 0 ]]; then run_args+=("$arg"); else cmd_args+=("$arg"); fi
  done

  log "${image}:${tag}  (expected: ${expected_ver})"

  # Pull when running filtered (full run pre-pulls in parallel above)
  [[ -n "$FILTER" ]] && docker pull --quiet "$full" >/dev/null 2>&1 || true

  # --- 1. Check APP_VERSION env var (read from image metadata; avoids entrypoint issues) ---
  local env_ver="" env_rc=0
  env_ver=$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$full" 2>/dev/null \
    | grep '^APP_VERSION=' | cut -d= -f2-) || env_rc=$?
  env_ver="${env_ver//[$'\r\n']}"   # strip newlines
  if [[ $env_rc -eq 0 && -n "$env_ver" ]]; then
    if version_match "$env_ver" "$expected_ver"; then
      ok "APP_VERSION=${env_ver}"
    else
      err "APP_VERSION mismatch: got=${env_ver}  expected=${expected_ver}"
      RESULTS+=("FAIL  ${image}:${tag}  expected=${expected_ver}  APP_VERSION=${env_ver}")
      FAIL=$((FAIL+1))
      return
    fi
  else
    err "Could not read APP_VERSION (rc=${env_rc})"
    RESULTS+=("FAIL  ${image}:${tag}  expected=${expected_ver}  [APP_VERSION unreadable]")
    FAIL=$((FAIL+1))
    return
  fi

  # --- 2. Binary version check (if a command was provided) ---
  if [[ ${#cmd_args[@]} -gt 0 ]]; then
    local bin_out="" bin_rc=0
    bin_out=$(docker run --rm "${run_args[@]}" "$full" "${cmd_args[@]}" 2>&1) || bin_rc=$?
    # rc=1 is acceptable (many --version flags exit 1)
    if [[ $bin_rc -gt 1 ]]; then
      err "Binary check failed (rc=${bin_rc}): $(echo "$bin_out" | head -2)"
      RESULTS+=("FAIL  ${image}:${tag}  expected=${expected_ver}  [binary rc=${bin_rc}]")
      FAIL=$((FAIL+1))
      return
    fi
    local bin_ver=""
    bin_ver=$(echo "$bin_out" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || true)
    if [[ -z "$bin_ver" ]]; then
      err "Binary produced no version number: $(echo "$bin_out" | head -2)"
      RESULTS+=("FAIL  ${image}:${tag}  expected=${expected_ver}  [no version in binary output]")
      FAIL=$((FAIL+1))
      return
    fi
    if version_match "$bin_ver" "$expected_ver"; then
      ok "binary version=${bin_ver}"
    else
      err "Binary version mismatch: got=${bin_ver}  expected=${expected_ver}"
      err "  output: $(echo "$bin_out" | head -2)"
      RESULTS+=("FAIL  ${image}:${tag}  expected=${expected_ver}  binary_got=${bin_ver}")
      FAIL=$((FAIL+1))
      return
    fi
  fi

  RESULTS+=("OK    ${image}:${tag}  ${expected_ver}")
  PASS=$((PASS+1))
}

get_expected() {
  grep -m1 'APP_VERSION=' "$1/Dockerfile" | grep -oE '[0-9]+([.][0-9]+)*' | head -1
}

# ---------------------------------------------------------------------------
# Pull all tags first (parallel background pulls)
# ---------------------------------------------------------------------------
if [[ -z "$FILTER" ]]; then
  log "Pulling all images from ${REGISTRY} (parallel)..."
  for ref in \
    jmx-exporter:1 \
    kafka:3.4 kafka:3.7 kafka:3.9 kafka:4.0 kafka:4.1 kafka:4.2 kafka:4.3 \
    kubectl:1.33 kubectl:1.34 kubectl:1.36 \
    mariadb:12.2 mariadb:12.3 \
    mongodb:8.2 mongodb:8.3 \
    os-shell:12 \
    pgpool:4 \
    postgres-exporter:0 \
    postgresql-repmgr:12 postgresql-repmgr:13 postgresql-repmgr:14 \
    postgresql-repmgr:15 postgresql-repmgr:16 postgresql-repmgr:17 postgresql-repmgr:18 \
    postgresql:18 \
    prometheus:3.0 prometheus:3.11 prometheus:3.12 \
    rabbitmq:4.1 rabbitmq:4.3 \
    redis:6.2 redis:7.0 redis:8.6 redis:8.8 \
    schema-registry:8.2; do
    docker pull "${REGISTRY}/${ref}" --quiet &
  done
  wait
  echo ""
fi

# ---------------------------------------------------------------------------
# Checks  (docker run args -- entrypoint [args])
# Every image gets APP_VERSION checked; binary command is the second source.
# ---------------------------------------------------------------------------

# jmx-exporter: no --version flag; APP_VERSION is sufficient
check jmx-exporter 1 "$(get_expected soldevelo/jmx-exporter/1/debian-12)"
echo ""

# kafka
for major in 3.4 3.7 3.9 4.0 4.1 4.2 4.3; do
  check kafka "$major" "$(get_expected "soldevelo/kafka/${major}/debian-12")" \
    --entrypoint bash -- -c "kafka-topics.sh --version 2>&1"
done
echo ""

# kubectl
for minor in 1.33 1.34 1.36; do
  check kubectl "$minor" "$(get_expected "soldevelo/kubectl/${minor}/debian-12")" \
    -- version --client
done
echo ""

# mariadb
for major in 12.2 12.3; do
  check mariadb "$major" "$(get_expected "soldevelo/mariadb/${major}/debian-12")" \
    --entrypoint mariadbd -- --version
done
echo ""

# mongodb
for major in 8.2 8.3; do
  check mongodb "$major" "$(get_expected "soldevelo/mongodb/${major}/debian-12")" \
    --entrypoint mongod -- --version
done
echo ""

# os-shell: no versioned application binary
check os-shell 12 "$(get_expected soldevelo/os-shell/12/debian-12)"
echo ""

# pgpool
check pgpool 4 "$(get_expected soldevelo/pgpool/4/debian-12)" \
  --entrypoint pgpool -- --version
echo ""

# postgres-exporter
check postgres-exporter 0 "$(get_expected soldevelo/postgres-exporter/0/debian-12)" \
  -- --version
echo ""

# postgresql-repmgr (run as root to avoid getpwuid failure on uid 1001)
for major in 12 13 14 15 16 17 18; do
  check postgresql-repmgr "$major" "$(get_expected "soldevelo/postgresql-repmgr/${major}/debian-12")" \
    --user root --entrypoint postgres -- --version
done
echo ""

# postgresql
check postgresql 18 "$(get_expected soldevelo/postgresql/18/debian-12)" \
  --entrypoint postgres -- --version
echo ""

# prometheus
for major in 3.0 3.11 3.12; do
  check prometheus "$major" "$(get_expected "soldevelo/prometheus/${major}/debian-12")" \
    --entrypoint prometheus -- --version
done
echo ""

# rabbitmq
for major in 4.1 4.3; do
  check rabbitmq "$major" "$(get_expected "soldevelo/rabbitmq/${major}/debian-12")" \
    --entrypoint bash -- -c "rabbitmqctl --version 2>&1"
done
echo ""

# redis
for major in 6.2 7.0 8.6 8.8; do
  check redis "$major" "$(get_expected "soldevelo/redis/${major}/debian-12")" \
    --entrypoint redis-server -- --version
done
echo ""

# schema-registry: APP_VERSION only (no simple --version binary)
check schema-registry 8.2 "$(get_expected soldevelo/schema-registry/8.2/debian-12)"
echo ""

# ---------------------------------------------------------------------------
echo "============================================================"
printf "  %d passed   %d failed   %d skipped\n" "$PASS" "$FAIL" "$SKIP"
echo ""
for r in "${RESULTS[@]}"; do echo "  $r"; done
echo "============================================================"
