# 🏠 Mini-Homelab

A production-like infrastructure lab designed for learning and practicing everything about DevOps.

## System Architecture

![system-diagram](/assets/system-diagram.drawio.png)

## Tech Stack

| Category | Tool | Role |
|----------|------|------|
| **Infrastructure** | Terraform (Azure) | Provision 2 VMs, networking, NSGs |
| **Configuration** | Ansible | Configure gateway/app servers, WireGuard VPN |
| **Kubernetes** | K3s | Lightweight Kubernetes distribution |
| **GitOps** | ArgoCD | Declarative continuous deployment |
| **Ingress** | Traefik | L7 load balancer & routing |
| **Metrics** | VictoriaMetrics | Prometheus-compatible TSDB (vmsingle + vmagent) |
| **Logging** | Loki + Promtail | Log aggregation & collection |
| **Visualization** | Grafana | Dashboards for metrics & logs |
| **Alerting** | VMAlert + Alertmanager | Alert evaluation & notification |
| **Chaos Engineering** | Chaos Mesh | Fault injection experiments |
| **Load Testing** | k6 (CronJob) | Traffic simulation (10 RPS against Podinfo) |
| **Workload** | Podinfo | Reference Go microservice with `/metrics` |

## Quick Start

```bash
# Provision everything (infra → config → k3s)
make up

# Tear down everything
make down
```

**Prerequisites**: Terraform, Ansible, kubectl, Helm, Python 3

## Directory Structure

```
mini-homelab/
├── infrastructure/          # Terraform — Azure VMs, VNet, NSGs
├── configuration/
│   ├── setup-gateway-layer/ # Ansible — Nginx, Squid, WireGuard
│   ├── setup-application-layer/ # Ansible — K3s setup
│   └── setup-local/         # Ansible — local hosts, WireGuard client
├── kubernetes/
│   ├── argocd-init/         # Bootstrap ArgoCD + app-of-apps
│   ├── argocd-apps/         # ArgoCD Application definitions
│   │   ├── addons/          # Monitoring, chaos, k6
│   │   └── workspace-lab/   # Workload apps (Podinfo)
│   ├── addons/
│   │   ├── grafana/         # Grafana + dashboards
│   │   ├── victoria-metrics/# VictoriaMetrics + alerting rules
│   │   ├── loki/            # Loki + Promtail
│   │   ├── chaos-mesh/      # Chaos Mesh
│   │   └── k6/              # k6 traffic simulator
│   └── workspace-lab/
│       └── podinfo/         # Podinfo deployment
├── scripts/                 # Helper scripts
├── assets/                  # Diagrams
└── Makefile                 # Main entrypoint
```

## Documentation

Full project planning: [Mini-Homelab Project Planning](https://www.notion.so/Mini-Homelab-Project-Planning-2d993f5285e780aca200d63768311c53?source=copy_link)
