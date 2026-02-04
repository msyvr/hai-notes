# Take Notes (Save State)

Save current progress to the session file.

## Process

1. Get current session file path from `~/.claude/session-notes/{project-name}/.current_session`

2. Search backward for `SESSION_NOTES_CHECKPOINT`:
   - If found: summarize only what happened AFTER that point
   - If not found: summarize from session start

3. Append to the session file with a timestamp header:

   ```markdown
   ## [HH:MM] Checkpoint

   **Accomplished:** [what was completed]

   **Decisions:** [key decisions with brief reasoning]

   **Open questions:** [unresolved issues]

   **Next steps:** [concrete actions]
   ```

4. Update `~/.claude/session-notes/{project-name}/index.md`:
   - If no entry exists for this session file, add one
   - Update tags and summary to reflect latest state

   Index entry format:

   ```markdown
   ## {filename}

   - **Date**: {date}
   - **Tags**: {3-5 searchable tags}
   - **Summary**: {one-sentence summary of session focus}
   ```

   If `index.md` doesn't exist, create it with:

   ```markdown
   # Session Archive Index

   Search by tags, date, or keywords. Newest sessions first.

   ---
   ```

5. End your response with exactly:

SESSION_NOTES_CHECKPOINT
