---
description: Run performance analysis on code, APIs, database queries, or frontend bundles. Identifies bottlenecks and provides optimization recommendations. Invokes the performance-engineer agent.
---

# /perf Command

This command invokes the **performance-engineer** agent to profile and optimize performance across all layers of the application.

## What This Command Does

1. **Profiles the target** -- Measures current performance baseline
2. **Identifies bottlenecks** -- Finds the actual constraint (not guesses)
3. **Recommends fixes** -- Specific, actionable optimizations
4. **Verifies improvement** -- Confirms the optimization worked

## Usage

```
/perf [target]
```

### Targets

| Target | Description |
|--------|-------------|
| `/perf api [endpoint]` | Profile API endpoint latency |
| `/perf db [query or file]` | Analyze database query performance |
| `/perf bundle` | Analyze frontend bundle size |
| `/perf memory` | Check for memory leaks |
| `/perf algorithm [file]` | Review Big-O complexity in code |
| `/perf` (no target) | Full performance audit of changed files |

## Examples

```
/perf api /users
/perf db src/repositories/orderRepository.ts
/perf bundle
/perf algorithm src/utils/searchService.ts
```

## What Gets Analyzed

### API Performance
- Response time (p50, p95, p99)
- Identify N+1 database queries
- Connection pool usage
- Unnecessary data in responses

### Database Performance
- Slow query identification via EXPLAIN ANALYZE
- Missing index detection
- N+1 pattern detection in ORM code
- Connection pool configuration

### Frontend Performance
- Bundle size per route (code splitting opportunities)
- Core Web Vitals (LCP, INP, CLS)
- Image optimization opportunities
- Render-blocking resources

### Algorithmic Complexity
- Big-O analysis of critical loops
- Data structure selection review
- Memoization opportunities

## Output Format

The agent produces a report:

```
PERFORMANCE ANALYSIS
====================
Target: /api/orders
Baseline: 450ms avg (p95: 890ms)

BOTTLENECKS FOUND:
1. [HIGH] N+1 query: 1 + N queries for order items
   Location: src/services/orderService.ts:45
   Fix: Use include/join in Prisma query
   Expected improvement: 350ms -> 50ms

2. [MEDIUM] Missing index on orders.status column
   Fix: CREATE INDEX CONCURRENTLY idx_orders_status ON orders(status)
   Expected improvement: 100ms -> 10ms

RECOMMENDED ACTION PLAN:
Step 1: Fix N+1 query (30 min effort, ~80% improvement)
Step 2: Add missing index (5 min effort, ~12% improvement)
```

## Integration

- Run `/perf` after `/tdd` to catch performance regressions
- Add performance benchmarks to CI/CD pipeline
- Use `/checkpoint` before and after optimizations

## Related

This command uses the `performance-engineer` agent. Source: `agents/performance-engineer.md`
For detailed optimization patterns, see skill: `performance-optimization`
