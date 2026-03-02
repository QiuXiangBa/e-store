#!/usr/bin/env bash
set -euo pipefail

# mall-pc 验收环境停止 / Mall-pc acceptance environment shutdown

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${ROOT_DIR}/.acceptance-logs"
PID_FILE="${LOG_DIR}/acceptance-mall.pids"

kill_pid() {
  local pid="$1"
  local name="$2"
  if [[ -n "${pid}" && "${pid}" != "existing" ]]; then
    if kill -0 "${pid}" 2>/dev/null; then
      echo "Stopping ${name} (pid ${pid})..."
      kill "${pid}" 2>/dev/null || true
      sleep 2
      kill -9 "${pid}" 2>/dev/null || true
    fi
  fi
}

[[ -f "${LOG_DIR}/mall-backend.pid" ]] && kill_pid "$(cat "${LOG_DIR}/mall-backend.pid")" "mall-backend"
[[ -f "${LOG_DIR}/mall-pc.pid" ]] && kill_pid "$(cat "${LOG_DIR}/mall-pc.pid")" "mall-pc"

# Also try by port
for port in 8092 5175; do
  pid=$(lsof -iTCP:${port} -sTCP:LISTEN -t 2>/dev/null || true)
  if [[ -n "${pid}" ]]; then
    echo "Killing process on port ${port} (pid ${pid})..."
    kill -9 ${pid} 2>/dev/null || true
  fi
done

rm -f "${PID_FILE}" "${LOG_DIR}/mall-backend.pid" "${LOG_DIR}/mall-pc.pid"
echo "[acceptance-mall-down] Done."
