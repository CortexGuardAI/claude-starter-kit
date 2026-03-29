---
description: Analyze code for smells and apply safe, test-driven refactoring. NEVER changes behavior -- only structure. Invokes the refactoring-guru agent.
---

# /refactor Command

This command invokes the **refactoring-guru** agent to identify code smells and apply safe, incremental refactoring techniques.

## What This Command Does

1. **Scans for smells** -- Finds God classes, long methods, duplication, etc.
2. **Prioritizes by impact** -- Critical > High > Medium > Low
3. **Plans safe steps** -- Small, verifiable refactoring moves
4. **Executes with tests** -- Ensures tests pass at each step
5. **Commits incrementally** -- Each safe step is its own commit

## Usage

```
/refactor [target] [--mode]
```

### Targets and Modes

| Invocation | Action |
|------------|--------|
| `/refactor scan` | Scan project for all code smells, produce report |
| `/refactor [file]` | Refactor a specific file |
| `/refactor --dry-run` | Show what would be changed, do not modify |
| `/refactor --debt` | Generate technical debt register |
| `/refactor` (no target) | Refactor recently changed files |

## Examples

```
/refactor scan
/refactor src/services/orderService.ts
/refactor src/services/orderService.ts --dry-run
/refactor --debt
```

## What Gets Detected

### Critical (Fix Now)
- God classes (single class > 300 lines)
- Functions > 50 lines
- Nesting depth > 4 levels
- Magic numbers (unexplained literals)
- Dead code (unused functions/variables)
- Blatant duplication (copy-paste code)

### High (Fix This Sprint)
- Feature envy (method uses another class's data heavily)
- Long parameter lists (4+ parameters)
- Data clumps (same variables always together)
- Primitive obsession (using strings for domain concepts)

### Medium (Backlog)
- Inconsistent naming
- Missing abstractions
- Large switch statements (replace with polymorphism)
- Temporary fields

## Important Rules

**CRITICAL**: `/refactor` will NEVER change behavior.

- Tests must pass before AND after every step
- If tests don't exist, the agent writes characterization tests first
- Each refactoring move gets its own commit
- If tests break, the refactor is reverted -- stop and investigate

## Refactoring Process

```
1. Ensure tests exist (write if missing)
2. Run tests -> must pass
3. Apply one refactoring move
4. Run tests -> must still pass
5. Commit: refactor(scope): description
6. Repeat from step 3
```

## Sample Output

```
REFACTORING SCAN: src/services/orderService.ts
===============================================
Lines: 620 | Functions: 28

CRITICAL:
  Line 1-620: God class -- extract PaymentProcessor, ShippingCalculator
  Line 89: Function processOrder() is 85 lines -- extract 3 sub-functions
  Lines 201, 340, 478: Duplicated order validation -- extract validateOrder()

HIGH:
  Line 134: Magic number 0.1 -- replace with TAX_RATE constant
  Line 290: 6 parameters in createOrder() -- use CreateOrderParams object

RECOMMENDED ORDER:
  1. Extract validateOrder() -- low risk, high value
  2. Extract calculateTotals() -- low risk
  3. Extract PaymentProcessor class -- medium risk, write tests first

Shall I proceed with step 1? (y/n)
```

## Integration

- Use `/plan` for large refactoring initiatives
- Always use `/tdd` to add missing test coverage before refactoring
- Use `/code-review` after refactoring to verify quality
- Use `/checkpoint` before starting a refactoring session

## Related

This command uses the `refactoring-guru` agent. Source: `agents/refactoring-guru.md`
