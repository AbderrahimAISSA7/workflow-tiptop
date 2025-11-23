#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <env> [tiptop-api|tiptop-front|all]" >&2
  exit 1
fi

ENVIRONMENT="$1"
MODULE="${2:-all}"
ENV_DIR="app-envs/${ENVIRONMENT}"
COMPOSE_FILE="${ENV_DIR}/docker-compose.yml"
ENV_FILE="${ENV_DIR}/.env"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "Compose file introuvable : ${COMPOSE_FILE}" >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Fichier ${ENV_FILE} manquant (copier .env.example)" >&2
  exit 1
fi

if [[ -z "${IMAGE_TAG:-}" ]]; then
  echo "Variable IMAGE_TAG non définie (exporter IMAGE_TAG avant d'appeler le script)" >&2
  exit 1
fi

available_services=$(docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" config --services)
service_exists() {
  grep -q "^$1$" <<<"${available_services}"
}

TARGET_SERVICES=()
case "${MODULE}" in
  tiptop-api)
    TARGET_SERVICES+=(api)
    ;;
  tiptop-front)
    TARGET_SERVICES+=(front)
    ;;
  all)
    TARGET_SERVICES+=(front api postgres)
    if service_exists pgadmin; then
      TARGET_SERVICES+=(pgadmin)
    fi
    ;;
  *)
    echo "Module inconnu : ${MODULE} (attendus: tiptop-api, tiptop-front, all)" >&2
    exit 1
    ;;
ESAC

printf '[deploy] env=%s module=%s image=%s\n' "${ENVIRONMENT}" "${MODULE}" "${IMAGE_TAG}"

export IMAGE_TAG

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" pull "${TARGET_SERVICES[@]}"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d --no-deps "${TARGET_SERVICES[@]}"
