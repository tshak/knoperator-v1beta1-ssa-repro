
#!/bin/bash
set -o errexit

function apply() {
  RESOURCE=$1
  kubectl --force-conflicts --wait=true --server-side=true apply -f ${RESOURCE}
}

function applyOperator() {
  OPERATOR_VERSION=$1
  echo "Applying Operator ${OPERATOR_VERSION}..."
  apply https://github.com/knative/operator/releases/download/knative-${OPERATOR_VERSION}/operator.yaml
  echo "Waiting for Operator ${OPERATOR_VERSION} to be ready..."
  kubectl wait deployment --all --for condition=Available=True --timeout=120s
}

applyOperator v1.2.2
apply "./knativeserving-v1alpha1.yaml"
# Repros with or without incremental operator upgrades
# applyOperator v1.3.2
# applyOperator v1.4.1
applyOperator v1.5.3
apply "./knativeserving-v1beta1.yaml"
# Wait for the operator to reconcile, otherwise the bug does not reproduce consitently
sleep 30
applyOperator v1.6.1
# Applying v1beta1 again fails with:
# Error from server: request to convert CR to an invalid group/version: operator.knative.dev/v1alpha1
apply "./knativeserving-v1beta1.yaml"


# kubectl get knativeserving knative-serving --show-managed-fields=true -n default -o yaml | grep v1alpha1





