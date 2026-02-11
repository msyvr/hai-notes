# Refine Response

Iteratively improve a response through self-critique.

## Usage

- `/refine 3` — Refine your previous response 3 times
- `/refine 3 focus on error handling` — Refine 3 times, each pass prioritizing error handling
- `/refine 3 yes use Redis` — Incorporate that context, then refine 3 times
- `/refine 3 explain gradient descent` — Generate response to that prompt, then refine 3 times

## Process

1. Parse the iteration count (first argument; if present, must be integer 1-9)
   - If missing or invalid, default to 1

2. If additional arguments are provided, classify them into one of three categories:

   **Refinement directive** — The arguments describe *how* to refine, not *what* to respond to. They act as a lens or constraint applied to every iteration.
   - Signals: references the previous response implicitly ("focus on...", "make it more...", "emphasize...", "with X in mind"), or is a short modifier phrase that only makes sense as a per-pass filter
   - Examples: `focus on performance`, `make it more concise`, `with security in mind`

   **Preamble context** — The arguments answer a question, pick an option, or supply missing info that should be addressed *before* refinement starts. They don't make sense as a per-iteration constraint.
   - Signals: answers a question from the previous response, is a short factual reply, picks among presented alternatives, or provides a clarification the previous response needed
   - Examples: `yes, use Redis`, `Python 3.12`, `the second approach`

   **New prompt** — The arguments are a standalone request that needs an initial response generated first.
   - Signals: a complete sentence or question that stands on its own without referencing the prior response
   - Examples: `explain gradient descent`, `write a retry decorator with exponential backoff`

   **Classification heuristics** (apply in order; pick the first match and move on — do not deliberate):
   1. Previous response asked a question or presented options, and the extra args answer/select → **preamble**
   2. Short modifier phrase that implies "refine the existing response this way" → **refinement directive**
   3. Standalone sentence or question → **new prompt**
   4. When ambiguous, state your interpretation in one sentence, then proceed

3. Handle based on classification:

   - **No extra args**: proceed directly to the refinement loop on the previous response
   - **Refinement directive**: proceed to the refinement loop; thread the directive into each iteration's critique as a priority focus area
   - **Preamble context**: first, incorporate the context into/update the previous response (e.g., re-answer using the clarification), then enter the refinement loop on that updated response
   - **New prompt**: generate an initial response to the prompt, then enter the refinement loop on that response

4. Refinement loop — for each iteration (1 to N):

   ```
   ## Refinement [N]

   **Issues with previous response:**
   - [specific problems: unclear, incomplete, incorrect, verbose, etc.]
   - [if a refinement directive is active, explicitly evaluate against it here]

   **Improved response:**
   [full revised response]
   ```

5. Stop early if 100% confident no improvements possible — state why

## Guidelines

- Each refinement should be meaningfully different, not cosmetic
- Focus on: accuracy, clarity, completeness, conciseness
- If a refinement directive is active, treat it as an additional priority alongside the defaults above
- If the response involves code, verify correctness on each pass
- Final refinement should be production-ready
- Keep meta-commentary minimal: classification reasoning should be at most one sentence; iteration headers and issue lists should be concise so the improved response gets the space
- For preamble handling, make targeted updates — don't regenerate the entire response from scratch unless the context fundamentally changes the answer
