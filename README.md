# Test reporting sample

One repo with a .NET API, an Angular page, and all test levels. A single GitHub Actions pipeline runs them and posts the result to a Teams channel.

| Folder | What it is | Tests |
|---|---|---|
| `api/` | .NET 10 minimal API with static data (`/api/properties`, `/api/health`) | MSTest |
| `web/` | Angular page that lists the properties | Vitest |
| `bruno/` | API tests against the running API | Bruno CLI |
| `playwright/` | UI tests against the running page | Playwright |

## Run locally
```bash
cd api/SampleApi && dotnet run --urls http://localhost:5003   # terminal 1
cd web && npm install && npm start                            # terminal 2, http://localhost:4200
cd bruno && npm install && npm test                           # terminal 3
cd playwright && npm install && npx playwright install chromium && npm test
```

## Pipeline
`.github/workflows/test-report.yml` needs one repository secret, `TEAMS_WORKFLOW_URL` (a Teams Workflows "post when a webhook request is received" URL).
