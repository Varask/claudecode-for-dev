# claudecode-for-dev

Environnement Docker où chaque projet vit dans son propre container, et Claude Code s'y connecte directement via `docker exec`.

## Démarrage rapide

```bash
# Rendre cdev accessible globalement (optionnel mais recommandé)
sudo ln -s "$(pwd)/cdev" /usr/local/bin/cdev

# Initialiser le projet (wizard guidé)
./cdev init
```

## La commande `cdev`

Tout se gère avec une seule commande :

```
cdev init          → Configurer le projet (wizard guidé)
cdev auth          → Se connecter à Claude (OAuth ou API key)
cdev start         → Démarrer l'infra (PostgreSQL, Redis)
cdev stop          → Arrêter l'infra

cdev new <nom>     → Créer un nouveau projet (wizard)
cdev list          → Lister tous les projets
cdev up <nom>      → Démarrer un projet
cdev down <nom>    → Arrêter un projet
cdev logs <nom>    → Voir les logs

cdev code <nom>    → Ouvrir Claude Code interactif dans un projet

cdev status        → État de tous les services
cdev reset         → Tout supprimer
cdev update        → Mettre à jour Claude Code
```

## Parcours complet (première fois)

```bash
./cdev init        # configure .env, build les images, démarre l'infra
./cdev auth        # connexion OAuth claude.ai
./cdev new mon-api # crée et démarre un projet, propose d'ouvrir Claude Code
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Docker Network                  │
│                                                  │
│  ┌─────────────┐      ┌──────────────────────┐  │
│  │ claude-code │─────▶│  project-a  /app/src │  │
│  │             │─────▶│  project-b  /app/src │  │
│  └─────────────┘      └──────────────────────┘  │
│                                                  │
│       ┌──────────┐        ┌───────┐              │
│       │ postgres │        │ redis │              │
│       └──────────┘        └───────┘              │
└─────────────────────────────────────────────────┘
```

## Structure

```
claudecode-for-dev/
├── cdev                    ← Commande principale
├── auth/                   ← Flow OAuth
├── claude/                 ← Image Claude Code
├── scripts/                ← Scripts internes (appelés par cdev)
├── services/               ← Config PostgreSQL et Redis
├── projects/
│   ├── project-a/
│   └── project-b/
├── docker-compose.yml      ← Infra partagée
├── workflow.html           ← Schéma du workflow
└── .env.example
```

## Prérequis

- Docker & Docker Compose v2
- Un compte [claude.ai](https://claude.ai) Pro/Team **ou** une clé API Anthropic
