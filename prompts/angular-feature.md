---
title: Angular feature
use_when: Building a new Angular feature module, route, or component flow
related_skills:
  - angular-frontend
  - tdd-workflow
  - oidc-oauth-auth
---

# Prompt: Angular feature

Copy everything below the line into chat.

---

Build Angular feature **`<FEATURE_NAME>`**.

Requirements:
- Newest stable Angular; standalone components; signals
- Lazy-loaded route
- Strict TDD: failing specs first
- HTTP only in services; presentational components stay dumb
- If auth needed: OIDC authorization code + PKCE; Bearer interceptor; no client secrets in the SPA (KumpeCloud Auth default issuer config)

Match existing project structure and lint/format tooling. Summarize files created/changed.
