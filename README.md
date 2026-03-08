# claudecode-for-dev

Environnement Docker où chaque projet vit dans son propre container. Claude Code s'y connecte directement via `docker exec`. Le code source est cloné depuis Git au démarrage du container.

## Prérequis

- Docker Desktop installé et **démarré**
- macOS / Linux (Windows → WSL2)
- Un compte [claude.ai](https://claude.ai) Pro/Team **ou** une clé API Anthropic

## Installation

```bash
# 1. Cloner le repo
git clone https://github.com/Varask/claudecode-for-dev.git
cd claudecode-for-dev

# 2. Rendre cdev exécutable
chmod +x cdev

# 3. Créer le lien symbolique (accès global)
sudo ln -sf "$(pwd)/cdev" /usr/local/bin/cdev

# 4. Vérifier
cdev
```

> **Note** : le `-f` dans `ln -sf` est important — il écrase un éventuel lien existant.

## Démarrage

```bash
cdev init     # wizard guidé : .env, build Docker, démarrage infra
cdev auth     # connexion OAuth claude.ai (ou API key dans .env)
cdev new mon-api   # crée un projet, demande l'URL du repo Git
cdev code mon-api  # ouvre Claude Code interactif dans le container
```

## La commande `cdev`

```
cdev init          → Wizard de configuration (première fois)
cdev auth          → Se connecter à Claude (OAuth ou API key)
cdev start         → Démarrer l'infra (PostgreSQL, Redis)
cdev stop          → Arrêter l'infra

cdev new <nom>     → Créer un projet (wizard : nom, port, repo Git)
cdev list          → Lister tous les projets et leur statut
cdev up <nom>      → Démarrer un projet (clone le repo au premier démarrage)
cdev down <nom>    → Arrêter un projet
cdev logs <nom>    → Voir les logs en temps réel

cdev code <nom>    → Ouvrir Claude Code interactif dans un projet

cdev status        → État de tous les services + auth
cdev reset         → Tout supprimer (containers + volumes)
cdev update        → Mettre à jour Claude Code
```

## Repos Git

Chaque projet clone son repo Git au démarrage du container. Configurer dans `.env` :

```env
# Repo public (HTTPS)
MON_API_REPO=https://github.com/toi/mon-api.git
MON_API_BRANCH=main

# Repo privé (SSH)
MON_API_REPO=git@github.com:toi/mon-api.git
SSH_KEY_PATH=~/.ssh   # clé montée en lecture seule dans le container
```

Si `GIT_REPO` n'est pas défini, le container démarre vide — prêt pour que Claude Code initialise le projet.

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Docker Network                  │
│                                                  │
│  ┌─────────────┐      ┌──────────────────────┐  │
│  │ claude-code │─────▶│  project-a  /app/src │  │  ← cloné depuis Git
│  │             │─────▶│  project-b  /app/src │  │  ← cloné depuis Git
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
├── cdev                        ← Commande principale (lien symlink → /usr/local/bin/cdev)
├── auth/                       ← Flow OAuth
├── claude/                     ← Image Claude Code
├── scripts/                    ← Scripts internes (appelés par cdev)
├── services/                   ← Config PostgreSQL et Redis
├── projects/
│   ├── project-a/
│   │   ├── Dockerfile          ← Image node + Claude Code
│   │   ├── docker-compose.yml  ← GIT_REPO, GIT_BRANCH, ports
│   │   └── entrypoint.sh       ← Clone le repo au démarrage
│   └── project-b/
├── docker-compose.yml          ← Infra partagée
├── workflow.html               ← Schéma du workflow
└── .env.example                ← Template de configuration
```

## Dépannage

**`Permission denied` sur cdev**
```bash
chmod +x cdev
sudo ln -sf "$(pwd)/cdev" /usr/local/bin/cdev
```

**`.env.example` introuvable au `cdev init`**
Le lien symbolique ne pointait pas vers le bon dossier. Refaire :
```bash
chmod +x cdev
sudo ln -sf "$(pwd)/cdev" /usr/local/bin/cdev
```

**Token OAuth expiré**
```bash
cdev auth   # répond "o" pour forcer la ré-authentification
```

**Repo privé non accessible**
Vérifier que `SSH_KEY_PATH` pointe vers un dossier contenant ta clé et que celle-ci est ajoutée à ton compte GitHub/GitLab.
