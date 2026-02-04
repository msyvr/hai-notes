# Refine Response

Iteratively improve a response through self-critique.

## Usage

- `/refine 3` — Refine your previous response 3 times
- `/refine 3 explain the reward shaping algorithm` — Generate response, then refine 3 times

## Process

1. Parse the iteration count (first argument, must be integer 2-9)
   - If missing or invalid, reply: "Specify iterations 2-9, e.g., `/refine 3`" and stop

2. If additional arguments provided, generate initial response to that prompt first

3. For each iteration (1 to N):

   ```
   ## Refinement [N]

   **Issues with previous response:**
   - [specific problems: unclear, incomplete, incorrect, verbose, etc.]

   **Improved response:**
   [full revised response]
   ```

4. Stop early if 100% confident no improvements possible — state why

## Guidelines

- Each refinement should be meaningfully different, not cosmetic
- Focus on: accuracy, clarity, completeness, conciseness
- If the response involves code, verify correctness on each pass
- Final refinement should be production-ready
