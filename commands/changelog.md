---
description: Generate changelog entries from recent git commits following Keep a Changelog format and semantic versioning. Invokes the docs-writer agent.
---

# /changelog Command

This command invokes the **docs-writer** agent to generate or update CHANGELOG.md from recent git commits.

## What This Command Does

1. **Reads commit history** -- Parses commits since last version tag
2. **Categorizes changes** -- Maps conventional commits to changelog sections
3. **Generates entries** -- Follows Keep a Changelog format
4. **Suggests version** -- Recommends semver bump based on change types
5. **Updates CHANGELOG.md** -- Prepends new version section

## Usage

```
/changelog [version]
```

### Arguments

| Invocation | Action |
|------------|--------|
| `/changelog` | Auto-detect version from commits and generate |
| `/changelog 2.1.0` | Generate changelog for a specific version |
| `/changelog --preview` | Show what would be generated, do not write |
| `/changelog --unreleased` | Append to [Unreleased] section only |

## Examples

```
/changelog
/changelog 2.1.0
/changelog --preview
/changelog --unreleased
```

## How Version Is Determined

Based on Semantic Versioning and conventional commit types:

| Commit Type | Version Bump |
|------------|-------------|
| `feat` | Minor (1.x.0) |
| `fix`, `perf` | Patch (1.0.x) |
| `feat!`, `fix!`, `BREAKING CHANGE` | Major (x.0.0) |
| `docs`, `style`, `refactor`, `test`, `chore` | No version bump |

## Commit to Changelog Mapping

| Conventional Commit Type | Changelog Section |
|--------------------------|------------------|
| `feat:` | ### Added |
| `fix:` | ### Fixed |
| `perf:` | ### Changed |
| `refactor:` | ### Changed |
| `docs:` | (omit or ### Changed) |
| `security:` / `fix(security):` | ### Security |
| `deprecated:` | ### Deprecated |
| Breaking changes | ### Removed or noted in ### Changed |

## Output Format (Keep a Changelog)

```markdown
## [2.1.0] - 2024-03-15

### Added
- Two-factor authentication via TOTP (feat: add TOTP two-factor auth)
- CSV export for all report types (feat: add CSV export to reports)
- Webhook support for order status changes (feat: add order webhooks)

### Changed
- Improved search performance by 3x with new index strategy (perf: add composite index on search)
- Password requirements now enforce minimum 12 characters

### Deprecated
- `/api/v1/orders/list` endpoint -- use `/api/v2/orders` instead

### Fixed
- Fixed race condition in concurrent order creation
- Fixed email not sent when order is cancelled (#234)

### Security
- Updated jsonwebtoken to 9.0.2 (CVE-2022-23529)

[2.1.0]: https://github.com/org/repo/compare/v2.0.0...v2.1.0
```

## Workflow

The agent runs:
```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline --no-merges

# Get last version tag
git describe --tags --abbrev=0
```

## Important Notes

- Commits that are `docs:`, `style:`, `test:`, `chore:` are **not** included in the changelog (they are internal changes, not user-facing)
- Commit messages that are unclear will be flagged and you'll be asked to clarify
- The agent will **not** auto-push or tag -- you control the release

## Integration

- Run `/changelog --preview` before every release
- Run `/checkpoint` after updating CHANGELOG.md and tagging
- Combine with semantic-commits skill for best results

## Related

This command uses the `docs-writer` agent. Source: `agents/docs-writer.md`
For commit formatting standards, see skill: `semantic-commits`
