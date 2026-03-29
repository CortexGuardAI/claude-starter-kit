---
name: cicd-pipelines
description: Use this skill when creating or reviewing CI/CD pipelines, GitHub Actions workflows, GitLab CI configurations, Dockerfiles, or deployment strategies. Provides templates, best practices, and security guidance.
---

# CI/CD Pipelines Skill

Production-grade CI/CD pipeline templates, Docker patterns, and deployment strategies.

## When to Activate

- Creating GitHub Actions or GitLab CI workflows
- Writing or reviewing Dockerfiles
- Setting up deployment automation
- Configuring branch protection and merge gates
- Designing multi-environment promotion strategies

---

## Core Concepts

### Pipeline Stages (Always in This Order)
```
1. Validate     → Lint, type-check, format check (fast, fail early)
2. Test         → Unit + integration tests (parallel if possible)
3. Security     → Dependency audit, secrets scan (on every PR)
4. Build        → Compile, package, push image
5. Deploy Staging → Automated (on merge to main)
6. E2E Tests    → Run against staging environment
7. Deploy Prod  → Manual gate or automatic on tag
```

---

## GitHub Actions Templates

### Full CI/CD Pipeline (Node.js/TypeScript)
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # ─── Stage 1: Validate ──────────────────────────────────────────
  validate:
    name: Validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run format:check

  # ─── Stage 2: Test ──────────────────────────────────────────────
  test:
    name: Test
    needs: validate
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports: ['5432:5432']
    env:
      DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run db:migrate:test
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  # ─── Stage 3: Security ──────────────────────────────────────────
  security:
    name: Security Scan
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm audit --audit-level=high
      - uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}

  # ─── Stage 4: Build ─────────────────────────────────────────────
  build:
    name: Build & Push Image
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-
            type=ref,event=branch
            type=semver,pattern={{version}}
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ─── Stage 5: Deploy Staging ────────────────────────────────────
  deploy-staging:
    name: Deploy to Staging
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          # Add your deployment command here
          # e.g., kubectl set image, helm upgrade, fly deploy, etc.
          echo "Deploying ${{ needs.build.outputs.image-tag }} to staging"

  # ─── Stage 6: Deploy Production ─────────────────────────────────
  deploy-production:
    name: Deploy to Production
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production  # Requires manual approval in GitHub UI
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - name: Deploy to production
        run: echo "Deploying to production"
```

### Pull Request Check (Lean, Fast)
```yaml
name: PR Check
on:
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test
      - run: npm audit --audit-level=high
```

---

## Dockerfile Patterns

### Node.js Multi-Stage (Production Ready)
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine AS runtime
RUN apk add --no-cache dumb-init \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup
WORKDIR /app
COPY --chown=appuser:appgroup --from=builder /app/dist ./dist
COPY --chown=appuser:appgroup --from=builder /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package*.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### Python Multi-Stage
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir poetry
COPY pyproject.toml poetry.lock ./
RUN poetry export --without-hashes -f requirements.txt -o requirements.txt
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim AS runtime
RUN useradd -m -u 1000 appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### .dockerignore (Always Required)
```
node_modules
.git
.gitignore
*.md
.env
.env.*
!.env.example
dist
coverage
.nyc_output
*.log
.DS_Store
```

---

## Deployment Strategies

### Blue-Green Deployment
```yaml
# Zero-downtime, easy rollback
# Maintain two identical environments, switch traffic between them
- name: Deploy Blue-Green
  run: |
    # Deploy to green
    kubectl set image deployment/app-green app=$IMAGE
    kubectl rollout status deployment/app-green
    # Switch traffic
    kubectl patch service app -p '{"spec":{"selector":{"slot":"green"}}}'
    # Old blue is kept for instant rollback
```

### Canary Release
```yaml
# Gradually route traffic to new version
- name: Deploy Canary (10%)
  run: |
    kubectl apply -f canary-deployment.yaml
    kubectl patch ingress app --patch '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight":"10"}}}'
```

---

## Secrets Management

```yaml
# NEVER put secrets in workflow files
# USE: GitHub Secrets (Settings > Secrets > Actions)
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}

# For production: use external secret managers
# AWS Secrets Manager:
- uses: aws-actions/configure-aws-credentials@v4
- run: |
    SECRET=$(aws secretsmanager get-secret-value --secret-id prod/app --query SecretString --output text)
    echo "DATABASE_URL=$(echo $SECRET | jq -r .database_url)" >> $GITHUB_ENV
```

---

## CI/CD Checklist

### Pipeline
- [ ] Pipeline runs on every PR
- [ ] Tests must pass before merge allowed (branch protection)
- [ ] Security scan runs on every PR
- [ ] Build artifacts tagged with git SHA
- [ ] Staging deployment is automatic; production is gated

### Docker
- [ ] Multi-stage build used
- [ ] Non-root user configured
- [ ] `.dockerignore` exists
- [ ] `HEALTHCHECK` defined
- [ ] Image size < 200MB (target)

### Security
- [ ] No secrets in workflow YAML files
- [ ] Branch protection rules enabled on main
- [ ] Required reviewers configured
- [ ] Dependency scanning enabled
- [ ] Container image scanning enabled (Trivy, Snyk, or similar)
