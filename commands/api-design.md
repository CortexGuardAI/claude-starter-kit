---
description: Design or review API contracts (REST/GraphQL). Generates OpenAPI specs, standardizes error formats, and enforces naming conventions. Invokes the api-designer agent.
---

# /api-design Command

This command invokes the **api-designer** agent to design new API endpoints, review existing contracts, or generate OpenAPI specifications.

## What This Command Does

1. **Designs resources** -- Proper RESTful naming, HTTP methods, status codes
2. **Standardizes errors** -- RFC 7807 error format across all endpoints
3. **Defines pagination** -- Consistent filtering, sorting, cursor/offset pagination
4. **Generates specs** -- OpenAPI 3.1 YAML or GraphQL schema
5. **Reviews for consistency** -- Flags naming inconsistencies, missing patterns

## Usage

```
/api-design [action]
```

### Actions

| Action | Description |
|--------|-------------|
| `/api-design new [resource]` | Design a new REST resource with full CRUD |
| `/api-design review` | Review all existing API routes for consistency |
| `/api-design spec` | Generate OpenAPI 3.1 spec from existing routes |
| `/api-design graphql [type]` | Design a GraphQL schema for a type |
| `/api-design errors` | Standardize error responses to RFC 7807 |
| `/api-design` (no action) | Review recently changed API files |

## Examples

```
/api-design new orders
/api-design review
/api-design spec
/api-design graphql Order
/api-design errors
```

## What Gets Designed / Generated

### New REST Resource (`/api-design new orders`)
```
GET    /orders         -- List orders (with pagination, filtering, sorting)
POST   /orders         -- Create order
GET    /orders/{id}    -- Get order by ID
PATCH  /orders/{id}    -- Update order (partial)
DELETE /orders/{id}    -- Cancel order

Nested:
GET    /orders/{id}/items        -- Order items
POST   /orders/{id}/items        -- Add item

Actions:
POST   /orders/{id}/confirm      -- Confirm pending order
POST   /orders/{id}/cancel       -- Cancel order
```

### OpenAPI Spec
Full OpenAPI 3.1 YAML with:
- All paths and operations
- Request/response schemas
- Error response definitions
- Authentication configuration
- Pagination parameters

### GraphQL Schema
- Type definitions with descriptions
- Query and Mutation resolvers
- Relay-style connections for pagination
- Mutation payload pattern with errors

## API Design Checklist

The agent enforces:
- [ ] Plural noun resource names
- [ ] Correct HTTP methods and status codes
- [ ] RFC 7807 error response format
- [ ] Pagination on all list endpoints
- [ ] Consistent filtering and sorting syntax
- [ ] API versioning strategy defined
- [ ] Authentication documented

## Integration

- Use `/api-design` before starting implementation (contract-first)
- Use `/tdd` to write tests against the designed contract
- Use `/code-review` to verify implementation matches contract
- Use `/docs` to look up OpenAPI tooling documentation

## Related

This command uses the `api-designer` agent. Source: `agents/api-designer.md`
For detailed API patterns, see skill: `api-design-patterns`
