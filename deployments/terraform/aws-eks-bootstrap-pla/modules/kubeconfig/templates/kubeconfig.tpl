apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${cluster_auth_base64}
    server: ${endpoint}
  name: ${arn}
contexts:
- context:
    cluster: ${arn}
    user: ${arn}
  name: ${arn}
current-context: ${arn}
kind: Config
preferences: {}
users:
- name: ${arn}
  user:
    exec:
      apiVersion: ${kubeconfig_auth_api_version}
      args:
%{~ for i in kubeconfig_auth_command_args }
      - ${i}
%{~ endfor ~}
%{ for i in kubeconfig_auth_additional_args }
      - ${i}
%{~ endfor ~}
      
      command: ${kubeconfig_auth_command}
%{ if length(kubeconfig_auth_env_variables) > 0 }
      env:
  %{~ for k, v in kubeconfig_auth_env_variables ~}
      - name: ${k}
        value: ${v}
  %{~ endfor ~}
%{ endif }
