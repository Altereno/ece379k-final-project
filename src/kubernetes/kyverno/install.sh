#!/usr/bin/env bash

KUBECONFIG=../config-10.0.10.173
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace