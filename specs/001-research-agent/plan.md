# Implementation Plan: Research Agent

**Branch**: `001-build-research-agent` | **Date**: 2026-05-03 | **Spec**: `specs/001-research-agent/spec.md`
**Input**: Feature specification from `/specs/001-research-agent/spec.md`

## Summary

Build a Python HTTP research service that accepts a natural-language question,
uses pydantic-ai with OpenAI GPT-4 to decompose and synthesize the work,
executes up to four parallel web searches with aiohttp, streams Server-Sent
Events (SSE) progress updates, and saves a cited markdown report to `outputs/`.

## Technical Context

**Language/Version**: Python 3.11  
**Primary Dependencies**: pydantic, pydantic-ai, openai, aiohttp, FastAPI,
sse-starlette, structlog, pytest, pytest-anyio  
**Storage**: Local filesystem in `outputs/` for generated markdown reports; no
database in v1  
**Testing**: pytest with unit, integration, and contract coverage above 80%  
**Target Platform**: Linux server exposing an HTTP API with SSE streaming  
**Project Type**: Single-project backend/web-service  
**Performance Goals**: First SSE progress event within 5 seconds; at most 4
parallel sub-question searches; 15-second timeout per sub-question; terminal
`complete` or `error` event on every run  
**Constraints**: OpenAI GPT-4 orchestrator, aiohttp for outbound web requests,
SSE over HTTP, max 4 sub-questions per request, preserve conflicting findings
with confidence notes, continue after partial failures, no secrets in source,
structured logging, reports written to `outputs/`  
**Scale/Scope**: Interactive single-request MVP for one caller at a time per
run, one markdown report per request, no multi-user persistence or replay store
in v1

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] All agent inputs, outputs, tool payloads, and boundary data are defined with typed
      Pydantic models.
- [x] External I/O is async-first and HTTP integrations use aiohttp or a documented,
      approved exception.
- [x] pytest coverage strategy is defined and keeps repository coverage above 80%.
- [x] Secrets are sourced from environment variables or a secret manager; no secrets are
      committed, hard-coded, or copied into fixtures.
- [x] Structured logging covers critical agent, tool, and integration flows without
      exposing sensitive data.

**Gate Result (Pre-Design)**: PASS  
**Gate Result (Post-Design)**: PASS — `data-model.md`, `contracts/`,
`quickstart.md`, and this plan all preserve the constitution requirements with
typed models, async aiohttp I/O, pytest coverage expectations, env-var
configuration, and structured logging.

## Project Structure

### Documentation (this feature)

```text
specs/001-research-agent/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── research-api.yaml
└── tasks.md
```

### Source Code (repository root)

```text
agents/
├── deps.py
├── decompose.py
├── orchestrator.py
└── synthesize.py

models/
├── events.py
└── research.py

tools/
├── logging_config.py
├── markdown.py
├── search.py
└── search_provider.py

main.py

tests/
├── contract/
├── integration/
└── unit/

outputs/
└── .gitkeep
```

**Structure Decision**: Use a single-project service layout at the repository
root. Keep agent orchestration in `agents/`, all validated schemas in
`models/`, outbound search and markdown/logging helpers in `tools/`, pytest
suites in `tests/`, and generated reports in `outputs/`. The HTTP entrypoint
lives in `main.py`.

## Complexity Tracking

No constitution violations or justified complexity exceptions are required for
this plan.
