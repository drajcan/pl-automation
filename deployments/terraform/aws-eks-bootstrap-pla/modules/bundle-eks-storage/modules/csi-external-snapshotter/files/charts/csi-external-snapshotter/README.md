# CSI External Snapshotter

As of May 2022 no helm charts exists for CSI External Snapshotter, this helm chart contains the major files for installing the Snapshotter including CRDs.

Important: Do use v6.0.1 or higher as it includes fixes. Do **NOT** use v6.0.0

## Content

- templates/setup-snapshot-controller - Taken from [https://github.com/kubernetes-csi/external-snapshotter/blob/v6.1.0/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml](https://github.com/kubernetes-csi/external-snapshotter/blob/v6.1.0/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml)

  - Added container and pod security context
  - Image is located at [gcr.io/k8s-staging-sig-storage/snapshot-controller](https://console.cloud.google.com/gcr/images/k8s-staging-sig-storage/GLOBAL/snapshot-controller) and not at *k8s.gcr.io/sig-storage/snapshot-controller* as documented. Also see this [issue 769](https://github.com/kubernetes-csi/external-snapshotter/issues/769)
- templates/rbac-snapshot-controller - Taken from [https://github.com/kubernetes-csi/external-snapshotter/blob/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml](https://github.com/kubernetes-csi/external-snapshotter/blob/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml)
- crds/ - Taken from [https://github.com/kubernetes-csi/external-snapshotter/tree/v6.1.0/client/config/crd](https://github.com/kubernetes-csi/external-snapshotter/tree/v6.1.0/client/config/crd)

## Links

- [https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v6.1.0](https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v6.1.0)
- [https://github.com/kubernetes-csi/external-snapshotter/tree/v6.1.0](https://github.com/kubernetes-csi/external-snapshotter/tree/v6.1.0)
- [https://github.com/kubernetes-sigs/aws-ebs-csi-driver/issues/1249](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/issues/1249)
