#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for stack in "$ROOT_DIR"/*/; do
  [ -f "$stack/compose.yaml" ] || continue

  echo "📦 Processing $(basename "$stack")"

  if [ ! -f "$stack/.env" ]; then
    if [ -f "$stack/.env.sample" ]; then
      cp "$stack/.env.sample" "$stack/.env"
      echo "  → Created .env from .env.sample"
      echo "  ⚠️  Please review and fill required values"
    fi
  fi

  if grep -q "=$" "$stack/.env"; then
    echo "  ❗ Empty values detected in .env"
    echo "  👉 Edit $stack/.env before continuing"
    exit 1
  fi

  (
    cd "$stack"
    docker compose up -d
  )
done
