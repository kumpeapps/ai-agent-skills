---
name: sqlalchemy-db
description: Designs dialect-agnostic SQLAlchemy 2.x models, sessions, and Alembic migrations. Use when working with databases, ORM models, queries, migrations, or SQLAlchemy.
---

# SQLAlchemy (DB-Agnostic)

## Defaults

- SQLAlchemy **2.x** style (`select()`, `Session`, mapped classes with `Mapped[]`).
- Keep models **dialect-agnostic** (avoid MySQL-/Postgres-only types unless behind dialect checks).
- Migrations via **Alembic**.
- App runtime DB may vary; **integration tests use MariaDB in Docker** (`testing-mariadb`).

## Patterns

- Central `Base`, engine, and `session_factory` in `app/db/`.
- Prefer repository or unit-of-work wrappers for services (SOLID / DIP).
- Use explicit transactions; commit at use-case boundary.
- Connection URL from settings (`postgresql+psycopg://`, `mysql+pymysql://`, etc.) — code stays the same.

## Model sketch

```python
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import String

class Base(DeclarativeBase):
    pass

class Item(Base):
    __tablename__ = "items"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255))
```

## Alembic

1. Autogenerate only after models reflect intent.
2. Review migration for dialect-specific ops; keep portable when possible.
3. Test upgrade/downgrade against MariaDB in the `test` Compose profile.

## TDD

- Unit-test query helpers with a session fixture.
- Integration-test persistence against MariaDB, not SQLite, for realism.

## Prompt-like workflow

```
Add SQLAlchemy model + Alembic migration for <ENTITY>.
Keep types DB-agnostic. TDD against MariaDB Docker for integration.
Use SQLAlchemy 2.x Mapped style and newest stable SQLAlchemy/Alembic.
```

## Related

- Prompt: [../../prompts/sqlalchemy-model-migration.md](../../prompts/sqlalchemy-model-migration.md)
- Skills: `python-fastapi`, `testing-mariadb`, `tdd-workflow`, `solid-dry`
