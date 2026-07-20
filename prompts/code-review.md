---
title: Code review
use_when: Reviewing a PR or diff against repository standards
related_skills:
  - code-review
  - tdd-workflow
  - solid-dry
  - python-style
  - oidc-oauth-auth
---

# Prompt: Code review

Copy everything below the line into chat.

---

Review the current diff/PR against **ai-agent-skills** standards:

- TDD (failing test first)
- DRY and SOLID
- PEP8 + black (Python)
- Stack: Angular + FastAPI + SQLAlchemy 2.x
- Docker: separate frontend/backend/db containers
- Integration tests: MariaDB in Docker
- Auth: KumpeCloud Auth–first OIDC with provider-agnostic abstraction
- Newest stable deps when packages were added; Dev Container/venv only

Output findings as **Critical** / **Suggestion** / **Nice to have**, plus a short standards pass/fail summary.
