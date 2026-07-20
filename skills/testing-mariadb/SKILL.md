---
name: testing-mariadb
description: Runs integration tests against MariaDB in Docker Compose. Use when writing DB integration tests, pytest fixtures, CI database setup, or Compose test profiles.
---

# Testing with MariaDB (Docker)

## Policy

- Integration tests that touch persistence use **MariaDB in Docker**, not SQLite (unless the user explicitly waives this).
- Prefer Compose profile `test` with a dedicated `mariadb-test` service.
- Tear down or isolate data per test session (transactions or fresh schema).

## Compose sketch

```yaml
services:
  mariadb-test:
    image: mariadb:latest  # pin newest stable after check
    profiles: ["test"]
    environment:
      MARIADB_ROOT_PASSWORD: test
      MARIADB_DATABASE: app_test
      MARIADB_USER: test
      MARIADB_PASSWORD: test
    ports: ["3307:3306"]
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 5s
      timeout: 5s
      retries: 20
```

## Pytest fixture pattern

```python
import os
import pytest
from sqlalchemy import create_engine
from app.db.base import Base

@pytest.fixture(scope="session")
def engine():
    url = os.environ["TEST_DATABASE_URL"]  # mysql+pymysql://test:test@localhost:3307/app_test
    eng = create_engine(url)
    Base.metadata.create_all(eng)
    yield eng
    Base.metadata.drop_all(eng)
    eng.dispose()
```

Start DB with: `docker compose --profile test up -d mariadb-test`.

## TDD flow

1. Bring up MariaDB test container.
2. Write failing integration test.
3. Implement; keep unit tests fast and DB-free where possible.
4. CI job starts Compose `test` profile before pytest.

## Prompt-like workflow

```
Add integration tests for <FEATURE> against MariaDB in Docker.
Use Compose profile test, healthcheck wait, and pytest fixtures.
Do not use SQLite for these tests.
```

## Related

- Skills: `sqlalchemy-db`, `docker-multi-container`, `tdd-workflow`, `python-fastapi`
