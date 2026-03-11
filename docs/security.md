# Security Documentation

This document covers the security decisions made across the application, infrastructure, CI/CD pipeline, and container configuration.

> **Note**: For architectural context, see [architecture.md](architecture.md). For getting started, see the [root README](../README.md).

---

## Principles

- **Least privilege** — every component has only the permissions it needs
- **No long-lived credentials** — OIDC and instance profiles replace static access keys
- **Shift left** — security scanning runs on every PR, before code reaches `main`
- **Defence in depth** — multiple independent controls at each layer

---

## Network Security

### No Public Access to EC2

The EC2 instance runs in a **private subnet** with no inbound rules for port 22. There is no jump host and no public IP assigned to the instance. The only inbound traffic allowed is from the **ALB security group** on ports 3000 and 3001.

### ALB as the Sole Entry Point

All user traffic enters through the **Application Load Balancer** in the public subnet. The ALB:
- Forces HTTPS — HTTP (port 80) redirects to HTTPS (port 443)
- Terminates TLS using an ACM-managed certificate
- Forwards decrypted traffic to the active EC2 target group over a private network path

### No SSH Access

Port 22 is not open on any security group. All operator and CI/CD access to the EC2 instance is performed exclusively via **AWS SSM Session Manager**, which requires no open ports.

---

## Identity and Access Management

### No Long-Lived Credentials

No static AWS access keys are used anywhere in this project.

- **CI/CD (GitHub Actions)** authenticates using **OIDC**. GitHub exchanges a signed JWT for short-lived AWS credentials scoped to a specific role. Credentials expire at the end of the workflow run.
- **EC2** authenticates to AWS services using an **instance profile** (IAM role attached at the instance level). No credentials are stored on disk.

### EC2 Instance Role

The EC2 instance role is scoped to what the deploy script and application runtime require:

| Permission | Purpose |
|------------|---------|
| `secretsmanager:GetSecretValue` | Retrieve DB credentials at deploy time |
| `ssm:*` (receive-side) | Allow SSM agent to receive commands |
| `elasticloadbalancing:DescribeListeners` | Detect active target group |
| `elasticloadbalancing:ModifyListener` | Switch ALB listener during deployment |

### GitHub Actions OIDC Role

The CI role is restricted by a trust policy that only allows tokens issued by `token.actions.githubusercontent.com` for this specific repository and branch. 

---

## Secret Management

All secrets are stored in **AWS Secrets Manager** and retrieved at runtime. Nothing sensitive is hardcoded, committed to the repository, or stored in environment files.

| Secret | Consumer | How Retrieved |
|--------|----------|---------------|
| DB credentials (`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`) | `deploy.sh` on EC2 | `aws secretsmanager get-secret-value` at deploy time |
| DockerHub credentials | GitHub Actions build workflow | Fetched via OIDC-authenticated Secrets Manager call |
| Cloudflare API token | Terraform DNS env | Passed as a Terraform variable (not stored in state) |

GitHub Actions secrets (e.g. OIDC role ARN, target group ARNs) are stored as **GitHub encrypted secrets** and injected as environment variables — they are never printed in logs.

---

## CI/CD Security

### Shift-Left Scanning

Security checks run on every pull request before code reaches `main`:

| Tool | What It Scans |
|------|--------------|
| **SonarQube** | Static code analysis — code smells, bugs, security hotspots |
| **Snyk** | Dependency vulnerabilities in `package.json` / `package-lock.json` |
| **Checkov** | Terraform IaC misconfigurations + custom policies in `policies/checkov/` |
| **Trivy** | Docker image vulnerabilities — scans the built image before it's pushed |

PRs cannot be merged if these checks fail.

### Custom Checkov Policies

Project-specific IaC rules are defined in `policies/checkov/custom_checks/`. These enforce conventions that generic rules don't cover — for example, ensuring the EC2 instance has no public IP, or that all S3 buckets have versioning enabled.

### Pipeline Permissions

Each GitHub Actions workflow declares only the IAM permissions it needs. The OIDC trust policy is locked to this repository, preventing credential misuse from forks or other repositories.

---

## Container Security

### Distroless Runtime Image

The production image uses `gcr.io/distroless/nodejs22-debian12` as its runtime base. Distroless images contain only the language runtime and its dependencies — no shell, no package manager, no system utilities. This means:

- No shell access even if the container is compromised
- Dramatically smaller attack surface
- Fewer CVEs to manage

### Non-Root User

The container runs as the `nonroot` user (`USER nonroot`). Files are owned by `nonroot:nonroot` via `--chown` in the `COPY` instructions. The application has no ability to write outside its working directory.

### Multi-Stage Build

The `builder` stage (`node:22-bookworm-slim`) installs dependencies and compiles assets. Only the required output files are copied into the runtime stage — `devDependencies` and build tooling are left behind, keeping the final image small and clean.

### No Sensitive Data in Image

The Docker image contains no credentials, `.env` files, or configuration secrets. All runtime secrets are injected as environment variables by `deploy.sh` after being retrieved from Secrets Manager.

---

## Data Security

### Database

PostgreSQL runs as a Docker container on the EC2 instance. It is not exposed to the network — it binds only to the Docker bridge network and is accessible solely by the application containers on the same host.

DB credentials are never stored in plaintext. They are fetched from Secrets Manager at deploy time and passed to Docker Compose as environment variables.

### TLS

All traffic to the application is encrypted in transit. The ALB terminates TLS using an ACM certificate. HTTP traffic is redirected to HTTPS at the load balancer level — unencrypted application traffic never leaves the AWS network boundary.

### ALB Access Logs

ALB access logs are stored in a dedicated S3 bucket for audit and forensic purposes.

---

## Audit and Visibility

| Control | Coverage |
|---------|---------|
| CloudTrail | All AWS API calls, including SSM command execution |
| ALB access logs | All HTTP/S requests to the application |
| Application logs | All requests logged to PostgreSQL with timestamp |
| GitHub Actions audit log | All workflow runs, triggering actors, and outcomes |
| Trivy + Snyk reports | Surfaced in CI for every build |

---

## Related Documentation

- [← Back to README](../README.md)
- [← architecture.md](architecture.md)