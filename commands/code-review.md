---
description: Comprehensive security, quality, performance, accessibility, and API design review of uncommitted changes. Blocks commit on critical issues.
---

# Code Review

Comprehensive review of uncommitted changes across security, quality, performance, accessibility, and API design.

## Step 1: Get Changed Files

```bash
git diff --name-only HEAD
```

## Step 2: Review Each File

### Security Issues (CRITICAL — blocks commit)
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities (string-concatenated queries)
- XSS vulnerabilities (`innerHTML = userInput`)
- Missing input validation
- Path traversal risks
- Missing authentication on routes
- Plaintext password comparison

### Code Quality (HIGH — blocks commit)
- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling (bare try/catch swallowing errors)
- console.log / print / debug statements
- TODO/FIXME comments without linked issue
- Missing documentation for public APIs

### Performance (MEDIUM — warns)
- N+1 database query patterns (loop with DB call inside)
- Missing indexes for newly queried columns
- Unbounded queries (no LIMIT/pagination)
- Large synchronous operations on the event loop
- Bundle imports of entire libraries (`import _ from 'lodash'`)

### API Design (MEDIUM — warns)
- Verb in REST URL path (e.g., `/getUser`)
- Non-RFC-7807 error response format
- Missing pagination on new list endpoints
- Inconsistent naming (camelCase vs snake_case mixed)
- HTTP status codes misused (e.g., 200 for errors)

### Accessibility (MEDIUM — warns, required for UI changes)
- Images missing alt text
- Form inputs without associated labels
- Interactive elements not keyboard-accessible
- Color used as the only way to convey information
- Missing ARIA attributes on custom interactive components

### Best Practices (LOW — advisory)
- Mutation patterns (use immutable instead)
- Missing tests for new code
- Code duplication (copy-paste patterns)
- Naming inconsistencies within the module
- Overly complex logic that could be simplified

## Step 3: Generate Report

For each issue found:
```
[SEVERITY] filename:lineNumber
Issue: <description>
Fix: <specific suggested fix>
```

## Step 4: Verdict

- **CRITICAL or HIGH issues found** → Block commit, fix before proceeding
- **MEDIUM issues found** → Warn clearly, ask developer to confirm intent
- **LOW issues found** → Advisory only, document in report

## Example Report

```
CODE REVIEW REPORT
==================
Files reviewed: 4 | Issues: 6

[CRITICAL] src/auth/login.ts:45
Issue: Password compared with == instead of bcrypt.compare()
Fix: Use bcrypt.compare(inputPassword, user.passwordHash)

[HIGH] src/services/orderService.ts:120
Issue: Function processOrder() is 87 lines
Fix: Extract validateOrder(), calculateTotals(), persistOrder()

[MEDIUM] src/api/orders.ts:34
Issue: GET /api/getOrders — verb in URL
Fix: Rename to GET /api/orders

[MEDIUM] src/api/users.ts:78
Issue: N+1: db.findUser() called inside forEach loop
Fix: Batch-load users before loop with db.findMany({ where: { id: { in: ids } } })

[LOW] src/utils/format.ts:12
Issue: Function duplicated from src/utils/string.ts:45
Fix: Import from existing utility instead of duplicating
```

Never approve code with CRITICAL or HIGH security issues!
