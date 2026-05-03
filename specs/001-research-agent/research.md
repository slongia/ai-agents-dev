# Research: Research Agent

## Decision 1: Use application-managed hand-off between two pydantic-ai agents and async search tools

**Decision**: Implement a three-stage pipeline: `decompose_agent` creates a
typed `ResearchPlan`, application code executes parallel web searches, and
`synthesize_agent` converts typed search outcomes into a `ResearchReport`.

**Rationale**: This keeps GPT-4 focused on reasoning tasks while application
code owns deterministic concurrency, timeout handling, and partial-failure
behavior. It also cleanly satisfies the constitution requirement that every
boundary object use validated Pydantic models.

**Alternatives considered**:
- A single monolithic agent with search tools was rejected because it mixes LLM
  reasoning with I/O orchestration and makes concurrency harder to control.
- Agent-to-agent delegation was rejected because it gives the LLM unnecessary
  control over search scheduling and retry behavior.

## Decision 2: Expose the feature as an HTTP job API with SSE progress streaming

**Decision**: Use a lightweight FastAPI service with SSE endpoints powered by
`sse-starlette`. The API creates a research job, streams typed progress events,
and exposes the finished markdown report as a separate resource.

**Rationale**: The feature explicitly requires SSE over HTTP and streaming
progress. FastAPI provides a small, well-understood HTTP layer for request
validation and routing, while `sse-starlette` handles event streaming and client
disconnects without replacing aiohttp for outbound web requests.

**Alternatives considered**:
- `aiohttp.web` was rejected because the service still needs pydantic-friendly
  request validation and simpler OpenAPI-style contracts.
- A single blocking HTTP response was rejected because it cannot satisfy the
  progress-streaming requirement.

## Decision 3: Use aiohttp with bounded parallelism and a single-attempt 15-second search budget

**Decision**: Run up to four sub-question searches in parallel with aiohttp,
enforcing a 15-second timeout per sub-question, a bounded connector, and no
automatic retries in the MVP.

**Rationale**: The spec requires a hard per-sub-question timeout and graceful
partial completion. A single bounded attempt keeps latency predictable and makes
progress state easy to understand. Failures are captured as typed outcomes and
fed forward into synthesis instead of aborting the run.

**Alternatives considered**:
- Sequential search was rejected because it would turn one slow source into a
  full-run bottleneck.
- Automatic retries were rejected for v1 because they blur the 15-second budget
  and complicate progress reporting.

## Decision 4: Use a provider adapter with Tavily as the initial web-search backend

**Decision**: Define a provider adapter in `tools/search_provider.py` and
implement the first provider against Tavily's HTTP API, configured through
`TAVILY_API_KEY`.

**Rationale**: The feature needs structured web-search results with source URLs,
titles, and snippets that can feed citations directly. A provider adapter keeps
the orchestration code provider-agnostic while Tavily offers a practical default
for search-oriented LLM workflows.

**Alternatives considered**:
- SerpAPI or Bing were left as future adapters; they were not chosen for the
  first implementation because one provider is enough for MVP scope.
- Direct page scraping was rejected because it adds unnecessary complexity and
  fragility before the orchestration workflow is proven.

## Decision 5: Model all workflow state with explicit Pydantic schemas

**Decision**: Create Pydantic models for request input, sub-questions, research
plans, source findings, per-sub-question outcomes, SSE progress events, and the
final report. Encode the four-sub-question cap in schema validation.

**Rationale**: This directly implements the constitution's type-safety rule and
ensures that agent outputs, SSE payloads, and persisted report metadata remain
consistent and testable. Schema-level validation also prevents silent drift
between orchestrator, tools, and API layers.

**Alternatives considered**:
- Plain dictionaries were rejected because they violate the constitution and are
  harder to validate.
- Dataclasses alone were rejected because they do not provide the same runtime
  validation guarantees at external boundaries.

## Decision 6: Use footnote-style markdown citations and persist reports to `outputs/`

**Decision**: Generate markdown reports with sectioned findings, inline footnote
references such as `[^1]`, a deduplicated citation list, explicit gap notes, and
an ambiguity note when needed. Save each report to `outputs/{request_id}.md`.

**Rationale**: The feature requires cited markdown reports and a filesystem-based
output location. Footnote citations keep prose readable while preserving
traceability, and stable file naming makes retrieval and testing simple.

**Alternatives considered**:
- Inline links in every sentence were rejected because they clutter narrative
  output.
- Database-backed report storage was rejected because the MVP does not require
  multi-user persistence.

## Decision 7: Use `structlog` and a typed outcome state machine for graceful degradation

**Decision**: Represent each sub-question result as a typed success/failure
outcome, synthesize partial reports whenever at least one search succeeds, and
emit structured JSON logs for stage transitions, search outcomes, and final
status using `structlog`.

**Rationale**: Partial completion is a first-class requirement. A typed outcome
model avoids exception-driven business logic and gives both the SSE stream and
final report enough information to distinguish success, timeout, and other
failures. Structured logs satisfy the constitution and keep debugging safe
without exposing full secrets or raw user questions.

**Alternatives considered**:
- Aborting on the first failed search was rejected because it violates the spec.
- Plain-text logging was rejected because it does not meet the observability
  standard for multi-step agent workflows.

## Decision 8: Test at unit, integration, and contract layers with async coverage

**Decision**: Use pytest for all tests, `pytest.mark.anyio` for async execution,
mocked pydantic-ai models for deterministic unit tests, and contract/integration
tests for the HTTP and SSE behavior. Coverage must stay above 80%.

**Rationale**: The feature mixes LLM orchestration, async I/O, SSE streaming,
and partial-failure behavior. That requires layered testing rather than a single
happy-path suite. Deterministic agent/model substitutes keep the core workflows
fast and stable in CI.

**Alternatives considered**:
- Real GPT-4 in unit tests was rejected because it is non-deterministic and too
  expensive for routine validation.
- Manual API checks alone were rejected because they cannot enforce coverage or
  regression safety.
