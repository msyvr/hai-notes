# Review Notes

Search session notes for relevant context. Accepts an optional query argument: any text after `/review-notes` is used as the search topic.

**Usage:**
- `/review-notes` — summarize recent sessions
- `/review-notes observations performance` — find notes related to observations performance
- `/review-notes what was the cache warming issue` — find notes matching a natural language question

## Process

1. **Determine project** from `~/.claude/session-notes/` using the current working directory name.

2. **Read `index.md`** to get the full list of sessions with their tags and summaries.

3. **Select sessions to search:**
   - Start with the **5 most recent** session files (by filename date, newest first).
   - Read the timestamp prefix from `.current_session` and exclude any file matching `{timestamp}*.md` — that's the live session, not archived notes.

4. **If a query argument was provided** (`$ARGUMENTS`):
   a. First pass: scan `index.md` tags and summaries for relevance to the query.
   b. Read the full content of sessions that look relevant (up to 5).
   c. If no relevant sessions found in the 5 most recent, report that and offer:
      - "No matches in the 5 most recent sessions. Want me to search all {N} sessions?"
   d. Extract and present findings organized by relevance, not chronology.

5. **If no query argument was provided:**
   a. Read the 5 most recent sessions.
   b. Present a concise digest: for each session, show date, tags, and 2-3 key bullet points (decisions, constraints, open questions).

6. **Format output** as:

   ```markdown
   ## Session Notes Review

   **Query:** {query or "recent sessions overview"}
   **Sessions searched:** {count} of {total}

   ### Findings

   {organized findings — group by theme if query provided, by session if overview}

   ### Open Questions (still unresolved)

   {any open questions from matched sessions that remain relevant}
   ```

7. **If results are thin**, append:
   > Searched {N} of {total} sessions. Run `/review-notes {query} --all` to search the full archive.

## Notes

- This is read-only — it never modifies session files or index.md.
- When a query matches multiple sessions, synthesize across them rather than repeating per-session.
- Prioritize: decisions and their reasoning > constraints discovered > open questions > accomplishments.
- Keep output concise. Link to session filenames so the user can dig deeper with `Read` if needed.
