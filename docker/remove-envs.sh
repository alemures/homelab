#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

for stack in "$ROOT_DIR"/*; do
  stack_name="$(basename "$stack")"
  env_file="$stack/.env"

  [ -f "$env_file" ] || continue

  echo "📦 Removing $stack_name .env file"

  rm "$env_file"
done
