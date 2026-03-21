---
name: codebase-onboarding
description: Use this skill when starting work on a new or unfamiliar codebase. Provides a systematic discovery process for understanding project structure, patterns, and conventions.
---

# Codebase Onboarding Skill

Systematic approach to understanding and mapping a new codebase quickly.

## When to Activate

- Starting work on a new project
- Joining an existing team's codebase
- Reviewing an open-source project
- Before making significant changes to unfamiliar code

## Discovery Process

### Step 1: Project Identity

Gather basic project information:

```bash
# Check project type and dependencies
cat package.json      # Node.js
cat requirements.txt  # Python (pip)
cat pyproject.toml    # Python (modern)
cat go.mod            # Go
cat Cargo.toml        # Rust
cat pom.xml           # Java (Maven)
cat build.gradle      # Java/Kotlin (Gradle)
```

Document:
- [ ] Project name and description
- [ ] Programming language(s)
- [ ] Framework(s) used
- [ ] Package manager
- [ ] Build system

### Step 2: Architecture Mapping

```bash
# Get top-level structure
ls -la
find . -maxdepth 2 -type d | head -40

# Find entry points
grep -r "main\|app\|index\|server" --include="*.{ts,js,py,go,rs}" -l | head -20

# Find configuration files
find . -name "*.config.*" -o -name "*.json" -o -name "*.yaml" -o -name "*.toml" | grep -v node_modules | head -20
```

Document:
- [ ] Folder structure and purpose of each directory
- [ ] Entry points (main files, app bootstrap)
- [ ] Configuration files and their roles
- [ ] Architecture pattern (MVC, hexagonal, microservices, etc.)

### Step 3: Dependency Analysis

```bash
# Node.js
cat package.json | jq '.dependencies, .devDependencies'

# Python
cat requirements.txt
pip list

# Go
cat go.mod

# Check for key frameworks
grep -r "express\|fastapi\|django\|gin\|actix\|spring" --include="*.{ts,js,py,go,rs,java,kt}" -l | head -10
```

Document:
- [ ] Key dependencies and their purpose
- [ ] Framework version
- [ ] Database driver/ORM
- [ ] Testing framework
- [ ] External service integrations

### Step 4: Code Patterns

```bash
# Find common patterns
grep -r "class \|interface \|type \|struct " --include="*.{ts,js,py,go,rs}" -l | head -20

# Find test files
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" | grep -v node_modules | head -20

# Find API routes/endpoints
grep -r "router\|route\|endpoint\|@app\.\|@Get\|@Post" --include="*.{ts,js,py,go,rs,java,kt}" -l | head -20
```

Document:
- [ ] Coding patterns and conventions
- [ ] Naming conventions (camelCase, snake_case, etc.)
- [ ] Error handling approach
- [ ] Logging strategy
- [ ] Testing patterns

### Step 5: Development Workflow

```bash
# Check for scripts
cat package.json | jq '.scripts'   # Node.js
cat Makefile                        # Make
cat Taskfile.yml                    # Task

# Check for CI/CD
ls .github/workflows/ 2>/dev/null
cat .gitlab-ci.yml 2>/dev/null
```

Document:
- [ ] How to run the project locally
- [ ] How to run tests
- [ ] How to build for production
- [ ] CI/CD pipeline
- [ ] Deployment process

## Output: Project Codemap

Generate a codemap summarizing your findings:

```markdown
# Project Codemap: [Project Name]

## Overview
- **Language**: [Language + version]
- **Framework**: [Framework + version]
- **Database**: [DB + ORM]
- **Testing**: [Test framework]
- **Package Manager**: [npm/pip/cargo/etc.]

## Architecture
[Brief description of architecture pattern]

## Key Directories
| Directory | Purpose |
|-----------|---------|
| `src/` | Main application code |
| `tests/` | Test files |
| `config/` | Configuration |

## Entry Points
- Main: `src/index.ts`
- API: `src/routes/`

## Key Commands
| Command | Purpose |
|---------|---------|
| `npm run dev` | Start dev server |
| `npm test` | Run tests |
| `npm run build` | Build for production |

## Conventions
- [Naming conventions]
- [File organization rules]
- [Error handling patterns]

## External Services
- [Service 1]: [Purpose]
- [Service 2]: [Purpose]
```

## Tips

1. **Start broad, go deep** - Understand the big picture before diving into specifics
2. **Follow the data** - Trace data flow from input to output
3. **Read tests first** - Tests reveal expected behavior
4. **Check git history** - Recent commits show active areas
5. **Look for documentation** - README, CLAUDE.md, docs/ folder

---

**Remember**: Time spent understanding a codebase upfront saves hours of confusion later.
