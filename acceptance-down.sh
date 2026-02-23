#!/usr/bin/env bash
set -euo pipefail

# 一键停止验收环境 / One-command shutdown for acceptance environment

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${ROOT_DIR}/.acceptance-logs"
PID_FILE="${LOG_DIR}/acceptance.pids"
BACKEND_PORT=8092
FRONTEND_PORT=5173

kill_by_pid() {
  local pid="$1"
  if [[ -n "${pid}" ]] && [[ "${pid}" != "existing" ]] && kill -0 "${pid}" >/dev/null 2>&1; then
    kill "${pid}" >/dev/null 2>&1 || true
    sleep 1
    if kill -0 "${pid}" >/dev/null 2>&1; then
      kill -9 "${pid}" >/dev/null 2>&1 || true
    fi
  fi
}

kill_by_port() {
  local port="$1"
  local pids
  pids="$(lsof -tiTCP:${port} -sTCP:LISTEN -n -P 2>/dev/null || true)"
  if [[ -n "${pids}" ]]; then
    echo "${pids}" | xargs kill >/dev/null 2>&1 || true
    sleep 1
    echo "${pids}" | xargs kill -9 >/dev/null 2>&1 || true
  fi
}

backend_pid=""
frontend_pid=""
if [[ -f "${PID_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${PID_FILE}" || true
  backend_pid="${backend_pid:-}"
  frontend_pid="${frontend_pid:-}"
fi

echo "[acceptance-down] Stopping managed processes..."
kill_by_pid "${frontend_pid}"
kill_by_pid "${backend_pid}"

echo "[acceptance-down] Releasing ports ${FRONTEND_PORT}/${BACKEND_PORT}..."
kill_by_port "${FRONTEND_PORT}"
kill_by_port "${BACKEND_PORT}"

rm -f "${LOG_DIR}/backend.pid" "${LOG_DIR}/frontend.pid" "${PID_FILE}"
echo "[acceptance-down] Done."
