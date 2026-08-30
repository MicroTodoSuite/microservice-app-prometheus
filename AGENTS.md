## Overview
This repository builds a custom Prometheus container that renders its scrape configuration from environment variables at startup.
It collects metrics from the suite's authentication, users, todos, log-processing, and frontend-exporter services.

## Stack
- Runtime: Prometheus from Alpine's `prometheus` package; the repository does not pin the Prometheus version.
- Base image: Alpine Linux `3.18` (`alpine:3.18`).
- Entrypoint: POSIX shell (`#!/bin/sh`); the image also installs Bash and `gettext` for `envsubst`.
- Release tooling only: Node.js `22` in CI and `semantic-release` `24.2.3` in `package-lock.json`; there is no application framework.

## Commands
- Build the image: `docker build -t custom-prometheus .`
- Run locally: `docker run -e PROMETHEUS_SCRAPE_INTERVAL=15s -p 9090:9090 custom-prometheus`
- Install release dependencies: `npm ci`
- Test script: `npm test` (this is a placeholder that prints an error and exits with status 1; no tests exist).
- Run a release: `npx semantic-release`

## Structure
- `Dockerfile`: creates the Alpine-based Prometheus runtime image.
- `entrypoint.sh`: renders the template to `/tmp/prometheus.yml` and starts Prometheus.
- `prometheus.template.yml`: defines the global interval and five static scrape jobs.
- `.github/workflows/`: contains the Azure build/deploy pipeline and semantic-release workflow.
- `package.json`, `package-lock.json`, and `.releaserc`: contain release automation only.
- `README.md` and `CHANGELOG.md`: contain usage and release history; there are no source or test directories.

## Conventions
- Runtime configuration is generated with `envsubst`; do not edit a generated Prometheus configuration in the image.
- Prometheus data is stored at `/prometheus`, while the generated configuration is ephemeral under `/tmp`.
- Only `users-api` overrides `metrics_path` to `/prometheus`; the other jobs use Prometheus defaults.
- Node.js is not part of the service runtime and is used only for release automation.
- Write pull-request bodies bilingually: every section in English, then repeated under a `## Español` heading with the same content, not a summary. Titles, commits, code comments, documentation, and specification text stay English-only. As an AI agent you write both halves yourself.
- Open every pull request through `.github/pull_request_template.md` and follow `microservice-app-docs/docs/Pull request and task tracking conventions.md`: one concern per short-lived `<type>/<summary>` branch, a Conventional Commit title with a scope, and every template section filled. Constitution principle 13 makes this binding, not advisory.
- Keep the Spec-Driven Development commit pair intact: `test(<scope>): specify ...` must be committed failing before `feat(<scope>): implement ...`. Never squash the pair; the failing-test commit is the evidence the cycle was followed.
- Track every task. Name in the pull-request body the task IDs it advances, qualified by repository and spec, and update `tasks.md` in that same pull request rather than a follow-up. Mark a task `[X]` only after locating and inspecting its named artifact — never from a summary, a green check, a rendered manifest, or recollection. Annotate partial delivery instead of ticking it; work no register covers either gains a task or records in the PR body why none applies.
- Reconcile, never quietly edit, when a register and reality disagree: a specification that pins a version nobody shipped is a maintainer decision, and `microservice-app-docs/full-platform/plan-reconciliation.md` is the worked example.
- Never merge with `--admin`, force-push to `main`, disable a branch protection rule to land your own work, or approve your own pull request. As an AI agent you may open, describe, and update a pull request; you may never approve one and never author an acceptance or approval artifact — only a named human unlocks a gate.
- Report outcomes faithfully in commits and pull-request bodies: name what is red, say what was skipped, and correct an earlier claim that turns out to be wrong rather than leaving the record wrong.

## Notes for the Kubernetes migration
- The documented Prometheus port is `9090`; the Dockerfile does not declare `EXPOSE`.
- Required target variables are `AUTH_API_TARGET`, `USERS_API_TARGET`, `TODOS_API_TARGET`, `LOG_PROCESSOR_TARGET`, and `FRONTEND_EXPORTER_TARGET`.
- Scrape dependencies are `auth-api`, `users-api`, `todos-api`, `log-message-processor`, and `frontend-nginx`; all are configured as static targets.
- `PROMETHEUS_SCRAPE_INTERVAL` appears in the README run command but is not referenced by the template; the interval is hard-coded to `15s`.
- Mount persistent storage at `/prometheus`; ensure `/tmp` remains writable for startup configuration generation.
- Review the unpinned Alpine Prometheus package, root user, and missing health check and `EXPOSE` declarations before migration.
- `.github/workflows/development.yml` pushes a release tag plus `latest`, then directly updates and restarts an Azure Container App. Direct Azure Container App mutation is Azure-era only and is not used on EKS.
- No Azure Container Apps manifest is present, so resource limits, probes, runtime environment values, and storage settings must be recovered from the deployed environment if this image is ever redeployed on Azure again.
- Superseded on EKS, decided 2026-08-23: `microservice-app-gitops/infrastructure/prometheus/` deploys Prometheus Operator (kube-prometheus subset) with `ServiceMonitor`-based discovery and the official `quay.io/prometheus/prometheus` image, not this custom image. Static `envsubst`-templated targets fit Azure Container Apps, which has no native service discovery; Kubernetes does, so the standard, CNCF-recommended pattern (Prometheus Operator + ServiceMonitor) is used there instead. This image and its Azure pipeline are left as-is, unused by the EKS path, the same way `microservice-app-ops`'s old Azure Container Apps Terraform modules remain alongside the new EKS modules during the migration.
