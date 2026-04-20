#!/usr/bin/env bash
# sync-upstream.sh - Sync upstream changes into soldevelo/ images.
#
# Auto-discovers every soldevelo/<image>/<version>/<os>/Dockerfile and maps it
# to the corresponding bitnami/<image>/<version>/<os> path in the upstream repo.
# No manual mapping is needed - new images are picked up automatically.
#
# Usage:
#   ./scripts/sync-upstream.sh           # show what has changed
#   ./scripts/sync-upstream.sh apply     # create a branch and auto-merge everything
#
# Merge strategy for each changed image:
#   Dockerfile                 - our copyright header + description/documentation/
#                                source/vendor labels kept; everything else from upstream.
#   all subdirectories         - file-by-file (prebuildfs/, rootfs/, and any others):
#       new file in upstream   - added to ours
#       header-only diff       - header kept, upstream content applied
#       functional diff        - 3-way merge attempted; kept ours only on conflict
#       our file not upstream  - kept as-is (our intentional addition)
#   tags-info.yaml             - patch version updated; revision reset to 0

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$REPO_ROOT"

MODE="${1:-diff}"
BITNAMI_REMOTE="bitnami"
BITNAMI_REPO="https://github.com/bitnami/containers.git"

# ---------------------------------------------------------------------------
# Python script: merge upstream file while preserving our leading comment header.
# Works for both Dockerfiles and shell scripts.
# For Dockerfiles also preserves specific OCI label values.
# ---------------------------------------------------------------------------
MERGE_FILE_PY='
import sys, re

our_path, upstream_path, file_type = sys.argv[1], sys.argv[2], sys.argv[3]

with open(our_path) as f:
    our_lines = f.readlines()
with open(upstream_path) as f:
    upstream_lines = f.readlines()

# --- Extract our header (leading # comment block)
our_header = []
for line in our_lines:
    if line.startswith("#"):
        our_header.append(line)
    elif line.strip() == "" and not our_header:
        continue
    else:
        break
while our_header and our_header[-1].strip() == "":
    our_header.pop()
our_header.append("\n")

# --- For Dockerfiles: also preserve specific OCI label values
preserve = {}
if file_type == "dockerfile":
    def get_label(lines, key):
        for line in lines:
            m = re.search(r"org\.opencontainers\.image\." + key + r"=\"([^\"]*)\"", line)
            if m:
                return m.group(1)
        return None
    preserve = {k: get_label(our_lines, k)
                for k in ("description", "documentation", "source", "vendor")}

# --- Skip upstream header block
start = 0
for i, line in enumerate(upstream_lines):
    if line.strip() and not line.startswith("#"):
        start = i
        break

# --- Write: our header + upstream body with patched labels
sys.stdout.writelines(our_header)
for line in upstream_lines[start:]:
    for key, val in preserve.items():
        if val and "org.opencontainers.image." + key + "=" in line:
            line = re.sub(
                r"(org\.opencontainers\.image\." + key + r"=\")[^\"]*(\"\s*)",
                r"\g<1>" + val + r"\2",
                line,
            )
    sys.stdout.write(line)
'

# ---------------------------------------------------------------------------
# Python helper: return the functional content (everything after the leading
# comment header block) so we can compare without header noise.
# ---------------------------------------------------------------------------
STRIP_HEADER_PY='
import sys

with open(sys.argv[1]) as f:
    lines = f.readlines()
i = 0
while i < len(lines) and (lines[i].startswith("#") or lines[i].strip() == ""):
    i += 1
sys.stdout.writelines(lines[i:])
'

# ---------------------------------------------------------------------------
# Python helper: union diff merge - used when no git ancestor is available.
# Takes (our_path, upstream_path) and merges by:
#   - Lines only in ours (our intentional additions) - KEEP
#   - Lines only in upstream, or changed in upstream - take upstream
# This preserves custom RUN/COPY additions even without git history.
# ---------------------------------------------------------------------------
UNION_DIFF_PY='
import sys, difflib

with open(sys.argv[1]) as f:
    our_lines = f.readlines()
with open(sys.argv[2]) as f:
    upstream_lines = f.readlines()

result = []
matcher = difflib.SequenceMatcher(None, our_lines, upstream_lines, autojunk=False)
for tag, i1, i2, j1, j2 in matcher.get_opcodes():
    if tag in ("equal", "replace", "insert"):
        result.extend(upstream_lines[j1:j2])
    elif tag == "delete":
        # Lines only in ours - our intentional additions, keep them
        result.extend(our_lines[i1:i2])
sys.stdout.writelines(result)
'

# ---------------------------------------------------------------------------
# Python helper: extract just the leading comment header block from a file.
# Used to rebuild a file after 3-way merge: our header + merged body.
# ---------------------------------------------------------------------------
EXTRACT_HEADER_PY='
import sys
with open(sys.argv[1]) as f:
    lines = f.readlines()
i = 0
while i < len(lines) and (lines[i].startswith("#") or lines[i].strip() == ""):
    i += 1
header = lines[:i]
while header and header[-1].strip() == "":
    header.pop()
header.append("\n")
sys.stdout.writelines(header)
'

# ---------------------------------------------------------------------------
# Python helper: patch our OCI label values into an already-merged Dockerfile.
# Takes (source_of_our_labels, target_file_to_patch) and writes result to stdout.
# Used after a 3-way merge so our description/documentation/source/vendor survive.
# ---------------------------------------------------------------------------
PATCH_LABELS_PY='
import sys, re

our_path, target_path = sys.argv[1], sys.argv[2]

with open(our_path) as f:
    our_lines = f.readlines()
with open(target_path) as f:
    content = f.read()

def get_label(lines, key):
    for line in lines:
        m = re.search(r"org\.opencontainers\.image\." + key + r"=\"([^\"]*)\"", line)
        if m:
            return m.group(1)
    return None

for key in ("description", "documentation", "source", "vendor"):
    val = get_label(our_lines, key)
    if val:
        content = re.sub(
            r"(org\.opencontainers\.image\." + key + r"=\")[^\"]*(\"|\\\n)",
            r"\g<1>" + val + r"\2",
            content,
        )

sys.stdout.write(content)
'

# ---------------------------------------------------------------------------
# Python helper: normalize volatile upstream-owned fields in a stripped Dockerfile
# to the same values that appear in upstream, so git merge-file does not see
# a conflict on those lines (IMAGE_REVISION, APP_VERSION, image.created, etc.).
# Reads target from sys.argv[1], upstream reference from sys.argv[2]; writes stdout.
# ---------------------------------------------------------------------------
NORMALIZE_VOLATILE_PY='
import sys, re

target_path, upstream_path = sys.argv[1], sys.argv[2]

with open(upstream_path) as f:
    upstream = f.read()
with open(target_path) as f:
    content = f.read()

# Fields that upstream always owns - normalize ours to match so they never conflict
volatile_patterns = [
    r"IMAGE_REVISION=\"[^\"]*\"",
    r"APP_VERSION=\"[^\"]*\"",
    r"org\.opencontainers\.image\.created=\"[^\"]*\"",
    r"org\.opencontainers\.image\.version=\"[^\"]*\"",
    r"org\.opencontainers\.image\.base\.name=\"[^\"]*\"",
]

for pattern in volatile_patterns:
    m = re.search(pattern, upstream)
    if m:
        content = re.sub(pattern, m.group(0), content)

# Component binary archive names embedded in COMPONENTS=(...) blocks.
# Pattern: "pkg-name-X.Y.Z-N-linux-${OS_ARCH}-os-ver"
# The build counter N is upstream-owned; normalize each component by matching
# on package+version+platform (ignoring N) and replacing with the upstream value.
# Uses a replace function so multiple distinct components are handled correctly.
comp_re = re.compile(
    r"\"([a-zA-Z][a-zA-Z0-9_-]*?-\d+\.\d+\.\d+)-(\d+)(-(?:linux|aarch64)-[^\"]+)\""
)
upstream_comps = {}
for m in comp_re.finditer(upstream):
    key = (m.group(1), m.group(3))   # (pkg-version, platform-suffix)
    upstream_comps[key] = m.group(0)  # full replacement string

def _norm_comp(match):
    return upstream_comps.get((match.group(1), match.group(3)), match.group(0))

content = comp_re.sub(_norm_comp, content)

sys.stdout.write(content)
'

# ---------------------------------------------------------------------------
# Python script: update tags-info.yaml after a version bump.
# Replaces X.Y.Z patch-version entries with the new version; resets revision.
# ---------------------------------------------------------------------------
UPDATE_TAGS_PY='
import sys, re

tags_path, new_ver = sys.argv[1], sys.argv[2]

with open(tags_path) as f:
    content = f.read()

# Reset revision counter
content = re.sub(r"^revision:\s*\d+", "revision: 0", content, flags=re.MULTILINE)

# Replace any X.Y.Z version string in rolling-tags (quoted or bare)
content = re.sub(
    r"(^\s*-\s*\"?)(\d+\.\d+\.\d+)(\"?\s*$)",
    lambda m: m.group(1) + new_ver + m.group(3),
    content,
    flags=re.MULTILINE,
)

with open(tags_path, "w") as f:
    f.write(content)
'

# ---------------------------------------------------------------------------
# Auto-discover: find all soldevelo/<image>/<version>/<os> dirs with Dockerfiles.
# The upstream path is obtained by replacing the 'soldevelo/' prefix with 'bitnami/'.
# ---------------------------------------------------------------------------
discover_local_dirs() {
  find soldevelo -maxdepth 4 -name 'Dockerfile' \
    | sed 's|/Dockerfile$||' \
    | sort
}

# ---------------------------------------------------------------------------
# Helper: extract the upstream directory from a local path
# ---------------------------------------------------------------------------
upstream_of() { echo "$1" | sed 's|^soldevelo/|bitnami/|'; }

# ---------------------------------------------------------------------------
# Helper: sync a subdirectory from upstream, file-by-file.
#   - New file from upstream  - add it
#   - Header-only diff        - apply header-merge (keep our header, take upstream body)
#   - Functional diff         - attempt 3-way merge; add to MANUAL_REVIEW list on conflict
#   - Our file, not upstream  - keep as-is (our intentional addition)
# Usage: sync_subdir <upstream_dir> <local_dir> <subdir_name>
# Sets: appends to global MANUAL_REVIEW array on functional conflicts.
# ---------------------------------------------------------------------------
sync_subdir() {
  local upstream_dir="$1" local_dir="$2" subdir="$3"

  if ! git rev-parse "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/${subdir}" &>/dev/null; then
    return 0
  fi

  echo "   Processing ${subdir}/..."

  # Extract all upstream files for this subdir into a temp dir
  local strip
  strip=$(( $(echo "${upstream_dir}" | tr -cd '/' | wc -c) + 1 ))
  local tmpd
  tmpd=$(mktemp -d)
  git archive "remotes/${BITNAMI_REMOTE}/main" "${upstream_dir}/${subdir}/" \
    | tar -x --strip-components="${strip}" -C "${tmpd}"

  # Walk every file upstream provides
  while IFS= read -r upstream_file; do
    local rel="${upstream_file#${tmpd}/}"   # relative path within subdir tree
    local our_file="${local_dir}/${rel}"

    if [[ ! -f "$our_file" ]]; then
      # New file from upstream - add it
      mkdir -p "$(dirname "$our_file")"
      cp "$upstream_file" "$our_file"
      git add "$our_file"
      echo "     + added: $rel"
      continue
    fi

    if diff -q "$upstream_file" "$our_file" >/dev/null 2>&1; then
      continue  # identical, nothing to do
    fi

    # Files differ - check if it's header-only or functional
    our_functional=$(python3 -c "$STRIP_HEADER_PY" "$our_file")
    upstream_functional=$(python3 -c "$STRIP_HEADER_PY" "$upstream_file")

    if [[ "$our_functional" == "$upstream_functional" ]]; then
      # Only header differs (branding, copyright) - apply header-merge
      python3 -c "$MERGE_FILE_PY" "$our_file" "$upstream_file" "script" > "${our_file}.merged"
      mv "${our_file}.merged" "$our_file"
      git add "$our_file"
      echo "     ~ header-merged: $rel"
    else
      # Functional difference - attempt 3-way merge using upstream git history.
      # If no ancestor is available or merge has conflicts, keep ours and flag for review.
      local prev_sha ancestor_tmp ancestor_stripped_f
      prev_sha=$(git log --oneline -n 2 \
        "remotes/${BITNAMI_REMOTE}/main" \
        -- "${upstream_dir}/${rel}" 2>/dev/null | awk 'NR==2{print $1}')

      ancestor_tmp=$(mktemp)
      ancestor_stripped_f=$(mktemp)

      if [[ -n "$prev_sha" ]]; then
        git show "${prev_sha}:${upstream_dir}/${rel}" > "$ancestor_tmp" 2>/dev/null || true
      fi
      if [[ -s "$ancestor_tmp" ]]; then
        python3 -c "$STRIP_HEADER_PY" "$ancestor_tmp" > "$ancestor_stripped_f"
      fi

      if [[ -s "$ancestor_stripped_f" ]]; then
        local our_stripped_f upstream_stripped_f merge_tmp merge_rc
        our_stripped_f=$(mktemp)
        upstream_stripped_f=$(mktemp)
        merge_tmp=$(mktemp)
        merge_rc=0

        python3 -c "$STRIP_HEADER_PY" "$our_file"      > "$our_stripped_f"
        python3 -c "$STRIP_HEADER_PY" "$upstream_file" > "$upstream_stripped_f"
        cp "$our_stripped_f" "$merge_tmp"

        git merge-file --quiet \
          "$merge_tmp" "$ancestor_stripped_f" "$upstream_stripped_f" \
          2>/dev/null || merge_rc=$?

        if [[ $merge_rc -eq 0 ]]; then
          # Clean 3-way merge - prepend our header to the merged body
          python3 -c "$EXTRACT_HEADER_PY" "$our_file" \
            | cat - "$merge_tmp" > "${our_file}.merged"
          mv "${our_file}.merged" "$our_file"
          git add "$our_file"
          echo "     ~ auto-merged (3-way): $rel"
        else
          # Conflicts - keep our version, flag for manual review
          MANUAL_REVIEW+=("${local_dir}/${rel}")
          echo "     ! merge conflict; kept ours (review needed): $rel"
        fi

        rm -f "$our_stripped_f" "$upstream_stripped_f" "$merge_tmp"
      else
        # No ancestor found in shallow history (repo is far behind upstream).
        # Without a common base we cannot safely auto-merge a modified script block -
        # union diff would silently overwrite our logic rewrites with upstream's version.
        # Keep ours and flag for manual review; the diff command below shows what changed.
        MANUAL_REVIEW+=("${local_dir}/${rel}")
        echo "     ! no ancestor; kept ours (manual review needed): $rel"
        echo "       upstream diff: git diff remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/${rel} -- ${our_file}"
      fi

      rm -f "$ancestor_tmp" "$ancestor_stripped_f"
    fi
  done < <(find "$tmpd" -type f | sort)

  # Files we have locally that don't exist upstream are kept as-is (intentional additions)

  rm -rf "$tmpd"
  git add "${local_dir}/${subdir}/" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Helper: sync ALL subdirectories of an image dir from upstream (generic).
# Discovers which subdirs exist in upstream and calls sync_subdir for each.
# Also handles subdirs we have locally that upstream doesn't (kept as-is).
# ---------------------------------------------------------------------------
sync_all_subdirs() {
  local upstream_dir="$1" local_dir="$2"

  # Collect subdirs that exist in upstream for this image path
  local upstream_subdirs
  upstream_subdirs=$(git ls-tree --name-only "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}" 2>/dev/null \
    | while IFS= read -r entry; do
        # Only include entries that are trees (directories), skip files
        if git rev-parse "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/${entry}" &>/dev/null; then
          obj_type=$(git cat-file -t "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/${entry}" 2>/dev/null || echo 'blob')
          [[ "$obj_type" == 'tree' ]] && echo "$entry"
        fi
      done)

  while IFS= read -r subdir; do
    [[ -z "$subdir" ]] && continue
    sync_subdir "$upstream_dir" "$local_dir" "$subdir"
  done <<< "$upstream_subdirs"
}

# ---------------------------------------------------------------------------
# Setup remote
# ---------------------------------------------------------------------------
if ! git remote | grep -q "^${BITNAMI_REMOTE}$"; then
  echo "Adding '${BITNAMI_REMOTE}' remote - ${BITNAMI_REPO}"
  git remote add "${BITNAMI_REMOTE}" "${BITNAMI_REPO}"
fi

echo "Fetching ${BITNAMI_REMOTE}/main..."
# depth=200 gives enough history to find the previous upstream version of any recently-changed
# file across the large bitnami monorepo, which is required for the 3-way merge below.
git fetch "${BITNAMI_REMOTE}" main --depth=200 --quiet
echo ""

# ---------------------------------------------------------------------------
# Compare each local image against upstream
# ---------------------------------------------------------------------------
CHANGED=()

echo "=== Upstream comparison ==="
while IFS= read -r local_dir; do
  upstream_dir=$(upstream_of "$local_dir")

  # Skip if upstream doesn't have this path at all
  if ! git rev-parse "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/Dockerfile" &>/dev/null; then
    printf "  %-60s [SKIP - not in upstream]\n" "${local_dir}"
    continue
  fi

  # Compare functional content (strip custom labels + header so our differences
  # don't cause false positives)
  upstream_functional=$(
    git show "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/Dockerfile" \
      | grep -v 'image\.description\|image\.documentation\|image\.source\|image\.vendor' \
      | awk '/^FROM /{found=1} found{print}'
  )
  our_functional=$(
    grep -v 'image\.description\|image\.documentation\|image\.source\|image\.vendor' \
      "${local_dir}/Dockerfile" \
      | awk '/^FROM /{found=1} found{print}'
  )

  if [[ "$upstream_functional" == "$our_functional" ]]; then
    our_ver=$(grep -m1 'org.opencontainers.image.version' "${local_dir}/Dockerfile" \
      | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
    printf "  %-60s [up to date (%s)]\n" "${local_dir}" "${our_ver}"
  else
    upstream_ver=$(git show "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/Dockerfile" \
      | grep -m1 'org.opencontainers.image.version' | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
    our_ver=$(grep -m1 'org.opencontainers.image.version' "${local_dir}/Dockerfile" \
      | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)

    if [[ "$upstream_ver" != "$our_ver" ]]; then
      printf "  %-60s [VERSION %s -> %s]\n" "${local_dir}" "${our_ver}" "${upstream_ver}"
    else
      printf "  %-60s [CONTENT CHANGED (%s)]\n" "${local_dir}" "${our_ver}"
    fi
    # Emit a grep-able marker used by the GitHub Actions sync workflow
    echo "${local_dir} [CHANGED]"
    CHANGED+=("$local_dir")
  fi
done < <(discover_local_dirs)

echo ""

if [[ ${#CHANGED[@]} -eq 0 ]]; then
  echo "All images are up to date with upstream."
  exit 0
fi

if [[ "$MODE" != "apply" ]]; then
  echo "---"
  echo "Run '$0 apply' to auto-merge all changes into a new branch."
  echo "---"
  exit 0
fi

# ---------------------------------------------------------------------------
# Apply mode: create branch + fully auto-merge every changed image
# ---------------------------------------------------------------------------
BRANCH="sync/upstream-$(date +%Y%m%d)"
git rev-parse --verify "$BRANCH" &>/dev/null && BRANCH="${BRANCH}-$(date +%H%M)"

echo "Creating branch: ${BRANCH}"
git checkout -b "$BRANCH"
echo ""

MANUAL_REVIEW=()

for local_dir in "${CHANGED[@]}"; do
  upstream_dir=$(upstream_of "$local_dir")
  echo "[sync] ${local_dir}"

  # -- Dockerfile: 3-way merge to preserve our custom RUN/COPY additions ------
  echo "   Merging Dockerfile..."
  upstream_df=$(mktemp)
  ancestor_df=$(mktemp)
  git show "remotes/${BITNAMI_REMOTE}/main:${upstream_dir}/Dockerfile" > "$upstream_df"

  # Find the previous upstream commit so we have an ancestor for 3-way merge
  prev_df_sha=$(git log --oneline -n 2 \
    "remotes/${BITNAMI_REMOTE}/main" \
    -- "${upstream_dir}/Dockerfile" 2>/dev/null | awk 'NR==2{print $1}')
  if [[ -n "$prev_df_sha" ]]; then
    git show "${prev_df_sha}:${upstream_dir}/Dockerfile" > "$ancestor_df" 2>/dev/null || true
  fi

  if [[ -s "$ancestor_df" ]]; then
    our_stripped_df=$(mktemp)
    upstream_stripped_df=$(mktemp)
    ancestor_stripped_df=$(mktemp)
    merge_df=$(mktemp)
    result_df=$(mktemp)
    norm_tmp=$(mktemp)

    python3 -c "$STRIP_HEADER_PY" "${local_dir}/Dockerfile" > "$our_stripped_df"
    python3 -c "$STRIP_HEADER_PY" "$upstream_df"             > "$upstream_stripped_df"
    python3 -c "$STRIP_HEADER_PY" "$ancestor_df"             > "$ancestor_stripped_df"

    # Normalize volatile upstream-owned fields (IMAGE_REVISION, APP_VERSION, image.created
    # etc.) to upstream's values in both ours and ancestor, so they never create false
    # 3-way merge conflicts on lines we do not manage.
    python3 -c "$NORMALIZE_VOLATILE_PY" "$our_stripped_df"      "$upstream_stripped_df" > "$norm_tmp"
    mv "$norm_tmp" "$our_stripped_df"
    python3 -c "$NORMALIZE_VOLATILE_PY" "$ancestor_stripped_df" "$upstream_stripped_df" > "$norm_tmp"
    mv "$norm_tmp" "$ancestor_stripped_df"
    rm -f "$norm_tmp"

    cp "$our_stripped_df" "$merge_df"

    df_merge_rc=0
    git merge-file --quiet "$merge_df" "$ancestor_stripped_df" "$upstream_stripped_df" \
      2>/dev/null || df_merge_rc=$?

    if [[ $df_merge_rc -eq 0 ]]; then
      # Clean merge: prepend our header then restore our label values.
      # IMPORTANT: always write to a separate temp file - never redirect output to a file
      # that is also passed as an input argument, or bash truncates it before Python reads it.
      python3 -c "$EXTRACT_HEADER_PY" "${local_dir}/Dockerfile" > "$result_df"
      cat "$merge_df" >> "$result_df"
      python3 -c "$PATCH_LABELS_PY" "${local_dir}/Dockerfile" "$result_df" > "${result_df}.patched"
      mv "${result_df}.patched" "${local_dir}/Dockerfile"
      echo "     ~ auto-merged (3-way): Dockerfile"
    else
      # Real conflict: fall back to upstream body, preserving our header + labels
      python3 -c "$MERGE_FILE_PY" "${local_dir}/Dockerfile" "$upstream_df" "dockerfile" \
        > "$result_df"
      mv "$result_df" "${local_dir}/Dockerfile"
      MANUAL_REVIEW+=("${local_dir}/Dockerfile")
      echo "     ! merge conflict; took upstream body (review needed): Dockerfile"
    fi

    rm -f "$our_stripped_df" "$upstream_stripped_df" "$ancestor_stripped_df" "$merge_df" "$result_df"
  else
    # No ancestor found in shallow history - use union diff to apply upstream changes
    # while preserving lines we added (e.g. RUN chmod +x, custom COPY etc.)
    result_df=$(mktemp)
    our_stripped_df=$(mktemp)
    upstream_stripped_df=$(mktemp)
    python3 -c "$STRIP_HEADER_PY" "${local_dir}/Dockerfile" > "$our_stripped_df"
    python3 -c "$STRIP_HEADER_PY" "$upstream_df"             > "$upstream_stripped_df"
    python3 -c "$UNION_DIFF_PY" "$our_stripped_df" "$upstream_stripped_df" > "$result_df"
    python3 -c "$EXTRACT_HEADER_PY" "${local_dir}/Dockerfile" | cat - "$result_df" > "${result_df}.merged"
    python3 -c "$PATCH_LABELS_PY" "${local_dir}/Dockerfile" "${result_df}.merged" > "${result_df}.patched"
    mv "${result_df}.patched" "${local_dir}/Dockerfile"
    rm -f "$our_stripped_df" "$upstream_stripped_df" "$result_df" "${result_df}.merged"
    echo "     ~ union-merged (no ancestor available): Dockerfile"
  fi

  rm -f "$upstream_df" "$ancestor_df"
  git add "${local_dir}/Dockerfile"

  # -- all subdirectories (file-by-file, preserving our functional changes) ---
  sync_all_subdirs "$upstream_dir" "$local_dir"

  # -- tags-info.yaml ------------------------------------------------------
  TAGS_FILE="${local_dir}/tags-info.yaml"
  if [[ -f "$TAGS_FILE" ]]; then
    NEW_VER=$(grep -m1 'org.opencontainers.image.version' "${local_dir}/Dockerfile" \
      | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
    echo "   Updating tags-info.yaml -> version ${NEW_VER}, revision 0"
    python3 -c "$UPDATE_TAGS_PY" "$TAGS_FILE" "$NEW_VER"
    git add "$TAGS_FILE"
  fi

  echo ""
done

git commit -m "chore: sync upstream bitnami changes"

echo "Sync complete. Branch: ${BRANCH}"
echo "Diff vs main:  git diff main"
echo "Push:          git push -u origin ${BRANCH}"
echo "Then open a PR - merging it will trigger the build-and-publish workflow."

if [[ ${#MANUAL_REVIEW[@]} -gt 0 ]]; then
  echo ""
  echo "WARNING: Files where 3-way merge had conflicts (kept our version; needs manual review):"
  for f in "${MANUAL_REVIEW[@]}"; do
    echo "   $f"
    # Machine-readable marker parsed by the GitHub Actions sync workflow
    echo "[REVIEW] $f"
  done
  echo ""
  echo "   For each file above, compare our version with the current upstream:"
  echo "   upstream path: replace 'soldevelo/' with 'bitnami/' in the path above"
  echo "   git diff \"remotes/bitnami/main:<upstream_path>\" -- <our_path>"
fi

git status --short
