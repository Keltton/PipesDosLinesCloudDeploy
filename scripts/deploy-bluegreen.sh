#!/usr/bin/env bash
# T6 — Deploy blue/green da Biblioteca
# Uso: ./scripts/deploy-bluegreen.sh <tag-da-imagem>
#   ex.: ./scripts/deploy-bluegreen.sh a1b2c3d
# Variáveis opcionais: IMAGE_REPO (padrão ghcr.io/keltton/biblioteca), NAMESPACE (padrão default)
# Fork: trocar keltton pelo seu usuário do GitHub em minúsculas (ver README)
set -euo pipefail

TAG="${1:?uso: deploy-bluegreen.sh <tag-da-imagem>}"
IMAGE_REPO="${IMAGE_REPO:-ghcr.io/keltton/biblioteca}"
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
falhar() {
  echo "SMOKE TEST FALHOU: $1. Tráfego continua em $ACTIVE." >&2
  k scale "deployment/biblioteca-$TARGET" --replicas=0
  exit 1
}

# Os testes rodam DENTRO do cluster, num pod temporário com curl, chamando o Service de preview.
# Sem port-forward (trava no Windows/Git Bash) e sem "kubectl run -i --rm" (o attach trava no Git Bash):
# cria o pod, espera a fase final, lê os logs e apaga.
echo "==> Smoke tests (pod temporário no cluster)"
SMOKE="smoke-$TARGET-$RANDOM"
# shellcheck disable=SC2016  # o script abaixo é avaliado pelo sh do pod, não por este shell
SMOKE_SCRIPT='
  APP=http://biblioteca-preview:8080
  MGMT=http://biblioteca-preview:8081
  code() { curl -s -o /dev/null -w "%{http_code}" "$@"; }

  # readiness: até 30 s, para dar tempo de o Service enxergar o pod novo
  ok=""
  for i in $(seq 1 15); do
    [ "$(code $MGMT/actuator/health/readiness)" = "200" ] && ok=1 && break
    sleep 2
  done
  [ -n "$ok" ] || { echo "falhou: readiness"; exit 1; }
  echo "ok: readiness 200"

  [ "$(code $APP/login)" = "200" ] || { echo "falhou: GET /login"; exit 1; }
  echo "ok: GET /login 200"

  T=$(curl -s -X POST $APP/api/auth/login -H "Content-Type: application/json" \
      -d "{\"username\":\"admin\",\"password\":\"admin\"}" \
      | sed -n "s/.*\"token\":\"\([^\"]*\)\".*/\1/p")
  [ -n "$T" ] || { echo "falhou: POST /api/auth/login sem token"; exit 1; }
  echo "ok: login na API devolveu JWT"

  # A API responde 404 quando ainda não há livros: o que importa é o JWT ser aceito (não 401/403)
  c=$(code -H "Authorization: Bearer $T" $APP/api/livros)
  case "$c" in 200|404) ;; *) echo "falhou: GET /api/livros com JWT (HTTP $c)"; exit 1 ;; esac
  echo "ok: /api/livros aceitou o JWT (HTTP $c)"
'
k run "$SMOKE" --restart=Never --image=curlimages/curl:8.10.1 --command -- sh -c "$SMOKE_SCRIPT" >/dev/null
RESULT=""
for _ in $(seq 1 90); do      # até 3 min (a 1ª vez baixa a imagem do curl)
  PHASE="$(k get pod "$SMOKE" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  case "$PHASE" in Succeeded|Failed) RESULT="$PHASE"; break ;; esac
  sleep 2
done
k logs "$SMOKE" 2>&1 || true
k delete pod "$SMOKE" --ignore-not-found --wait=false >/dev/null 2>&1 || true
[ "$RESULT" = "Succeeded" ] || falhar "smoke tests (${RESULT:-tempo esgotado}); ver as linhas acima"
echo "==> Smoke tests OK"

# 3. Troca de tráfego: o Service passa a apontar para a nova cor
k annotate svc biblioteca bluegreen/previous-color="$ACTIVE" --overwrite
k patch svc biblioteca --type merge \
  -p "{\"spec\":{\"selector\":{\"app\":\"biblioteca\",\"version\":\"$TARGET\"}}}"

echo "==> Tráfego agora em $TARGET ($TAG). A versão anterior ($ACTIVE) continua ligada."
echo "    Observe o painel do T7 por 15 minutos (critérios em T6-CD.md)."
echo "    Tudo OK  -> ./scripts/finalizar.sh"
echo "    Problema -> ./scripts/rollback.sh"
