> **Credits:** This project is based on the open-source course project
> [LondheShubham153/e-commerce-github-actions](https://github.com/LondheShubham153/e-commerce-github-actions)
> by Shubham Londhe (TrainWithShubham). The original app, Dockerfile and base workflows are his.
> My additions and changes are listed in [CHANGES.md](CHANGES.md) and in the "My Contributions" section below.

# E-commerce App for GitHub actions practice

## GitHub Actions Fundamentals:
- What is CI/CD
- Workflows, Jobs, Steps, Actions
- Creating workflows
- Secrets & Variables
- GitHub Pages
- Workflow Dispatch vs push


## Deploy on Elastic Beanstalk (Standard Mode)

Elastic Beanstalk is a powerful PaaS that runs your application and manages the servers, load balancer and health checks for you. This app ships as a Docker image on Docker Hub, so the only file you upload is `beanstalk/docker-compose.yml`. There is no ZIP and no Dockerfile to upload.

The image is `trainwithshubham/e-commerce-python:1.1.0`. It is built for both linux/amd64 and linux/arm64, runs as a non-root user and listens on port 8080 inside the container. The compose file publishes it on port 80 of the instance. The app also has a `/health` route that returns `{"status":"ok"}`.

### Steps

1. Sign in to the AWS console, pick a region and open the Elastic Beanstalk service.
2. Click Create environment.
3. Choose the Web server environment and keep Standard as the configuration mode.
4. Enter an application name such as `ecommerce-app`. The environment name and domain are filled in for you.
5. Under Platform, choose Docker, with the platform branch Docker running on 64bit Amazon Linux 2023. Keep the recommended platform version.
6. Under Application code, choose Upload your code and select Local file.
7. Choose the file `beanstalk/docker-compose.yml` from this repo. Give it a version label like `v1`.
8. On the service access step, pick Create and use new service role, and pick an EC2 instance profile. If you do not have one, create it from the IAM link on that page, using the AWSElasticBeanstalkWebTier managed policy. Skip the key pair.
9. Leave the remaining steps on their defaults and click Submit on the review page.

### Check that it works

1. Open the Events tab and wait for the message that the environment launched successfully. This takes a few minutes.
2. The environment health should turn green and show Ok.
3. Click the environment URL at the top of the page. You should see the e-commerce home page.
4. Add `/health` to the end of the URL. You should get `{"status":"ok"}`.

### Clean up

Terminate the environment when you are done so you are not charged for the instance. From the environment page choose Actions, then Terminate environment, and type the environment name to confirm. You can delete the application as well from the Applications page.

### Run it locally

```
docker compose up -d
```

Then open http://localhost. The root `docker-compose.yml` uses the `latest` tag, and the Beanstalk one pins `1.1.0`.


## CI/CD Pipeline (DevSecOps)

`.github/workflows/devsecops_pipeline.yml` runs on every push and on pull requests to `main`:

```
secret-scan
   |-------------------------------|
   v               v               v
 code+tests     SonarQube     dependency scan        <- run in parallel
   |_______________|_______________|
                   v
     build once -> Trivy scan -> push -> SBOM + sign
                   |
                   v   (main branch pushes only)
          deploy -> smoke test -> auto rollback
                   |
                  DAST (OWASP ZAP)
                   |
                notify (Slack)
```

| Feature | Where |
|---|---|
| Build once, scan that exact image, push that same image (SHA tag, `latest` only from main) | `build_scan_push.yml` |
| SBOM (CycloneDX) + keyless Cosign signature | `build_scan_push.yml` |
| Deploy only from `main`; deploy the image for that commit | `devsecops_pipeline.yml`, `cd.yml` |
| Smoke test `/health` + automatic rollback | `cd.yml` |
| Slack / Discord notifications | `notify.yml` |
| PR checks (tests, scans, build without push) | `devsecops_pipeline.yml` |
| Tests with 80% coverage gate | `test_app.py`, `pytest.ini` |
| Pip cache, Docker layer cache, parallel scans | `lint_and_test.yml`, `build_scan_push.yml` |
| Dependabot (actions, pip, docker, terraform) | `.github/dependabot.yml` |
| Infrastructure as code (EC2, firewall, IAM, CloudWatch alarms) | `terraform/` |
| Prometheus + Grafana monitoring with alert rules | `monitoring/`, `/metrics` endpoint |

**Start here:** [docs/SETUP.md](docs/SETUP.md) (server, runner, secrets, branch protection, monitoring, rollback).

## My Contributions

Built on top of the original course project:

- Redesigned the image flow: build once, scan that exact image, push the same image
- Commit-SHA tagging; `latest` moved only from `main`; deploys only from `main`
- Smoke test after deploy with automatic rollback to the previous version
- SBOM generation and keyless image signing (Cosign)
- Terraform for the EC2 server, firewall, IAM (SSM access) and CloudWatch alarms
- Slack/Discord pipeline notifications
- Prometheus metrics endpoint, Prometheus + Grafana stack, alert rules
- Expanded tests with a coverage gate; split runtime and dev requirements
- Faster pipeline: caching and parallel scan jobs
- Pull-request checks, Dependabot, blocking secret scan, pinned an unpinned action
