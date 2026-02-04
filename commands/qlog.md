Append a question to ~/.claude/session-notes/{session_project}/open-questions/log.md

1. Create the open-questions/ directory if it doesn't exist
2. Prompt user for:
   - **Location**: file/function (or "general")
   - **Question**: what's unclear
   - **Urgency**: blocking | uncomfortable | curious (default: uncomfortable)
3. Append entry:

## {date} | {urgency}

**Location**: `{location}`
**Question**: {question}

4. Confirm: "Logged to open-questions/log.md"
