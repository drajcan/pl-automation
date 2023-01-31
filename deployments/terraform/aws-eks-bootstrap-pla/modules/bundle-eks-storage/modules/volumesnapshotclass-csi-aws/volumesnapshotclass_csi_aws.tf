#
# Creates a default VolumeSnapshotClass csi-aws
#
# https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/
#
# See https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a 
# why we use helm_release instead of kubernetes_manifest
resource "helm_release" "main" {
  name      = "volumesnapshotclass-csi-aws"
  namespace = "kube-system"

  chart = "${path.module}/../../../../files/charts/raw"

  values = [<<EOF
extraResources:
- |
  apiVersion: snapshot.storage.k8s.io/v1
  kind: VolumeSnapshotClass
  driver: ebs.csi.aws.com
  deletionPolicy: Delete
  metadata:
    name: csi-aws
    annotations:
      snapshot.storage.kubernetes.io/is-default-class: "true"

- |
  apiVersion: snapshot.storage.k8s.io/v1
  kind: VolumeSnapshotClass
  driver: ebs.csi.aws.com
  deletionPolicy: Retain
  metadata:
    name: csi-aws-retain
    annotations:
      snapshot.storage.kubernetes.io/is-default-class: "false"

EOF
  ]
}
