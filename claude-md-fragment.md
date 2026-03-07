# Working Memory (Session Notes)

Session notes are working memory—not just history. Use them actively to avoid retreading ground, remember what was ruled out, and build on prior reasoning.

Location: `~/.claude/session-notes/{project-name}/`

## Session Start

1. SessionStart hook outputs project resolution status
2. If output contains `NO_MATCH:`, prompt user with the choices shown (y/n/c)
3. Otherwise, use the indicated session project
4. The hook creates `{timestamp}-no-notes.md` and writes the timestamp prefix to `.current_session`
   - To find the actual file, glob for `{timestamp}*.md` in the project directory
5. Add an initial entry in `index.md` for this session file:
   - **Tags**: `no-notes`
   - **Summary**: `no notes taken yet`
6. Skim `index.md` for recent session summaries
7. If the current task relates to prior work, load the relevant session file **before starting**

## Before Major Decisions

Before choosing an implementation approach, ruling out an alternative, or making an architectural choice:

1. Check notes for **failed approaches**—what was tried and why it didn't work
2. Check for **constraints discovered**—gotchas, edge cases, dependencies found previously
3. Check for **open questions**—unresolved issues that may affect this decision

If notes exist on the topic, load and review them first. Don't rediscover what's already known.

## Mid-Task Checkpoint

At significant milestones or roughly every 30 minutes of work:

1. Review current session notes
2. Ask: "Am I retreading ground already covered?"
3. Update notes with new findings before continuing
4. If stuck, explicitly search notes for related prior work

## What to Record

Structure each session file with these sections:

### Approaches Tried

- What was attempted
- Outcome (worked / partially worked / failed)
- Why it was kept or abandoned

### Constraints Discovered

- Unexpected limitations or requirements
- Dependencies and interactions
- Edge cases that must be handled

### Decisions Made

- The choice
- Alternatives considered
- Reasoning for the decision

### Open Questions

- Unresolved issues
- Things to investigate later
- Uncertainties that may affect future work

## Retrieval Triggers

Actively consult notes when you encounter:

- "We tried this before..." → search notes for prior attempts
- Choosing between approaches → check for failed approaches and constraints
- Unexpected behavior → search for related edge cases or gotchas
- "Why did we..." → search for decision reasoning
- Starting work on a feature touched previously → load that session file

Don't wait to be asked. If context would help, retrieve it.

## Context Organization

When asked to "remember" something or establish a convention, decide where it belongs:

**In CLAUDE.md** (always loaded):

- Behavioral constraints for every task
- Project conventions and coding style
- Workflow rules
- Pointers to reference material

**In the session file** (via /take-notes):

- What we're working on
- Decisions and reasoning
- Open questions and next steps

**In standalone files** (on-demand reference):

- Large documentation
- Code examples longer than ~20 lines
- Anything that would bloat always-on context

# Session Notes & Session Continuity

## Session Notes Protocol

The sentinel `SESSION_NOTES_CHECKPOINT` marks where the last save ended. When saving:

1. Search backward for the sentinel to scope what's new
2. Summarize only what happened after that point (or entire session if no sentinel)
3. End with the sentinel

## Available Commands

- `/take-notes` — Save current progress to session file
- `/review-notes [query]` — Search session notes for relevant context
- `/move-note [project]` — Extract latest checkpoint to a different project's notes
- `/move-current-session-notes [project]` — Move entire current session file to a different project

## Session Notes Directory Structure

```
~/.claude/session-notes/{project-name}/
├── index.md                              # Searchable manifest
├── .session.log                          # Session timestamps
├── .current_session                      # Path to active session file
├── 2026-02-03-0945-context-memory.md     # Completed session
└── 2026-02-03-1430-no-notes.md           # Session where /take-notes was never called
```
