---
title: Setup KumpeApps Deployment Bot
use_when: Onboarding an app repo to KumpeApps deploy.kumpe.app / .kumpeapps-deploy-bot
related_skills:
  - kumpeapps-deploy
  - docker-multi-container
---

# Prompt: Setup KumpeApps Deployment Bot

Copy everything below the line into chat.

---

Set up **KumpeApps Deployment Bot** for this repository using the `kumpeapps-deploy` skill.

Do the following:

1. Confirm (or ask me for) `assigned_username`, `vm_hostname`, approved domains, and which envs (`dev` / `stage` / `prod`) to enable.
2. Ensure layout under `.kumpeapps-deploy-bot/{env}/` with **real** YAML (not `*.template` / `*example*`), sibling `docker-compose.yml`, and lowercase `caddyfile` when HTTP is needed.
3. Map `NEBULA_CLIENT_TOKEN` → `{ENV}_NEBULA_CLIENT_TOKEN`. Do **not** add `nebula_client` to compose.
4. Do **not** use a YAML `caddy:` key — only a sibling `caddyfile` with hosts listed in `domains`. Use `{{nebula.ip}}` / `{{vm.ip}}` as needed.
5. Set `deploy_rules` so `environment` matches the folder (default: label `deploy-dev`, push `main` for stage, published non-prerelease release for prod).
6. Ensure `.github/workflows/sync-secrets.yml` uses `kumpeapps/kumpeapps-deployment-bot@v1` (or the repo’s chosen pin) and either lists every secret in `env` or uses `OP_SERVICE_ACCOUNT_TOKEN` + `OP_ENVIRONMENT_ID`.
7. Tell me what GitHub secrets to create and how to trigger the first deploy + Sync Secrets run.
