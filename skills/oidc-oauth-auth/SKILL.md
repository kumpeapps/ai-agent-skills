---
name: oidc-oauth-auth
description: Integrates OIDC/OAuth with KumpeCloud Auth (Logto fork) as default and any standards-compliant provider via abstraction. Use when adding login, JWT validation, OAuth, OIDC, Logto, or KumpeCloud Auth.
---

# OIDC / OAuth Auth

## Default IdP

- **KumpeCloud Auth** — self-hosted Logto fork.
- Image: `ghcr.io/kumpecloud/kumpecloud-auth`
- Internal APIs and environment variables remain **Logto-compatible** unless noted upstream.
- Prefer newest stable image tag (`dependency-versions`).

## Provider-agnostic config

All apps expose settings like:

| Setting | Purpose |
|---------|---------|
| `OIDC_ISSUER` | Discovery base / issuer URL |
| `OIDC_CLIENT_ID` | Public or confidential client id |
| `OIDC_CLIENT_SECRET` | Confidential clients only (backend) |
| `OIDC_SCOPES` | e.g. `openid profile email` |
| `OIDC_AUDIENCE` / resource | API audience when applicable |
| `OIDC_REDIRECT_URI` | SPA or BFF callback |

Domain/services depend on an **auth adapter** interface, not on KumpeCloud/Logto SDKs directly. Swapping to Auth0, Keycloak, Okta, or generic OIDC is a config + adapter change.

## FastAPI

- Fetch JWKS from the issuer; validate JWT `iss`, `aud`/`client_id`, `exp`, signature.
- Protect routes with `Depends(get_current_user)`.
- Machine clients: client credentials where appropriate; users: bearer access tokens from the SPA/BFF.

## Angular

- Authorization **code + PKCE** (public client).
- Store tokens per SPA security guidance; refresh via token endpoint.
- HTTP interceptor adds `Authorization: Bearer <access_token>`.
- Never ship client secrets in frontend bundles.

## Docker

- Optional Compose service `auth` using `ghcr.io/kumpecloud/kumpecloud-auth`.
- Wire frontend/backend env to the auth issuer URL on the Compose network.

## TDD

- Unit-test JWT validation with JWKS stubs.
- Integration-test protected routes with generated/test tokens or IdP test users—failing tests first.

## Prompt-like workflow

```
Add OIDC auth with KumpeCloud Auth as the default IdP.
Use a provider-agnostic settings/adapter layer so any OIDC/OAuth provider can be swapped.
FastAPI: JWKS JWT validation. Angular: PKCE + Bearer interceptor.
TDD for protected routes. Newest stable images/SDKs.
```

## Related

- Prompt: [../../prompts/add-oidc-auth.md](../../prompts/add-oidc-auth.md)
- Skills: `python-fastapi`, `angular-frontend`, `docker-multi-container`, `solid-dry`, `tdd-workflow`

## Reference

- KumpeCloud Auth: https://github.com/kumpecloud/kumpecloud-auth
- Upstream Logto compatibility: env vars and APIs unless fork docs say otherwise
