#!/bin/bash
set -e

# Usage examples:
#   ./compose.sh up media-arr
#   ./compose.sh down downloads
#   ./compose.sh restart proxy

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
IGNORED_STACKS=("media-plex")

ACTION="${1:-up}"
shift || true

# If args are given → only run those stacks
# If no args → run all stacks
SELECTED_STACKS=("$@")

is_ignored() {
  for ignored in "${IGNORED_STACKS[@]}"; do
    [[ "$1" == "$ignored" ]] && return 0
  done
  return 1
}

for stack in "$ROOT_DIR"/*; do
  stack_name="$(basename "$stack")"

  [ -f "$stack/compose.yaml" ] || continue

  # If args exist, they override everything
  if [ ${#SELECTED_STACKS[@]} -gt 0 ]; then
    [[ " ${SELECTED_STACKS[*]} " =~ " ${stack_name} " ]] || continue
  else
    is_ignored "$stack_name" && continue
  fi

  echo "📦 Processing $stack_name"

  if [ ! -f "$stack/.env" ]; then
    if [ -f "$stack/.env.example" ]; then
      cp "$stack/.env.example" "$stack/.env"
      echo "  → Created .env from .env.example"
    fi
  fi

  if grep -q "=$" "$stack/.env"; then
    echo "  ❗ Empty values detected in .env"
    echo "  👉 Edit $stack/.env before continuing"
    exit 1
  fi

  (
    cd "$stack"
    docker compose $ACTION -d
  )
done
