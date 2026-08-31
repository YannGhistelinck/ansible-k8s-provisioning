# ansible-k8s-provisioning

Infrastructure as code project using Ansible to provision a production-ready Kubernetes cluster on local Multipass virtual machines.

## Overview

Complete automation of a Kubernetes cluster lifecycle. Powered by kubeadm, Ansible playbooks, and a custom Multipass connection plugin.

Designed for developers and DevOps engineers who need a real multi-node Kubernetes environment locally, without relying on cloud providers or simplified distributions like Minikube or K3s. 

## Features

Clusters come pre-configured with Flannel networking, Ingress NGINX, and a default StorageClass, making them ready for real workload testing. The project provides three core operations:

- Cluster creation
	- Create VMs, configure one control plane, configure many workers and join them to the cluster.
- Worker node scale up
	- Create, configure and join a new VM worker to the cluster to scale up workers resources.
- Worker node scale down
	- Gracefully remove a worker from the current cluster to scale down workers resources.

Technical features: 
- Custom Multipass connection plugin — Ansible communicates directly with VMs through multipass exec, no SSH configuration needed
- Idempotent playbooks — Safe to re-run without breaking existing cluster state
- Graceful node removal — Workers are cordoned, drained, then deleted from the cluster before VM cleanup   
- Dynamic inventory — Inventory is generated at runtime based on actual VM state
- Configurable resources — CPU, memory, disk, Kubernetes version, all defined in a single config file 

## Prerequisites

Ensure the following are installed: 
- Multipass (For VM management)
- Ansible (To run playbooks)

Currently tested on macOS. Linux support is planned. 

## Quick Start

## Configuration

## Usage

## Project Structure
