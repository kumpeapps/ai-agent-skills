---
name: solid-dry
description: Applies SOLID and DRY design checks when designing modules, refactoring, or reviewing structure. Use when discussing architecture, extracting shared code, interfaces, or when the user mentions SOLID, DRY, coupling, or cohesion.
---

# SOLID and DRY

## DRY

- Duplicate **behavior** once → extract (function, service, shared schema).
- Duplicate **coincidence** (similar-looking but different reasons to change) → do not merge.
- Prefer configuration or small helpers over copy-pasted constants and validation.

## SOLID checklist

| Principle | Ask |
|-----------|-----|
| **S**ingle responsibility | Does this module have one reason to change? |
| **O**pen/closed | Can I extend via new types/strategies without editing core? |
| **L**iskov | Can substitutes honor the contract without surprises? |
| **I**nterface segregation | Are clients forced to depend on unused methods? |
| **D**ependency inversion | Do high-level modules depend on abstractions (protocols/interfaces)? |

## Stack mapping

- **FastAPI**: routers thin; services hold use-cases; `Depends` injects abstractions (protocols), not concrete infra in domain code.
- **SQLAlchemy**: repositories/unit-of-work behind interfaces; models stay persistence-focused.
- **Angular**: inject services via DI; presentational components avoid HTTP; auth behind an adapter.
- **Auth**: OIDC provider details live in an adapter; domain never imports IdP SDKs directly.

## When extracting

1. Confirm real duplication (same rule, same failure mode).
2. Name the abstraction after the **capability**, not the vendor.
3. Add or update tests around the extracted unit (TDD).

## Prompt-like workflow

```
Review this change for SOLID and DRY:
- Flag unjustified duplication.
- Flag SRP/ISP/DIP violations.
- Suggest the smallest refactor that improves boundaries without speculative abstraction.
Keep TDD: any extract gets tests first or with the move.
```

## Related

- Skills: `tdd-workflow`, `python-fastapi`, `angular-frontend`, `oidc-oauth-auth`, `code-review`
