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

## Notes for the Kubernetes migration
- The documented Prometheus port is `9090`; the Dockerfile does not declare `EXPOSE`.
- Required target variables are `AUTH_API_TARGET`, `USERS_API_TARGET`, `TODOS_API_TARGET`, `LOG_PROCESSOR_TARGET`, and `FRONTEND_EXPORTER_TARGET`.
- Scrape dependencies are `auth-api`, `users-api`, `todos-api`, `log-message-processor`, and `frontend-nginx`; all are configured as static targets.
- `PROMETHEUS_SCRAPE_INTERVAL` appears in the README run command but is not referenced by the template; the interval is hard-coded to `15s`.
- Mount persistent storage at `/prometheus`; ensure `/tmp` remains writable for startup configuration generation.
- Review the unpinned Alpine Prometheus package, root user, and missing health check and `EXPOSE` declarations before migration.
- `.github/workflows/development.yml` pushes a release tag plus `latest`, then directly updates and restarts an Azure Container App. Replace this with an immutable image reference committed to `microservice-app-gitops` and reconciled by ArgoCD; do not deploy with `kubectl apply`.
- No Azure Container Apps manifest is present, so resource limits, probes, runtime environment values, and storage settings must be recovered from the deployed environment before migration.
