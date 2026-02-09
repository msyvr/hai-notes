# Move Session Note

Move the entire current session file to a different project's session notes.

**Usage:**
- `/move-session-note` — prompts for target project
- `/move-session-note my-project` — moves to the specified project

## Process

1. Read the timestamp prefix from `~/.claude/session-notes/{current-project}/.current_session` and glob to find the current session file.

2. **Identify the target project:**
   - If `$ARGUMENTS` provides a project name, use it.
   - Otherwise, list directories in `~/.claude/session-notes/` and use `AskUserQuestion` to let the user pick or type a new project name.

3. **Move the file:**
   - Ensure `~/.claude/session-notes/{target-project}/` exists.
   - Move the session file to the target project directory (same filename).
   - Write the timestamp prefix to `~/.claude/session-notes/{target-project}/.current_session`.

4. **Update indexes:**
   - Remove the entry from the source project's `index.md`.
   - Add the entry to the target project's `index.md` (create `index.md` if needed).

5. **Clean up source:**
   - Clear the source `.current_session` (the session file no longer lives there).

6. Report what was moved and where.

## Notes

- Moves the entire session file, not just the latest checkpoint. Use `/move-note` to extract a single checkpoint instead.
- The timestamp prefix in `.current_session` stays the same — only the project directory changes.
