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

## Available Agents

| Agent | Purpose |
|-------|---------|
| `planner` | Creates implementation plans for complex features |
| `architect` | System design, scalability, and architecture decisions |
| `loop-operator` | Runs autonomous loops safely with stop conditions |
| `tdd-guide` | Enforces test-driven development (Red-Green-Refactor) |
| `security-reviewer` | OWASP Top 10 vulnerability detection |

## Available Commands

| Command | Description |
|---------|-------------|
| `/plan` | Create implementation plan (waits for approval) |
| `/tdd` | Test-driven development workflow |
| `/build-fix` | Auto-detect and fix build errors |
| `/code-review` | Security and quality review of changes |
| `/checkpoint` | Create/verify workflow checkpoints |
| `/docs` | Look up library documentation |
| `/setup-github` | Configure GitHub MCP server PAT token |

## Available Skills

| Skill | Description |
|-------|-------------|
| TDD Workflow | Best practices for test-first development |
| Security Review | Checklists and patterns for secure coding |
| Codebase Onboarding | Process for understanding new applications |
| Semantic Commits | Strategy enforcing atomic, conventional commits |

## Environment Variables

<!-- List your project's required environment variables -->
```bash
# Required
DATABASE_URL=
API_KEY=

# Optional
DEBUG=false
```

## MCP Servers

This project includes recommended Model Context Protocol (MCP) configurations in `mcp-configs/mcp-servers.json` for training and extended capabilities. 

To enable live documentation (Context7), browser testing (Playwright), or GitHub integration, copy the JSON blocks to your global `~/.claude.json` file. See `mcp-configs/README.md` for details.

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never commit to main directly
- PRs require review
- All tests must pass before merge
