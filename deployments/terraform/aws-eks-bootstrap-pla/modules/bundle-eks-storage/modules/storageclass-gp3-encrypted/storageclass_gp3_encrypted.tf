#
# Creates a storage class named gp3-encrypted based on encrypted EBS volumes
#
resource "kubernetes_storage_class" "main" {
  metadata {
    name = "gp3-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  parameters = {
    "csi.storage.k8s.io/fstype" = "ext4"
    "type"                      = "gp3"
    "encrypted"                 = "true"
  }
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}