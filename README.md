# ai-agent-skills

A **submodule-ready** package of agent **skills**, **rules/instructions**, and **reusable prompts** for coding development. One install wires **Cursor**, **VS Code / GitHub Copilot**, **Claude Code**, **Codex**, **Windsurf**, **Gemini CLI**, **Aider**, and any tool that reads `AGENTS.md`.

It encodes non-negotiable engineering standards and a default full-stack:

| Concern | Standard / default |
|---------|-------------------|
| Process | **TDD** (red → green → refactor) |
| Design | **DRY**, **SOLID** |
| Python style | **PEP8**, **black**, ruff, type hints |
| Frontend | **Angular** (newest stable), standalone + signals |
| Backend | **FastAPI** (newest stable), Pydantic v2 |
| Data | **SQLAlchemy 2.x**, dialect-agnostic; Alembic |
| Runtime | **Docker** — separate containers (frontend / backend / db / optional auth) |
| Integration tests | **MariaDB** in Docker (Compose `test` profile) |
| Environment | **Dev Container** preferred; else Python **venv** (never system Python) |
| Versions | Prefer **newest stable**; pin in lockfiles |
| Auth | **KumpeCloud Auth** (Logto fork) OIDC by default; **any OIDC/OAuth** via abstraction |

Repository: [github.com/kumpeapps/ai-agent-skills](https://github.com/kumpeapps/ai-agent-skills)

---

## What's included

```
.ai-agent-skills/          # after submodule add (name is conventional)
├── AGENTS.md              # Shared agent contract (open standard)
├── install.sh             # Multi-IDE installer (default: all targets)
├── uninstall.sh           # Remove managed links / generated files
├── rules/                 # Source rules (Cursor .mdc; converted for Copilot)
├── skills/                # SKILL.md workflows (Cursor, Claude, Copilot, …)
└── prompts/               # Reusable prompt templates
```

| Kind | Role |
|------|------|
| **Rules** | Always-on / path-scoped standards (Cursor `.mdc`; Copilot `.instructions.md`) |
| **Skills** | Discoverable workflows (`SKILL.md`) with in-skill prompt checklists |
| **Prompts** | Copy-paste / `@` templates (also linked as Copilot `.prompt.md`) |
| **AGENTS.md** | Cross-tool project contract (Codex, Cursor, Copilot agents, and more) |

---

## Import as a git submodule

Run these commands from the **root of the consumer repository** (the app you are building).

### 1. Add the submodule

```bash
git submodule add https://github.com/kumpeapps/ai-agent-skills.git .ai-agent-skills
git submodule update --init --recursive
```

### 2. Wire for your IDE / agent

**All supported tools (default):**

```bash
.ai-agent-skills/install.sh
# same as:
.ai-agent-skills/install.sh --target all
```

**Specific tools only:**

```bash
.ai-agent-skills/install.sh --target cursor
.ai-agent-skills/install.sh --target claude,copilot
.ai-agent-skills/install.sh --target vscode          # alias for copilot
.ai-agent-skills/install.sh --list-targets
```

Install is **idempotent**. Local non-symlink files are never overwritten (project overrides win).

### 3. What each target installs

| Target | Skills | Instructions / rules | Root contract |
|--------|--------|----------------------|---------------|
| `cursor` | `.cursor/skills/*` | `.cursor/rules/*.mdc` | `AGENTS.md` |
| `claude` | `.claude/skills/*` | — | `CLAUDE.md` (imports `@AGENTS.md`) + `AGENTS.md` |
| `copilot` / `vscode` | `.github/skills/*` | `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `.github/prompts/*.prompt.md` | `AGENTS.md` |
| `codex` | `.agents/skills/*` | — | `AGENTS.md` |
| `windsurf` | — | `.windsurfrules`, `.windsurf/rules/agents.md` | `AGENTS.md` |
| `gemini` | — | — | `GEMINI.md` → `AGENTS.md` |
| `aider` | — | — | `CONVENTIONS.md` → `AGENTS.md` |

`AGENTS.md` is the shared source of truth. Tool-specific files either symlink it or (for Claude) import it.

### 4. Reload your tool

Reload the IDE window or restart the CLI agent so skills and instructions are discovered.

### 5. Commit consumer wiring

```bash
git add .gitmodules .ai-agent-skills
git add AGENTS.md CLAUDE.md GEMINI.md CONVENTIONS.md .windsurfrules \
  .cursor .claude .github .agents .windsurf 2>/dev/null || true
git commit -m "Add ai-agent-skills submodule and multi-agent wiring"
```

> **Note:** Git stores symlinks as symlinks. Generated files (`CLAUDE.md`, Copilot `*.instructions.md`) are marked with `generated-by: ai-agent-skills` so uninstall can remove them safely. Teammates need `git submodule update --init` after clone, then may re-run `install.sh` if links are missing.

### Clone an existing consumer that already uses the submodule

```bash
git clone --recurse-submodules <your-app-repo-url>
cd <your-app>
# If you forgot --recurse-submodules:
git submodule update --init --recursive
.ai-agent-skills/install.sh   # refresh wiring for all (or pass --target)
```

---

## Manual symlink alternative

Prefer `install.sh` for multi-tool setups. For **Cursor-only** manual wiring:

```bash
mkdir -p .cursor/skills .cursor/rules

for d in .ai-agent-skills/skills/*; do
  ln -s "$(pwd)/$d" ".cursor/skills/$(basename "$d")"
done

for f in .ai-agent-skills/rules/*; do
  ln -s "$(pwd)/$f" ".cursor/rules/$(basename "$f")"
done

ln -s "$(pwd)/.ai-agent-skills/AGENTS.md" AGENTS.md
```

Use absolute or repo-relative symlink targets consistently so links work for all developers.

---

## Uninstall wiring (keep submodule)

```bash
.ai-agent-skills/uninstall.sh
.ai-agent-skills/uninstall.sh --target cursor,claude
```

Removes managed symlinks that point into `.ai-agent-skills` and generated files marked `generated-by: ai-agent-skills`. Does **not** remove the submodule or local non-symlink overrides.

To remove the submodule entirely, follow standard git submodule removal (`git submodule deinit`, remove from `.gitmodules` and the working tree, then commit).

---

## Updating the submodule

From the consumer repo:

```bash
cd .ai-agent-skills
git fetch origin
git checkout main          # or desired tag/commit
git pull
cd ..
.ai-agent-skills/install.sh   # refresh links if new skills/rules were added
git add .ai-agent-skills
git commit -m "Bump ai-agent-skills submodule"
```

Or:

```bash
git submodule update --remote --merge .ai-agent-skills
.ai-agent-skills/install.sh
```

---

## How agents use this package

### Shared: `AGENTS.md`

Cross-tool contract (Codex, Cursor, Copilot agent mode, and others). Prefer editing the submodule copy when changing shared policy; use a non-symlink local `AGENTS.md` for consumer-specific amendments.

### Cursor

- Rules: `.cursor/rules/*.mdc` (`alwaysApply` or `globs`)
- Skills: `.cursor/skills/*/SKILL.md`

### Claude Code

- Skills: `.claude/skills/*/SKILL.md`
- `CLAUDE.md` imports `@AGENTS.md`

### GitHub Copilot / VS Code

- Skills: `.github/skills/*/SKILL.md`
- Repo instructions: `.github/copilot-instructions.md` → `AGENTS.md`
- Path-scoped: `.github/instructions/*.instructions.md` (converted from `rules/*.mdc`, including `applyTo`)
- Prompts: `.github/prompts/*.prompt.md`

### Codex / Windsurf / Gemini / Aider

- Primarily `AGENTS.md` (plus `.windsurfrules`, `GEMINI.md`, `CONVENTIONS.md` as linked above)
- Codex also gets `.agents/skills/`

### Prompts (`prompts/`)

Use by:

1. **`@`-referencing** e.g. `@.ai-agent-skills/prompts/tdd-implement-endpoint.md`
2. **Copying** the prompt body (below the horizontal rule) into chat
3. In Copilot: use linked `.github/prompts/*.prompt.md` after install

Skills also embed shorter **prompt-like workflows** you can paste directly.

---

## Standards summary

1. **TDD** — No production code without a failing test first (unless you explicitly waive it for that turn).
2. **DRY / SOLID** — Real duplication only; clear module boundaries; depend on abstractions.
3. **PEP8 + black** — Format and lint Python before done.
4. **Newest stable** — Check current releases when adding or upgrading tooling.
5. **Isolated env** — Dev Container or venv.
6. **Multi-container Docker** — Do not collapse frontend and backend into one service.
7. **MariaDB for integration tests** — Compose `test` profile.
8. **Auth** — KumpeCloud Auth default; configure via issuer/client/scopes/redirects so any OIDC/OAuth IdP can replace it.

---

## Skill catalog

| Skill | When to use |
|-------|-------------|
| `tdd-workflow` | Implementing features/bugs test-first; pytest / Angular tests |
| `solid-dry` | Architecture, extractions, coupling/cohesion reviews |
| `python-style` | black, ruff, PEP8, typing, `pyproject.toml` |
| `python-fastapi` | FastAPI apps, routers, DI, Pydantic v2 |
| `angular-frontend` | Angular apps, components, routes, signals |
| `sqlalchemy-db` | ORM models, sessions, Alembic, DB-agnostic access |
| `docker-multi-container` | Compose, Dockerfiles, service separation |
| `testing-mariadb` | Integration tests against MariaDB in Docker |
| `oidc-oauth-auth` | Login, JWT, KumpeCloud Auth / generic OIDC |
| `devcontainer-venv` | Dev Containers, venv setup |
| `dependency-versions` | Upgrades, pins, newest stable policy |
| `code-review` | PR/diff review against all standards |
| `kumpeapps-deploy` | Onboard app repos to KumpeApps Deployment Bot (`.kumpeapps-deploy-bot`, secrets sync) |

---

## Prompt catalog

| Prompt file | Use when |
|-------------|----------|
| `prompts/scaffold-fullstack-feature.md` | End-to-end Angular + FastAPI feature |
| `prompts/tdd-implement-endpoint.md` | New/changed FastAPI endpoint, TDD |
| `prompts/angular-feature.md` | New Angular feature/route |
| `prompts/sqlalchemy-model-migration.md` | Model + Alembic migration |
| `prompts/dockerize-stack.md` | Multi-container Docker setup |
| `prompts/add-oidc-auth.md` | KumpeCloud Auth / OIDC integration |
| `prompts/code-review.md` | Standards-based review |
| `prompts/bump-dependencies.md` | Dependency/image upgrades |
| `prompts/setup-kumpeapps-deploy.md` | Wire a repo to KumpeApps Deployment Bot |

---

## Rules catalog

| File | Scope |
|------|--------|
| `rules/00-coding-standards.mdc` | Always — TDD, DRY, SOLID, PEP8/black, env, versions |
| `rules/10-stack-defaults.mdc` | Always — Angular, FastAPI, SQLAlchemy, Docker, auth |
| `rules/20-python-fastapi.mdc` | `**/*.py` |
| `rules/30-angular.mdc` | `**/*.{ts,html,scss,css}` |
| `rules/40-docker-testing.mdc` | Compose / Dockerfile / `.devcontainer` |
| `rules/50-auth-oidc.mdc` | Auth / OIDC / security paths |

---

## Local overrides without forking

1. Add a **local** skill under `.cursor/skills/my-local-skill/` (regular directory, not a symlink).
2. Add a **local** rule under `.cursor/rules/99-my-project.mdc`.
3. Replace shared `AGENTS.md` with a regular file if you need consumer-specific policy (install will not overwrite non-symlinks).

To customize a shared skill long-term, open a PR against this repo or vendor a fork and point the submodule at your fork.

---

## Auth notes (KumpeCloud Auth)

- Project: [kumpecloud/kumpecloud-auth](https://github.com/kumpecloud/kumpecloud-auth)
- Image: `ghcr.io/kumpecloud/kumpecloud-auth`
- Fork of Logto; **APIs and environment variables remain Logto-compatible** unless fork docs say otherwise.
- Applications should still expose a **provider-agnostic** OIDC config surface so Auth0, Keycloak, Okta, or any OAuth 2.x/OIDC IdP can be used by changing config and the auth adapter—not domain code.

See skill `oidc-oauth-auth` and prompt `prompts/add-oidc-auth.md`.

---

## Day-to-day usage examples

**Implement an API with TDD**

```text
@.ai-agent-skills/prompts/tdd-implement-endpoint.md
METHOD=POST PATH=/api/items BEHAVIOR=create item for the current user
```

**Dockerize a repo**

```text
Follow @.ai-agent-skills/prompts/dockerize-stack.md for this repository.
```

**Review a PR**

```text
@.ai-agent-skills/prompts/code-review.md
```

**Ask the agent to load a skill workflow**

```text
Use the tdd-workflow and python-fastapi skills to add GET /api/health.
```

---

## Contributing to this repository

When adding a skill:

1. Create `skills/<name>/SKILL.md` with YAML frontmatter:
   - `name`: lowercase, hyphens, max 64 chars (match folder name)
   - `description`: third person; include **what** and **when** (trigger terms)
2. Keep `SKILL.md` under ~500 lines; put deep detail in `reference.md` linked one level deep.
3. Include a short **prompt-like workflow** block where useful.
4. Link related files under `prompts/` when applicable.
5. Update this README catalog.
6. Run `./install.sh` in a scratch consumer (or in-repo preview) to verify symlink wiring.

Rules: prefer short `.mdc` files with clear `description`, and `alwaysApply` or `globs` as appropriate.

Prompts: include frontmatter (`title`, `use_when`, `related_skills`) and a ready-to-paste body after a horizontal rule.

---

## License

MIT — see [LICENSE](LICENSE).
