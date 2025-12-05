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
        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$host" "cat <<EOF > /home/$SSH_USER/kind-expose.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: \"0.0.0.0\"
  apiServerPort: 6443
kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      certSANs:
        - \"$host\"
EOF"
        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$host" "$KIND_CMD create cluster --config /home/$SSH_USER/kind-expose.yaml"
    fi

    echo "Copying kubeconfig."
    scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$host:/home/$SSH_USER/.kube/config" "./config-$host"
    sed -i '' "s/0.0.0.0/$host/g" ./config-$host

done

exit 0