This contains a repro of a bug when upgrading the Knative Operator to `v1.6.1` that was found when debugging https://github.com/knative/operator/issues/1131. This issue seems related. The end result is that it blocks the user from
applying a knative CR using [Server-Side Apply](https://kubernetes.io/docs/reference/using-api/server-side-apply/) after upgrading to the Knative Opererator `v1.6.1`.
This repo contains [a script](./repro.sh) which repor's the issue. The issue seems to be related to converting from `operator.knative.dev/v1alpha1` to `operator.knative.dev/v1beta1`. You may wish to adjust the script to test different combinations of Operator versions and CR versions.

Automated repro steps:
1) Create a clean cluster (never had knative installed) e.g. with Kind or Minikube
2) Ensure that you're Kubernetes Context is pointing to the desired cluster
3) Run ./repro.sh
4) Observe the following error:

```
Error from server: request to convert CR to an invalid group/version: operator.knative.dev/v1alpha1
```

This appears to be due to a `metadata.managedFields` entry that references `operator.knative.dev/v1alpha1`:

`$ kubectl get knativeserving knative-serving --show-managed-fields=true -n default -o yaml`
Output (truncated):
```
- apiVersion: operator.knative.dev/v1alpha1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:finalizers:
          .: {}
          v:"knativeservings.operator.knative.dev": {}
    manager: operator
    operation: Update
    time: "2022-08-17T09:11:59Z"
```

This script was tested using Kind on server version `1.24.0`, although the issue has been ad hoc reproduced on other clusters versions (`1.22.*` and `1.23.*`).