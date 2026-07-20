---
name: angular-frontend
description: Builds Angular frontends with standalone components, signals, lazy routes, and OIDC-ready HTTP. Use when creating Angular apps, components, services, routes, or frontend features.
---

# Angular Frontend

## Defaults

- Newest stable Angular (CLI + packages aligned).
- Standalone components; signals for local state; lazy-loaded feature routes.
- TDD with the project's runner (Jest/Vitest/Karma as configured).
- No client secrets in the SPA; OIDC with PKCE (`oidc-oauth-auth`).

## Suggested layout

```
frontend/
  src/app/
    core/           # auth, interceptors, guards
    shared/
    features/<name>/
    app.routes.ts
    app.config.ts
  Dockerfile
```

## Patterns

- **Components**: presentational vs container; inputs/outputs or signals.
- **Services**: `providedIn: 'root'` or feature providers; no HTTP in dumb components.
- **HTTP**: `HttpClient` + interceptor attaching `Authorization: Bearer`.
- **Guards**: route protection based on auth state from the OIDC adapter.
- **Styles**: follow existing design system; avoid introducing a second UI kit without ask.

## TDD for a feature

1. Write failing component/service spec for the behavior.
2. Implement minimum template/class/service.
3. Wire route; keep bundle lazy where appropriate.
4. Ensure auth interceptor covers API calls.

## Prompt-like workflow

```
Build Angular feature <NAME>:
- Standalone components + signals
- Lazy route
- Failing tests first
- HTTP via services; OIDC Bearer interceptor if authenticated
Use newest stable Angular. Match existing project structure.
```

## Related

- Prompt: [../../prompts/angular-feature.md](../../prompts/angular-feature.md)
- Skills: `tdd-workflow`, `oidc-oauth-auth`, `dependency-versions`, `docker-multi-container`
