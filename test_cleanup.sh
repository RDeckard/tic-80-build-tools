#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

WORK_DIR="$TMP_DIR/work"
mkdir -p "$WORK_DIR/carts" "$WORK_DIR/dists"

cp "$ROOT_DIR/bundle" "$WORK_DIR/bundle"
cp "$ROOT_DIR/build" "$WORK_DIR/build"

assert_exists() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "FAIL: expected to exist: $path"
    exit 1
  fi
}

assert_missing() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "FAIL: expected to be removed: $path"
    exit 1
  fi
}

echo "[1/3] Syntax check"
ruby -c "$WORK_DIR/bundle" >/dev/null
ruby -c "$WORK_DIR/build" >/dev/null

echo "[2/3] Test bundle cleanup (keep latest per variant)"
touch "$WORK_DIR/carts/mygame-2026-02-20-120000.lua"
touch "$WORK_DIR/carts/mygame-2026-02-22-120000.lua"
touch "$WORK_DIR/carts/mygame.local-2026-02-21-120000.lua"
touch "$WORK_DIR/carts/mygame.local-2026-02-22-130000.lua"
touch "$WORK_DIR/carts/keep-me.lua"

(cd "$WORK_DIR" && ruby bundle cleanup >/dev/null)

assert_missing "$WORK_DIR/carts/mygame-2026-02-20-120000.lua"
assert_exists "$WORK_DIR/carts/mygame-2026-02-22-120000.lua"
assert_missing "$WORK_DIR/carts/mygame.local-2026-02-21-120000.lua"
assert_exists "$WORK_DIR/carts/mygame.local-2026-02-22-130000.lua"
assert_exists "$WORK_DIR/carts/keep-me.lua"

echo "[3/3] Test build cleanup (keep latest per variant)"
mkdir -p "$WORK_DIR/dists/mygame-2026-02-20-120000"
mkdir -p "$WORK_DIR/dists/mygame-2026-02-22-120000"
mkdir -p "$WORK_DIR/dists/mygame.local-2026-02-21-120000"
mkdir -p "$WORK_DIR/dists/mygame.local-2026-02-22-130000"
mkdir -p "$WORK_DIR/dists/misc"

(cd "$WORK_DIR" && ruby build cleanup >/dev/null)

assert_missing "$WORK_DIR/dists/mygame-2026-02-20-120000"
assert_exists "$WORK_DIR/dists/mygame-2026-02-22-120000"
assert_missing "$WORK_DIR/dists/mygame.local-2026-02-21-120000"
assert_exists "$WORK_DIR/dists/mygame.local-2026-02-22-130000"
assert_exists "$WORK_DIR/dists/misc"

echo "OK: cleanup behavior is correct for bundle and build."
