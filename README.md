# Test reporting sample

Two small sample apps, each laid out like a Zebra stripe: a .NET API with static data, an Angular page, API tests (Bruno) and UI tests (Playwright). Each project has its own GitHub Actions pipeline that posts its result to a Teams channel.

| Project | Data | API port | Page port | Pipeline |
|---|---|---|---|---|
| `Project1` | Properties | 5003 | 4200 | `.github/workflows/project1.yml` |
| `Project2` | Tenancies | 5004 | 4201 | `.github/workflows/project2.yml` |

Inside each project:

| Folder | What it is | Tests |
|---|---|---|
| `api/` | .NET 10 minimal API | MSTest |
| `web/` | Angular page | Vitest |
| `bruno/` | API tests | Bruno CLI |
| `playwright/` | UI tests | Playwright |

## Run one project locally
Replace `Project1` with `Project2` as needed, and use the ports in the table above.
```bash
cd Project1/api/SampleApi && dotnet run --urls http://localhost:5003   # terminal 1
cd Project1/web && npm install && npm start                            # terminal 2
cd Project1/bruno && npm install && npm test                           # terminal 3
cd Project1/playwright && npm install && npx playwright install chromium && npm test
```

## Pipelines
Each pipeline needs one repository secret, `TEAMS_WORKFLOW_URL`, a Teams Workflows "post when a webhook request is received" URL. A pipeline runs on its own folder's changes or from the Actions tab.
