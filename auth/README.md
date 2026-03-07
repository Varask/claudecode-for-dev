# Authentification OAuth — Claude Code

## Deux modes supportés

| Mode        | Variable              | Quand l'utiliser          |
|-------------|-----------------------|---------------------------|
| **OAuth**   | _(aucune)_            | Compte claude.ai Pro/Team |
| **API Key** | `ANTHROPIC_API_KEY`   | Compte API Anthropic      |

## Flow OAuth (première fois)

```bash
./scripts/claude-auth.sh
```

1. Un lien s'affiche dans le terminal
2. Ouvre-le dans ton navigateur
3. Connecte-toi avec ton compte claude.ai
4. Le token est sauvegardé dans le volume Docker `claude-auth`

## Token expiré ?

```bash
./scripts/claude-auth.sh
# répondre "o" pour forcer la ré-authentification
```

## Sécurité

- Le token est stocké dans un volume Docker nommé `claude-auth`
- Partagé entre `claude-auth` et `claude-code` via ce volume
- Jamais écrit dans un fichier local ni dans le repo
