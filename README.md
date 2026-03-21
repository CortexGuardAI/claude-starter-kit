# Claude Code Starter Kit

A production-ready boilerplate for supercharging your development workflow with Claude Code. Includes battle-tested agents, slash commands, skills, and hooks that work with any tech stack.

## Quick Start

### Option 1: Zero-Install (Recommended)

Instantly initialize any new or existing project with this starter kit by running a single command inside your project directory (macOS & Linux):

> **Note**: Update `your-org` and `claude-starter-kit` in the URL to match your fork's destination before providing this to your team!

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/claude-starter-kit/main/init.sh | bash
```

### Option 2: Clone and customize

```bash
git clone https://github.com/your-org/claude-starter-kit.git my-project
cd my-project
```

### Option 3: Copy into existing project

```bash
# Create the .claude directory if it doesn't exist
mkdir -p /path/to/your/project/.claude

# Copy the folders into your project's .claude folder
cp -r agents/ commands/ skills/ hooks/ /path/to/your/project/.claude/

# Copy CLAUDE.md to your project root
cp CLAUDE.md /path/to/your/project/
```

Then edit `CLAUDE.md` to match your project's specifics.

## What's Included

### Agents

Specialized sub-agents that Claude delegates to for specific tasks.

| Agent | File | Description |
|-------|------|-------------|
| **Planner** | `agents/planner.md` | Creates detailed implementation plans with phased steps, risk assessment, and testing strategy |
| **Architect** | `agents/architect.md` | System design, trade-off analysis, ADR templates, and scalability planning |
| **Loop Operator** | `agents/loop-operator.md` | Runs autonomous fix/refactor loops with safety controls, checkpoints, and escalation |
| **TDD Guide** | `agents/tdd-guide.md` | Enforces Red-Green-Refactor cycle with 80%+ coverage across unit, integration, and E2E tests |
| **Security Reviewer** | `agents/security-reviewer.md` | OWASP Top 10 detection, secrets scanning, input validation, and dependency auditing |

### Commands

Slash commands you invoke directly (e.g., `/plan`, `/tdd`).

| Command | File | Description |
|---------|------|-------------|
| `/plan` | `commands/plan.md` | Analyze requirements, create step-by-step plan, wait for approval before coding |
| `/tdd` | `commands/tdd.md` | Scaffold interfaces, write tests first, implement, refactor, verify coverage |
| `/build-fix` | `commands/build-fix.md` | Auto-detect build system, parse errors, fix one at a time with guardrails |
| `/code-review` | `commands/code-review.md` | Review uncommitted changes for security (CRITICAL), quality (HIGH), practices (MEDIUM) |
| `/checkpoint` | `commands/checkpoint.md` | Create/verify git-based workflow checkpoints with state comparison |
| `/docs` | `commands/docs.md` | Look up current documentation for any library via Context7 MCP |

### Skills

Deep workflow knowledge that Claude activates automatically when relevant.

| Skill | Directory | Description |
|-------|-----------|-------------|
| **TDD Workflow** | `skills/tdd-workflow/` | Testing patterns, mocking strategies, coverage verification, and common mistakes |
| **Security Review** | `skills/security-review/` | Secrets management, input validation, SQL injection prevention, pre-deployment checklist |
| **Codebase Onboarding** | `skills/codebase-onboarding/` | Systematic discovery process for mapping and understanding new codebases |

### MCP Configurations

Pre-configured Model Context Protocol servers to give Claude Code live access to external data. See `mcp-configs/README.md` for setup instructions.

| Configuration | Description |
|---------------|-------------|
| **Context7** | Live framework documentation lookups using `@upstash/context7-mcp` |
| **Playwright** | Browser automation and E2E testing using `@playwright/mcp` |
| **GitHub** | Read/write PRs, issues, and repos using `@modelcontextprotocol/server-github` |

### Hooks

Event-driven automations that run before/after Claude's tool executions.

| Hook | Event | Behavior |
|------|-------|----------|
| No-verify blocker | PreToolUse (Bash) | **Blocks** `git --no-verify` to protect pre-commit hooks |
| File size limit | PreToolUse (Write) | **Blocks** creation of files > 800 lines |
| TODO/FIXME warning | PreToolUse (Edit) | **Warns** when adding TODO/FIXME/HACK comments |
| console.log warning | PostToolUse (Edit) | **Warns** about console.log in edited code |
| Test file reminder | PostToolUse (Write) | **Warns** when creating source files without tests |
| Console.log audit | Stop | Checks all modified files for console.log |

## Project Structure

```
claude-starter-kit/
├── CLAUDE.md              # Project-level instructions for Claude
├── README.md              # This file
├── agents/                # Specialized sub-agents
│   ├── planner.md
│   ├── architect.md
│   ├── loop-operator.md
│   ├── tdd-guide.md
│   └── security-reviewer.md
├── commands/              # Slash commands
│   ├── plan.md
│   ├── tdd.md
│   ├── build-fix.md
│   ├── code-review.md
│   ├── checkpoint.md
│   └── docs.md
├── skills/                # Deep workflow knowledge
│   ├── tdd-workflow/
│   │   └── SKILL.md
│   ├── security-review/
│   │   └── SKILL.md
│   └── codebase-onboarding/
│       └── SKILL.md
└── hooks/                 # Event-driven automations
    ├── hooks.json
    └── README.md
```

## File Format Reference

### Agents
Markdown with YAML frontmatter:
```yaml
---
name: agent-name
description: What this agent does
tools: ["Read", "Grep", "Glob", "Bash", "Edit", "Write"]
model: opus | sonnet
---
```

### Commands
Markdown with YAML frontmatter:
```yaml
---
description: What this command does when invoked
---
```

### Skills
Markdown with YAML frontmatter in a `SKILL.md` file inside a named directory:
```yaml
---
name: skill-name
description: When and why to use this skill
---
```

### Hooks
JSON configuration in `hooks.json`:
```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...]
  }
}
```

## Customization Guide

### Adding a New Agent

1. Create `agents/your-agent.md`
2. Add YAML frontmatter (`name`, `description`, `tools`, `model`)
3. Define the agent's role, workflow, and output format
4. Reference it from your commands

### Adding a New Command

1. Create `commands/your-command.md`
2. Add YAML frontmatter (`description`)
3. Document usage, workflow, and examples
4. Reference related agents and skills

### Adding a New Skill

1. Create `skills/your-skill/SKILL.md`
2. Add YAML frontmatter (`name`, `description`)
3. Include "When to Activate" section
4. Provide detailed patterns, checklists, and examples

### Adding a New Hook

1. Edit `hooks/hooks.json`
2. Add entry to appropriate event (`PreToolUse`, `PostToolUse`, `Stop`)
3. Set the `matcher` (tool name pattern)
4. Write the hook command (receives JSON on stdin, outputs JSON on stdout)
5. Use exit code `2` to block (PreToolUse only), stderr to warn

## Recommended Workflow

```
1. /plan          --> Create implementation plan
2. Review         --> Approve or modify the plan
3. /tdd           --> Implement with tests first
4. /checkpoint    --> Save progress
5. /build-fix     --> Fix any build errors
6. /code-review   --> Review before committing
7. /checkpoint    --> Verify final state
```

## Contributing

1. Follow the file format conventions above
2. Keep files under 800 lines
3. Use lowercase with hyphens for filenames (e.g., `my-agent.md`)
4. Include examples in all agents, commands, and skills
5. Test hooks locally before adding to `hooks.json`

## License

MIT
