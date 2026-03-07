-- Script d'initialisation PostgreSQL
-- Exécuté automatiquement au premier démarrage du container

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO users (email) VALUES
  ('alice@example.com'),
  ('bob@example.com')
ON CONFLICT DO NOTHING;
