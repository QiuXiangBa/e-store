#!/usr/bin/env bash
set -euo pipefail

# 一键启动验收环境 / One-command startup for acceptance environment

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="${ROOT_DIR}/repos/backend/e-store"
FRONTEND_DIR="${ROOT_DIR}/repos/frontend/admin-ui"
LOG_DIR="${ROOT_DIR}/.acceptance-logs"
PID_FILE="${LOG_DIR}/acceptance.pids"

BACKEND_PORT=8092
FRONTEND_PORT=5173
BACKEND_HEALTH_URL="http://127.0.0.1:${BACKEND_PORT}/health/status"
FRONTEND_URL="http://localhost:${FRONTEND_PORT}"

mkdir -p "${LOG_DIR}"
BACKEND_LOG="${LOG_DIR}/backend.log"
FRONTEND_LOG="${LOG_DIR}/frontend.log"

is_port_listening() {
  local port="$1"
  lsof -iTCP:"${port}" -sTCP:LISTEN -n -P >/dev/null 2>&1
}

wait_http_ok() {
  local url="$1"
  local max_retry="$2"
  local sleep_seconds="$3"
  local current_retry=0

  while (( current_retry < max_retry )); do
    if curl -fsS "${url}" >/dev/null 2>&1; then
      return 0
    fi
    current_retry=$((current_retry + 1))
    sleep "${sleep_seconds}"
  done
  return 1
}

echo "[acceptance-up] Checking directories..."
[[ -d "${BACKEND_DIR}" ]] || { echo "Backend directory not found: ${BACKEND_DIR}"; exit 1; }
[[ -d "${FRONTEND_DIR}" ]] || { echo "Frontend directory not found: ${FRONTEND_DIR}"; exit 1; }

if is_port_listening "${BACKEND_PORT}"; then
  echo "[acceptance-up] Backend port ${BACKEND_PORT} is already in use. Skip backend startup."
  BACKEND_PID="existing"
else
  echo "[acceptance-up] Starting backend on port ${BACKEND_PORT}..."
  (
    cd "${BACKEND_DIR}"
    nohup sh -c "mvn -DskipTests clean package && java -jar admin/target/admin.jar --spring.profiles.active=dev --server.port=${BACKEND_PORT}" >"${BACKEND_LOG}" 2>&1 &
    echo $! >"${LOG_DIR}/backend.pid"
  )
  BACKEND_PID="$(cat "${LOG_DIR}/backend.pid")"
fi

if is_port_listening "${FRONTEND_PORT}"; then
  echo "[acceptance-up] Frontend port ${FRONTEND_PORT} is already in use. Skip frontend startup."
  FRONTEND_PID="existing"
else
  echo "[acceptance-up] Starting frontend on port ${FRONTEND_PORT}..."
  (
    cd "${FRONTEND_DIR}"
    nohup npm run dev -- --host localhost --port "${FRONTEND_PORT}" >"${FRONTEND_LOG}" 2>&1 &
    echo $! >"${LOG_DIR}/frontend.pid"
  )
  FRONTEND_PID="$(cat "${LOG_DIR}/frontend.pid")"
fi

echo "backend_pid=${BACKEND_PID}" >"${PID_FILE}"
echo "frontend_pid=${FRONTEND_PID}" >>"${PID_FILE}"
echo "backend_port=${BACKEND_PORT}" >>"${PID_FILE}"
echo "frontend_port=${FRONTEND_PORT}" >>"${PID_FILE}"

echo "[acceptance-up] Health checking backend: ${BACKEND_HEALTH_URL}"
if ! wait_http_ok "${BACKEND_HEALTH_URL}" 45 2; then
  echo "[acceptance-up] Backend health check failed."
  echo "---- backend.log (tail -n 80) ----"
  tail -n 80 "${BACKEND_LOG}" 2>/dev/null || true
  exit 1
fi

echo "[acceptance-up] Health checking frontend: ${FRONTEND_URL}"
if ! wait_http_ok "${FRONTEND_URL}" 30 2; then
  echo "[acceptance-up] Frontend health check failed."
  echo "---- frontend.log (tail -n 80) ----"
  tail -n 80 "${FRONTEND_LOG}" 2>/dev/null || true
  exit 1
fi

echo ""
echo "[acceptance-up] Acceptance environment is ready."
echo "Frontend URL: ${FRONTEND_URL}"
echo "Backend URL : http://localhost:${BACKEND_PORT}"
echo "Health URL  : ${BACKEND_HEALTH_URL}"
echo "Logs:"
echo "  - ${BACKEND_LOG}"
echo "  - ${FRONTEND_LOG}"
echo "Stop command: ${ROOT_DIR}/acceptance-down.sh"
