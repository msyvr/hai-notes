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
│   ├── review-notes.md               # Search session notes for context
│   ├── move-note.md                  # Move checkpoint to another project
│   ├── move-current-session-notes.md # Move session file to another project
│   ├── refine.md                      # Iterative response improvement
│   ├── qlog.md                        # Log knowledge gaps
│   ├── check-commit.md                # Pre-commit review
│   └── check-pr.md                    # PR self-review
└── session-notes/
    └── {project-name}/
        ├── index.md                   # Searchable session index (tags, summaries)
        ├── {timestamp}-no-notes.md    # Created by hook; renamed by /take-notes
        ├── {timestamp}-{topic}.md     # Renamed after /take-notes
        └── open-questions/
            └── log.md                 # Append-only knowledge gap log
```

## How It Works

**Session start:**

1. Project name derived from launch directory basename
2. If no session notes exist for the directory, prompts to create or choose a project
3. Hook creates `{timestamp}-no-notes.md` and writes `.current_session`
4. Claude skims `index.md` for recent session context
5. Loads specific session files only when relevant

**During work:**

- `/take-notes` captures current state manually
- `/qlog` logs questions/gaps with location, description, urgency
- PreCompact hook auto-saves before context compression

**Session end:**

- SessionEnd hook logs to `.session.log` and reminds to run `/take-notes`
- `/take-notes` renames file with topic suffix and updates index

## Slash Commands

| Command                          | Purpose                                                              |
| -------------------------------- | -------------------------------------------------------------------- |
| `/take-notes`                    | Save session state to timestamped file                               |
| `/review-notes [query]`         | Search session notes for relevant context                            |
| `/move-note [project]`          | Move latest checkpoint to another project's notes                    |
| `/move-current-session-notes [project]` | Move entire current session file to another project           |
| `/refine N [args]`              | Iterate N times (1-9); args can be directive, preamble, or new prompt |
| `/qlog`                         | Log a knowledge gap (location, question, urgency)                    |
| `/check-commit`                 | Review staged changes before commit                                  |
| `/check-pr`                     | Self-review before submitting PR                                     |

## Session File Format

Each `/take-notes` checkpoint appends:

- **Accomplished** — what was completed
- **Decisions** — key decisions with reasoning
- **Open questions** — unresolved issues and related discussion
- **Next steps** — concrete actions

CLAUDE.md also provides broader content guidelines (Approaches Tried, Constraints Discovered, etc.) for structuring session thinking.

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

After substantive responses, `/refine N` available (N = 1-9) for iterative improvement. Extra arguments serve as a refinement directive, preamble context, or new prompt. Claude auto-runs refinement for complex code with multiple valid approaches.

## Plan Mode

Use for anything non-trivial:

- Multiple files affected
- Unclear requirements
- Significant code changes (>50 lines)

Iterate on the plan before implementation begins.

## Deferred / Future

- Subagents (code-reviewer, etc.) — Phase 2+
- RLM library integration — Phase 3
