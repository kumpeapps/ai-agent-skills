---
title: Add OIDC auth
use_when: Integrating login and API protection with OIDC/OAuth
related_skills:
  - oidc-oauth-auth
  - python-fastapi
  - angular-frontend
  - docker-multi-container
  - tdd-workflow
---

# Prompt: Add OIDC auth

Copy everything below the line into chat.

---

Add authentication using **OIDC**.

Defaults:
- IdP: **KumpeCloud Auth** (`ghcr.io/kumpecloud/kumpecloud-auth`), Logto-compatible environment variables and APIs
- Design a **provider-agnostic** settings/adapter layer (issuer, client id/secret, scopes, redirect URIs, audience) so any OIDC/OAuth provider can be swapped

Implement:
- FastAPI: JWKS JWT validation; `Depends` for protected routes
- Angular: authorization code + PKCE; Bearer interceptor; no SPA client secrets
- Optional Compose `auth` service
- TDD for protected endpoints and auth adapter unit tests

Document required env vars and how to point at a non-KumpeCloud provider.
