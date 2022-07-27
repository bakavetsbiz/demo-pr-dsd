locals {
  argocd = {
    namespace = "argocd"
  }
  initial_bootstrap = {
    repoURL               = "https://github.com/bakavetsbiz/demo-dsd.git"
    targetRevision        = "main"
    destination_namespace = "argocd"
    source_path           = "k8s/infrastructure/applications/"
  }

  certIssuer = {
    email        = "anton.bokovets@effective-soft.com"
    hostedZoneID = "Z04935571NDH8HTVRWFZ3"
    awsRegion    = "eu-west-1"
    dnsZones     = "devops-lab.co.uk"
  }

  externalDNS = {
    domain     = "devops-lab.co.uk"
    txtOwnerId = "Z04935571NDH8HTVRWFZ3"
  }

  appHosts = {
    apitextstat = "app-demo.devops-lab.co.uk"
    testApp1    = "app-1.devops-lab.co.uk"
    testApp2    = "app-2.devops-lab.co.uk"
  }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "4.9.16"
  namespace        = local.argocd.namespace
  create_namespace = true

  depends_on = [
    module.eks
  ]
}

resource "kubectl_manifest" "initial_bootstrap" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: initial-bootstrap
  namespace: ${local.argocd.namespace}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    path: ${local.initial_bootstrap.source_path}
    repoURL: ${local.initial_bootstrap.repoURL}
    targetRevision: ${local.initial_bootstrap.targetRevision}

    helm:
      parameters:
      - name: awsRegion
        value: ${var.aws_region}
      - name: domain
        value: ${local.externalDNS.domain}
      - name: targetRevision
        value: ${local.initial_bootstrap.targetRevision}
      - name: certManager_sa_eks_role_arn
        value: ${module.iam_assumable_role_admin_cert_manager.iam_role_arn}

      - name: certIssuer.email
        value: ${local.certIssuer.email}
      - name: certIssuer.hostedZoneID
        value: ${local.certIssuer.hostedZoneID}
      - name: certIssuer.awsRegion
        value: ${local.certIssuer.awsRegion}
      - name: certIssuer.dnsZones
        value: ${local.certIssuer.dnsZones}

      - name: externalDNS.domain
        value: ${local.externalDNS.domain}
      - name: externalDNS.txtOwnerId
        value: ${local.externalDNS.txtOwnerId}
      - name: externalDNS.serviceAccount.name
        value: ${local.k8s_service_account_external_dns_name}
      - name: externalDNS.serviceAccount.eksRoleARN
        value: ${module.iam_assumable_role_external_dns.iam_role_arn}
      - name: externalDNS.namespace
        value: ${local.k8s_service_account_external_dns_namespace}

      - name: appHosts.apitextstat
        value: ${local.appHosts.apitextstat}
      - name: appHosts.testApp1
        value: ${local.appHosts.testApp1}
      - name: appHosts.testApp2
        value: ${local.appHosts.testApp2}

  destination:
    namespace: ${local.argocd.namespace}
    server: https://kubernetes.default.svc

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: -1
YAML

  depends_on = [
    helm_release.argocd
  ]
}