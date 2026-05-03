# Data Model: Research Agent

## Entities

### ResearchRequest

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `request_id` | string | Yes | Unique identifier for report file naming, SSE correlation, and logs |
| `question` | string | Yes | Non-empty natural-language prompt from the caller |
| `status` | enum | Yes | `queued`, `planning`, `searching`, `synthesizing`, `complete`, `failed` |
| `created_at` | datetime | Yes | Server-generated timestamp |
| `completed_at` | datetime \| null | No | Populated when processing ends |
| `report_path` | string \| null | No | Set to `outputs/{request_id}.md` when a report is written |
| `ambiguity_note` | string \| null | No | Present when the question lacks sufficient specificity |

### SubQuestion

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `index` | integer | Yes | Zero-based position within the plan |
| `text` | string | Yes | Natural-language search question |

### ResearchPlan

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `original_question` | string | Yes | Copy of the request question |
| `sub_questions` | list[`SubQuestion`] | Yes | Length 1-4, enforcing the spec cap |

### Citation

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `index` | integer | Yes | Global footnote number in the final report |
| `url` | string | Yes | Canonical source URL |
| `title` | string | Yes | Human-readable source title |
| `snippet` | string | Yes | Short supporting excerpt or summary |
| `source_type` | string | No | Optional label such as `article`, `docs`, or `news` |

### SourceFinding

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `sub_question_index` | integer | Yes | Links the finding to one planned sub-question |
| `summary` | string | Yes | Condensed evidence for synthesis |
| `citations` | list[`Citation`] | Yes | One or more citations supporting the summary |
| `retrieved_at` | datetime | Yes | Timestamp of collection |

### SubQuestionOutcome

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `sub_question` | `SubQuestion` | Yes | Original planned sub-question |
| `status` | enum | Yes | `success`, `timeout`, `failed` |
| `finding` | `SourceFinding` \| null | No | Present on success |
| `error_type` | string \| null | No | High-level failure category |
| `error_message` | string \| null | No | Sanitized user-safe failure description |

### ProgressEvent

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `event_id` | integer | Yes | Monotonic SSE event id |
| `event_type` | enum | Yes | `planning`, `plan_ready`, `searching`, `subquestion_done`, `synthesizing`, `complete`, `error` |
| `request_id` | string | Yes | Correlates stream messages to the run |
| `stage` | string | Yes | Human-readable stage name |
| `payload` | object | Yes | Event-specific typed content |
| `created_at` | datetime | Yes | Server-generated timestamp |

### ResearchReport

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `question` | string | Yes | Original research question |
| `completeness` | enum | Yes | `complete`, `partial`, `failed` |
| `summary` | string | Yes | Top-level answer overview |
| `sections` | list[`ReportSection`] | Yes | Sectioned markdown findings |
| `citations` | list[`Citation`] | Yes | Deduplicated global footnotes |
| `gaps` | list[string] | Yes | Missing coverage and failure notes |
| `ambiguity_note` | string \| null | No | Present when the request was ambiguous |

### ReportSection

| Field | Type | Required | Validation / Notes |
|---|---|---|---|
| `title` | string | Yes | Section heading in markdown |
| `body` | string | Yes | Markdown content with inline footnote references |

## Relationships

- One `ResearchRequest` produces exactly one `ResearchPlan`.
- One `ResearchPlan` contains one to four `SubQuestion` records.
- Each `SubQuestion` produces exactly one `SubQuestionOutcome`.
- A successful `SubQuestionOutcome` contains one `SourceFinding`.
- One `ResearchReport` aggregates all `SubQuestionOutcome` values for a single
  `ResearchRequest`.
- `ProgressEvent` records are emitted across the lifecycle of a
  `ResearchRequest` and may reference sub-question-specific payloads.

## Validation Rules

- `ResearchPlan.sub_questions` MUST contain no more than four items.
- `ResearchRequest.question` MUST be non-empty after trimming whitespace.
- `SubQuestionOutcome.status = success` requires a non-null `finding`.
- `SubQuestionOutcome.status != success` requires a null `finding` and a
  non-empty error description.
- `ResearchReport.completeness = complete` only when every sub-question outcome
  succeeded.
- `ResearchReport.completeness = failed` only when every sub-question outcome
  failed or timed out.
- Every citation index in report sections MUST resolve to one entry in the global
  `ResearchReport.citations` list.

## State Transitions

### ResearchRequest Lifecycle

`queued` → `planning` → `searching` → `synthesizing` → `complete`

`queued` → `planning` → `searching` → `failed`

`searching` may still transition to `synthesizing` when some sub-questions fail,
as long as at least one successful finding is available.

### SubQuestionOutcome Lifecycle

`planned` → `success`

`planned` → `timeout`

`planned` → `failed`
