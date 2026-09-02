#!/bin/bash

# Create a new Kubernetes cluster using Ansible and Multipass.
# Usage: ./run-cluster.sh

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

# Check prerequisites
if ! command -v multipass &> /dev/null; then
    echo -e "${RED}Error: Multipass is not installed${NC}"
    echo "Install it with: brew install multipass"
    exit 1
fi

if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: Ansible is not installed${NC}"
    echo "Install it with: pip3 install ansible"
    exit 1
fi

echo -e "${GREEN}Prerequisites OK${NC}"

# Clean old inventory if exists
if [ -f "inventory/cluster.yml" ]; then
    echo -e "${YELLOW}Cleaning old inventory file...${NC}"
    rm -f inventory/cluster.yml
fi

# Run playbook
echo -e "${GREEN}Starting cluster creation...${NC}"
ansible-playbook create-cluster.yml

echo -e "${GREEN}Cluster creation completed!${NC}"
echo ""
echo "To access your cluster:"
echo "  multipass shell ${CLUSTER_NAME}-cplane"
echo "  kubectl get nodes"
