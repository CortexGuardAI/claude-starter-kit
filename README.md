# Claude Code Starter Kit

A production-ready boilerplate that transforms Claude Code into a **complete AI-powered development department**. Includes battle-tested agents, slash commands, skills, hooks, and MCP configurations for any tech stack.

## Quick Start

### Option 1: Zero-Install (Recommended)

```bash
npx @cortexguardai/claude-starter-kit
```

### Option 2: Clone and customize

```bash
git clone https://github.com/CortexGuardAI/claude-starter-kit.git my-project
cd my-project
```

### Option 3: Copy into existing project

```bash
mkdir -p /path/to/your/project/.claude
cp -r agents/ commands/ skills/ hooks/ mcp-configs/ /path/to/your/project/.claude/
cp CLAUDE.md /path/to/your/project/
cp mcp-configs/mcp-servers.json /path/to/your/project/.claude.json
```

Then edit `CLAUDE.md` to match your project's specifics.

---

## What's Included

### Agents

Specialized sub-agents that Claude delegates to for specific tasks.

| Agent | File | Description |
|-------|------|-------------|
| **Planner** | `agents/planner.md` | Creates phased implementation plans with risk assessment and testing strategy |
| **Architect** | `agents/architect.md` | System design, trade-off analysis, ADR templates, Technology Radar |
| **Loop Operator** | `agents/loop-operator.md` | Runs autonomous fix/refactor loops with safety controls and escalation |
| **TDD Guide** | `agents/tdd-guide.md` | Enforces Red-Green-Refactor with 80%+ coverage across unit, integration, E2E |
| **Security Reviewer** | `agents/security-reviewer.md` | OWASP Top 10 detection, secrets scanning, input validation, dependency auditing |
| **DevOps Engineer** | `agents/devops-engineer.md` | CI/CD pipelines, Dockerfile, docker-compose, deployment strategies |
| **Database Specialist** | `agents/database-specialist.md` | Schema design, safe migrations, query optimization, N+1 prevention |
| **Performance Engineer** | `agents/performance-engineer.md` | Profiling, bottleneck analysis, caching strategies, bundle optimization |
| **API Designer** | `agents/api-designer.md` | REST/GraphQL design, OpenAPI specs, RFC 7807 errors, versioning |
| **Refactoring Guru** | `agents/refactoring-guru.md` | Code smell detection, design patterns, safe incremental refactoring |
| **Docs Writer** | `agents/docs-writer.md` | READMEs, API docs, ADRs, changelogs, runbooks |

### Commands

Slash commands you invoke directly in Claude Code.

| Command | File | Description |
|---------|------|-------------|
| `/plan` | `commands/plan.md` | Create implementation plan, wait for approval before coding |
| `/tdd` | `commands/tdd.md` | Scaffold interfaces, write tests first, implement, verify coverage |
| `/build-fix` | `commands/build-fix.md` | Auto-detect build system, parse errors, fix one at a time |
| `/code-review` | `commands/code-review.md` | Security, quality, performance, a11y, and API design review |
| `/checkpoint` | `commands/checkpoint.md` | Create/verify git-based workflow checkpoints |
| `/docs` | `commands/docs.md` | Look up current documentation via Context7 MCP |
| `/setup-github` | `commands/setup-github.md` | Configure GitHub MCP server with PAT token |
| `/deploy` | `commands/deploy.md` | Generate Dockerfile, docker-compose, or CI/CD pipeline |
| `/migrate` | `commands/migrate.md` | Create safe database migrations (always confirms before executing) |
| `/perf` | `commands/perf.md` | Profile API, DB queries, bundles, and algorithm complexity |
| `/refactor` | `commands/refactor.md` | Detect code smells and apply safe test-driven refactoring |
| `/api-design` | `commands/api-design.md` | Design REST/GraphQL APIs and generate OpenAPI specs |
| `/dependency-check` | `commands/dependency-check.md` | Audit dependencies for CVEs, outdated packages, license issues |
| `/changelog` | `commands/changelog.md` | Generate changelog entries from git commits |

### Skills

Deep workflow knowledge that Claude activates automatically when relevant.

| Skill | Directory | Description |
|-------|-----------|-------------|
| **TDD Workflow** | `skills/tdd-workflow/` | Testing patterns, mocking strategies, coverage verification |
| **Security Review** | `skills/security-review/` | Secrets management, input validation, SQL injection, pre-deploy checklist |
| **Codebase Onboarding** | `skills/codebase-onboarding/` | Systematic discovery process for mapping new codebases |
| **Semantic Commits** | `skills/semantic-commits/` | Atomic, conventional commits with correct types and scopes |
| **API Design Patterns** | `skills/api-design-patterns/` | REST naming, pagination, RFC 7807 errors, versioning, OpenAPI |
| **Database Migrations** | `skills/database-migrations/` | Zero-downtime patterns, ORM templates, index design |
| **CI/CD Pipelines** | `skills/cicd-pipelines/` | GitHub Actions templates, Docker multi-stage, deployment strategies |
| **Error Handling** | `skills/error-handling/` | Custom error classes, retry/backoff, circuit breakers |
| **Logging & Observability** | `skills/logging-observability/` | Structured logging, correlation IDs, metrics, no PII in logs |
| **Accessibility** | `skills/accessibility/` | WCAG 2.1 AA, ARIA, keyboard navigation, color contrast |
| **Performance Optimization** | `skills/performance-optimization/` | Backend/frontend profiling, caching, bundle size, memory leaks |
| **Documentation Generation** | `skills/documentation-generation/` | README, JSDoc/docstrings, ADR, changelog, runbook templates |

### MCP Configurations

| Configuration | Description |
|---------------|-------------|
| **Context7** | Live framework documentation lookups |
| **Playwright** | Browser automation and E2E testing |
| **GitHub** | Read/write PRs, issues, and repos |
| **Filesystem** | Sandboxed project filesystem access |
| **PostgreSQL** | Direct DB introspection for schema and query work |

### Hooks

Event-driven automations enforcing code quality and safety.

| Hook | Event | Behavior |
|------|-------|----------|
| No-verify blocker | PreToolUse (Bash) | **Blocks** `git --no-verify` |
| Destructive command blocker | PreToolUse (Bash) | **Blocks** `rm -rf /`, `DROP DATABASE`, `TRUNCATE TABLE` |
| Migration execution guard | PreToolUse (Bash) | **Warns** when running migration commands |
| File size limit | PreToolUse (Write) | **Blocks** files > 800 lines |
| TODO/FIXME warning | PreToolUse (Edit) | **Warns** on new TODO/FIXME/HACK comments |
| Large diff warning | PreToolUse (Edit) | **Warns** when a single edit adds > 50 lines |
| console.log warning | PostToolUse (Edit) | **Warns** about console.log in edits |
| Test file reminder | PostToolUse (Write) | **Warns** when creating source files without tests |
| Console.log audit | Stop | Checks all modified files for console.log |

---

## Recommended Workflow

```
/plan          → Create implementation plan (approve before coding)
  ↓
/api-design    → Design API contracts if adding endpoints
  ↓
/migrate       → Plan schema changes if touching DB
  ↓
/tdd           → Implement with tests first
  ↓
/build-fix     → Fix any build errors
  ↓
/perf          → Check for performance regressions
  ↓
/code-review   → Full review before committing
  ↓
/checkpoint    → Save progress
  ↓
/changelog     → Update changelog before PR
```

---

## Project Structure

```
claude-starter-kit/
├── CLAUDE.md                    # Project-level instructions for Claude
├── README.md                    # This file
├── agents/                      # Specialized sub-agents (11 total)
│   ├── planner.md
│   ├── architect.md
│   ├── loop-operator.md
│   ├── tdd-guide.md
│   ├── security-reviewer.md
│   ├── devops-engineer.md
│   ├── database-specialist.md
│   ├── performance-engineer.md
│   ├── api-designer.md
│   ├── refactoring-guru.md
│   └── docs-writer.md
├── commands/                    # Slash commands (14 total)
│   ├── plan.md
│   ├── tdd.md
│   ├── build-fix.md
│   ├── code-review.md
│   ├── checkpoint.md
│   ├── docs.md
│   ├── setup-github.md
│   ├── deploy.md
│   ├── migrate.md
│   ├── perf.md
│   ├── refactor.md
│   ├── api-design.md
│   ├── dependency-check.md
│   └── changelog.md
├── skills/                      # Deep workflow knowledge (12 total)
│   ├── tdd-workflow/
│   ├── security-review/
│   ├── codebase-onboarding/
│   ├── semantic-commits/
│   ├── api-design-patterns/
│   ├── database-migrations/
│   ├── cicd-pipelines/
│   ├── error-handling/
│   ├── logging-observability/
│   ├── accessibility/
│   ├── performance-optimization/
│   └── documentation-generation/
├── hooks/                       # Event-driven automations
│   ├── hooks.json               # 9 hooks across PreToolUse, PostToolUse, Stop
│   └── README.md
└── mcp-configs/                 # MCP server configurations (5 servers)
    ├── mcp-servers.json
    └── README.md
```

---

## File Format Reference

### Agents
```yaml
---
name: agent-name
description: What this agent does
tools: ["Read", "Grep", "Glob", "Bash", "Edit", "Write"]
model: opus | sonnet
---
```

### Commands
```yaml
---
description: What this command does when invoked
---
```

### Skills
```yaml
---
name: skill-name
description: When and why to use this skill
---
```

---

## Contributing

1. Follow the file format conventions above
2. Keep files under 800 lines
3. Use lowercase with hyphens for filenames (e.g., `my-agent.md`)
4. Include examples in all agents, commands, and skills
5. Test hooks locally before adding to `hooks.json`

## License

MIT
