#!/bin/bash
set -e

FILE="$1"
LAST="0"

while true; do
  sleep 1
  NEW=`ls -l "$FILE"`
  if [ "$NEW" != "$LAST" ]; then
    ./generate.sh "$FILE" || true
    LAST="$NEW"
  fi
done
