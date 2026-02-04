Before staging, review changes for commit readiness.

1. Run `git diff` (or `git diff --cached` if files already staged)
2. For each changed file, explain:
   - What changed and why
   - Any edge cases not covered by tests
   - Potential rollback approach if this breaks something
3. Flag anything that:
   - You (Claude) are uncertain about
   - Lacks test coverage
   - Touches critical paths
4. Ask: "Ready to stage, or want to address something first?"
