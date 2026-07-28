---
name: kumpeapps-deploy
description: >-
  Sets up KumpeApps Deployment Bot in an application repo — GitHub App install,
  .kumpeapps-deploy-bot configs, docker-compose, caddyfile, env_mappings, deploy_rules,
  and secrets sync (Action or 1Password). Use when adding deployments, onboarding a repo
  to deploy.kumpe.app, editing .kumpeapps-deploy-bot/**, sync-secrets workflows, Nebula
  VPN mappings, or when the user mentions KumpeApps deploy bot / KUMPEAPPS_DEPLOY_BOT_TOKEN.
---

# KumpeApps Deployment Bot Setup

Wire a **consumer application repo** to [kumpeapps/kumpeapps-deployment-bot](https://github.com/kumpeapps/kumpeapps-deployment-bot) so pushes/labels/releases deploy Docker Compose apps to VMs via Managed Nebula + Caddy.

Bot UI / API default: `https://deploy.kumpe.app`

## Prerequisites (human / admin)

- GitHub user approved in the bot with domain + VM quotas
- Domains for every hostname in config + `caddyfile` approved for that user
- GitHub App **KumpeApps Deployment Bot** installed on the repo

Do not invent approved domains or `assigned_username` — ask the user if unknown.

## Onboarding workflow

Copy and track:

```
Deploy setup:
- [ ] 1. Confirm App install + KUMPEAPPS_DEPLOY_BOT_TOKEN
- [ ] 2. Merge init PR (or create layout manually)
- [ ] 3. Real env YAML from templates (not *.template / *example*)
- [ ] 4. Sibling docker-compose.yml + caddyfile per env
- [ ] 5. env_mappings include NEBULA_CLIENT_TOKEN
- [ ] 6. App secrets in GitHub (and/or 1Password Environment)
- [ ] 7. sync-secrets workflow lists secrets (or OP_*)
- [ ] 8. Run Sync Secrets Action
- [ ] 9. Trigger deploy per deploy_rules; verify status
```

### 1. App install + token

After App install, wait for repository secrets (minutes; hourly reprovision):

| Secret | Purpose |
|--------|---------|
| `KUMPEAPPS_DEPLOY_BOT_TOKEN` | Sync Action auth (`kdbt_…`) |
| `{DEV,STAGE,PROD}_NEBULA_CLIENT_TOKEN` | VPN client (if Nebula enabled) |
| `{DEV,STAGE,PROD}_NEBULA_IP` | Caddy `{{nebula.ip}}` |

### 2. Init PR (preferred)

Bot opens a PR with:

```
.github/workflows/sync-secrets.yml
.kumpeapps-deploy-bot/{dev,stage,prod}/*-example.yml.template
.gitleaks.toml
.gitleaksignore
```

Merge it. If missing, create the same layout from templates in the deployment-bot repo (`templates/*-example.yml.template`).

### 3. Real configs (required)

Templates are **skipped** by sync. Create real files:

```bash
cp .kumpeapps-deploy-bot/dev/dev-example.yml.template .kumpeapps-deploy-bot/dev/<app>.yml
# repeat for stage/ and prod/ as needed
```

Layout:

```
.kumpeapps-deploy-bot/
  dev/
    <app>.yml              # real config
    docker-compose.yml     # typical
    caddyfile              # lowercase; optional but usual
  stage/ …
  prod/ …
.github/workflows/sync-secrets.yml
```

### 4. Minimal config shape

```yaml
deployment_type: docker
assigned_username: <github-username>
vm_hostname: <vm-name>
domains:
  - app.dev.example.com
docker_compose: docker-compose.yml   # path preferred over inline
env_mappings:
  NEBULA_CLIENT_TOKEN: DEV_NEBULA_CLIENT_TOKEN   # required for injected VPN
  DATABASE_URL: DEV_DATABASE_URL
deploy_rules:
  - environment: dev          # MUST match folder name
    labels:
      - deploy-dev
```

**Default triggers (from templates):**

| Env | Typical `deploy_rules` |
|-----|------------------------|
| `dev` | PR label `deploy-dev` |
| `stage` | Push to `main` |
| `prod` | Release `published`, `exclude_prerelease: true` |

### 5. Compose + Caddy rules

- **Do not** author `nebula_client` in compose — the bot injects Managed Nebula.
- Prefer `docker_compose: docker-compose.yml` beside the YAML.
- **No YAML `caddy:` key** — put a sibling file named `caddyfile` (lowercase).
- Every host in `caddyfile` must also be in `domains` and approved.
- Placeholders: `{{nebula.ip}}`, `{{vm.ip}}`.

```caddyfile
app.dev.example.com {
  import ssl_defaults
  reverse_proxy {{nebula.ip}}:8080
}
```

### 6. Secrets sync

Action: `kumpeapps/kumpeapps-deployment-bot@v1` (pin intentionally; init may use `@main`).

GitHub cannot expand dynamic `secrets[name]` — either:

1. **List each secret** under the step `env:`, or  
2. Set **`OP_SERVICE_ACCOUNT_TOKEN`** + **`OP_ENVIRONMENT_ID`** so the Action loads a 1Password Environment.

`env_mappings` values must equal the **GitHub / synced secret names**. Sync pushes everything you pass; mappings select what each deploy uses.

See [reference.md](reference.md) for full schema, pitfalls, and workflow examples.

## Agent rules while editing

1. Prefer schema truth over outdated docs that show a YAML `caddy:` block.
2. Never hardcode secrets into compose or config — mappings only.
3. Keep `deploy_rules[].environment` equal to the parent folder (`dev`|`stage`|`prod`).
4. Always map `NEBULA_CLIENT_TOKEN` → `{ENV}_NEBULA_CLIENT_TOKEN`.
5. Do not add `nebula_client` to consumer `docker-compose.yml`.
6. After config changes, remind the user to run **Sync Secrets** (or push paths that trigger the workflow).

## Prompt-like workflow

```
Set up KumpeApps Deployment Bot for this repo.
Follow the kumpeapps-deploy skill: real .kumpeapps-deploy-bot/{dev,stage,prod} YAML,
sibling docker-compose.yml + caddyfile, NEBULA_CLIENT_TOKEN mappings,
sync-secrets workflow (list secrets or 1Password OP_*), no nebula_client in compose,
no YAML caddy: key. Ask me for assigned_username, vm_hostname, and approved domains.
```

## Related

- Detail: [reference.md](reference.md)
- Prompt: [../../prompts/setup-kumpeapps-deploy.md](../../prompts/setup-kumpeapps-deploy.md)
- Skills: `docker-multi-container`, `oidc-oauth-auth`
- Upstream: https://github.com/kumpeapps/kumpeapps-deployment-bot (`docs/user-guide.md`, `README-ACTION.md`, `templates/`)
