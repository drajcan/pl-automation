#
# (Unmanaged) Addon "AWS LoadBalancer Controller"
#
# Helm Chart:     https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
# AWS/IAM Policy: https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.3/docs/install/iam_policy.json

# 1. Create an IAM Role which can be used by a Kubernetes Service Account
# See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-aws-load-balancer-controller"
  service_accounts                    = ["kube-system/aws-load-balancer-controller"]
  inline_policies = [<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  ]
}

#
# 2. Deployment of CRDs
# See https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html and https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
# Expected Result:
# customresourcedefinition.apiextensions.k8s.io/ingressclassparams.elbv2.k8s.aws configured
# customresourcedefinition.apiextensions.k8s.io/targetgroupbindings.elbv2.k8s.aws configured
resource "null_resource" "prerequisites" {
  triggers = {
    kubeconfig_path = var.kubeconfig_filename
  }
  provisioner "local-exec" {
    command = <<EOF
    kubectl --kubeconfig ${var.kubeconfig_filename} apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
EOF
  }
  provisioner "local-exec" {
    command = <<EOF
    kubectl --kubeconfig ${self.triggers.kubeconfig_path} --ignore-not-found=true --wait=true delete -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
  EOF
    when    = destroy
  }
}

#
# Nice try but does not work due to plugin error:
#
# Instead of
# kubectl --kubeconfig ${self.triggers.kubeconfig_path} delete -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
# we use kubernetes_manifest - files taken from https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
# https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest
# resource "kubernetes_manifest" "eks_addon_aws_lb_controller_crd_1" {
#   manifest = yamldecode(file("${path.module}/files/eks_addon_aws_lb_controller_crd_1.yaml"))
# }
# resource "kubernetes_manifest" "eks_addon_aws_lb_controller_crd_2" {
#   manifest = yamldecode(file("${path.module}/files/eks_addon_aws_lb_controller_crd_2.yaml"))
# }

# 3. Deploy LB Controller via helm (v3)
resource "helm_release" "main" {
  depends_on = [
    null_resource.prerequisites,
    module.iam_role
  ]

  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.5" # 2022-Sep-24

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "replicaCount"
    value = "2"
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_role.this_role_arn
  }
  # Only required if not running on EC2 Workernode, e.g. on Fargate instead
  # AND if hoplimit to metadata instance service  is < 2 - see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#using-metadata-server-version-2-imdsv2
  set {
    name  = "region"
    value = var.region
  }
  # Only required if not running on EC2 Workernode, e.g. on Fargate instead
  # AND if hoplimit to metadata instance service is < 2 - see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#using-metadata-server-version-2-imdsv2
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  # v2.4.1: If you do use the authentication via OIDC IDP feature for any Ingress in cluster, you must grant the controller RBAC permission to access Secret resources been referenced. For backwards compatibility, the helm chart provides an option to grant controller RBAC permission to access all Secrets by explicitly setting --set clusterSecretsPermissions.allowAllSecrets=true. However, we recommend configuring separate namespaced Role/RoleBinding to grant controller access to your specific secret resources to strengthen security posture.
  set {
    name  = "clusterSecretsPermissions.allowAllSecrets"
    value = "true"
  }

  values = [<<EOF
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 10m
    memory: 128Mi

securityContext:
  privileged: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 65534
  runAsGroup: 65534

podSecurityContext:
  runAsUser: 65534
  runAsGroup: 65534
  fsGroup: 65534
  seccompProfile:
    type: RuntimeDefault
EOF
  ]
}
