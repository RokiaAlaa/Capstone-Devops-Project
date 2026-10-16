# Capstone DevOps Project

![CI](https://github.com/RokiaAlaa/Capstone-Devops-Project/actions/workflows/ci.yaml/badge.svg)

A small online store backend (users, products, orders) built to practice a full DevOps workflow: Terraform, Ansible, GitHub Actions, ArgoCD, Istio, Prometheus and Grafana, and an EFK logging stack.

## How it fits together

```
GitHub Actions:  test -> build -> push images to Docker Hub

Git repo (gitops/)  <-- ArgoCD syncs -->  Kubernetes (EKS)
                                            |
        nginx Ingress -> Istio mesh -> user / product / order services
                                            |
         Prometheus + Grafana     Elasticsearch + Fluent Bit + Kibana
                                            |
        RDS PostgreSQL (one database per service)    ElastiCache Redis

Secrets:  HashiCorp Vault -> External Secrets Operator -> Kubernetes
```

## What's in the repo

```
backend/            3 Django services, docker-compose, .env.example
infrastructure/     Terraform (vpc, eks, rds, redis) with local and prod environments
ansible/            Roles that install the cluster tools
k8s/                Istio, ingress, and monitoring manifests
gitops/             App manifests (Kustomize) and ArgoCD applications
scripts/            Test traffic script
.github/workflows/  CI, CD, and security scan
```

`k8s/` holds the mesh, ingress, and monitoring manifests applied directly. `gitops/` holds the application workloads synced by ArgoCD.

## Services

- **User service**: `/api/users/`, database `user_service_db`
- **Product service**: `/api/products/`, database `product_service_db`. The product list is cached in Redis for 60 seconds.
- **Order service**: `/api/orders/`, database `order_service_db`

Each service has its own database and a `/health/` endpoint for Kubernetes probes. Orders only store user and product IDs, with no foreign keys across databases.

To run locally, copy `backend/.env.example` to `backend/.env`, fill in the values, and start Docker Compose from `backend/`.

## CI/CD

CI runs on every push to `main`:

1. Run each service's tests against real Postgres and Redis containers
2. Build the images and push them to Docker Hub (tagged `latest` and the commit SHA)
3. Check the Kubernetes YAML and Terraform formatting
4. Send a Slack message with the result

A separate workflow scans each service with Trivy. The CD workflow is manual.

For GitOps, a root ArgoCD app (`gitops/argocd/app-of-apps.yaml`) creates one app per service plus one for shared config. They sync from `gitops/overlays/prod` with auto-prune and self-heal on.

## Secrets

- The database credentials, the Grafana admin login, and the Django `SECRET_KEY` live in Vault. External Secrets Operator pulls them into the cluster. None of them are in Git.
- After Vault starts, write the values by hand: `secret/prod/db` (user, password), `secret/prod/grafana` (admin-user, admin-password), and `secret/prod/django` (secret-key).
- Pipeline secrets (Docker Hub, Slack, kubeconfig) are kept in GitHub Secrets.
- `backend/.env.example` is only for local Docker Compose.

## Service mesh and security

- Istio retries, timeouts, connection limits, and outlier detection for each service
- mTLS in STRICT mode between services
- An authorization policy that only allows traffic from the `prod` and `ingress-nginx` namespaces
- Trivy scans in CI

## Monitoring and logging

- Prometheus collects metrics, including Istio request metrics, and has alert rules for errors, latency, and crash loops
- A Grafana dashboard shows request rate, errors, p95 latency, and memory
- Fluent Bit sends logs to Elasticsearch, and Kibana reads them (index pattern `logs-*`)

## Deploying

1. Create the infrastructure with Terraform (`infrastructure/environments/prod`).
2. Run the Ansible playbook from `ansible/` to install ingress, Vault, ArgoCD, monitoring, and logging. ArgoCD gets a LoadBalancer by default. On minikube, add `-e argocd_service_type=NodePort`.
3. Write the secrets into Vault (see Secrets above).
4. Turn on Istio injection and apply the mesh config:

```bash
kubectl label namespace prod istio-injection=enabled
kubectl label namespace ingress-nginx istio-injection=enabled
kubectl apply -f k8s/istio-config.yaml -f k8s/mtls-config.yaml -f k8s/ingress.yaml
```

5. Apply `gitops/argocd/app-of-apps.yaml`. ArgoCD deploys the services from there.

## Notes and known limitations

- **Validation scope:** Validated with `terraform plan`/`apply` against LocalStack (Community Edition). VPC provisioning confirmed working; EKS/RDS/ElastiCache require LocalStack Pro or real AWS to fully apply — code is structured and ready for either.
- **Logging:** Used EFK (Fluent Bit instead of Logstash) for lower resource footprint in local Kubernetes environments.
- **Secrets in manifests:** Database credentials are not stored in Git. An External Secrets Operator `ExternalSecret` pulls them from HashiCorp Vault at runtime. Vault runs in dev mode here for demonstration; production would use HA mode with proper unseal and auth.
- **Secrets in pipelines:** CI/CD pipeline secrets (Docker Hub, kubeconfig) are managed via GitHub Secrets, scoped to the pipeline itself. Application runtime secrets (DB credentials) are designed to be injected via HashiCorp Vault at the pod level, keeping CI/CD and application secret management separate.
- **CD workflow:** CD workflow is implemented and manually triggerable; requires a KUBECONFIG secret pointing to a real EKS cluster to execute.
- **Environments:** Terraform has local (LocalStack) and prod environments. The local one is kept as a reference.
- **Elasticsearch security:** Turned off in the logging role to keep the setup simple. Turn it on for a real production deployment.
- **API access:** The APIs have no authentication yet.

## Author

Built by Rokia Alaa as a capstone DevOps project.
