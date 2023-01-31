#
# AWS EBS CSI
#
module "csi_external_snapshotter" {
  source = "./modules/csi-external-snapshotter"
}

module "aws_ebs_csi_driver" {
  # External Snapshotter and its CRDs must be installed first! See doc!
  depends_on = [module.csi_external_snapshotter]

  source = "./modules/aws-ebs-csi-driver"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  kubeconfig_filename                 = var.kubeconfig_filename
}

#
# Volume Snapshot Scheduler
#
module "snapscheduler" {
  # Requires the CRDs to be installed first and the EBS CSI Driver which creates the snapshots
  depends_on = [
    module.csi_external_snapshotter,
    module.aws_ebs_csi_driver
  ]

  source = "./modules/snapscheduler"
}

#
# AWS EFS CSI
#
module "aws_efs_csi_driver" {
  source = "./modules/aws-efs-csi-driver"

  account_id                          = var.account_id
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
}


#
# Secret Mounting from AWS Secrets Manager
#
module "csi_secrets_store_driver" {
  source = "./modules/csi-secrets-store-driver"
}
module "aws_csi_secrets_store_provider" {
  # Requires the secrets store driver to be installed first
  depends_on = [module.csi_secrets_store_driver]

  source = "./modules/aws-csi-secrets-store-provider"
}

#
# Storage Classes
#
module "storageclass_gp2_encrypted" {
  source = "./modules/storageclass-gp2-encrypted"

  kubeconfig_filename = var.kubeconfig_filename
}
module "storageclass_gp3_encrypted" {
  # Requires the AWS EBS driver
  depends_on = [
    module.csi_external_snapshotter,
    module.aws_ebs_csi_driver
  ]
  source = "./modules/storageclass-gp3-encrypted"
}


#
# VolumeSnapshotClass
#
module "volumesnapshotclass_csi_aws" {
  # Requiresd the CRDs
  depends_on = [module.csi_external_snapshotter]
  source     = "./modules/volumesnapshotclass-csi-aws"
}
