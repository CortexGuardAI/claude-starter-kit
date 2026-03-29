---
name: documentation-generation
description: Use this skill when generating or updating READMEs, API documentation, ADRs, changelogs, or operational runbooks. Provides templates and standards for all documentation types a production project needs.
---

# Documentation Generation Skill

## When to Activate

- Starting a new project (README needed)
- Public API is growing without docs
- Making a significant architectural decision (ADR needed)
- Preparing a release (changelog + runbook needed)
- Onboarding new team members
- Any public function/class is missing docstrings

---

## README Template

```markdown
# Project Name

One-paragraph description of what it does, for whom, and why it exists.

## Quick Start

\`\`\`bash
npm install
cp .env.example .env   # Configure your environment
npm run dev            # Start dev server at http://localhost:3000
\`\`\`

## Features

- **Feature A**: Brief description
- **Feature B**: Brief description

## Architecture

\`\`\`
src/
├── api/          # HTTP handlers and route definitions
├── services/     # Business logic
├── repositories/ # Database access
├── models/       # Domain types and entities
└── utils/        # Shared utilities
\`\`\`

## Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | — | PostgreSQL connection string |
| `JWT_SECRET` | Yes | — | Token signing secret (min 32 chars) |
| `PORT` | No | `3000` | HTTP server port |

## Development

\`\`\`bash
npm test              # Run unit + integration tests
npm run test:e2e      # Run E2E tests
npm run lint          # Lint code
npm run build         # Build for production
\`\`\`

## API Reference

Full OpenAPI spec: [`docs/openapi.yaml`](./docs/openapi.yaml)
Interactive docs: http://localhost:3000/docs (when running locally)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

MIT © [Your Organization]
```

---

## JSDoc / Docstring Standards

### TypeScript (JSDoc)
```typescript
/**
 * Creates a new user account and sends a welcome email.
 *
 * @param params - User creation parameters
 * @param params.email - User email address (must be unique)
 * @param params.name - Display name
 * @param params.role - Access level (default: 'user')
 * @returns The created user with generated ID and timestamps
 * @throws {ValidationError} If email is already registered
 * @throws {ExternalServiceError} If welcome email fails to send
 *
 * @example
 * const user = await createUser({ email: 'jane@example.com', name: 'Jane' })
 * console.log(user.id) // 'usr_abc123'
 */
async function createUser(params: CreateUserParams): Promise<User>
```

### Python (Google-style docstring)
```python
def create_user(email: str, name: str, role: str = "user") -> User:
    """Creates a new user account and sends a welcome email.

    Args:
        email: Unique email address for the account.
        name: User's display name.
        role: Access role, one of 'user' or 'admin'. Defaults to 'user'.

    Returns:
        The created User object with generated ID and timestamps.

    Raises:
        ValidationError: If the email is already registered.
        EmailError: If the welcome email cannot be sent.

    Example:
        >>> user = create_user("jane@example.com", "Jane Doe")
        >>> print(user.id)
        'usr_abc123'
    """
```

### Go
```go
// CreateUser creates a new user account and sends a welcome email.
// Returns an error if the email is already registered or if
// the welcome email cannot be sent.
//
// Example:
//
//	user, err := CreateUser(ctx, CreateUserParams{Email: "jane@example.com"})
//	if err != nil { log.Fatal(err) }
func CreateUser(ctx context.Context, params CreateUserParams) (*User, error)
```

---

## Architecture Decision Record (ADR)

Store in `docs/adr/` numbered sequentially: `001`, `002`, etc.

```markdown
# ADR-001: PostgreSQL as Primary Database

**Date**: 2024-01-15
**Status**: Accepted
**Authors**: @your-name

## Context

We need a primary database. Requirements: ACID transactions,
JSON support, strong ORM ecosystem, managed cloud offering.

## Decision

Use **PostgreSQL 16** as the primary database.

## Rationale

- Full ACID compliance (required for payment operations)
- JSONB for flexible metadata without a separate document store
- pgvector extension available for future AI/embedding features
- Strong support across Prisma, Drizzle, SQLAlchemy, GORM

## Consequences

**Positive**: Strong consistency, rich queries, single DB for all data types.
**Negative**: Horizontal write scaling requires Citus (added complexity).

## Alternatives Rejected

- **MySQL 8**: Weaker JSON, no window functions
- **MongoDB**: No cross-collection ACID, we need joins
- **SQLite**: Not suited for multi-instance production
```

---

## CHANGELOG.md (Keep a Changelog)

```markdown
# Changelog

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com)
Versioning: [Semantic Versioning](https://semver.org)

## [Unreleased]

### Added
- Dark mode support

## [2.1.0] - 2024-03-15

### Added
- Two-factor authentication via TOTP
- CSV export for all report types

### Changed
- Search performance improved 3x via composite index

### Fixed
- Race condition in concurrent order creation (#234)

### Security
- Updated jsonwebtoken to 9.0.2 (CVE-2022-23529)

[2.1.0]: https://github.com/org/repo/compare/v2.0.0...v2.1.0
[Unreleased]: https://github.com/org/repo/compare/v2.1.0...HEAD
```

### Generate from commits
```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD \
  --pretty=format:"%s" --no-merges \
  | grep -E "^(feat|fix|perf|security|refactor|docs)(\(.+\))?:"
```

---

## Operational Runbook Template

Store in `docs/runbooks/`:

```markdown
# Runbook: [Incident Type]

**Severity**: P0 / P1 / P2
**Owner**: @team-name
**Last Updated**: YYYY-MM-DD

## Symptoms
- [ ] Symptom 1 (how you know this is happening)
- [ ] Symptom 2

## Diagnosis

\`\`\`bash
# Commands to run to confirm the issue
kubectl get pods -n production
kubectl logs deploy/app --tail=100 | grep ERROR
\`\`\`

## Resolution Steps

1. **Step 1**: What to do first
   \`\`\`bash
   # Command
   \`\`\`
2. **Step 2**: What to do next

## Rollback

\`\`\`bash
# How to revert if resolution makes things worse
kubectl rollout undo deployment/app
\`\`\`

## Post-Incident

- Create incident report within 24h
- Schedule post-mortem within 48h
- Update this runbook with new findings
```

---

## Documentation Checklist

### Project
- [ ] README covers install, configure, run, test
- [ ] `.env.example` documents all env variables with descriptions
- [ ] CHANGELOG.md follows Keep a Changelog format
- [ ] ADR exists for every significant architectural decision
- [ ] CONTRIBUTING.md explains how to run locally and open PRs

### Code
- [ ] All public functions have JSDoc / docstrings
- [ ] Complex algorithms have explanatory inline comments
- [ ] Non-obvious business rules documented in code

### Operations
- [ ] Runbooks exist for all P0/P1 scenarios
- [ ] Deployment steps documented
- [ ] Rollback procedure documented and tested

---

**Remember**: The best documentation is written when you still remember why you made the decisions. Do it now, not later.
