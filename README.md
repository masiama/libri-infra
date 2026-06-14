# libri-infra

Local development infrastructure for the Libri platform — brings up Postgres,
Redis, the API, and the crawler with a single command.

## Repositories

- [libri-api](https://github.com/masiama/libri-api) — Kotlin/Spring Boot backend
- [libri-crawler](https://github.com/masiama/libri-crawler) — Go crawler

## Prerequisites

- Docker & Docker Compose

## Setup

```bash
git clone https://github.com/masiama/libri-infra
cd libri-infra
cp .env.example .env
```

Edit `.env` and fill in `CLERK_JWKS_URL` (required for the api service to
start).

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

## Connecting the frontend

The API is exposed on `http://localhost:8080`. Point your local Vue dev server
at it, e.g.:

```bash
VITE_API_BASE_URL=http://localhost:8080
```

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

| Variable         | Description                               | Default    |
| ---------------- | ----------------------------------------- | ---------- |
| `API_TAG`        | Image tag for `libri-api`                 | `latest`   |
| `CRAWLER_TAG`    | Image tag for `libri-crawler`             | `latest`   |
| `CLERK_JWKS_URL` | Clerk JWKS endpoint for auth verification | _required_ |
