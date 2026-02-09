# Take Notes (Save State)

Save current progress to the session file.

## Process

1. Read the timestamp prefix from `~/.claude/session-notes/{project-name}/.current_session` and glob for `{timestamp}*.md` in that directory to find the current session file.

2. Search backward for `SESSION_NOTES_CHECKPOINT`:
   - If found: create detailed notes about both process and outcomes for only what happened AFTER that point
   - If not found: create detailed notes about both process and outcomes from session start

3. Append to the session file with a timestamp header:

   ```markdown
   ## [HH:MM] Checkpoint

   **Accomplished:** [what was completed]

   **Decisions:** [key decisions with detailed reasoning]

   **Open questions:** [unresolved issues and any related discussion]

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
   - **Summary**: {summary of session focus}
   ```

   If `index.md` doesn't exist, create it with:

   ```markdown
   # Session Archive Index

   Search by tags, date, or keywords. Newest sessions first.

   ---
   ```

5. **Rename session file to reflect dominant theme:**
   - From the tags and summary you just wrote in the index entry, pick the single most dominant theme (1-3 words, kebab-case).
   - If the file already has the correct suffix, do nothing.
   - Otherwise, use `AskUserQuestion` to propose the theme (as the first option) and offer "Keep current name" as the second. The user can also type their own via "Other".
   - Rename to the confirmed theme, then update the `## {filename}` heading in `index.md` to match.
   - (`.current_session` stores only the timestamp prefix, so no update needed.)

6. End your response with exactly:

SESSION_NOTES_CHECKPOINT
