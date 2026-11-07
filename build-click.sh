#!/bin/sh
# Обёртка над build-click.py: сборка click-пакета без Docker и Clickable.
#   ./build-click.sh
set -eu
DIR=$(dirname "$0")
exec python3 "$DIR/build-click.py" "$@"
