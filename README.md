# libri-infra

Local development infrastructure for the Libri platform — brings up Postgres,
Redis, the API, the crawler, and the admin frontend with a single command.

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
docker compose logs -f admin
```

## Accessing the app

The admin frontend is available at `http://localhost:3000`. It proxies API
requests under `/api/` to the `api` service internally — no separate API URL
configuration is needed.

The API is also directly exposed on `http://localhost:8080` if needed for
debugging or external tools.

## Service reference

| Service  | Host port | Notes                                                                                       |
| -------- | --------- | ------------------------------------------------------------------------------------------- |
| postgres | `5433`    | Mapped to `5433` to avoid clashing with a local Postgres instance. Internal port is `5432`. |
| redis    | `6379`    |                                                                                             |
| api      | `8080`    |                                                                                             |
| crawler  | —         | No exposed ports; communicates via Redis.                                                   |
| admin    | `3000`    | Vue admin frontend, proxies `/api/` to `api`.                                               |

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
| `ADMIN_TAG`                  | Image tag for `libri-admin`                     | `latest`   |
| `CLERK_JWKS_URL`             | Clerk JWKS endpoint for auth verification (api) | _required_ |
| `VITE_CLERK_PUBLISHABLE_KEY` | Clerk publishable key (admin)                   | _required_ |
| `VITE_CLERK_JWT_TEMPLATE`    | Clerk JWT template name (admin)                 | _required_ |
| `VITE_SENTRY_DSN`            | Sentry DSN for error reporting (admin)          | _required_ |
