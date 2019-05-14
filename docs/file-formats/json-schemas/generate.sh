#!/bin/bash

set -e
YAML_FILE="$1"
JSON_FILE=$(echo "$YAML_FILE" | sed "s/\.yml/\.json/g")
MD_FILE=$(echo "$YAML_FILE" | sed "s/\.yml/\.md/g")

mkdir ./.generated &>/dev/null || true

npx js-yaml "./$YAML_FILE" > "./.generated/$JSON_FILE"
npx json-schema-to-md "./.generated/$JSON_FILE" > "../$MD_FILE"

echo "✓ Generated $JSON_FILE and $MD_FILE from $YAML_FILE"
