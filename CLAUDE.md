# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

<!-- Replace this section with your project's specific details -->
[Brief description of your project - what it does, tech stack, main goals]

## Architecture

<!-- Customize this to match your project structure -->
```
src/
|-- app/              # Application entry point / routing
|-- components/       # Reusable UI components (if frontend)
|-- services/         # Business logic / service layer
|-- repositories/     # Database access layer
|-- models/           # Data models / types
|-- utils/            # Utility functions and helpers
|-- config/           # Configuration files
```

## Critical Rules

### 1. Code Organization
- Many small files over few large files
- High cohesion, low coupling
- 200-400 lines typical, 800 max per file
- Organize by feature/domain, not by type

### 2. Code Style
- No emojis in code, comments, or documentation
- Immutability always - never mutate objects or arrays
- No console.log in production code
- Proper error handling with try/catch
- Input validation at all boundaries

### 3. Testing
- TDD: Write tests first (use `/tdd` command)
- 80% minimum coverage
- Unit tests for utilities
- Integration tests for APIs
- E2E tests for critical flows

### 4. Security
- No hardcoded secrets
- Environment variables for sensitive data
- Validate all user inputs
- Parameterized queries only
- CSRF protection enabled

### 5. Database
- Never execute migrations without user confirmation
- Always create migration files — never modify schema directly
- Use parameterized queries exclusively
- Document all schema changes in migration files
- Use `/migrate` command for all schema changes

### 6. API Design
- RESTful naming: plural nouns, no verbs in URLs
- Consistent error format (RFC 7807 Problem Details)
- Pagination required on all list endpoints
- Versioning strategy documented before first release
- Use `/api-design` command when designing new endpoints

### 7. Logging
- Structured JSON logging in production (no console.log)
- No PII, passwords, tokens, or secrets in logs
- Correlation IDs on all requests
- Log levels: ERROR (failures), WARN (recoverable), INFO (business events), DEBUG (dev only)
- Slow operations logged with duration

### 8. Git Workflow
- Never commit directly to main — always use a feature branch
- Branch naming: `feature/*`, `fix/*`, `refactor/*`, `docs/*`
- Squash merge to main with a descriptive commit message
- Include individual branch commits in the squash commit body
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `perf:`

## Development Workflow

```
/plan        → Create implementation plan (wait for approval)
  ↓
/tdd         → Implement with tests first
  ↓
/build-fix   → Fix any build errors
  ↓
/perf        → Check for performance regressions (if relevant)
  ↓
/code-review → Security and quality review before committing
  ↓
/checkpoint  → Save final state
  ↓
/changelog   → Update changelog before PR
```

## Available Agents

| Agent | Purpose |
|-------|---------|
| `planner` | Creates implementation plans for complex features |
| `architect` | System design, scalability, and architecture decisions |
| `loop-operator` | Runs autonomous loops safely with stop conditions |
| `tdd-guide` | Enforces test-driven development (Red-Green-Refactor) |
| `security-reviewer` | OWASP Top 10 vulnerability detection |
| `devops-engineer` | CI/CD pipelines, Docker, deployment strategies |
| `database-specialist` | Schema design, migrations, query optimization |
| `performance-engineer` | Profiling, bottleneck analysis, caching |
| `api-designer` | REST/GraphQL design, OpenAPI specs, error standardization |
| `refactoring-guru` | Code smells, design patterns, safe refactoring |
| `docs-writer` | READMEs, API docs, ADRs, changelogs, runbooks |

## Available Commands

| Command | Description |
|---------|-------------|
| `/plan` | Create implementation plan (wait for approval) |
| `/tdd` | Test-driven development workflow |
| `/build-fix` | Auto-detect and fix build errors |
| `/code-review` | Security and quality review of changes |
| `/checkpoint` | Create/verify workflow checkpoints |
| `/docs` | Look up library documentation |
| `/setup-github` | Configure GitHub MCP server PAT token |
| `/deploy` | Generate Dockerfile, docker-compose, or CI/CD pipeline |
| `/migrate` | Plan and create database migrations (asks before executing) |
| `/perf` | Profile and optimize performance bottlenecks |
| `/refactor` | Identify code smells and apply safe refactoring |
| `/api-design` | Design REST/GraphQL APIs and generate OpenAPI specs |
| `/dependency-check` | Audit dependencies for vulnerabilities and outdated packages |
| `/changelog` | Generate changelog entries from git commits |

## Available Skills

| Skill | Description |
|-------|-------------|
| `tdd-workflow` | Best practices for test-first development |
| `security-review` | Checklists and patterns for secure coding |
| `codebase-onboarding` | Process for understanding new applications |
| `semantic-commits` | Strategy enforcing atomic, conventional commits |
| `api-design-patterns` | REST, pagination, error formats, versioning, OpenAPI |
| `database-migrations` | Safe migration patterns, zero-downtime, ORM templates |
| `cicd-pipelines` | GitHub Actions templates, Docker, deployment strategies |
| `error-handling` | Custom errors, retry patterns, circuit breakers |
| `logging-observability` | Structured logging, correlation IDs, metrics, no PII |
| `accessibility` | WCAG 2.1 AA, ARIA, keyboard navigation, color contrast |
| `performance-optimization` | Backend/frontend profiling, caching, memory leaks |
| `documentation-generation` | README, JSDoc, ADR, changelog, runbook templates |

## Environment Variables

<!-- List your project's required environment variables -->
```bash
# Required
DATABASE_URL=
API_KEY=
JWT_SECRET=

# Optional
PORT=3000
DEBUG=false
LOG_LEVEL=info
```

## MCP Servers

This project includes recommended Model Context Protocol (MCP) configurations in `.claude/mcp-configs/mcp-servers.json`.

To enable live documentation (Context7), browser testing (Playwright), or GitHub integration, copy the JSON blocks to your global `~/.claude.json` file. See `.claude/mcp-configs/README.md` for details.
