#!/usr/bin/env bash

HOSTS=("10.0.10.172" "10.0.10.173" "10.0.10.174")
SSH_USER="compsec"
SSH_KEY="../keys/ansible"
KIND_CMD="/home/linuxbrew/.linuxbrew/bin/kind"

for host in "${HOSTS[@]}"; do
    echo "Current host: $host"

    REMOTE_CLUSTERS=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$host" "$KIND_CMD get clusters")
    echo $REMOTE_CLUSTERS

    if echo "$REMOTE_CLUSTERS" | grep -q "^kind$"; then
        echo "Cluster already exists on $host. Skipping creation."
    else
        echo "No cluster found. Creating default cluster."
        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$host" "$KIND_CMD create cluster"
    fi

    echo "Copying kubeconfig."
    scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$host:/home/$SSH_USER/.kube/config" "./config-$host"

done

exit 0