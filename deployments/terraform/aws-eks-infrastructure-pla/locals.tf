locals {

  # We build up an array of objects for each managed node group.
  # Each object contains: its key, the tags of each managed node group and a list of the auto scaling group(s)
  node_groups_autoscaling_tags = [for each_node_group_k, each_node_group_v in var.eks_managed_node_groups :
    {
      # The key of the managed node group
      "node_group_key" = each_node_group_k
      # All tags of the managed node group
      "tags" = lookup(each_node_group_v, "tags", {})
      # Determine the name(s) of the AWS Autoscaling Group created by the EKS module for that managed node group
      "autoscaling_groups" = flatten(lookup(module.eks.eks_managed_node_groups, each_node_group_k, { node_group_autoscaling_group_names = [] }).node_group_autoscaling_group_names.*)
    }
  ]
}
