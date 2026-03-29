---
name: api-design-patterns
description: Use this skill when designing new API endpoints, reviewing existing API contracts, generating OpenAPI specs, or standardizing error formats across a project. Covers REST, GraphQL, pagination, versioning, and RFC 7807 error handling.
---

# API Design Patterns Skill

Deep knowledge for designing consistent, developer-friendly APIs that scale and are easy to maintain.

## When to Activate

- Designing new REST or GraphQL API endpoints
- Reviewing existing API routes for consistency
- Generating OpenAPI specifications
- Standardizing error response formats
- Planning API versioning strategy
- Onboarding to a new API codebase

---

## REST API Patterns

### Resource Naming Rules

```
# Plural nouns, lowercase, hyphen-separated
/users                    ✓
/user                     ✗ (singular)
/getUsers                 ✗ (verb)
/Users                    ✗ (uppercase)

/user-profiles            ✓
/userProfiles             ✗ (camelCase in URL)

# Nested resources (max 2 levels -- beyond that, use query params)
/users/{id}/orders        ✓  (user owns orders)
/users/{id}/orders/{id}/items  ✓ (but getting deep)
/users/{id}/orders/{id}/items/{id}/refunds  ✗ (too deep)

# Use query params for filtering across relationships
/refunds?orderId=123&userId=456  ✓
```

### HTTP Method Semantics

| Method | Semantics | Idempotent | Body |
|--------|----------|-----------|------|
| GET | Read resource | Yes | No |
| POST | Create resource | No | Yes |
| PUT | Replace resource (full update) | Yes | Yes |
| PATCH | Partial update | No | Yes |
| DELETE | Remove resource | Yes | No |

### Actions on Resources (Sub-resources for RPC-style)
```
POST /orders/{id}/confirm      ✓ (order action)
POST /orders/{id}/cancel       ✓
POST /users/{id}/activate      ✓
POST /payments/{id}/refund     ✓

# NOT:
POST /confirmOrder             ✗ (verb URL)
GET  /order/cancel?id=123      ✗ (mutating with GET)
```

### Standard Response Envelope

```json
// Success (single resource)
{
  "data": { "id": "123", "email": "user@example.com" }
}

// Success (collection)
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTIwfQ",
    "hasNextPage": true,
    "total": 1500
  }
}

// Never return raw arrays at the top level -- always wrap in object
// This allows adding metadata (pagination, etc.) without breaking clients
```

---

## Error Response Pattern (RFC 7807)

**Every API error MUST follow Problem Details format:**

```json
{
  "type": "https://errors.example.com/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "One or more fields failed validation.",
  "instance": "/api/users/create",
  "errors": [
    { "field": "email", "message": "Must be a valid email", "code": "INVALID_FORMAT" },
    { "field": "age",   "message": "Must be at least 18",   "code": "MIN_VALUE" }
  ]
}
```

**Content-Type for errors**: `application/problem+json`

### Status Code Reference

| Code | When to Use |
|------|------------|
| 200 | Successful GET, PUT, PATCH |
| 201 | Successful POST (add `Location` header pointing to new resource) |
| 204 | Successful DELETE, or action with no body |
| 400 | Malformed request (syntax error, wrong JSON) |
| 401 | Not authenticated (no/invalid token) |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state clash) |
| 422 | Validation error (semantically invalid input) |
| 429 | Rate limit exceeded |
| 500 | Unexpected server error (never expose stack traces) |
| 503 | Service temporarily unavailable (maintenance, overload) |

---

## Pagination Patterns

### Cursor-Based (Recommended for large datasets)

```
Request:  GET /orders?cursor=eyJpZCI6MTAwfQ&limit=20
Response:
{
  "data": [...20 items...],
  "pagination": {
    "cursor": "eyJpZCI6MTIwfQ",  // opaque, base64-encoded pointer
    "hasNextPage": true,
    "limit": 20
  }
}
```

**Why cursor**: Consistent results even if data changes. No "page drift".

### Offset-Based (Simple, for small datasets)

```
Request:  GET /users?page=2&pageSize=20
Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "pageSize": 20,
    "totalPages": 75,
    "total": 1500
  }
}
```

### All List Endpoints MUST Have:
- Default page size (e.g., 20)
- Maximum page size (e.g., 100)
- Total count (when feasible)
- Next/previous page links or cursor

---

## Filtering, Sorting, Search

```
# Simple filters (exact match)
GET /orders?status=pending&userId=abc123

# Range filters
GET /orders?createdAfter=2024-01-01&createdBefore=2024-03-31

# Multiple values (OR)
GET /orders?status=pending,confirmed

# Sorting (- = descending, + or no prefix = ascending)
GET /users?sort=-createdAt,+name

# Full-text search
GET /products?q=wireless+headphones

# Sparse fieldsets (reduce payload)
GET /users?fields=id,email,name
```

---

## API Versioning

### Recommended: URL Path Versioning

```
/v1/users
/v2/users
```

**Breaking change** (requires new major version):
- Removing a field from response
- Changing a field's type
- Making an optional field required
- Changing URL structure
- Changing authentication method

**Non-breaking** (no version bump):
- Adding new optional fields to response
- Adding new optional query parameters
- Adding new endpoints
- Relaxing validation constraints

### Deprecation Policy

```http
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 31 Dec 2024 23:59:59 GMT
Link: <https://api.example.com/v2/users>; rel="successor-version"
```

---

## OpenAPI 3.1 Key Patterns

### Reusable Component References
```yaml
components:
  schemas:
    PaginationMeta:
      type: object
      properties:
        cursor: { type: string }
        hasNextPage: { type: boolean }
        total: { type: integer }

    Error:
      type: object
      required: [type, title, status]
      properties:
        type: { type: string, format: uri }
        title: { type: string }
        status: { type: integer }
        detail: { type: string }
        errors:
          type: array
          items:
            type: object
            properties:
              field: { type: string }
              message: { type: string }
              code: { type: string }

  responses:
    NotFound:
      description: Resource not found
      content:
        application/problem+json:
          schema: { $ref: '#/components/schemas/Error' }
    Unauthorized:
      description: Authentication required
      content:
        application/problem+json:
          schema: { $ref: '#/components/schemas/Error' }
```

---

## GraphQL Patterns

### Relay Connections (Pagination)
```graphql
type OrderConnection {
  edges: [OrderEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type OrderEdge {
  node: Order!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

### Mutation Payload Pattern
```graphql
# Always return the affected record AND errors array
type CreateOrderPayload {
  order: Order          # null if there were errors
  errors: [UserError!]! # empty array on success
}

type UserError {
  field: String  # null for non-field errors
  message: String!
  code: String!
}
```

---

## API Design Checklist

- [ ] Resource names are plural nouns, lowercase, hyphen-separated
- [ ] HTTP methods used semantically (GET reads, POST creates, etc.)
- [ ] HTTP status codes are correct and meaningful
- [ ] All errors follow RFC 7807 Problem Details format
- [ ] All list endpoints have pagination (with max limit)
- [ ] Filtering, sorting, and search are consistent across resources
- [ ] Versioning strategy defined and documented
- [ ] OpenAPI spec or GraphQL schema exists for all endpoints
- [ ] Authentication requirements documented per endpoint
- [ ] Rate limiting headers documented (`X-RateLimit-*`)
