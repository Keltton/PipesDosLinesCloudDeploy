#!/usr/bin/env bash
# T7 — Gera tráfego para popular o painel e disparar alertas
# Uso:
#   ./scripts/gerar-trafego.sh normal   # tráfego saudável (para o print do painel)
#   ./scripts/gerar-trafego.sh erro     # força erros 500 (para o print do alerta)
# Variável opcional: URL (padrão http://localhost:8080)
set -euo pipefail

MODO="${1:-normal}"
URL="${URL:-http://localhost:8080}"

TOKEN="$(curl -s -X POST "$URL/api/auth/login" -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin"}' | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
[ -n "$TOKEN" ] || { echo "Não foi possível obter o token em $URL" >&2; exit 1; }
AUTH="Authorization: Bearer $TOKEN"

echo "Modo: $MODO | alvo: $URL | Ctrl+C para parar"
while true; do
  curl -s -o /dev/null "$URL/login"
  curl -s -o /dev/null -H "$AUTH" "$URL/api/livros"
  curl -s -o /dev/null -H "$AUTH" "$URL/api/autores"
  if [ "$MODO" = "erro" ]; then
    # Livro inexistente: o serviço usa Optional.get() e responde 500
    for _ in 1 2 3; do curl -s -o /dev/null -H "$AUTH" "$URL/api/livros/999999"; done
  fi
  sleep 0.5
done
