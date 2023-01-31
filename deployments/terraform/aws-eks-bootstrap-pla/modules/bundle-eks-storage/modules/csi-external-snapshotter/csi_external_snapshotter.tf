#
# We use an own Helm Chart with the original files for CSI Snapshot Controller
# as no official helm chart exists for the CSI Snapshot Controller
# See https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html
#
resource "helm_release" "main" {
  name      = "csi-external-snapshotter"
  namespace = "kube-system"

  chart = "${path.module}/files/charts/csi-external-snapshotter"

  values = [<<EOF
image: "registry.k8s.io/sig-storage/snapshot-controller:v6.1.0@sha256:823c75d0c45d1427f6d850070956d9ca657140a7bbf828381541d1d808475280"

EOF
  ]
}
