#!/bin/bash

# Add a new worker node to an existing Kubernetes cluster.
# Uses LIFO strategy: new worker gets number = max existing + 1.
# Usage: ./run-add-worker.sh -c <cluster_name>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CLUSTER_NAME=""

usage() {
    cat << EOF
Usage: $0 -c <cluster_name>

Add a new worker node to an existing Kubernetes cluster.

OPTIONS:
    -c, --cluster NAME    Cluster name (required)
    -h, --help            Show this help message

EXAMPLES:
    $0 --cluster test
    $0 -c test

EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--cluster)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
    esac
done

if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}Error: Cluster name is required${NC}"
    usage
fi

# Verify control plane exists
if ! multipass list 2>/dev/null | grep -q "${CLUSTER_NAME}-cplane"; then
    echo -e "${RED}Error: Control plane '${CLUSTER_NAME}-cplane' not found${NC}"
    echo -e "${YELLOW}Available VMs:${NC}"
    multipass list
    exit 1
fi

echo -e "${GREEN}Adding worker to cluster: ${CLUSTER_NAME}${NC}"
ansible-playbook add-worker.yml -e "cluster_name=${CLUSTER_NAME}"
echo -e "${GREEN}Worker added successfully!${NC}"
