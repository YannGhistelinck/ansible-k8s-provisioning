#!/bin/bash

# Destroy an entire Kubernetes cluster (control plane + all workers).
# Discovers VMs dynamically from Multipass instead of relying on config.
# Usage: ./cleanup-cluster.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load cluster name from config
CLUSTER_NAME=$(grep "^cluster_name:" vars/cluster-config.yml | awk '{print $2}' | tr -d '"')

# Discover actual VMs for this cluster
CPLANE="${CLUSTER_NAME}-cplane"
WORKERS=$(multipass list --format csv 2>/dev/null | grep "^${CLUSTER_NAME}-worker-" | cut -d',' -f1 || true)
WORKER_COUNT=$(echo "$WORKERS" | grep -c . 2>/dev/null || echo "0")

echo -e "${YELLOW}Cluster: ${CLUSTER_NAME}${NC}"
echo -e "Control plane: ${CPLANE}"
echo -e "Workers found: ${WORKER_COUNT}"
if [ -n "$WORKERS" ]; then
    echo "$WORKERS" | while read -r w; do echo "  - $w"; done
fi
echo ""

read -p "Are you sure you want to delete this cluster? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
fi

# Delete control plane
echo -e "${YELLOW}Deleting control plane...${NC}"
multipass delete "$CPLANE" 2>/dev/null || echo "Control plane not found"

# Delete all discovered workers
if [ -n "$WORKERS" ]; then
    echo "$WORKERS" | while read -r w; do
        echo -e "${YELLOW}Deleting ${w}...${NC}"
        multipass delete "$w" 2>/dev/null || echo "${w} not found"
    done
fi

# Purge deleted instances
echo -e "${YELLOW}Purging deleted instances...${NC}"
multipass purge

# Clean inventory file
if [ -f "inventory/cluster.yml" ]; then
    rm -f inventory/cluster.yml
    echo -e "${YELLOW}Inventory file removed${NC}"
fi

echo -e "${GREEN}Cluster cleanup completed!${NC}"
echo ""
echo "Remaining instances:"
multipass list
