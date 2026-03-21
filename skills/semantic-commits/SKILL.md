---
name: semantic-commits
description: Git version control strategy enforcing atomic, semantic commits
---

# Semantic Commits Skill

## When to Use This Skill
- Whenever you are about to create a Git commit or push changes.
- During any coding task that alters multiple files logically apart from each other.
- When organizing work before executing a pull request or merge.

## Core Principles

1. **Atomic Commits:** Avoid huge, monolithic commits. A single commit should represent **one specific logical change** (e.g., adding a single feature, fixing one bug, or refactoring a specific module). Do not bundle an unrelated bug fix with a new feature.
2. **Comprehensive Git Log:** A developer should be able to read the commit history and perfectly understand how the application evolved.
3. **Semantic/Conventional Commits:** Every commit message must follow the Conventional Commits specification.

## Conventional Commits Format

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

### Approved Types

- `feat`: A new feature was added.
- `fix`: A bug was fixed.
- `docs`: Documentation-only changes (README, inline docs).
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance.
- `test`: Adding missing tests or correcting existing tests.
- `chore`: Changes to the build process or auxiliary tools and libraries (e.g., updating dependencies).

### Description Guidelines
- Use the imperative, present tense: "change" not "changed" nor "changes".
- Don't capitalize the first letter of the description.
- No dot (.) at the end.
- Be concise but highly descriptive. `fix: typo` is bad. `fix: address null pointer exception in login flow` is good.

## Implementation Workflow

When you are asked to commit work:

1. **Analyze the `git status` / `git diff`:**
   Review all changed files. Are there multiple unrelated changes here? If yes, group them logically.

2. **Stage Logically (Interactive Add):**
   Use `git add <specific-files>` rather than `git add .` to create focused, atomic commits. If a single file contains both a bug fix and a new feature, use `git add -p` to stage logical blocks independently.

3. **Craft the Message:**
   Determine the appropriate `<type>` based on the staged changes. If the change is significant enough that reviewers need context, write a multi-line commit message providing the body.

   *Example of a multi-line commit:*
   ```bash
   git commit -m "feat(auth): implement JWT-based login" -m "- Added jsonwebtoken dependency" -m "- Created POST /login endpoint" -m "- Integrated bcrypt password hashing"
   ```

4. **Iterate:** Repeat the staging and committing steps until the entire working directory is clean.

## Common Mistakes to Avoid
- ❌ **The "Kitchen Sink" Commit:** `git commit -am "fixed stuff and added feature"`. This makes reverting specific changes or pinpointing bugs incredibly difficult.
- ❌ **Non-Semantic Messages:** `git commit -m "update files"`.
- ❌ **Wrong Tense:** `feat: fixed the broken link`. (Remember, always use imperative: "fix the broken link").
- ❌ **Excessive scopes:** `feat(src/components/button/button.tsx): added colors`. Scopes are optional and should refer to high-level modules, e.g., `feat(ui): added colors to Button`.
