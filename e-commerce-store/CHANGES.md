# Attribution and Changes

## Original source
Based on [LondheShubham153/e-commerce-github-actions](https://github.com/LondheShubham153/e-commerce-github-actions)
by Shubham Londhe (TrainWithShubham). The Flask app, Dockerfile, demo workflows and the
original pipeline structure come from that project.

## My contributions

| Change | File(s) |
|---|---|
| Build once, scan that exact image, push that same image | NEW `build_scan_push.yml` (replaces `trivy_scans.yml`, `docker_push.yml`, `docker.yml`, deleted) |
| Commit-SHA tags; `latest` only from main; main-only deploys | `build_scan_push.yml`, `devsecops_pipeline.yml`, `cicd.yml` |
| Deploy the SHA-tagged image; smoke test; automatic rollback | `cd.yml`, `docker-compose.yml` |
| SBOM + Cosign keyless signing | `build_scan_push.yml` |
| Slack/Discord notifications | NEW `notify.yml` |
| Terraform: EC2, Elastic IP, security group, IAM (SSM), CloudWatch alarms | NEW `terraform/`, `terraform.yml` |
| Prometheus `/metrics`, Prometheus + Grafana stack, alert rules, dashboard | `app.py`, `monitoring/`, `docker-compose.yml` (profile `monitoring`) |
| More tests, 80% coverage gate | `test_app.py`, `pytest.ini` |
| Runtime vs dev requirements split; smaller image | `requirements.txt`, `requirements-dev.txt`, `.dockerignore` |
| Pip cache, Docker layer cache, parallel scans | `lint_and_test.yml`, `dependency_scan.yml`, `build_scan_push.yml`, `devsecops_pipeline.yml` |
| Pull-request checks, concurrency control | `devsecops_pipeline.yml` |
| Dependabot | `.github/dependabot.yml` |
| Secret scan now blocks the pipeline | `secrets-scanning.yml` |
| Pinned `upload-artifact@master` to `@v4` | `dependency_scan.yml` |
| Setup guide | `docs/SETUP.md`, `README.md` |


