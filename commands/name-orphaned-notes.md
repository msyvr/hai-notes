# Name Orphaned Notes Files

Rename session files that lack a topic suffix (from sessions that ended abruptly).

## Process

1. Find orphaned files in `~/.claude/session-notes/{project-name}/`:
   - Pattern: `YYYY-MM-DD-HHMM.md` (no topic suffix)
   - Exclude the current session file

2. For each orphaned file:
   a. Read its contents
   b. Choose a kebab-case topic based on what was discussed (e.g., `reward-shaping`, `agent-protocol`)
   c. Rename from `2026-02-03-0945.md` → `2026-02-03-0945-{topic}.md`
   d. Update or add its entry in `index.md`

3. If a file is empty or contains only the frontmatter, delete it and remove any index entry.

4. Report what was renamed/deleted.
