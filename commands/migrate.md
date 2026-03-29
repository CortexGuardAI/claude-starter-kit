---
description: Plan and create database migrations safely. ALWAYS asks for user confirmation before executing any migration. Invokes the database-specialist agent.
---

# /migrate Command

This command invokes the **database-specialist** agent to create, review, and plan database migrations.

## What This Command Does

1. **Analyzes schema changes** -- Understands what changed and why
2. **Creates migration file** -- Generates a versioned migration with up/down
3. **Reviews for safety** -- Checks for table locks, zero-downtime compatibility
4. **Asks for confirmation** -- ALWAYS requires explicit user approval before execution
5. **Reports result** -- Confirms what was applied

## Usage

```
/migrate [action]
```

### Actions

| Action | Description |
|--------|-------------|
| `/migrate create <name>` | Create a new migration file |
| `/migrate review` | Review pending migration files |
| `/migrate status` | Show migration history and pending migrations |
| `/migrate rollback` | Plan rollback of last migration (asks before executing) |
| `/migrate` (no action) | Create migration based on context |

## Examples

```
/migrate create add-user-profile-table
/migrate create add-index-on-orders-status
/migrate review
/migrate status
```

## Important Rules

> **CRITICAL**: This command will NEVER execute migrations automatically. It will always:
> 1. Show you the migration file contents
> 2. Explain the impact and any risks
> 3. Ask for your explicit `yes` / confirm before running

If you just want the migration file without executing, say "create only, do not run".

## Migration Safety Checks

Before creating a migration, the agent checks:
- **Table locks**: Long-running `ALTER TABLE` can block production writes
- **Zero-downtime**: Is this migration safe to run while the app is live?
- **Rollback feasibility**: Can it be reversed cleanly?
- **Data loss risk**: Does this drop columns or tables?
- **Index creation**: Large tables need `CREATE INDEX CONCURRENTLY`

## Migration File Output

The agent generates framework-specific migration files:

| Framework | Output Location |
|-----------|----------------|
| Prisma | `prisma/migrations/TIMESTAMP_name/` |
| Drizzle | `src/db/migrations/TIMESTAMP_name.ts` |
| TypeORM | `src/migrations/TIMESTAMP_name.ts` |
| Alembic (Python) | `alembic/versions/TIMESTAMP_name.py` |
| Raw SQL | `migrations/TIMESTAMP_name.sql` |

## Integration

- Always use `/plan` before significant schema changes
- Always run `/checkpoint` before and after migrations in production
- Use `database-specialist` agent for complex schema design

## Related

This command uses the `database-specialist` agent. Source: `agents/database-specialist.md`
For detailed migration patterns, see skill: `database-migrations`
