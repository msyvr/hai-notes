# Move Note

Extract the most recent checkpoint from the current session file and move it to a different project's session notes.

**Usage:**
- `/move-note` — prompts for target project
- `/move-note my-project` — moves to the specified project

## Process

1. Read the timestamp prefix from `~/.claude/session-notes/{current-project}/.current_session` and glob to find the current session file.

2. Read the session file and find the last `SESSION_NOTES_CHECKPOINT`. Extract everything after it (the most recent checkpoint section). If no sentinel exists, extract from the last `## [HH:MM] Checkpoint` heading to the end.

3. **Identify the target project:**
   - If `$ARGUMENTS` provides a project name, use it.
   - Otherwise, list directories in `~/.claude/session-notes/` and use `AskUserQuestion` to let the user pick or type a new project name.

4. **Create the note in the target project:**
   - Ensure `~/.claude/session-notes/{target-project}/` exists.
   - Create a new file: `{target-project}/{original-timestamp}-moved.md` with the extracted checkpoint content.
   - Add an index entry in the target project's `index.md` (create `index.md` if needed).
   - Use `AskUserQuestion` to propose a theme for the new file (same as `/take-notes` step 5), then rename accordingly.

5. **Clean up the source file:**
   - Remove the extracted checkpoint section from the source session file.
   - Update the source project's index entry (tags/summary may have changed with that section removed).

6. Report what was moved and where.

## Notes

- This only moves the most recent checkpoint, not the entire session file.
- The source file retains all prior checkpoints.
- If the source file only had one checkpoint, it becomes effectively empty (just the `# Session:` heading). The source index entry should update to reflect `no-notes`.
