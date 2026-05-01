---
name: hermes-pr-workflow
description: Use when creating pull requests for any GitHub fork-based project. Covers branch creation, conventional commits, pushing to fork, and creating PRs with gh CLI.
version: 1.0.0
author: SoRcKwYo
license: MIT
metadata:
  hermes:
    tags:
      - github
      - pull-requests
      - devops
      - fork-workflow
    related_skills:
      - github-code-review
      - github-pr-workflow
---

# GitHub Fork PR Workflow

## Overview

Standard workflow for contributing PRs to a GitHub project via fork. Works with any fork-based contribution model.

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth login`)
- Fork created on GitHub

## Remote Setup

There are two common conventions. Pick **one** and stay consistent:

### Convention A: `origin` = fork (recommended)

```bash
# One-time setup
git remote add upstream https://github.com/OWNER/REPO.git
# origin already points to your fork after git clone
```

Verify:
```bash
git remote -v
# origin    → YOUR_FORK/REPO (push target)
# upstream  → OWNER/REPO (read-only)
```

### Convention B: `origin` = upstream, `fork` = your fork

```bash
# One-time setup
git remote add fork https://github.com/YOUR_FORK/REPO.git
```

Verify:
```bash
git remote -v
# origin    → OWNER/REPO (read-only)
# fork      → YOUR_FORK/REPO (push target)
```

**Always push to your fork remote, never to `upstream`/`origin` if that points to the original repo.**

## Workflow

### 0. Duplicate Check (MUST do before creating PR)

Before pushing or creating a PR, check whether similar work already exists. This avoids wasting reviewer time and creating conflicting PRs.

**Check open PRs for overlapping scope:**

```bash
# Search open PRs by keywords related to your change
gh pr list --repo OWNER/REPO --state open --search "keyword1 OR keyword2"

# Also check draft PRs — someone may be working on the same thing
gh pr list --repo OWNER/REPO --state open --search "is:draft keyword"
```

**Check if the feature/fix already exists in the codebase:**

```bash
# Search the codebase for the functionality you're adding
grep -rn "feature_name\|function_name" --include="*.py" --include="*.ts" src/

# Check if a similar command/handler/skill already exists
grep -rn "command_name" --include="*.py" hermes_cli/ gateway/ skills/
```

**Check closed/recently merged PRs:**

```bash
# Recently merged PRs with similar keywords
gh pr list --repo OWNER/REPO --state merged --search "keyword" --limit 10

# Check if your change was already attempted and reverted
gh pr list --repo OWNER/REPO --state closed --search "keyword is:unmerged" --limit 5
```

**Decision tree:**

| Finding | Action |
|---------|--------|
| Open PR with same scope | Coordinate with that PR's author; don't duplicate |
| Merged PR with same feature | Your change may be redundant — verify before proceeding |
| Feature exists in codebase | You may be re-implementing something already built |
| No overlap found | Proceed to Step 1 |

### 1. Sync & Branch

```bash
git checkout main
git fetch upstream
git merge upstream/main          # or: git rebase upstream/main
git checkout -b feat/short-desc  # or fix/, docs/, refactor/, etc.
```

### 2. Commit (Conventional Commits)

```
feat(scope): description
fix(scope): description
docs(scope): description
refactor(scope): description
```

Keep commits focused — one logical change per commit.

**Squash if needed:**
```bash
git reset --soft HEAD~N
git commit -m "feat(scope): description"
```

### 3. Push to Fork

```bash
# Convention A (origin = fork):
git push -u origin branch-name

# Convention B (fork = your fork):
git push -u fork branch-name
```

### 4. Create PR

**Write body to a temp file first, then use `--body-file`:**

```bash
cat > /tmp/pr-body.md <<'EOF'
## What does this PR do?

Clear description of the problem and solution.

## Related Issue

Fixes #123

## Type of Change

- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] ♻️ Refactor
- [ ] 📝 Documentation
- [ ] ✅ Tests

## Changes Made

- `path/to/file.py`: what changed and why

## How to Test

1. Step to reproduce
2. Expected result

## Checklist

- [ ] Conventional Commits format
- [ ] Only related changes (no drive-by fixes)
- [ ] Tested on target platform
- [ ] Added tests (if applicable)
EOF

gh pr create \
  --repo OWNER/REPO \
  --head YOUR_FORK:branch-name \
  --base main \
  --title "feat(scope): description" \
  --body-file /tmp/pr-body.md
```

**Always use `--body-file` with a temp file. Never use `--body "..."` or heredoc directly in the terminal tool — `&` in PR body text gets intercepted and the command fails.**

## Common Pitfalls

| Problem | Fix |
|---------|-----|
| Push to upstream fails (403) | Push to your fork remote instead |
| `gh pr create` fails with `&` in body | Write body to `/tmp/pr-body.md`, use `--body-file` |
| Wrong commit message format | `git reset --soft HEAD~1` and recommit |
| Branch has unrelated commits | `git reset --soft` to squash |
| Fork out of sync with upstream | `git fetch upstream && git rebase upstream/main` |
| PR shows wrong file changes | Check branch is based on latest upstream main |
