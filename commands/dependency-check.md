---
description: Audit project dependencies for security vulnerabilities, outdated packages, and license compliance. Runs automated scans and generates a prioritized remediation plan.
---

# /dependency-check Command

Comprehensive dependency audit for security vulnerabilities, outdated packages, unused dependencies, and license compliance.

## What This Command Does

1. **Security audit** -- Scans for known CVEs in dependencies
2. **Outdated packages** -- Identifies packages behind their latest version
3. **Unused dependencies** -- Finds packages installed but never imported
4. **License compliance** -- Flags incompatible or non-permissive licenses
5. **Remediation plan** -- Prioritized list of actions with commands

## Step 1: Detect Package Manager

| Indicator | Audit Command |
|-----------|--------------|
| `package.json` (npm) | `npm audit --json` |
| `package.json` (pnpm) | `pnpm audit --json` |
| `package.json` (yarn) | `yarn audit --json` |
| `requirements.txt` / `pyproject.toml` | `pip audit` or `safety check` |
| `Cargo.toml` | `cargo audit` |
| `go.mod` | `govulncheck ./...` |
| `pom.xml` | `mvn dependency:check` |
| `Gemfile` | `bundle audit` |

## Step 2: Security Vulnerability Scan

Run the appropriate audit command and parse output:

- **Critical**: Vulnerabilities with CVSS score >= 9.0 -- Block deployment
- **High**: CVSS >= 7.0 -- Fix before next release
- **Medium**: CVSS >= 4.0 -- Fix within 30 days
- **Low**: CVSS < 4.0 -- Track and fix in regular upgrades

## Step 3: Outdated Package Scan

```bash
# Node.js
npm outdated

# Python
pip list --outdated

# Cargo
cargo outdated
```

Prioritize updates:
1. **Security updates** first (regardless of semver)
2. **Patch versions** (x.x.N) -- safe, usually fix-only
3. **Minor versions** (x.N.x) -- typically backward-compatible
4. **Major versions** (N.x.x) -- check changelog for breaking changes

## Step 4: Unused Dependency Detection

```bash
# Node.js
npx depcheck

# Python
pip install pip-autoremove
pip-autoremove --list
```

## Step 5: License Compliance

```bash
# Node.js: list all licenses
npx license-checker --summary

# Python
pip install pip-licenses
pip-licenses
```

**Flags** these license types (check with legal team):
- GPL / LGPL (copyleft -- may require open-sourcing your code)
- AGPL (strongest copyleft)
- Unknown / Unlicensed
- Creative Commons (not designed for software)

**Permissive licenses** (generally safe for commercial use):
- MIT, Apache 2.0, BSD, ISC

## Step 6: Remediation Plan

Generate prioritized action list:

```
DEPENDENCY AUDIT REPORT
========================
Scanned: 247 dependencies
Date: 2024-03-15

CRITICAL (fix immediately):
  [VULN] CVE-2023-1234 in jsonwebtoken@8.5.1
  Severity: Critical (CVSS 9.8)
  Fix: npm update jsonwebtoken

HIGH (fix before next release):
  [VULN] CVE-2023-5678 in axios@0.21.0
  Severity: High (CVSS 7.5)
  Fix: npm install axios@1.6.0

MEDIUM (fix within 30 days):
  3 medium-severity vulnerabilities found
  Run: npm audit fix

OUTDATED (20 packages behind):
  react: 18.2.0 -> 18.3.0 (patch -- safe)
  typescript: 5.1.0 -> 5.4.0 (minor -- review changelog)
  next: 13.0.0 -> 14.0.0 (major -- breaking changes)

UNUSED (consider removing):
  lodash -- no imports found
  moment -- no imports found (use date-fns instead)

LICENSE ISSUES:
  gpl-licensed-package@1.0.0: GPL-3.0 -- review with legal
```

## Guardrails

Stop and ask the user if:
- A fix requires a **major version upgrade** (breaking changes possible)
- Fixing one vulnerability **introduces another**
- An update requires **code changes** (not just a version bump)

## Auto-fix vs Manual

**Auto-fix safe** (`npm audit fix`):
- Patch and minor version upgrades within semver range

**Manual review required**:
- Major version upgrades
- Packages with no fix available (need to replace or accept risk)
- License issues

## Integration

- Schedule weekly: add to CI/CD pipeline as a separate job
- Run before every release: part of the release checklist
- Use `/code-review` to check for newly introduced dependency patterns
- Use `/build-fix` if an update breaks the build

## Related

See the `security-reviewer` agent for broader security scanning beyond dependencies.
