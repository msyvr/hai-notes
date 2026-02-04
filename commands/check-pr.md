Self-review before submitting PR.

1. Ask user: "What's the one-sentence intent of this PR?"
2. Run `git diff main...HEAD` (or appropriate base branch)
3. Review as if seeing this code for the first time:
   - Does the diff match the stated intent?
   - Any code you (Claude) wrote that the user should understand better? Flag it.
   - Any obvious improvements a reviewer might request?
4. Prompt user to add "confidence notes" to session notes via /take-notes:
   - What do you fully understand?
   - What are you trusting Claude on?
5. Output a draft PR description based on the intent and diff.
