# Agent-readiness rubric (the Honk three pillars)

Portable scoring basis used by `/spec:scan`. Repo-agnostic: the same three pillars
and the Honk gate reproduce Spotify's discipline on any repository, with no fleet
infrastructure. Encodes one lesson from Niklas Gustavsson's Honk: **verification is
the most underinvested lever, and consistency is what lets agents perform.**

## The Honk gate (non-negotiable)

Before scoring, detect the **verify substrate** — the commands an agent could invoke
*itself* to close the loop (test runner, lint/format, type-check, build, CI). If NO
agent-invokable verify command exists at all, the repo is `agent_ready: no` and the
verify loop becomes backlog item #1 with the highest ROI, regardless of every other
axis. A repo that agents cannot verify themselves is not ready, no matter how good its
tests look on paper.

## The three pillars (score each 0–5, cite observed evidence — never vibes)

- **A — Test automation:** tests present? coverage holes on critical paths?
  flaky/skipped/xfail? Can tests actually run from a clean checkout?
- **B — Closed-loop verification:** can an agent run verify end-to-end unattended? gap
  between "what CI does" and "what an agent can do locally"? Missing the loop is the
  most expensive gap.
- **C — Standardization / consistency:** naming / layering / pattern variance. Divergent
  idioms make agents guess; consistency is what made Claude work in a 20M-line monorepo.
  Cite concrete divergences, not impressions.

## Ranking

For each gap estimate `impact` (how much it unblocks autonomous/agent work) and
`effort`, then sort by impact/effort. The verify-loop gap, if present, dominates. Each
backlog row must be a one-line intent at intent altitude (no file paths, no tech
choices) — ready to feed straight into `/spec:requirement`.
