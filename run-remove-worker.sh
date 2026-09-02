#!/bin/bash

# Remove the worker with the highest index from a Kubernetes cluster.
# Uses LIFO strategy: always removes the last worker.
# Usage: ./run-remove-worker.sh -c <cluster_name>

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

Remove the worker node with the highest index from the cluster.

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

# Warn if control plane is missing
if ! multipass list 2>/dev/null | grep -q "${CLUSTER_NAME}-cplane"; then
    echo -e "${YELLOW}Warning: Control plane '${CLUSTER_NAME}-cplane' not found${NC}"
    echo -e "${YELLOW}Will attempt to delete the worker VM only${NC}"
fi

echo -e "${GREEN}Removing last worker from cluster: ${CLUSTER_NAME}${NC}"
ansible-playbook remove-worker.yml -e "cluster_name=${CLUSTER_NAME}"
echo -e "${GREEN}Worker removed successfully!${NC}"
