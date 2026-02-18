# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project snapshot
- `index.html`: Single-file web dashboard for monitoring site health and latency.
- `upwatch.ps1`: Windows PowerShell desktop monitor with similar node + status concepts.
- `README.md`: High-level project and usage docs.

## Working agreements
1. Keep the project lightweight: prefer minimal dependencies and static assets.
2. Preserve the current visual style and terminology (`Inject_Node`, `Purge_Node`, `Upload_Config`, etc.) unless asked to redesign.
3. For web changes, keep logic readable and avoid introducing large framework migrations.
4. For PowerShell changes, keep compatibility with standard Windows PowerShell environments.

## Validation expectations
- For documentation-only changes: run basic repo checks (for example `git status --short`).
- For UI/logic changes in `index.html`: sanity-check by opening in a browser and verifying controls.
- For PowerShell changes: include a syntax check and usage notes if runtime validation is not possible.

## Documentation expectations
- Update `README.md` for user-facing workflow changes.
- Add concise comments only where behavior is non-obvious.
- Include a short roadmap update when adding notable new capabilities.

## Git & PR hygiene
- Use focused commits with clear conventional-ish messages.
- Summarize what changed, why, and how it was validated.
