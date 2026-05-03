# Quickstart: Research Agent

## Prerequisites

- Python 3.11
- OpenAI API access for GPT-4
- Tavily API access for web search

## Environment

Export runtime secrets before starting the service:

```bash
export OPENAI_API_KEY=your-openai-key
export TAVILY_API_KEY=your-tavily-key
```

Create the report output directory if it does not exist:

```bash
mkdir -p outputs
```

## Install Dependencies

The repository already includes core dependencies in `requirements.txt`. During
implementation, add the service/runtime packages required by this plan:

```bash
pip install -r requirements.txt
pip install fastapi sse-starlette structlog pytest-anyio uvicorn
```

## Run the Service

```bash
uvicorn main:app --reload
```

## Start a Research Job

```bash
curl -X POST http://localhost:8000/research \
  -H "Content-Type: application/json" \
  -d '{"question":"What are the latest open-source trends in agent orchestration?"}'
```

Expected response:

```json
{
  "request_id": "req_123",
  "status": "queued",
  "events_url": "/research/req_123/events",
  "report_url": "/research/req_123/report"
}
```

## Stream Progress

```bash
curl -N http://localhost:8000/research/req_123/events
```

Expected event sequence:

1. `planning`
2. `plan_ready`
3. `searching`
4. one or more `subquestion_done`
5. `synthesizing`
6. `complete` or `error`

## Fetch the Final Report

```bash
curl http://localhost:8000/research/req_123/report
```

The same report is also written to `outputs/req_123.md`.

## Test Strategy

Run the automated test suite with pytest:

```bash
pytest
```

Implementation must include:

- unit tests for agent prompts, model validation, markdown rendering, and
  outcome classification
- integration tests for end-to-end research orchestration with mocked providers
- contract tests for the HTTP API and SSE event stream
- coverage checks that keep repository coverage above 80%
