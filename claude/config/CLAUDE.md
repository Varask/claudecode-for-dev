# Contexte projet

## Infra partagée

| Service    | Adresse interne           |
|------------|---------------------------|
| PostgreSQL | `postgres:5432`           |
| Redis      | `redis:6379`              |

## Projets disponibles

| Container    | Code         | Port  |
|--------------|--------------|-------|
| `project-a`  | `/app/src`   | 3000  |
| `project-b`  | `/app/src`   | 3001  |

## Accès au code d'un projet

Le code de chaque projet vit dans son propre container sous `/app/src`.
Claude Code y accède via `docker exec` depuis le script `claude-run.sh`.

## Variables d'environnement disponibles dans les projets

- `DATABASE_URL` — connexion PostgreSQL
- `REDIS_URL` — connexion Redis
