#!/usr/bin/env bash
# T6 — Deploy blue/green da Biblioteca
# Uso: ./scripts/deploy-bluegreen.sh <tag-da-imagem>
#   ex.: ./scripts/deploy-bluegreen.sh a1b2c3d
# Variáveis opcionais: IMAGE_REPO (padrão ghcr.io/OWNER/biblioteca), NAMESPACE (padrão default)
set -euo pipefail

TAG="${1:?uso: deploy-bluegreen.sh <tag-da-imagem>}"
IMAGE_REPO="${IMAGE_REPO:-ghcr.io/OWNER/biblioteca}"
NS="${NAMESPACE:-default}"
k() { kubectl -n "$NS" "$@"; }

ACTIVE="$(k get svc biblioteca -o jsonpath='{.spec.selector.version}')"
if [ "$ACTIVE" = "blue" ]; then TARGET="green"; else TARGET="blue"; fi
echo "==> Cor ativa: $ACTIVE | nova versão vai para: $TARGET | imagem: $IMAGE_REPO:$TAG"

# 1. Implantar a nova versão na cor INATIVA (sem tráfego de usuários)
k set image "deployment/biblioteca-$TARGET" biblioteca="$IMAGE_REPO:$TAG"
k set env "deployment/biblioteca-$TARGET" APP_VERSION="$TAG"
k scale "deployment/biblioteca-$TARGET" --replicas=1
if ! k rollout status "deployment/biblioteca-$TARGET" --timeout=180s; then
  echo "ERRO: a nova versão não ficou pronta. Tráfego continua em $ACTIVE." >&2
  k scale "deployment/biblioteca-$TARGET" --replicas=0
  exit 1
fi

# 2. Smoke tests pela rota de pré-visualização (Service interno)
k patch svc biblioteca-preview --type merge \
  -p "{\"spec\":{\"selector\":{\"app\":\"biblioteca\",\"version\":\"$TARGET\"}}}"
k port-forward svc/biblioteca-preview 18080:8080 18081:8081 >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true' EXIT
sleep 4

falhar() {
  echo "SMOKE TEST FALHOU: $1. Tráfego continua em $ACTIVE." >&2
  k scale "deployment/biblioteca-$TARGET" --replicas=0
  exit 1
}

code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }

[ "$(code http://localhost:18081/actuator/health/readiness)" = "200" ] || falhar "readiness"
[ "$(code http://localhost:18080/login)" = "200" ]                     || falhar "GET /login"

TOKEN="$(curl -s -X POST http://localhost:18080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin"}' | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
[ -n "$TOKEN" ] || falhar "POST /api/auth/login sem token"
[ "$(code -H "Authorization: Bearer $TOKEN" http://localhost:18080/api/livros)" = "200" ] \
  || falhar "GET /api/livros com JWT"
echo "==> Smoke tests OK"

# 3. Troca de tráfego: o Service passa a apontar para a nova cor
k annotate svc biblioteca bluegreen/previous-color="$ACTIVE" --overwrite
k patch svc biblioteca --type merge \
  -p "{\"spec\":{\"selector\":{\"app\":\"biblioteca\",\"version\":\"$TARGET\"}}}"

echo "==> Tráfego agora em $TARGET ($TAG). A versão anterior ($ACTIVE) continua ligada."
echo "    Observe o painel do T7 por 15 minutos (critérios em T6-CD.md)."
echo "    Tudo OK  -> ./scripts/finalizar.sh"
echo "    Problema -> ./scripts/rollback.sh"
