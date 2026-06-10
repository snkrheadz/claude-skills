---
name: create-pr
description: "Sync the base branch from origin, rebase the current branch onto it, then open a PR against the correct base. Prevents PRs created on a stale base from a git worktree. Triggers: /eng:create-pr, create PR, open pull request, gh pr create"
user-invocable: true
allowed-tools: Bash
---

# /eng:create-pr

Open a pull request **with the base branch already synced from origin**. This closes
the recurring failure where a PR is created from a git worktree without first merging
the latest base, so the PR targets a stale base and the branch is behind.

This skill is **self-contained**: it detects the base branch itself and does not depend
on any machine-local shell function. It works in any repo, with any default branch.

## Usage

```
/eng:create-pr                      # title/body inferred from commits
/eng:create-pr "feat: add X"        # explicit title
```

## Execution Flow

Run these in order. **Stop and hand back to the user on any conflict or error** —
never `gh pr create` against a base that failed to sync.

1. **Detect the base branch** (do NOT hardcode `main`):
   ```bash
   base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null) \
     || base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD | sed 's@^origin/@@') \
     || base=main
   echo "base = $base"
   ```

2. **Guard**: refuse if the current branch *is* the base, or has no commits ahead:
   ```bash
   cur=$(git rev-parse --abbrev-ref HEAD)
   [ "$cur" = "$base" ] && { echo "On base branch; nothing to PR."; exit 1; }
   ```

3. **Sync the base from origin**:
   ```bash
   git fetch origin "$base"
   ```

4. **Rebase the current branch onto the fresh base** (linear history, current base).
   On conflict, stop and let the user resolve — do not `--skip` or `--abort` silently:
   ```bash
   git rebase "origin/$base"
   ```

5. **Push the branch** (force-with-lease is required after rebase; safe for a personal
   worktree feature branch):
   ```bash
   git push --force-with-lease --set-upstream origin "$cur"
   ```

6. **Create the PR against the detected base explicitly** (never rely on the default):
   ```bash
   gh pr create --base "$base" --fill   # or --title/--body when you have them
   ```

## Notes

- **Base is always detected, never assumed.** A repo on `master`/`develop` works without
  changes.
- The rebase in step 4 is the fix for problem 1 ("PR created without merging origin"):
  the branch is brought up to the current base *before* the PR exists, so the diff and
  mergeability are correct from the start.
- Conflicts are a stop condition, not something to auto-resolve. Surface them and wait.
- Pairs with `/eng:merge-pr`, which keeps local base current *after* the merge.
