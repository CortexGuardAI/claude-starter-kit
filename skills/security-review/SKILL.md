---
name: security-review
description: Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Provides comprehensive security checklist and patterns.
---

# Security Review Skill

This skill ensures all code follows security best practices and identifies potential vulnerabilities.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

## Security Checklist

### 1. Secrets Management

**NEVER** hardcode secrets:
```
# BAD
API_KEY = "sk-proj-xxxxx"
DB_PASSWORD = "password123"

# GOOD
API_KEY = os.environ["API_KEY"]          # Python
apiKey = process.env.API_KEY             // Node.js
apiKey := os.Getenv("API_KEY")           // Go
```

Verification:
- [ ] No hardcoded API keys, tokens, or passwords
- [ ] All secrets in environment variables
- [ ] `.env` / `.env.local` in `.gitignore`
- [ ] No secrets in git history

### 2. Input Validation

Always validate user input at the boundary:

```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})

export async function createUser(input: unknown) {
  const validated = CreateUserSchema.parse(input)
  return await db.users.create(validated)
}
```

Verification:
- [ ] All user inputs validated with schemas
- [ ] File uploads restricted (size, type, extension)
- [ ] No direct use of user input in queries
- [ ] Whitelist validation (not blacklist)
- [ ] Error messages don't leak sensitive info

### 3. SQL Injection Prevention

```typescript
// DANGEROUS - SQL Injection
const query = `SELECT * FROM users WHERE email = '${userEmail}'`

// SAFE - Parameterized query
const { data } = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [userEmail]
)
```

Verification:
- [ ] All database queries use parameterized queries
- [ ] No string concatenation in SQL
- [ ] ORM/query builder used correctly

### 4. Authentication & Authorization

```typescript
// Tokens in httpOnly cookies, NOT localStorage
res.setHeader('Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`)

// ALWAYS verify authorization first
if (requester.role !== 'admin') {
  return { status: 403, error: 'Unauthorized' }
}
```

Verification:
- [ ] Tokens stored in httpOnly cookies (not localStorage)
- [ ] Authorization checks before sensitive operations
- [ ] Role-based access control implemented
- [ ] Session management secure

### 5. XSS Prevention

- Sanitize user-provided HTML (DOMPurify or equivalent)
- Set Content Security Policy (CSP) headers
- Use framework auto-escaping

Verification:
- [ ] User-provided HTML sanitized
- [ ] CSP headers configured
- [ ] No unvalidated dynamic content rendering

### 6. CSRF Protection

- Use CSRF tokens on state-changing operations
- Set `SameSite=Strict` on cookies

### 7. Rate Limiting

```typescript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,                  // 100 requests per window
  message: 'Too many requests'
})
```

Verification:
- [ ] Rate limiting on all API endpoints
- [ ] Stricter limits on expensive operations

### 8. Sensitive Data Exposure

```typescript
// WRONG: Logging sensitive data
console.log('User login:', { email, password })

// CORRECT: Redact sensitive data
console.log('User login:', { email, userId })
```

Verification:
- [ ] No passwords, tokens, or secrets in logs
- [ ] Error messages generic for users
- [ ] No stack traces exposed to users

## Critical Patterns to Flag

| Pattern | Severity | Fix |
|---------|----------|-----|
| Hardcoded secrets | CRITICAL | Use environment variables |
| Shell command with user input | CRITICAL | Use safe APIs |
| String-concatenated SQL | CRITICAL | Parameterized queries |
| `innerHTML = userInput` | HIGH | Use textContent or sanitizer |
| `fetch(userProvidedUrl)` | HIGH | Whitelist allowed domains |
| Plaintext password comparison | CRITICAL | Use bcrypt/argon2 |
| No auth check on route | CRITICAL | Add auth middleware |
| No rate limiting | HIGH | Add rate limiter |

## Pre-Deployment Checklist

Before ANY production deployment:

- [ ] **Secrets**: No hardcoded secrets, all in env vars
- [ ] **Input Validation**: All user inputs validated
- [ ] **SQL Injection**: All queries parameterized
- [ ] **XSS**: User content sanitized
- [ ] **CSRF**: Protection enabled
- [ ] **Authentication**: Proper token handling
- [ ] **Authorization**: Role checks in place
- [ ] **Rate Limiting**: Enabled on all endpoints
- [ ] **HTTPS**: Enforced in production
- [ ] **Security Headers**: CSP, X-Frame-Options configured
- [ ] **Error Handling**: No sensitive data in errors
- [ ] **Logging**: No sensitive data logged
- [ ] **Dependencies**: Up to date, no vulnerabilities

---

**Remember**: Security is not optional. One vulnerability can compromise the entire platform.
