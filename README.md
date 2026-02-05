# :notes: HAI Notes

A context continuity system for Claude Code that persists project knowledge across sessions and compactions.

## Core Problem

Claude Code sessions lose context on compaction and between sessions. This system preserves:

- What you're working on
- Decisions and their reasoning
- Open questions and knowledge gaps
- Historical work for selective retrieval

## Directory Structure

```
~/.claude/
├── CLAUDE.md                          # Global behavioral config
├── settings.json                      # Hooks (SessionStart, PreCompact, etc.)
├── commands/
│   ├── take-notes.md                  # Save current session state
│   ├── refine.md                      # Iterative response improvement
│   ├── qlog.md                        # Log knowledge gaps
│   ├── check-commit.md                # Pre-commit review
│   └── check-pr.md                    # PR self-review
└── session-notes/
    └── {project-name}/
        ├── index.md                   # Searchable session index (tags, summaries)
        ├── {timestamp}.md             # Individual session files
        ├── {timestamp}-{topic}.md     # Renamed after completion
        └── open-questions/
            └── log.md                 # Append-only knowledge gap log
```

## How It Works

**Session start:**

1. Project name derived from launch directory basename
2. Mismatch detection prompts if launched from subdirectory
3. Claude skims `index.md` for recent session context
4. Loads specific session files only when relevant

**During work:**

- `/take-notes` captures current state manually
- `/qlog` logs questions/gaps with location, description, urgency
- PreCompact hook auto-saves before context compression

**Session end:**

- State saved with topic suffix
- Index updated with tags and summary

## Slash Commands

| Command         | Purpose                                           |
| --------------- | ------------------------------------------------- |
| `/take-notes`   | Save session state to timestamped file            |
| `/refine N`     | Iterate N times (2-9) on previous response        |
| `/qlog`         | Log a knowledge gap (location, question, urgency) |
| `/check-commit` | Review staged changes before commit               |
| `/check-pr`     | Self-review before submitting PR                  |

## Session File Schema

Each session file contains structured sections:

- **Approaches Tried** — what was attempted, outcomes, why kept/abandoned
- **Constraints Discovered** — limitations, dependencies, edge cases
- **Decisions Made** — choice, alternatives, reasoning
- **Open Questions** — unresolved issues, things to investigate

## Context Organization Principle

Where information belongs:

| Location                   | What goes there                                     |
| -------------------------- | --------------------------------------------------- |
| `CLAUDE.md`                | Behavioral constraints, conventions, workflow rules |
| `session-notes/{project}/` | Session state, decisions, historical work           |
| Standalone files           | Large docs, long code examples                      |

---

# General Preferences & Workflows

These preferences apply broadly, independent of the session notes system.

## Communication Style

- Direct, technically precise
- Concrete examples over abstractions
- Terse responses; expand only when asked

## Code Standards

- Explicit over clever
- Error handling required
- Tests for non-trivial changes (specifics in project-level CLAUDE.md)

## Development Workflow

Five-step process for non-trivial tasks:

1. **Plan & Agree** — clarify requirements, probe alternatives, confirm approach
2. **Define Success Criteria** — tests, performance targets, security considerations
3. **Implement** — write code; run `/refine` for complex work
4. **Verify** — run tests, check targets, summarize outcomes
5. **Iterate** — diagnose failures, fix, re-verify

## Quality Gates

**Pre-commit (`/check-commit`):**

- Explain each change and why
- Flag uncovered edge cases
- Note potential rollback approach

**Pre-PR (`/check-pr`):**

- Confirm diff matches stated intent
- Flag code requiring deeper understanding
- Generate draft PR description

## Response Iteration

After substantive responses, `/refine N` available (N = 2-9) for iterative improvement. Claude auto-runs refinement for complex code with multiple valid approaches.

## Plan Mode

Use for anything non-trivial:

- Multiple files affected
- Unclear requirements
- Significant code changes (>50 lines)

Iterate on the plan before implementation begins.

## Deferred / Future

- Subagents (code-reviewer, etc.) — Phase 2+
- RLM library integration — Phase 3
