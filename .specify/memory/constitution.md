<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles:
  - template principle 1 -> I. Type-Safe Agent Contracts
  - template principle 2 -> II. Async-First External I/O
  - template principle 3 -> III. Pytest Quality Gates
  - template principle 4 -> IV. Secret-Safe Configuration
  - template principle 5 -> V. Structured Observability
- Added sections:
  - Technical Standards
  - Delivery Workflow & Quality Gates
- Removed sections: None
- Templates requiring updates:
  - ✅ updated: /workspace/.specify/templates/plan-template.md
  - ✅ updated: /workspace/.specify/templates/spec-template.md
  - ✅ updated: /workspace/.specify/templates/tasks-template.md
  - ⚠ pending: /workspace/.specify/templates/commands/*.md (directory not present in this repository)
- Follow-up TODOs: None
-->
# ai-agents-dev Constitution

## Core Principles

### I. Type-Safe Agent Contracts
All agent inputs, outputs, tool payloads, and persisted exchange objects MUST be
defined as explicit Pydantic models with validated field types. Unstructured
dictionaries, ad hoc JSON blobs, and implicit schema contracts MUST NOT cross
module boundaries unless they are immediately parsed into typed models at the
edge. Rationale: pydantic-ai workflows are reliable only when agent state and
tool contracts remain explicit, validated, and reviewable.

### II. Async-First External I/O
Code that touches network, model APIs, files, or other blocking integrations MUST
be implemented with async interfaces first, and HTTP integrations MUST use
aiohttp unless a documented exception is approved. Synchronous wrappers MAY exist
only at process boundaries and MUST delegate to the async implementation rather
than duplicating logic. Rationale: AI agent systems spend most of their time in
I/O-bound orchestration, so async-first design is required for throughput,
timeouts, and cancellation safety.

### III. Pytest Quality Gates
Every shipped behavior MUST be covered by pytest-based unit, integration, or
contract tests, and the repository MUST maintain greater than 80% automated test
coverage. A feature is not complete until new tests fail before implementation,
pass after implementation, and preserve the coverage threshold in CI or local
verification. Rationale: agent behavior changes are difficult to reason about
without executable regression protection and measurable coverage discipline.

### IV. Secret-Safe Configuration
Secrets, API keys, tokens, and credentials MUST NOT be committed to source,
hard-coded in examples, or embedded in test fixtures. Runtime configuration for
OpenAI and related services MUST be loaded from environment variables or secret
stores, and documentation MUST name required variables without exposing values.
Rationale: AI integrations are security-sensitive and frequently depend on paid
credentials that must remain revocable and environment-specific.

### V. Structured Observability
Application and agent execution paths MUST emit structured logs with stable field
names that capture request context, model/tool identifiers, outcomes, and failure
causes without leaking secrets or sensitive payloads. Human-only print debugging
is insufficient for production code; log records MUST support filtering,
aggregation, and incident review. Rationale: agent systems are probabilistic and
multi-step, so structured logging is required to diagnose behavior reliably.

## Technical Standards

The approved baseline stack for this project is Python with pydantic-ai, the
OpenAI API, aiohttp for HTTP I/O, and pytest for automated verification. New
dependencies that overlap with these defaults MUST include a written justification
in the implementation plan. All feature specs and plans MUST state how typed
models, async I/O, logging, secrets handling, and coverage requirements will be
satisfied before implementation begins.

## Delivery Workflow & Quality Gates

Plans MUST fail Constitution Check unless they confirm typed Pydantic contracts,
async aiohttp integration strategy, pytest coverage impact, secret-safe
configuration, and structured logging. Task breakdowns MUST include work for
tests, environment configuration, and observability whenever a feature changes
runtime behavior or external integrations. Pull requests and reviews MUST treat
violations of these principles as blocking unless an amendment to this
constitution is approved first.

## Governance

This constitution supersedes conflicting local practices for the repository.
Amendments require a documented change to this file, a synchronized review of
affected templates and guidance artifacts, and an explicit semantic version
decision: MAJOR for incompatible governance changes or principle removals, MINOR
for new principles or materially expanded requirements, and PATCH for
clarifications that do not change expected behavior. Compliance review MUST occur
in every plan, task list, and pull request that affects production code or
project templates.

**Version**: 1.0.0 | **Ratified**: 2026-05-03 | **Last Amended**: 2026-05-03
