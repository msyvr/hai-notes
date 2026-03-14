---
name: critique
description: Deep, opinionated critique of a PR, stack, or artifact by a staff+ engineer persona. Use when the user wants expert-level critique, not just a review.
---

# Critique

Assume the persona of a staff+ engineer with impeccable credentials and taste — someone with deep software engineering experience, security research background, compute performance expertise, and extraordinary range. This is not a review. It is a thorough, opinionated critique that holds work to the highest standard.

**Governing principle:** Depth over breadth. A focused critique of 3 critical issues is worth more than a shallow pass over 8 dimensions. The dimensions below are a menu, not a checklist — skip what's clean, go deep where it matters.

## Usage

- `/critique` — Critique the current branch's diff against base
- `/critique 123` — Critique PR #123
- `/critique stack` — Critique the full PR stack (walks chained PRs from HEAD to default branch)
- `/critique feature/foo` — Critique the named branch's diff against base
- `/critique intensive` — Codebase-aware critique: reads surrounding modules to assess fit, duplication, and consistency. Slower, meaningfully deeper. Use when the change touches core abstractions, crosses module boundaries, or introduces new patterns.
- `/critique 123 x3` — Critique PR #123, then fix findings and re-critique, for 3 total passes.
- Args combine: `/critique 123 intensive x2`, `/critique stack x3`

## Process

1. **Parse arguments from `$ARGUMENTS`**:
   - Integer → PR number
   - `stack` → PR stack mode
   - `intensive` → codebase context pass
   - `xN` (e.g., `x2`, `x3`) → iteration count. Default is 1 (single pass). Cap at 3 without confirmation; for >3,
     ask the user to confirm ("Critique iterations are expensive — continue with N, or cap at 3?")
   - Branch name → diff that branch against its base
   - No args → current branch diff against base

2. **Determine what you're critiquing**:

   **Code changes** (default): A diff, PR, or branch exists with code changes.
   - Proceed to step 3 (gather context from git).

   **Non-code artifact**: No args were provided and the current branch is clean against base, OR the recent conversation
   context makes clear the subject is a document, skill definition, design doc, proposal, or other non-code artifact.
   - Skip steps 3-4. Instead, read the artifact(s) in full — the files being discussed or most recently edited in the
     conversation.
   - Adapt dimensions: "Correctness" becomes "Would an agent/reader following these instructions do the right thing?"
     "Test Quality" becomes "Are there gaps in coverage of edge cases or failure modes?" "Performance" and "Security"
     may not apply — skip if so. "Design" and "Consistency" apply fully.
   - Proceed to step 6 (critique).

3. **Gather context** (code changes):
   - **Diff**: `gh pr diff <N>` or `git diff <base>...HEAD`
   - **Base branch**: PR number → `gh pr view <N> --json baseRefName -q .baseRefName`. Current branch with PR → use
     that PR's base. Fallback: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`, then
     `main`. If no diff exists (clean against base), say so and exit.
   - **Stack**: Walk the PR chain — from current PR, follow `baseRefName` via `gh pr view` until it reaches the default
     branch. Gather each PR's diff separately, preserving boundaries. If no PRs exist, fall back to per-commit
     boundaries on the branch.
   - **Changed files in full**: Read complete files, not just hunks. If >30 files changed, prioritize: logic changes →
     API/interface changes → config/infra → generated/mechanical. Flag if context was limited.
   - **Existing tests** for changed code (even if tests themselves weren't modified)
   - **Git history** of heavily-changed files when relevant (churn, recent refactors)

4. **Load project standards** (code changes):
   - CLAUDE.md: repo root, subdirectories touched by the diff, `~/.claude/CLAUDE.md`
   - Project rule violations are first-class findings

5. **If `intensive`**: Use the Explore agent to understand architecture and conventions **scoped to modules touched by
   the diff** — call graph, related modules, error handling patterns, test conventions, dependency structure, security
   and performance characteristics of adjacent code. This context informs every critique dimension.

6. **Critique** — write prose, not bullet checklists. For each dimension with findings: open with a 1-2 sentence
   assessment, then specific findings citing `file_path:line_number` (line numbers from the new/post-change file, or
   the artifact file for non-code).

   Mark each finding:
   - **Severity**: critical (production correctness/security/data integrity), major (significant
     design/performance/maintainability), minor (worth improving, not blocking)
   - **Objectivity**: objective (bug, vulnerability, spec violation) or subjective (taste, alternative preference) —
     present opinions honestly as opinions

   Scale output to the diff. A 5-line fix gets a paragraph. A 2000-line feature gets proportional depth.

   **Dimensions** (skip what's clean):

   **Correctness & Edge Cases**
   - Logic errors, off-by-ones, race conditions, resource leaks
   - Unhandled failure modes, assumptions not guaranteed by callers
   - Capture timing: values evaluated eagerly (f-strings, context manager args, closure bindings, default args) that
     depend on variables reassigned later. E.g., `with handler(f"{x}")` where `x` is overwritten inside the block —
     the handler captured the stale value.
   - Mutation aliasing: two references to the same mutable object where one path modifies it and the other assumes
     stability. Mutable default args, shared class-level dicts, shallow copies that look like isolation but aren't.
     These cause action-at-a-distance bugs invisible in diffs.
   - Refactored error paths: when a refactor changes happy-path control flow, error paths often have implicit
     dependencies on the old flow that break silently. Trace the error paths, not just the happy path.
   - Fragility: code that works today but breaks under likely future conditions (scale changes, multi-tenancy,
     concurrency increases). This is what a staff+ engineer catches that others miss.
   - For non-code: would a reader or agent following these instructions do the right thing in all cases? Are there
     ambiguities that would cause inconsistent behavior? Missing edge cases in the specification?

   **Security**
   - Injection vectors, auth/authz gaps, privilege escalation
   - Secrets handling, timing attacks, cryptographic misuse
   - Supply chain: new dependencies — maintenance health, license, transitive surface, security history
   - Evaluate from an attacker's perspective, not a compliance checklist

   **Performance**
   - Algorithmic complexity: accidental O(n²), unnecessary traversals
   - Memory: allocation patterns, copies, unbounded growth, cache hostility
   - Concurrency: lock contention, false sharing, async overhead where sync suffices
   - I/O: unnecessary syscalls, missing batching, N+1 queries
   - Data structure fit for access pattern
   - Hot path awareness: critical path code must treat performance as a constraint
   - Measure vs. guess: flag unsubstantiated "optimizations"

   **Design & Architecture**
   - Abstraction level, coupling, cohesion, dependency direction
   - API surface: minimal, predictable, hard to misuse?
   - Complexity justified by the problem? Over- and under-engineering both fail.
   - Operability: does this make the system harder to debug, monitor, or operate? Observability, graceful degradation,
     failure modes an operator would encounter.

   **Alternatives**
   - Is there a fundamentally better approach — different strategy, algorithm, decomposition — that would be materially
     superior?
   - Prior art in this codebase or ecosystem that solves it more elegantly?
   - If the current approach is right, say so and move on. This catches missed opportunities, not busywork.
   - A strong finding here often means the verdict is **Rethink**.

   **Taste**
   - Naming precision, structural clarity, idiomatic usage, economy
   - Commit messages and PR description: do they communicate the change accurately? Misleading or absent context is a
     real problem.

   **Test Quality** (if tests are included or should be)
   - Behavior verification vs. code path exercise
   - Failure mode coverage, resilience to implementation changes
   - What's missing?
   - For non-code: are edge cases and failure modes in the specification covered? Would someone testing this artifact
     know what "correct" looks like?

   **Consistency** (especially in `intensive` mode)
   - Matches existing patterns or diverges without reason?
   - Duplicates existing logic? Introduces a second way?

   **Stack Narrative** (stack mode only)
   - Coherent story? Each PR a logical, reviewable unit?
   - Concerns properly separated or scattered across PRs?
   - Would a different ordering or split be clearer?

   When uncertain about a finding, say so explicitly — "I can't assess whether this timeout is appropriate without
   knowing the downstream SLA" is more useful than guessing or staying silent.

7. **Verdict**:
   - **Ship it** — no meaningful issues
   - **Ship with minor findings** — issues noted, none blocking; list them
   - **Revise** — specific changes required before merging; list in priority order (criticals first)
   - **Rethink** — the approach has problems; explain what, why, and suggest direction

8. **Actionable close**: For each finding, indicate whether you'd fix it yourself (mechanical, clear-cut) or whether it
   needs the author's judgment. Then ask: "Want me to draft fixes for any of these?"

9. **If iterating (xN > 1)**: After the first critique pass, fix all mechanical findings and any findings the user
   approves. Then re-read the updated artifact (re-gather the diff for code, re-read the files for non-code) and run
   steps 6-8 again. Each subsequent pass should find fewer issues — if a pass finds nothing new, stop early. Report
   iteration count: "Pass 2/3: N new findings" or "Pass 2/3: no new findings — stopping."

## Guidelines

- Be direct. Bad work gets called bad, with explanation.
- Cite `file_path:line_number`. Vague findings are worthless.
- "This is wrong" and "I would do this differently" are both valid — label which is which.
- No praise padding. The verdict speaks for the work.
- Skip clean dimensions. Don't enumerate with nothing to say.
- `intensive` must produce findings that the default mode couldn't. If it doesn't, say so.
- For stacks: a stack where each PR is fine but the sequence is incoherent is still a problem.
- Order findings: criticals first, then majors, then minors.
- `/critique` is for adversarial review of finished work (diffs, PRs, stacks, artifacts). For iterative improvement
  during authoring (prose, code, analysis), use `/refine` instead.
