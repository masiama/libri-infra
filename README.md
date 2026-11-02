# libri-infra

Local development infrastructure for the Libri platform — brings up Postgres,
Redis, the API and the crawler with a single command. Run the frontends
(`libri-admin`, `libri-web`) with `pnpm dev` against it.

## Repositories

- [libri-api](https://github.com/masiama/libri-api) — Kotlin/Spring Boot backend
- [libri-crawler](https://github.com/masiama/libri-crawler) — Go crawler
- [libri-admin](https://github.com/masiama/libri-admin) — Vue admin frontend

## Prerequisites

- Docker & Docker Compose

## Setup

```bash
git clone https://github.com/masiama/libri-infra
cd libri-infra
cp .env.example .env
```

Edit `.env` and fill in the required values (`CLERK_JWKS_URL`,
`VITE_CLERK_PUBLISHABLE_KEY`, `VITE_CLERK_JWT_TEMPLATE`).

## Usage

Start everything:

```bash
docker compose up -d
```

Stop everything:

```bash
docker compose down
```

Stop and wipe all data (database, redis, images volume):

```bash
docker compose down -v
```

View logs:

```bash
docker compose logs -f api
docker compose logs -f crawler
```

## Accessing the app

The API is exposed on `http://localhost:8080`. Run a frontend with `pnpm dev`
and set its `VITE_API_BASE` to that URL; Vite proxies `/api/v1` to it.

## Service reference

| Service  | Host port | Notes                                                                                       |
| -------- | --------- | ------------------------------------------------------------------------------------------- |
| postgres | `5433`    | Mapped to `5433` to avoid clashing with a local Postgres instance. Internal port is `5432`. |
| redis    | `6379`    |                                                                                             |
| api      | `8080`    |                                                                                             |
| crawler  | —         | No exposed ports; communicates via Redis.                                                   |

Database credentials (`libri` / `libri` / db `libri`) are hardcoded in
`docker-compose.yml` since both the database and its user only exist within this
compose stack.

## Shared storage

The `images` named volume is mounted at `/images` in both `api` and `crawler`,
so book cover images written by the crawler are immediately available to the
API.

## Environment variables

See [`.env.example`](.env.example) for all configurable values:

| Variable                     | Description                                     | Default    |
| ---------------------------- | ----------------------------------------------- | ---------- |
| `API_TAG`                    | Image tag for `libri-api`                       | `latest`   |
| `CRAWLER_TAG`                | Image tag for `libri-crawler`                   | `latest`   |
| `CLERK_JWKS_URL`             | Clerk JWKS endpoint for auth verification (api) | _required_ |

## Monitoring

Grafana Alloy collects host, container, API, Postgres and Redis metrics and
pushes them to Grafana Cloud (free tier). The plan and dashboard design are in
`docs/monitoring.md` in the parent workspace.

1. Fill the monitoring variables in `.env` (see [`.env.example`](.env.example)):

   | Variable                       | Description                                                      |
   | ------------------------------ | ---------------------------------------------------------------- |
   | `ALLOY_HOST`                   | `host` label on every series (`oracle-app`, `oracle-db`, `mac`) |
   | `GRAFANA_CLOUD_PROMETHEUS_URL` | Prometheus remote-write URL of the Grafana Cloud stack           |
   | `GRAFANA_CLOUD_USER`           | Prometheus user ID of the stack                                  |
   | `GRAFANA_CLOUD_TOKEN`          | Access policy token with `metrics:write`                         |

2. Start Alloy next to the stack:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.alloy.yml up -d
   ```

Config files in [`monitoring/`](monitoring):

- `common.alloy`: host and container metrics, the Grafana Cloud push. Every host.
- `api.alloy`: scrapes the API's private management port (`api:8081`).
- `db.alloy`: Postgres and Redis exporters.
- `dashboard.json`: the Grafana dashboard (Dashboards → New → Import).
- `alerts.yaml`: the alert rules, exported from Grafana (Alert rules → More → Export).

Alloy loads every `.alloy` file mounted into `/etc/alloy/libri`. On a host with only
the API (or only the DB), remove the other file's mount line from the Alloy
service.

On macOS, run Alloy natively (Homebrew), not in Docker: inside Docker it sees
OrbStack's VM, not the Mac and its disks.
