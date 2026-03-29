---
name: logging-observability
description: Use this skill when implementing logging, setting up monitoring, or designing observability. Ensures structured logs, no PII/secrets in logs, correlation IDs, and production-ready metrics.
---

# Logging & Observability Skill

## When to Activate

- Implementing logging in a new service or endpoint
- Reviewing logging for PII, secrets, or sensitive data
- Adding metrics or tracing to a service
- Debugging production issues with insufficient logging

---

## Log Levels

| Level | When to Use | Examples |
|-------|------------|---------|
| `ERROR` | Something failed, needs attention | Uncaught exceptions, DB down |
| `WARN` | Unexpected but recoverable | Retry succeeded, slow query |
| `INFO` | Normal business events | User signed in, order created |
| `DEBUG` | Dev/troubleshooting only | Variable values (disabled in prod) |

---

## Structured Logging Setup

### Node.js with Pino
```typescript
// src/logger.ts
import pino from 'pino'

export const logger = pino({
  level: process.env.LOG_LEVEL ?? (process.env.NODE_ENV === 'production' ? 'info' : 'debug'),
  ...(process.env.NODE_ENV !== 'production' && {
    transport: { target: 'pino-pretty', options: { colorize: true } }
  }),
  base: {
    service: process.env.SERVICE_NAME ?? 'app',
    env: process.env.NODE_ENV,
  },
  redact: {
    paths: ['*.password', '*.token', '*.secret', '*.apiKey', '*.creditCard'],
    censor: '[REDACTED]'
  }
})

// Usage
logger.info({ userId: 'u_123', orderId: 'ord_456' }, 'Order created')
logger.error({ err: error, userId: 'u_123' }, 'Failed to create order')
```

### Python with structlog
```python
import structlog

structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
)
log = structlog.get_logger()
log.info("order_created", user_id="u_123", order_id="ord_456", amount=99.99)
```

---

## Correlation IDs

Every request must carry a unique ID through all downstream calls.

```typescript
// Express middleware
import { randomUUID } from 'crypto'
import { AsyncLocalStorage } from 'async_hooks'

const storage = new AsyncLocalStorage<{ requestId: string; userId?: string }>()

export function correlationMiddleware(req: Request, res: Response, next: NextFunction) {
  const requestId = (req.headers['x-request-id'] as string) ?? randomUUID()
  res.setHeader('x-request-id', requestId)
  storage.run({ requestId }, next)
}

export function getLogger() {
  return logger.child(storage.getStore() ?? {})
}

// Usage in any handler — requestId is automatic
const log = getLogger()
log.info({ userId }, 'Processing order')
```

---

## What NEVER to Log

```typescript
// WRONG
logger.info({ email, password, token }, 'User login')
logger.info(`Payment for card ${creditCardNumber}`)

// CORRECT
logger.info({ userId, email: maskEmail(email) }, 'User login')
logger.info({ userId, paymentMethodId }, 'Payment processed')

function maskEmail(email: string): string {
  const [user, domain] = email.split('@')
  return `${user.slice(0, 2)}***@${domain}`
}
```

**Never log:** passwords, password hashes, API keys, tokens, secrets, full credit card numbers, SSNs, full session IDs, or health/medical data.

---

## Production Log Format (JSON)

```json
{
  "level": "info",
  "time": "2024-03-15T12:00:00.000Z",
  "service": "order-service",
  "requestId": "req_f7a9c3e1",
  "userId": "u_abc123",
  "msg": "Order created successfully",
  "orderId": "ord_xyz789",
  "durationMs": 145
}
```

---

## Performance Logging

```typescript
export async function withTiming<T>(
  name: string,
  fn: () => Promise<T>,
  warnThresholdMs = 500
): Promise<T> {
  const start = Date.now()
  try {
    const result = await fn()
    const durationMs = Date.now() - start
    const log = getLogger()
    if (durationMs > warnThresholdMs) {
      log.warn({ operation: name, durationMs }, 'Slow operation')
    } else {
      log.debug({ operation: name, durationMs }, 'Operation completed')
    }
    return result
  } catch (err) {
    getLogger().error({ operation: name, durationMs: Date.now() - start, err }, 'Operation failed')
    throw err
  }
}

// Usage
const user = await withTiming('db.user.findById', () => db.user.findById(id))
```

---

## Prometheus Metrics

```typescript
import { Counter, Histogram } from 'prom-client'

const httpDuration = new Histogram({
  name: 'http_request_duration_seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5]
})

const httpTotal = new Counter({
  name: 'http_requests_total',
  labelNames: ['method', 'route', 'status_code']
})

// Middleware
export function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const end = httpDuration.startTimer()
  res.on('finish', () => {
    const labels = { method: req.method, route: req.route?.path ?? req.path, status_code: res.statusCode }
    end(labels)
    httpTotal.inc(labels)
  })
  next()
}

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType)
  res.send(await register.metrics())
})
```

---

## Observability Checklist

### Logging
- [ ] Structured JSON logging configured (not console.log)
- [ ] Log level correct per environment (info in prod, debug in dev)
- [ ] PII and secrets redacted from all logs
- [ ] Correlation IDs on all requests and propagated downstream
- [ ] Slow operations logged with duration
- [ ] Errors logged with full context (stack, request ID, user ID)
- [ ] `unhandledRejection` / `uncaughtException` logged and process exits

### Metrics
- [ ] Request rate, error rate, latency collected (RED metrics)
- [ ] Business metrics tracked (orders, payments, signups)
- [ ] `/metrics` endpoint exposed for Prometheus scraping

### Alerting
- [ ] Error rate spike alert configured
- [ ] p99 latency alert configured
- [ ] Availability (uptime) alert configured
- [ ] Business metric anomaly alert configured

---

**Remember**: Logs are your eyes in production. Structure them for machines to parse and humans to read.
