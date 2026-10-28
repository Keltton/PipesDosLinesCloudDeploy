#!/usr/bin/env bash
# T6 — Finaliza o deploy: desliga a cor antiga após a janela de observação
# Uso: ./scripts/finalizar.sh
set -euo pipefail

NS="${NAMESPACE:-default}"
k() { kubectl -n "$NS" "$@"; }

PREVIOUS="$(k get svc biblioteca -o jsonpath='{.metadata.annotations.bluegreen/previous-color}')"
[ -n "$PREVIOUS" ] || { echo "Nada a finalizar." >&2; exit 0; }

k scale "deployment/biblioteca-$PREVIOUS" --replicas=0
echo "==> $PREVIOUS desligada (réplicas = 0). A imagem anterior continua no GHCR para rollback."
