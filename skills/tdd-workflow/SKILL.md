---
name: tdd-workflow
description: Enforces red-green-refactor test-driven development for Python (pytest) and Angular. Use when implementing features, fixing bugs, writing tests, or when the user mentions TDD, failing tests, or test-first development.
---

# TDD Workflow

## Rules

1. Write a **failing** test that expresses the desired behavior.
2. Run it and confirm it fails for the right reason.
3. Write the **minimum** production code to pass.
4. Refactor while keeping tests green.
5. Never commit production changes without the corresponding tests.

If asked to "just implement" without tests, still start with a failing test unless the user explicitly waives TDD for that turn.

## Python (pytest)

- Prefer `pytest` + `httpx`/`TestClient` for FastAPI.
- Unit tests for services; integration tests against MariaDB in Docker (see `testing-mariadb` skill).
- Name tests `test_<behavior>`; one assert focus per test when practical.

```python
def test_create_item_returns_201(client):
    response = client.post("/items", json={"name": "widget"})
    assert response.status_code == 201
    assert response.json()["name"] == "widget"
```

## Angular

- Use TestBed (or project Jest/Vitest setup).
- Test public behavior of components/services, not private implementation details.
- Write the failing spec before changing the component or service.

## Checklist

```
TDD Progress:
- [ ] Failing test written
- [ ] Failure confirmed (red)
- [ ] Minimal implementation (green)
- [ ] Refactor complete; suite still green
- [ ] Edge cases covered
```

## Prompt-like workflow

Copy into the agent chat when starting work:

```
Implement <FEATURE> using strict TDD:
1. Write a failing test that defines success.
2. Show me the red failure.
3. Implement the minimum code to pass.
4. Refactor and keep tests green.
Follow DRY, SOLID, PEP8, and black. Stack: Angular + FastAPI + SQLAlchemy unless I say otherwise.
```

## Related

- Prompt template: [../../prompts/tdd-implement-endpoint.md](../../prompts/tdd-implement-endpoint.md)
- Skills: `solid-dry`, `python-fastapi`, `angular-frontend`, `testing-mariadb`, `code-review`
