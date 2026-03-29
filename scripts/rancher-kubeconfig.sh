#!/usr/bin/env bash
#
# rancher-kubeconfig.sh — fetch kubeconfigs for all Rancher-managed clusters.
#
# Usage:
#   source rancher-kubeconfig.sh            # prompts for bearer token
#   source rancher-kubeconfig.sh -R https://rancher.example.com
#
# Must be sourced (not executed) so the KUBECONFIG export persists.

set -euo pipefail

RANCHER_URL="https://rancher.acerta.io"

while getopts "R:" opt; do
  case $opt in
    R) RANCHER_URL="${OPTARG}" ;;
    *) echo "Usage: source rancher-kubeconfig.sh [-R <rancher-url>]" >&2; return 1 2>/dev/null || exit 1 ;;
  esac
done

# Reset getopts so future invocations in the same shell work correctly
OPTIND=1

# Prompt for bearer token (hidden input)
echo -n "Rancher bearer token: "
read -rs TOKEN
echo

TOKEN=$(echo "$TOKEN" | tr -d '[:space:]')

if [[ -z "$TOKEN" ]]; then
  echo "Error: token cannot be empty" >&2
  return 1 2>/dev/null || exit 1
fi

mkdir -p "$HOME/.kube"

echo "Fetching clusters from $RANCHER_URL ..."

CLUSTERS_JSON=$(curl -sSf -H "Authorization: Bearer $TOKEN" "$RANCHER_URL/v3/clusters")

CLUSTER_COUNT=$(printf '%s\n' "$CLUSTERS_JSON" | jq -r '.data | length')

if [[ "$CLUSTER_COUNT" -eq 0 ]]; then
  echo "No clusters found."
  return 0 2>/dev/null || exit 0
fi

FETCHED=0

for i in $(seq 0 $(( CLUSTER_COUNT - 1 ))); do
  NAME=$(printf '%s\n' "$CLUSTERS_JSON" | jq -r ".data[$i].name")
  ID=$(printf '%s\n' "$CLUSTERS_JSON"   | jq -r ".data[$i].id")

  # Skip the local (management) cluster
  if [[ "$NAME" == "local" ]]; then
    continue
  fi

  echo "  Generating kubeconfig for $NAME ($ID) ..."

  KUBECONFIG_JSON=$(curl -sSf -X POST \
    -H "Authorization: Bearer $TOKEN" \
    "$RANCHER_URL/v3/clusters/${ID}?action=generateKubeconfig")

  printf '%s\n' "$KUBECONFIG_JSON" | jq -r '.config' > "$HOME/.kube/${NAME}.yaml"
  (( ++FETCHED ))
done

echo "Wrote $FETCHED kubeconfig(s) to ~/.kube/"

# Build KUBECONFIG from all .yaml files in ~/.kube/
export KUBECONFIG
KUBECONFIG=$(printf '%s:' "$HOME"/.kube/*.yaml)
KUBECONFIG="${KUBECONFIG%:}"   # trim trailing colon

echo "KUBECONFIG set ($FETCHED cluster(s))."
