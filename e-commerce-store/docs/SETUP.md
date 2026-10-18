# Setup Guide

Follow these steps once. Order matters.

## 1. Create the server with Terraform

Requires: [Terraform](https://developer.hashicorp.com/terraform/install) and AWS credentials configured locally (`aws configure`).

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit: your IP, email, region
terraform init
terraform plan
terraform apply
```

Note the `public_ip` output. This is your **EC2_HOST**.

To remove everything later: `terraform destroy`.

> Terraform keeps its state in `terraform.tfstate` on your machine (git-ignored). Do not delete it
> while the server exists. For team use, enable the S3 backend shown in `versions.tf`.

## 2. Register the server as a self-hosted GitHub runner

The deploy job runs *on* the EC2 server. Connect with SSH or SSM:

```bash
aws ssm start-session --target <instance_id>    # no SSH key needed
```

Then in GitHub: **Repo -> Settings -> Actions -> Runners -> New self-hosted runner -> Linux x64**.
Copy the commands GitHub shows (download, `./config.sh ...`) and run them as `ec2-user`, then install it as a service:

```bash
sudo ./svc.sh install ec2-user
sudo ./svc.sh start
```

## 3. Add repository variables and secrets

**Settings -> Secrets and variables -> Actions**

| Type | Name | Used for |
|---|---|---|
| Variable | `DOCKERHUB_USERNAME` | image name |
| Secret | `DOCKERHUB_TOKEN` | pushing images |
| Secret | `SONAR_TOKEN`, `SONAR_HOST_URL` | SonarQube scan |
| Secret | `EC2_HOST` | DAST target (the `public_ip`) |
| Secret | `SLACK_WEBHOOK_URL` | notifications (optional; skipped if missing) |

## 4. Protect the main branch

**Settings -> Branches -> Add rule** for `main`:
- Require a pull request before merging
- Require status checks to pass (pick the pipeline jobs: code, dependency-scan, build-scan-push)
- Do not allow bypassing

Now nothing reaches `main` unless the pipeline passes on the pull request.

## 5. Notifications (optional)

Create a Slack *Incoming Webhook* (or a Discord webhook; add `/slack` to the end of the Discord URL) and save it as `SLACK_WEBHOOK_URL`.

## 6. Turn on monitoring (optional)

On the server:

```bash
docker compose --profile monitoring up -d
```

- Grafana: `http://<EC2_HOST>:3000` (login `admin` / `$GRAFANA_ADMIN_PASSWORD`, default `admin` - change it)
- Prometheus: `http://<EC2_HOST>:9090`

Ports 3000 and 9090 are closed unless you set `monitoring_cidr_blocks` in Terraform.

## 7. Verify a signed image (optional)

Every pushed image is signed with Cosign (keyless) and has its SBOM attached:

```bash
cosign verify <dockerhub-user>/e-commerce-python:<commit-sha> \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/<owner>/<repo>/'

cosign verify-attestation --type cyclonedx <dockerhub-user>/e-commerce-python:<commit-sha> \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/<owner>/<repo>/'
```

## 8. Manual rollback

The pipeline rolls back automatically if the smoke test fails. To go back by hand:

```bash
IMAGE_TAG=<older-commit-sha> DOCKERHUB_USERNAME=<user> docker compose up -d --force-recreate app
```
