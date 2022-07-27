# bootstrap-app

## Introduction

Boostrap App is a Helm chart that utilizing pattern app of apps deploys sequentially required controllers and applications to run modern kubernetes cluster.
This chart bootstraps following applications:

1. [Cert Manager](https://cert-manager.io/docs/configuration/acme/dns01/route53/) with [istio-csr](https://github.com/cert-manager/istio-csr)
2. Certificate issuers for istio and cluster
3. [External DNS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md)
4. [ClusterScaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/CA_with_AWS_IAM_OIDC.md)
5. [Istio Opeartor](https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/) with [Istio](https://istio.io/) service mesh
6. [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
7. Jaeger Operator with [Jaeger](https://www.jaegertracing.io/docs/1.21/operator/#elasticsearch-storage) - due to issues with official helm operator chart we are maintaing it ourselves.
8. [Prometheus Operator with Grafana](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
9. [Kiali operator](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml) with [Kiali](https://kiali.io/) dashboard
10. [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller)
11. Exposes ArgoCD, Grafana, Prometheus, Jaeger internally to the network
12. Optionally [Elasticsearch](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-api-common-k8s-elastic-co-v1.html)

**Warning**: This Chart shouldn't be applied outside ArgoCD!

## Prerequisites

- Kubernetes 1.18+
- ArgoCD installed on cluster

## Installing the Chart

To install the chart deploy chart in [infrastructure/applications](../../applications). ArgoCD should handle of deploying and managing applications.

## Uninstalling the Chart

:warning: Once installed this chart shouldn't be removed as it will remove all service mesh, monitoring, certificate managements, etc. It should be removed alongside the cluster!

```console
argocd app delete boostrap-app
```

## Parameters

The following tables lists the configurable parameters of the contour chart and their default values.

### Environment specific parameters

| Parameter                          | Description                                                                                         | Default                                                 |
|------------------------------------|-----------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| `targetRevision`                   | GitHub branch revision name                                                                         | `main`                                                  |
| `domain`                           | Domain name                                                                                         | specific to env `k8s.outra.co.uk` or `outra.co.uk`      |
| `clusterName`                      | Name of deployed EKS Cluster                                                                        | `outra-dev-eks-poc` or `outra-data-eks`                 |
| `environment`                      | Name of the environment where it is deployed                                                        | `staging` or `production`                               |
| `alb.version`                      | Version of AWS Load Balancer Controller                                                             | `1.1.2`                                                 |
| `alb.vpcId`                        | AWS VPC id                                                                                          | Env specific VPC id                                     |
| `istioCsr.version`                 | Version of Istio csr                                                                                | `v0.1.0`                                                |
| `alb.version`                      | Version of AWS Load Balancer Controller                                                             | `1.1.2`                                                 |
| `externalDNS.version`              | Version of ExternalDNS                                                                              | `4.6.0`                                                 |
| `externalDNS.txtOwnerId`           | When using the TXT registry, a name that identifies this instance of ExternalDNS                    | `Z246JDEMZJWA94`                                        |
| `externalDNS.policy`               | Modify how DNS records are synchronized between sources and providers (options: sync, upsert-only ) | `upsert-only`                                           |
| `externalDNS.logLevel`             | Verbosity of the logs (options: panic, debug, info, warn, error, fatal)                             | `info`                                                  |
| `externalDNS.zoneType`             | When using the AWS provider, filter for zones of this type (optional, options: public, private)     | `public`                                                |
| `istio.operator.tag`               | Version of Istio operator image                                                                     | `1.8.3`                                                 |
| `certIssuer.hostedZoneId`          | AWS hosted zone id                                                                                  | `Z246JDEMZJWA94`                                        |
| `certIssuer.dnsZones`              | CertIssuer dns zones                                                                                | `k8s.outra.co.uk`                                       |
| `prometheus.version`               | Prometheus operator helm chart version                                                              | `13.7.2`                                                |
| `prometheus.protocol`              | Prometheus HTTP protocol                                                                            | `http`                                                  |
| `prometheus.service`               | Prometheus service name                                                                             | `prometheus-operated`                                   |
| `prometheus.external-service`      | Prometheus external service name                                                                    | `prometheus`                                            |
| `prometheus.port`                  | Prometheus HTTP port                                                                                | 9090                                                    |
| `grafana.protocol`                 | Grafana HTTP protocol                                                                               | `http`                                                  |
| `grafana.service`                  | Grafana service nam                                                                                 | `prometheus-operator-grafana`                           |
| `grafana.external-service`         | Grafana external service name                                                                       | `grafana`                                               |
| `tracing.protocol`                 | Tracing (Jaeger) HTTP protocol                                                                      | `http`                                                  |
| `tracing.service`                  | Tracing (Jaeger) service name                                                                       | `tracing`                                               |
| `tracing.image.tag`                | Tracing (Jaeger) image tag                                                                          | `1.21.1`                                                |
| `tracing.elastic.url`              | Tracing (Jaeger) elastic backend url                                                                | `http://elastic-istio-es-http:9200`                     |
| `tracing.elastic.secretName`       | Tracing (Jaeger) secret containing ES_USERNAME and ES_PASSWORD                                      | `elastic-istio-es-elastic-user-jaeger`                  |
| `tracing.elastic.usernmae`         | Tracing (Jaeger) elastic username that will be put in the secret                                    | `elastic`                                               |
| `tracing.elastic.password`         | Tracing (Jaeger) elastic password that will be put in the secret                                    | `jaeger`                                                |
| `kiali.version`                    | Kiali operator version                                                                              | `1.21.1`                                                |
| `kiali.logging.log_level`          | Kiali dashboard logging level                                                                       | `info`                                                  |
| `cert.version`                     | cert-manager version                                                                                | `v1.1.0`                                                |
| `sealedSecrets.version`            | Sealed Secrets version                                                                              | `1.13.2`                                                |
| `elastic.enabled`                  | Boolean flag controlling if we should deploy elastic to k8s                                         | `true` for dev `false` for prod                         |
| `elastic.version`                  | Elasticsearch version                                                                               | `7.11.0`                                                |
| `elastic.opeartorVersion`          | Elastic Opeartor version                                                                            | `1.4.0`                                                 |

### Common parameters

In [values.yaml](values.yaml) you can find common parameteres to each environment, e.g. resources requests and limits.
