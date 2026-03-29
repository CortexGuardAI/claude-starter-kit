---
description: Generate or review deployment configurations (Dockerfile, docker-compose, CI/CD pipelines). Invokes the devops-engineer agent.
---

# /deploy Command

This command invokes the **devops-engineer** agent to generate, review, or improve deployment and infrastructure configurations.

## What This Command Does

1. **Analyzes your project** -- Detects language, framework, and dependencies
2. **Generates configs** -- Dockerfile, docker-compose, or CI/CD pipeline
3. **Reviews existing configs** -- Flags issues and anti-patterns
4. **Documents deployment process** -- Deployment steps and rollback plan

## Usage

```
/deploy [target]
```

### Targets

| Target | Action |
|--------|--------|
| `/deploy dockerfile` | Generate or review Dockerfile |
| `/deploy compose` | Generate or review docker-compose.yml |
| `/deploy github-actions` | Generate GitHub Actions workflow |
| `/deploy gitlab-ci` | Generate GitLab CI pipeline |
| `/deploy review` | Review all existing deployment configs |
| `/deploy` (no target) | Auto-detect what's needed |

## Examples

```
/deploy dockerfile
/deploy github-actions
/deploy review
```

## What Gets Generated

### Dockerfile
- Multi-stage build for minimal image size
- Non-root user for security
- Health check endpoint configuration
- .dockerignore file

### docker-compose.yml
- App, database, cache services
- Named volumes for persistence
- Health check dependencies
- .env.example template

### GitHub Actions
- Validate → Test → Build → Deploy pipeline
- Parallel test execution
- Docker image push on main branch
- Manual approval gate for production

## Important Notes

- **Secrets**: The agent will NEVER hardcode secrets; it will use environment variables and point to your CI secret store
- **Review before applying**: Always review generated configurations before committing
- **Iterative**: Use `/deploy review` to improve existing configs

## Integration

- Use `/plan` first for major infrastructure changes
- Use `/code-review` after applying deployment configs
- Use `/checkpoint` before and after infrastructure changes

## Related

This command uses the `devops-engineer` agent. Source: `agents/devops-engineer.md`
For detailed CI/CD patterns, see skill: `cicd-pipelines`
