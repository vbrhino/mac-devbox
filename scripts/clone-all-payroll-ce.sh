#!/usr/bin/env bash
#
# clone-all-payroll-ce.sh — clone (or pull) all ce-* repos from acerta-payroll-service.
#
# Requires: gh (GitHub CLI) authenticated via `gh auth login`.

set -euo pipefail

ORG="Acerta-Payroll-Service"
CLONE_DIR="$HOME/github/$ORG"

mkdir -p "$CLONE_DIR"

echo "Fetching ce-* repos from $ORG ..."

gh repo list "$ORG" --limit 999 --json name,url --jq '.[] | select(.name | startswith("ce-")) | "\(.name)\t\(.url)"' |
while IFS=$'\t' read -r NAME REPO_URL; do
  REPO_PATH="$CLONE_DIR/$NAME"
  if [[ -d "$REPO_PATH" ]]; then
    echo "$NAME already exists — pulling ..."
    git -C "$REPO_PATH" pull --quiet
  else
    echo "Cloning $NAME ..."
    git clone --quiet "$REPO_URL" "$REPO_PATH"
  fi
done

echo "All repositories have been cloned & updated."
