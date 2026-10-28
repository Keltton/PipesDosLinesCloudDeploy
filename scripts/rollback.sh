#!/usr/bin/env bash
# T6 — Rollback: devolve o tráfego para a cor anterior
# Uso: ./scripts/rollback.sh
set -euo pipefail

NS="${NAMESPACE:-default}"
k() { kubectl -n "$NS" "$@"; }

CURRENT="$(k get svc biblioteca -o jsonpath='{.spec.selector.version}')"
PREVIOUS="$(k get svc biblioteca -o jsonpath='{.metadata.annotations.bluegreen/previous-color}')"
[ -n "$PREVIOUS" ] || { echo "ERRO: não há cor anterior registrada." >&2; exit 1; }

echo "==> Rollback: $CURRENT -> $PREVIOUS"

# Se a cor anterior já foi desligada (finalizar.sh), religa antes de trocar
if [ "$(k get deployment "biblioteca-$PREVIOUS" -o jsonpath='{.spec.replicas}')" = "0" ]; then
  echo "    $PREVIOUS estava desligada; religando..."
  k scale "deployment/biblioteca-$PREVIOUS" --replicas=1
fi
k rollout status "deployment/biblioteca-$PREVIOUS" --timeout=180s

k patch svc biblioteca --type merge \
  -p "{\"spec\":{\"selector\":{\"app\":\"biblioteca\",\"version\":\"$PREVIOUS\"}}}"
k annotate svc biblioteca bluegreen/previous-color="$CURRENT" --overwrite

echo "==> Tráfego de volta em $PREVIOUS ($(k get deployment "biblioteca-$PREVIOUS" \
  -o jsonpath='{.spec.template.spec.containers[0].image}'))."
echo "    A versão com problema ($CURRENT) foi mantida para investigação."
