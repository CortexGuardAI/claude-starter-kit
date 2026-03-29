---
name: performance-optimization
description: Use this skill when pages load slowly, APIs have high latency, bundle sizes are large, memory usage grows unboundedly, or database queries are slow. Provides profiling guidance, caching strategies, and frontend/backend optimization patterns.
---

# Performance Optimization Skill

## When to Activate

- API response time is above acceptable thresholds (> 200ms p95)
- Frontend Core Web Vitals are failing (LCP > 2.5s, INP > 200ms, CLS > 0.1)
- Bundle size is too large (> 200KB initial JS)
- Database queries are slow (> 100ms)
- Memory grows unboundedly (likely leak)
- Preparing for a load test or traffic spike

---

## Core Rule: Measure First

**Never optimize without data.** Profile before and after every change.

```bash
# API latency
curl -w "\n\nTime: %{time_total}s\nConnect: %{time_connect}s\nResponse: %{time_starttransfer}s\n" \
  -o /dev/null -s http://localhost:3000/api/orders

# Node.js CPU profiling
node --prof src/index.js
node --prof-process isolate-*.log > profile.txt

# Python profiling
python -m cProfile -o output.prof main.py && python -m pstats output.prof

# Frontend: Lighthouse
npx lighthouse http://localhost:3000 --view
```

---

## Algorithmic Complexity

Fix Big-O problems before any infrastructure optimization.

```typescript
// O(n²) — SLOW for large arrays
const result = users.map(user => ({
  ...user,
  orders: orders.filter(o => o.userId === user.id)
}))

// O(n) — index once, look up in O(1)
const byUserId = new Map<string, Order[]>()
for (const order of orders) {
  if (!byUserId.has(order.userId)) byUserId.set(order.userId, [])
  byUserId.get(order.userId)!.push(order)
}
const result = users.map(user => ({ ...user, orders: byUserId.get(user.id) ?? [] }))
```

| Pattern | Complexity | Fix |
|---------|-----------|-----|
| Nested loops over same array | O(n²) | Map/Set for O(1) lookup |
| Array.find inside loop | O(n²) | Pre-index with Map |
| Sorting every request | O(n log n) | Cache sorted result |
| Recursive without memo | O(2^n) | Memoize or use DP |
| Load all rows, filter in memory | O(n) | Filter at DB with WHERE |

---

## Database Performance

```sql
-- Find slow queries (PostgreSQL)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC LIMIT 10;

-- Analyze a specific query
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM orders WHERE user_id = $1;

-- Check missing indexes
SELECT attname, n_distinct FROM pg_stats WHERE tablename = 'orders';

-- Check index usage (low idx_scan = possibly unused)
SELECT indexrelname, idx_scan FROM pg_stat_user_indexes WHERE relname = 'orders';
```

**Index rules:**
- Index columns in WHERE, JOIN, ORDER BY
- Use `CREATE INDEX CONCURRENTLY` on large tables (no locking)
- Partial indexes for filtered queries (e.g., `WHERE status = 'active'`)
- Covering indexes (`INCLUDE`) to avoid heap fetches

```sql
-- Partial index: only active sessions
CREATE INDEX CONCURRENTLY idx_sessions_active
  ON sessions(user_id, expires_at) WHERE revoked_at IS NULL;

-- Covering index: avoid table lookup
CREATE INDEX CONCURRENTLY idx_orders_user_covering
  ON orders(user_id) INCLUDE (total_amount, created_at, status);
```

---

## Caching Strategy

### Cache Decision Matrix

| Data | Freshness | Strategy | TTL |
|------|-----------|---------|-----|
| User session | High | Redis, short TTL | 15min |
| User profile | Medium | Redis | 5min |
| Product catalog | Low | Redis + CDN | 1hr |
| Static assets | Very low | CDN + immutable | 1yr |
| API rate limits | Real-time | Redis sliding window | 1min |

### Redis Cache Pattern (Cache-Aside)
```typescript
async function getProduct(id: string): Promise<Product> {
  const key = `product:${id}`
  const cached = await redis.get(key)
  if (cached) return JSON.parse(cached)

  const product = await db.products.findById(id)
  if (!product) throw new NotFoundError('Product', id)

  await redis.setex(key, 3600, JSON.stringify(product)) // 1hr TTL
  return product
}

// Invalidate on write
async function updateProduct(id: string, data: Partial<Product>) {
  const product = await db.products.update({ where: { id }, data })
  await redis.del(`product:${id}`)
  return product
}
```

---

## Frontend Performance

### Core Web Vitals Targets

| Metric | Good | Poor |
|--------|------|------|
| LCP (Largest Contentful Paint) | < 2.5s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.25 |

### Bundle Size

```bash
# Analyze bundle
npx webpack-bundle-analyzer
# Vite:
npx vite-bundle-visualizer

# Find large dependencies
npx bundlephobia package-name
```

**Proven reductions:**
- `moment` → `date-fns` (saves ~67KB gzipped)
- `lodash` → native ES6 (saves ~25KB)
- `axios` → `fetch` native (saves ~13KB)
- Dynamic `import()` for route-level code splitting

```typescript
// Route-level code splitting (React)
const Dashboard = React.lazy(() => import('./pages/Dashboard'))
const Settings  = React.lazy(() => import('./pages/Settings'))

<Suspense fallback={<Spinner />}>
  <Routes>
    <Route path="/dashboard" element={<Dashboard />} />
    <Route path="/settings"  element={<Settings />} />
  </Routes>
</Suspense>

// Lazy-load heavy components
const HeavyChart = React.lazy(() => import('./components/HeavyChart'))
```

### Image Optimization
```html
<!-- Modern formats with fallback -->
<picture>
  <source srcset="hero.avif" type="image/avif" />
  <source srcset="hero.webp" type="image/webp" />
  <img src="hero.jpg" alt="..." loading="lazy" decoding="async"
       width="1200" height="630" />
</picture>

<!-- Eager-load above-the-fold images (LCP) -->
<img src="hero.jpg" alt="..." loading="eager" fetchpriority="high" />
```

---

## Memory Leak Patterns

```typescript
// Leak 1: Event listeners not removed
// WRONG
useEffect(() => {
  window.addEventListener('resize', handler)
}, [])

// CORRECT
useEffect(() => {
  window.addEventListener('resize', handler)
  return () => window.removeEventListener('resize', handler)
}, [])

// Leak 2: Intervals not cleared
// WRONG
setInterval(poll, 5000)

// CORRECT
const id = setInterval(poll, 5000)
return () => clearInterval(id)

// Leak 3: Closure holding large object
// WRONG
function process(largeData: LargeType[]) {
  return () => largeData.reduce(...)  // largeData never freed
}

// CORRECT — extract only what's needed
function process(largeData: LargeType[]) {
  const sum = largeData.reduce(...)
  return () => sum  // smallData, not largeData
}
```

---

## Performance Checklist

### Backend
- [ ] Critical endpoints profiled under load
- [ ] No N+1 database queries
- [ ] Indexes on all queried columns
- [ ] Connection pooling configured (PgBouncer, HikariCP)
- [ ] Redis caching for read-heavy data
- [ ] Pagination on all list endpoints (never unbounded queries)

### Frontend
- [ ] Lighthouse score ≥ 90 on simulated 3G
- [ ] LCP element identified and preloaded
- [ ] No render-blocking resources
- [ ] Bundle size analyzed (< 200KB initial JS gzipped target)
- [ ] Code splitting on routes
- [ ] Images lazy-loaded and in modern formats (avif/webp)

### Memory
- [ ] No uncleaned event listeners (useEffect cleanup)
- [ ] No uncleaned timers/intervals
- [ ] Heap snapshot taken without continuous growth

---

**Remember**: Make it work, make it right, make it fast — in that order.
