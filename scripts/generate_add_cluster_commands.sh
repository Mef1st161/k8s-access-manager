#!/bin/bash

SERVICE_ACCOUNT_NAME=$1
NAMESPACE=users # можно заменить если юзеры в другом NS


usage() {
  echo "Usage: bash generate_add_cluster_commands.sh <serviceaccount-name>"
  exit 1
}

[[ -z $SERVICE_ACCOUNT_NAME ]] && usage



# Get data from kubectl
CURRENT_CONTEXT=$(kubectl config current-context)

SECRET_NAME=$(kubectl get serviceaccount $SERVICE_ACCOUNT_NAME -n $NAMESPACE -o jsonpath='{.secrets[0].name}')
[[ -z $SECRET_NAME ]] && SECRET_NAME=$SERVICE_ACCOUNT_NAME-secret #для тест окружения
USER_TOKEN=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.token}' | base64 --decode)
CLUSTER_NAME=$(kubectl config view -o jsonpath="{.contexts[?(@.name == '${CURRENT_CONTEXT}')].context.cluster}")
CLUSTER_ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name == '${CLUSTER_NAME}')].cluster.server}")


# Generate kubectl commands using data
echo "# Commands to configure kubectl access for the service account: $SERVICE_ACCOUNT_NAME"
echo "kubectl config set-cluster $CLUSTER_NAME --server=$CLUSTER_ENDPOINT --insecure-skip-tls-verify=true"
echo "kubectl config set-credentials $SERVICE_ACCOUNT_NAME@$CLUSTER_NAME --token=$USER_TOKEN"
echo "kubectl config set-context $CLUSTER_NAME --cluster=$CLUSTER_NAME --user=$SERVICE_ACCOUNT_NAME@$CLUSTER_NAME"
echo "kubectl config use-context $CLUSTER_NAME"

