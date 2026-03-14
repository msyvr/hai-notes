---
name: refine
description: Iteratively improve a response through self-critique. Use when the user wants to refine, improve, or iterate on a previous response.
---

# Refine Response

Iteratively improve a response through mid-weight engineering self-critique. Each pass should apply the judgment of an
experienced engineer — not just "is this clear?" but "would I push back on this in review?"

## Usage

- `/refine 3` — Refine your previous response 3 times
- `/refine 3 focus on error handling` — Refine 3 times, each pass prioritizing error handling
- `/refine 3 yes use Redis` — Incorporate that context, then refine 3 times
- `/refine 3 explain gradient descent` — Generate response to that prompt, then refine 3 times

## Process

1. Parse the iteration count (first argument; if present, must be integer > 0)
   - If missing or invalid, default to 1
   - If greater than 9, ask the user to confirm: "Refining N times — continue, or cap at 9?"

2. **Determine context type**: Is the response being refined about code, or about a non-code artifact (design,
   documentation, skill definitions, proposals, analysis)?
   - This determines which critique dimensions to emphasize — not whether to apply rigor. Non-code work gets the same
     depth of scrutiny; the dimensions just shift (e.g., "Correctness" becomes "would someone following this do the
     right thing?" rather than "does this compile and pass tests?").

3. If additional arguments are provided, classify them into one of three categories:

   **Refinement directive** — The arguments describe _how_ to refine, not _what_ to respond to. They act as a lens or
   constraint applied to every iteration.
   - Signals: references the previous response implicitly ("focus on...", "make it more...", "emphasize...", "with X in
     mind"), or is a short modifier phrase that only makes sense as a per-pass filter
   - Examples: `focus on performance`, `make it more concise`, `with security in mind`

   **Preamble context** — The arguments answer a question, pick an option, or supply missing info that should be
   addressed _before_ refinement starts. They don't make sense as a per-iteration constraint.
   - Signals: answers a question from the previous response, is a short factual reply, picks among presented
     alternatives, or provides a clarification the previous response needed
   - Examples: `yes, use Redis`, `Python 3.12`, `the second approach`

   **New prompt** — The arguments are a standalone request that needs an initial response generated first.
   - Signals: a complete sentence or question that stands on its own without referencing the prior response
   - Examples: `explain gradient descent`, `write a retry decorator with exponential backoff`

   **Classification heuristics** (apply in order; pick the first match and move on — do not deliberate):
   1. Previous response asked a question or presented options, and the extra args answer/select → **preamble**
   2. Short modifier phrase that implies "refine the existing response this way" → **refinement directive**
   3. Standalone sentence or question → **new prompt**
   4. When ambiguous, state your interpretation in one sentence, then proceed

4. Handle based on classification:
   - **No extra args**: proceed directly to the refinement loop on the previous response
   - **Refinement directive**: proceed to the refinement loop; thread the directive into each iteration's critique as a
     priority focus area
   - **Preamble context**: first, incorporate the context into/update the previous response (e.g., re-answer using the
     clarification), then enter the refinement loop on that updated response
   - **New prompt**: generate an initial response to the prompt, then enter the refinement loop on that response

5. Refinement loop — for each iteration (1 to N):

   ```
   ## Refinement [N]

   **Issues found:**
   - [specific problems from the critique dimensions below]
   - [if a refinement directive is active, explicitly evaluate against it here]

   **Improved response:**
   [full revised response]
   ```

6. Stop early if 100% confident no improvements remain — state why

## Critique dimensions

Each refinement pass should evaluate across these dimensions. Skip what's clean — go deep where it matters.

**Correctness** — For code: logic errors, unhandled edge cases, incorrect assumptions. Does it actually work? Would it
break under realistic conditions? For non-code: would someone following these instructions do the right thing? Are there
ambiguities that would cause inconsistent behavior?

**Design** — Is this the right approach, or is there a materially better alternative? Are abstractions at the right
level? Would an experienced engineer accept this decomposition, or push back?

**Completeness** — Are there gaps the reader will hit? Missing error cases, unstated assumptions, important caveats
omitted? Does it answer the question that was actually asked?

**Consistency** — Does this match the patterns, conventions, and style of the surrounding codebase or context? Does it
introduce a second way of doing something that already has an established pattern?

**Clarity** — Can the reader follow this without re-reading? Is the structure logical? Are names precise? Is there
unnecessary complexity that obscures the intent?

**Economy** — Is this as concise as it can be without losing substance? Verbose explanations, redundant qualifications,
and hedging dilute the value.

## Guidelines

- Each refinement should be meaningfully different, not cosmetic
- Apply engineering judgment, not just editorial polish — "this API design is awkward" matters more than "this sentence
  is wordy"
- For code: verify correctness on each pass. For non-code: verify that instructions are unambiguous and complete on each
  pass.
- Final refinement should be production-ready
- Keep meta-commentary minimal: classification reasoning should be at most one sentence; iteration headers and issue
  lists should be concise so the improved response gets the space
- For preamble handling, make targeted updates — don't regenerate the entire response from scratch unless the context
  fundamentally changes the answer
- `/refine` is for iterative improvement during authoring. For adversarial review of finished work (diffs, PRs, stacks),
  use `/critique` instead.
