# CredPal DevOps Assessment

A production-ready DevOps pipeline for a Node.js Express API, demonstrating containerization, infrastructure as code, CI/CD automation, blue-green deployments, and secure cloud provisioning on AWS.
---

## Table of Contents

- [Application](#application)
- [Running Locally](#running-locally)
- [Deployment](#deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Infrastructure](#infrastructure)
- [Configuration Management](#configuration-management)
- [Repository Structure](#repository-structure)
- [Additional Documentation](#additional-documentation)

---

## Application

A Node.js Express API that logs every request to a PostgreSQL database. On startup, the app initialises the database schema and begins listening on the configured port.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message and available endpoints |
| `/health` | GET | Health check — verifies DB connectivity |
| `/status` | GET | Returns uptime, hostname, and timestamp |
| `/process` | POST | Accepts and echoes a JSON payload |
| `/logs` | GET | Returns all logged requests from the DB |

---

## Running Locally

**Prerequisites:** Docker, Docker Compose

```bash
# Start the database and application
docker compose up -d postgres app_blue

# Verify it's running
curl http://localhost:3000/health
```

The application will be available at `http://localhost:3000`.

### Environment Variables

| Variable | Description |
|----------|-------------|
| `DB_HOST` | PostgreSQL host |
| `DB_USER` | PostgreSQL username |
| `DB_PASSWORD` | PostgreSQL password |
| `DB_NAME` | PostgreSQL database name |
| `PORT` | Application port (default: `3000`) |
| `NODE_ENV` | Runtime environment |

In production, these are retrieved at deploy time from **AWS Secrets Manager**.

---

## Deployment

### How It Works

Deployments are triggered automatically after a successful build. The CI pipeline authenticates to AWS via OIDC and uses **AWS Systems Manager (SSM)** to execute `scripts/deploy.sh` on the EC2 instance — no SSH or open port 22 required.

### Blue-Green Strategy

At any given time, only one container is running — either `app_blue` (port 3000) or `app_green` (port 3001). During a deployment, both run briefly in parallel while health checks pass and connections drain, after which the previously active container is stopped.

**Deployment flow:**

1. Detect the currently active target group (blue or green)
2. Pull the latest image to the inactive environment
3. Start the inactive container
4. Run health checks against the new container (10 attempts, 5s apart)
5. Switch the ALB HTTPS listener to the new target group
6. Drain connections from the old environment (30s)
7. Stop the old container

If health checks fail, the inactive container is stopped and the active environment is untouched — no downtime, no bad release goes live.

### Manual Deployment

```bash
bash scripts/deploy.sh <blue_tg_arn> <green_tg_arn> <listener_arn>
```

### Docker Image

The image uses a **multi-stage build** to keep the runtime surface minimal:

- **Build stage** (`node:22-bookworm-slim`) — installs production dependencies via `npm ci --omit=dev`
- **Runtime stage** (`gcr.io/distroless/nodejs22-debian12`) — copies only required files, runs as `nonroot`

The Distroless base contains no shell, package manager, or OS utilities — significantly reducing the attack surface.

---

## CI/CD Pipeline

Implemented with **GitHub Actions**. All workflows are scoped to their appropriate trigger.

### Pull Request Workflows

Run on every PR to `main` and must pass before merging.

| Workflow | Description |
|----------|-------------|
| **Application Security** | SonarQube (static analysis), Snyk (dependency scanning), Checkov (IaC scanning + custom policies in `policies/checkov/`) |
| **Test** | Unit tests via Jest |

### Post-Merge Workflows

Run sequentially after a merge to `main`.

| Workflow | Description |
|----------|-------------|
| **Build** | OIDC auth → fetch Docker credentials from Secrets Manager → build image → Trivy scan → push to DockerHub |
| **Infrastructure** | OIDC auth → `terraform plan` → apply detected changes |
| **Deploy** | OIDC auth → execute `scripts/deploy.sh` on EC2 via SSM |

Infrastructure and Deploy only trigger after Build succeeds.

### Composite Actions

Common dependency installation steps (e.g. the [Task](https://taskfile.dev) runner) are extracted into reusable composite actions to avoid duplication across workflows.

---

## Infrastructure

Infrastructure is provisioned with **Terraform**, split across two environments, with the Terraform state stored remotely in S3.

See [docs/architecture.md](docs/architecture.md) for a full breakdown.

### Terraform Environments

#### `terraform/env/dns`

Provisions Cloudflare DNS records to validate the ACM certificate. **Ran once** during initial setup and not part of CI.

```bash
cd terraform/env/dns
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

Requires a Cloudflare domain and either `CLOUDFLARE_API_KEY` or a `cloudflare_api_token` variable. Once the certificate reaches `ISSUED` status, this environment doesn't need to be re-applied.

#### `terraform/env/main`

Provisions all AWS resources required to run the application.

```bash
cd terraform/env/main
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

Provisions: VPC (public/private subnets, Internet Gateway, NAT Gateway, Security Groups, Security Group Rules) EC2, ALB, ACM, IAM, and S3 buckets.

---

## Configuration Management

**Ansible** bootstraps the EC2 instance over SSM. It uses a `bootstrap` role to:

- Install Docker, Docker Compose, and AWS CLI
- Create `/app` and copy `docker-compose.yaml` + `scripts/deploy.sh` into the instance
- Start the PostgreSQL container and initial `app_blue` container

---

## Repository Structure

```
.
├── ansible/
│   └── roles/bootstrap/
├── app/
│   └── test/
├── policies/
│   └── checkov/custom_checks/
├── scripts/
│   └── deploy.sh
├── terraform/
│   ├── aws_modules/
│   │   ├── acm_cert/
│   │   ├── ec2/
│   │   ├── elb/
│   │   ├── iam/
│   │   ├── s3_alb_logs/
│   │   ├── s3_tf_state/
│   │   └── vpc/
│   ├── cloudflare_modules/
│   │   └── dns_validation/
│   └── env/
│       ├── dns/
│       └── main/
└── docs/
    ├── architecture.md
    └── security.md
```

---

## Additional Documentation

- [Architecture Overview](docs/architecture.md) — VPC layout, traffic flow, and AWS resource design
- [Security Design](docs/security.md) — IAM, secret management, network controls, and scanning strategy

---

## Stack

Node.js · Express · PostgreSQL · Docker · Terraform · GitHub Actions · AWS · Ansible · Cloudflare