# KumpeApps Deploy — Reference

Authoritative consumer schema lives in the deployment-bot repo: `src/schemas/deployment-config.ts`. Prefer that over older guide snippets.

## Required fields

| Field | Notes |
|-------|--------|
| `deployment_type` | Must be `"docker"` |
| `assigned_username` | GitHub user with quotas/approved domains |
| `vm_hostname` | Target VM hostname |
| `domains` | Non-empty; each must be approved |
| `docker_compose` | Relative/absolute path **or** inline YAML string |
| `env_mappings` | `CONTAINER_VAR: GITHUB_SECRET_NAME` |
| `deploy_rules` | ≥1 rule; `environment` matches folder |

## Optional fields

| Field | Notes |
|-------|--------|
| `plan_name` | Virtualizor plan (must be authorized) |
| `authorized_admins` | Usernames or smart groups |
| `registry_auth` | `{ registry, username_env, password_env }` — env names must appear in `env_mappings` |
| `ssh_port` / `caddy_ssh_port` | SSH overrides |
| `workflow_checks.require` | Gate deploy on named GitHub workflow runs |
| `post_deploy_hook` | Shell on VM after successful `compose up -d` |

### Smart groups (`authorized_admins`)

- `github.repo.collaborators` / `github.repo.admins`
- `github.org.team.TEAM_SLUG` / `github.org.ORG.team.TEAM_SLUG`  
Org teams need App **Organization: Members** read; otherwise use usernames.

### `post_deploy_hook` example

Use when host networking/VPN needs a nudge after Docker changes:

```yaml
post_deploy_hook: "docker compose -f /opt/nebula/docker-compose.yml restart nebula_client"
```

Prefer the bot's injected in-compose client + ensure-running path when available; only add hooks the VM actually needs.

## `deploy_rules` shapes

Triggers in one rule are OR'd.

```yaml
# Label (dev)
deploy_rules:
  - environment: dev
    labels: [deploy-dev]

# Branch push (stage)
deploy_rules:
  - environment: stage
    branches:
      include: [main]
      exclude: []

# Release (prod)
deploy_rules:
  - environment: prod
    release:
      types: [published]
      exclude_prerelease: true
```

Also supported: label+branch together; release types `published|created|released|edited`.

## What sync indexes

Under `.kumpeapps-deploy-bot/{dev,stage,prod}/`:

| Included | Skipped |
|----------|---------|
| `*.yml` / `*.yaml` real configs | `*.template`, `*example*` |
| | `docker-compose*`, `caddyfile` (deployed as siblings, not as “config docs”) |

## Secrets Action sketch

Prefer `docs/examples/repo-sync-secrets-simple.yml` from the bot repo.

```yaml
- name: Sync secrets to deployment bot
  uses: kumpeapps/kumpeapps-deployment-bot@v1
  env:
    KUMPEAPPS_DEPLOY_BOT_TOKEN: ${{ secrets.KUMPEAPPS_DEPLOY_BOT_TOKEN }}
    # Optional 1Password Environment (loads all vars; no per-secret list)
    # OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
    # OP_ENVIRONMENT_ID: ${{ secrets.OP_ENVIRONMENT_ID }}
    DEV_NEBULA_CLIENT_TOKEN: ${{ secrets.DEV_NEBULA_CLIENT_TOKEN }}
    DEV_DATABASE_URL: ${{ secrets.DEV_DATABASE_URL }}
    # …every secret you need synced
```

Default bot URL: `https://deploy.kumpe.app`. Endpoint: `POST /api/admin/repository-secrets/sync` with Bearer repo token.

## Caddyfile

- Filename: `caddyfile` (lowercase) next to the env YAML
- Remote name pattern: `{owner}-{repo}-{env}.caddy`
- Missing file → Caddy step skipped
- Hosts in file ⊆ `domains` ⊆ approved domains

## Pitfalls

1. Only `*.template` / `*example*` present → nothing synced, nothing deploys  
2. YAML `caddy:` key → ignored; use sibling `caddyfile`  
3. Domain in Caddy not in `domains` or not approved → fail  
4. Secret never passed into Action `env` → mapping resolves empty at deploy  
5. Missing `KUMPEAPPS_DEPLOY_BOT_TOKEN` → 401/404 on sync  
6. Forgot `NEBULA_CLIENT_TOKEN` mapping → VPN inject broken  
7. Org team smart group without Org Members permission → use usernames  
8. `registry_auth` without mapping those env names → pull fails  
9. `deploy_rules.environment` ≠ folder name  
10. Hand-authored `nebula_client` in compose → fights bot injection  

## Upstream paths (deployment-bot repo)

| Path | Role |
|------|------|
| `templates/{dev,stage,prod}-example.yml.template` | Init PR sources |
| `action.yml` / `README-ACTION.md` | Secrets Action |
| `docs/secret-sync-guide.md` | Sync troubleshooting |
| `docs/examples/repo-sync-secrets-simple.yml` | Workflow example |
| `src/schemas/deployment-config.ts` | Schema source of truth |
| `templates/mobile-nebula-docker-config.yml` | Injected Nebula service shape |
