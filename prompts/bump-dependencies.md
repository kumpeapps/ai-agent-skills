---
title: Bump dependencies
use_when: Upgrading packages, lockfiles, or base images to newest stable
related_skills:
  - dependency-versions
  - tdd-workflow
  - devcontainer-venv
---

# Prompt: Bump dependencies

Copy everything below the line into chat.

---

Upgrade **`<PACKAGE_OR_STACK>`** to the **newest stable** releases.

Steps:
1. Check current pins and newest stable (PyPI/npm/GHCR as applicable)
2. Update manifests and lockfiles
3. Run the full test suite; fix breakages
4. Note breaking changes; keep auth/DB behind existing abstractions
5. Use Dev Container or project venv only—no system Python

Summarize version deltas and any required code changes.
