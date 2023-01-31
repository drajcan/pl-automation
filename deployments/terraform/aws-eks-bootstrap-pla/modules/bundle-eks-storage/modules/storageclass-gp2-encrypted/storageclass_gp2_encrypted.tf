#
# Creates a default storage class named gp2-encrypted based on encrypted EBS volumes
# Note: Since EKS 1.11 a default storage class named "gp2" without encryption exists - we will also unset the default-flag from this storage class
#

resource "kubernetes_storage_class" "main" {
  metadata {
    name = "gp2-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner    = "kubernetes.io/aws-ebs"
  allow_volume_expansion = true
  parameters = {
    fsType    = "ext4"
    type      = "gp2"
    encrypted = "true"
  }
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "null_resource" "remove_default_storage_class_from_gp2" {
  triggers = {
    kubeconfig_path = var.kubeconfig_filename
  }
  provisioner "local-exec" {
    command = <<EOF
kubectl --kubeconfig ${var.kubeconfig_filename} patch storageclass gp2 --patch '
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
'
EOF
  }

  provisioner "local-exec" {
    command = <<EOF
kubectl --kubeconfig ${self.triggers.kubeconfig_path} patch storageclass gp2 --patch '
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
'
EOF
    when    = destroy
  }
}
