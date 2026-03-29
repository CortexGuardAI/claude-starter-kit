---
name: error-handling
description: Use this skill when implementing error handling, creating custom error classes, designing retry logic, or working with async operations. Provides consistent patterns for user-facing and internal error separation, circuit breakers, and graceful degradation.
---

# Error Handling Skill

Comprehensive patterns for predictable, resilient error handling across all layers of an application.

## When to Activate

- Implementing try/catch blocks or error boundaries
- Creating custom error classes or types
- Designing retry logic for flaky operations
- Building resilient external API integrations
- Handling async/await error flows
- Deciding what to show users vs what to log internally

---

## Core Principles

1. **Fail visibly, internally** -- Log full details internally; show sanitized messages to users
2. **Never swallow errors** -- Every caught error must be logged or re-thrown
3. **Type your errors** -- Named error classes make error handling predictable
4. **Recover or propagate** -- Know which errors you can handle vs which to let bubble up
5. **Expect failure** -- All I/O operations (DB, network, file) CAN and WILL fail

---

## Custom Error Classes

### TypeScript
```typescript
// Base application error
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly isOperational: boolean = true  // operational = expected, non-operational = bug
  ) {
    super(message)
    this.name = this.constructor.name
    Error.captureStackTrace(this, this.constructor)
  }
}

// Domain-specific errors
export class ValidationError extends AppError {
  constructor(message: string, public readonly fields?: Record<string, string>) {
    super(message, 'VALIDATION_ERROR', 422)
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} with id '${id}' not found`, 'NOT_FOUND', 404)
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 'UNAUTHORIZED', 401)
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Access denied') {
    super(message, 'FORBIDDEN', 403)
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 'CONFLICT', 409)
  }
}

export class ExternalServiceError extends AppError {
  constructor(service: string, cause: Error) {
    super(`External service '${service}' failed: ${cause.message}`, 'EXTERNAL_SERVICE_ERROR', 502, true)
    this.cause = cause
  }
}
```

### Python
```python
class AppError(Exception):
    def __init__(self, message: str, code: str, status_code: int = 500):
        super().__init__(message)
        self.code = code
        self.status_code = status_code

class ValidationError(AppError):
    def __init__(self, message: str, fields: dict = None):
        super().__init__(message, "VALIDATION_ERROR", 422)
        self.fields = fields or {}

class NotFoundError(AppError):
    def __init__(self, resource: str, resource_id: str):
        super().__init__(f"{resource} '{resource_id}' not found", "NOT_FOUND", 404)

class UnauthorizedError(AppError):
    def __init__(self, message: str = "Authentication required"):
        super().__init__(message, "UNAUTHORIZED", 401)
```

---

## Global Error Handler (Express / Node.js)

```typescript
import { Request, Response, NextFunction } from 'express'
import { AppError } from './errors'
import { logger } from './logger'

export function globalErrorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  // Known operational error
  if (err instanceof AppError && err.isOperational) {
    logger.warn('Operational error', {
      code: err.code,
      message: err.message,
      path: req.path,
      method: req.method,
    })

    res.status(err.statusCode).json({
      type: `https://errors.example.com/${err.code.toLowerCase().replace(/_/g, '-')}`,
      title: err.name,
      status: err.statusCode,
      detail: err.message,
      instance: req.path,
      ...(err instanceof ValidationError && err.fields
        ? { errors: Object.entries(err.fields).map(([field, message]) => ({ field, message })) }
        : {}),
    })
    return
  }

  // Unknown / programming error -- log full details, return generic message
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  })

  res.status(500).json({
    type: 'https://errors.example.com/internal-error',
    title: 'Internal Server Error',
    status: 500,
    detail: 'An unexpected error occurred. Please try again later.',
  })
}

// Catch unhandled rejections
process.on('unhandledRejection', (reason: Error) => {
  logger.error('Unhandled Promise Rejection', { error: reason.message, stack: reason.stack })
  process.exit(1) // fail loudly -- let process manager (PM2, k8s) restart
})

process.on('uncaughtException', (err: Error) => {
  logger.error('Uncaught Exception', { error: err.message, stack: err.stack })
  process.exit(1)
})
```

---

## Async Error Patterns

### Service Layer (Repository Pattern)
```typescript
// Wrap external calls and convert to domain errors
class UserService {
  async findById(id: string): Promise<User> {
    try {
      const user = await this.userRepo.findById(id)
      if (!user) throw new NotFoundError('User', id)
      return user
    } catch (err) {
      if (err instanceof AppError) throw err  // re-throw known errors
      // Wrap unknown errors
      throw new ExternalServiceError('database', err as Error)
    }
  }
}
```

### Retry with Exponential Backoff
```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxAttempts?: number; baseDelayMs?: number; shouldRetry?: (err: Error) => boolean } = {}
): Promise<T> {
  const { maxAttempts = 3, baseDelayMs = 200, shouldRetry = () => true } = options

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn()
    } catch (err) {
      const isLast = attempt === maxAttempts
      if (isLast || !shouldRetry(err as Error)) throw err

      const delay = baseDelayMs * Math.pow(2, attempt - 1) + Math.random() * 100
      logger.warn(`Attempt ${attempt}/${maxAttempts} failed, retrying in ${Math.round(delay)}ms`, {
        error: (err as Error).message,
      })
      await new Promise(r => setTimeout(r, delay))
    }
  }
  throw new Error('Max retries exceeded') // TypeScript satisfaction -- never reached
}

// Usage
const user = await withRetry(
  () => externalApi.getUser(userId),
  {
    maxAttempts: 3,
    shouldRetry: (err) => err instanceof ExternalServiceError && err.statusCode >= 500
  }
)
```

### Circuit Breaker (Graceful Degradation)
```typescript
class CircuitBreaker {
  private failures = 0
  private lastFailureTime = 0
  private state: 'closed' | 'open' | 'half-open' = 'closed'

  constructor(
    private readonly threshold: number = 5,
    private readonly resetTimeMs: number = 30_000
  ) {}

  async execute<T>(fn: () => Promise<T>, fallback?: () => T): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailureTime > this.resetTimeMs) {
        this.state = 'half-open'
      } else {
        if (fallback) return fallback()
        throw new ExternalServiceError('circuit-breaker', new Error('Circuit is open'))
      }
    }

    try {
      const result = await fn()
      if (this.state === 'half-open') this.reset()
      return result
    } catch (err) {
      this.recordFailure()
      throw err
    }
  }

  private recordFailure() {
    this.failures++
    this.lastFailureTime = Date.now()
    if (this.failures >= this.threshold) this.state = 'open'
  }

  private reset() {
    this.failures = 0
    this.state = 'closed'
  }
}
```

---

## React Error Boundaries
```tsx
class ErrorBoundary extends React.Component<
  { fallback: React.ReactNode; children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    // Log to error tracking service
    errorTracker.captureException(error, { extra: info })
  }

  render() {
    if (this.state.hasError) return this.props.fallback
    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={<ErrorPage />}>
  <UserProfile />
</ErrorBoundary>
```

---

## Error Handling Checklist

- [ ] Custom error classes defined for domain errors
- [ ] Global error handler catches all unhandled errors
- [ ] User-facing messages are generic (no stack traces, no internals)
- [ ] Internal details are logged with full context (stack, request ID, user ID)
- [ ] Async operations always have try/catch or `.catch()`
- [ ] External service calls have retry logic with backoff
- [ ] `unhandledRejection` and `uncaughtException` are handled at process level
- [ ] Errors are typed and distinguished (operational vs programming)
- [ ] Error responses follow RFC 7807 format
- [ ] Circuit breakers protect unstable external dependencies
