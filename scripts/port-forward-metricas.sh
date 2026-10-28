#!/usr/bin/env bash
# T6/T7 — Expõe as métricas (porta 8081) dos pods blue e green em localhost
#   blue -> localhost:18081 | green -> localhost:18082
# Deixe rodando em um terminal separado enquanto usa monitoring/docker-compose.k8s.yml.
# Se um pod some (troca de versão), o port-forward é refeito sozinho assim que o novo pod existir.
# Se travar no Windows: taskkill //IM kubectl.exe //F
set -uo pipefail

NS="${NAMESPACE:-default}"

forward() {   # $1 = cor, $2 = porta local
  local pid=""
  trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; exit 0' TERM INT
  while true; do
    if kubectl -n "$NS" get pod -l "app=biblioteca,version=$1" --field-selector=status.phase=Running -o name 2>/dev/null | grep -q .; then
      kubectl -n "$NS" port-forward "deployment/biblioteca-$1" "$2:8081" >/dev/null 2>&1 &
      pid=$!
      wait "$pid" || true
      pid=""
    fi
    sleep 3
  done
}

echo "Métricas: blue -> http://localhost:18081/actuator/prometheus | green -> http://localhost:18082/actuator/prometheus"
echo "Ctrl+C para parar"
forward blue 18081 &
P1=$!
forward green 18082 &
P2=$!
trap 'kill "$P1" "$P2" 2>/dev/null; exit 0' INT TERM
wait
