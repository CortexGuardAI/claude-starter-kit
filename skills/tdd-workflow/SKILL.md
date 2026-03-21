---
name: tdd-workflow
description: Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
---

# Test-Driven Development Workflow

This skill ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

### 1. Tests BEFORE Code
ALWAYS write tests first, then implement code to make tests pass.

### 2. Coverage Requirements
- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

### 3. Test Types

#### Unit Tests
- Individual functions and utilities
- Component logic
- Pure functions
- Helpers and utilities

#### Integration Tests
- API endpoints
- Database operations
- Service interactions
- External API calls

#### E2E Tests
- Critical user flows
- Complete workflows
- Browser automation
- UI interactions

## TDD Workflow Steps

### Step 1: Write User Journeys
```
As a [role], I want to [action], so that [benefit]
```

### Step 2: Generate Test Cases
For each user journey, create comprehensive test cases covering:
- Happy path
- Edge cases (null, empty, invalid)
- Error conditions
- Boundary values

### Step 3: Run Tests (They Should Fail)
```bash
# Run with your project's test framework
npm test              # Node.js (Jest/Vitest)
pytest                # Python
go test ./...         # Go
cargo test            # Rust
dotnet test           # .NET
```

### Step 4: Implement Code
Write minimal code to make tests pass.

### Step 5: Run Tests Again
Verify all tests pass.

### Step 6: Refactor
Improve code quality while keeping tests green:
- Remove duplication
- Improve naming
- Optimize performance
- Enhance readability

### Step 7: Verify Coverage
```bash
npm run test:coverage          # Node.js
pytest --cov                   # Python
go test -coverprofile=c.out    # Go
cargo tarpaulin                # Rust
```

## Testing Patterns

### Unit Test Pattern
```typescript
describe('calculateTotal', () => {
  it('sums items correctly', () => {
    const items = [{ price: 10 }, { price: 20 }]
    expect(calculateTotal(items)).toBe(30)
  })

  it('returns 0 for empty array', () => {
    expect(calculateTotal([])).toBe(0)
  })

  it('handles negative prices', () => {
    const items = [{ price: 10 }, { price: -5 }]
    expect(calculateTotal(items)).toBe(5)
  })
})
```

### API Integration Test Pattern
```typescript
describe('GET /api/users', () => {
  it('returns users successfully', async () => {
    const response = await request(app).get('/api/users')
    expect(response.status).toBe(200)
    expect(Array.isArray(response.body.data)).toBe(true)
  })

  it('validates query parameters', async () => {
    const response = await request(app).get('/api/users?limit=invalid')
    expect(response.status).toBe(400)
  })

  it('handles database errors gracefully', async () => {
    // Mock database failure
    jest.spyOn(db, 'query').mockRejectedValueOnce(new Error('DB down'))
    const response = await request(app).get('/api/users')
    expect(response.status).toBe(500)
  })
})
```

### E2E Test Pattern (Playwright)
```typescript
import { test, expect } from '@playwright/test'

test('user can complete signup flow', async ({ page }) => {
  await page.goto('/signup')
  await page.fill('input[name="email"]', 'test@example.com')
  await page.fill('input[name="password"]', 'SecurePass123!')
  await page.click('button[type="submit"]')
  await expect(page.locator('text=Welcome')).toBeVisible()
})
```

## Mocking External Services

When testing, mock external dependencies to isolate your code:

```typescript
// Mock a database client
jest.mock('./db', () => ({
  query: jest.fn(() => Promise.resolve({ rows: [] }))
}))

// Mock an HTTP client
jest.mock('./httpClient', () => ({
  get: jest.fn(() => Promise.resolve({ data: { id: 1 } }))
}))

// Mock environment variables
process.env.API_KEY = 'test-key'
```

## Common Testing Mistakes to Avoid

### Testing Implementation Details
```typescript
// WRONG: Testing internal state
expect(component.state.count).toBe(5)

// CORRECT: Test user-visible behavior
expect(screen.getByText('Count: 5')).toBeInTheDocument()
```

### Brittle Selectors
```typescript
// WRONG: Breaks easily
await page.click('.css-abc123')

// CORRECT: Semantic selectors
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
```

### No Test Isolation
```typescript
// WRONG: Tests depend on each other
test('creates user', () => { /* sets global state */ })
test('updates same user', () => { /* depends on previous test */ })

// CORRECT: Each test is independent
test('creates user', () => {
  const user = createTestUser()
  // ...
})
```

## Best Practices

1. **Write Tests First** - Always TDD
2. **One Assert Per Test** - Focus on single behavior
3. **Descriptive Test Names** - Explain what's tested
4. **Arrange-Act-Assert** - Clear test structure
5. **Mock External Dependencies** - Isolate unit tests
6. **Test Edge Cases** - Null, undefined, empty, large
7. **Test Error Paths** - Not just happy paths
8. **Keep Tests Fast** - Unit tests < 50ms each
9. **Clean Up After Tests** - No side effects
10. **Review Coverage Reports** - Identify gaps

---

**Remember**: Tests are the safety net that enables confident refactoring, rapid development, and production reliability.
