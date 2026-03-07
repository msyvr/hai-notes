# hai-notes

Session notes system for Claude Code. Provides skills and hooks for persistent, structured note-taking across Claude Code sessions.

## What it does

- **Session hooks** automatically create a session file on start, prompt to save before compaction, and log session end
- **Skills** let you save checkpoints (`/take-notes`), search past notes (`/review-notes`), move notes between projects (`/move-note`, `/move-current-session-notes`), log questions (`/qlog`), self-critique responses (`/refine`), and review changes before commits/PRs (`/check-commit`, `/check-pr`)
- **CLAUDE.md instructions** teach Claude how to use session notes as working memory

## Install

```bash
git clone git@github.com:msyvr/hai-notes.git
cd hai-notes
./install.sh
```

This will:
1. Symlink each skill into `~/.claude/skills/`
2. Merge session-notes instructions into `~/.claude/CLAUDE.md` (delimited, non-destructive)
3. Merge hooks into `~/.claude/settings.json` (additive, preserves existing settings)

Re-running `install.sh` is idempotent — it won't create duplicates.

## Uninstall

```bash
./uninstall.sh
```

This will:
1. Remove skill symlinks (only those pointing into this repo)
2. Remove the hai-notes section from `~/.claude/CLAUDE.md`
3. Remove hai-notes hooks from `~/.claude/settings.json`

Session notes data at `~/.claude/session-notes/` is **never deleted** by uninstall.

## Skills

| Skill | Description |
|-------|-------------|
| `/take-notes` | Save current progress to session file |
| `/review-notes` | Search session notes for relevant context |
| `/refine N` | Iteratively improve a response through self-critique |
| `/qlog` | Log an open question for later review |
| `/check-commit` | Review changes before committing |
| `/check-pr` | Self-review before submitting a PR |
| `/move-note` | Move latest checkpoint to a different project |
| `/move-current-session-notes` | Move entire session file to a different project |

## Data

Session notes live at `~/.claude/session-notes/{project-name}/` and are not part of this repo. Each project directory contains:
- `index.md` — searchable manifest of all sessions
- `.current_session` — timestamp prefix of the active session
- `.session.log` — session start/end timestamps
- `{timestamp}-{theme}.md` — individual session files
