output "this_crb_view_group_name" {
  description = "The name of the subject of type group in clusterrolebinding view"
  value       = local.crb_view_group_name
}
output "this_crb_edit_group_name" {
  description = "The name of the subject of type group in clusterrolebinding edit"
  value       = local.crb_edit_group_name
}
output "this_crb_admin_group_name" {
  description = "The name of the subject of type group in clusterrolebinding admin"
  value       = local.crb_admin_group_name
}
