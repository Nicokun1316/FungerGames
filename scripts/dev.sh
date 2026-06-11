#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
QT_ROOT="${QT_ROOT:-$HOME/Qt/6.9.3/gcc_64}"
SERVICE_PIDS=()

build() {
  local generator_args=()
  if command -v ninja >/dev/null 2>&1; then
    generator_args=(-G Ninja)
  fi

  cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
    "${generator_args[@]}" \
    -DCMAKE_PREFIX_PATH="${QT_ROOT}"
  cmake --build "${BUILD_DIR}"
}

clean() {
  rm -rf "${BUILD_DIR}"
}

run_all() {
  if [[ ! -x "${BUILD_DIR}/bin/FungerGames" ]]; then
    build
  fi

  "${BUILD_DIR}/bin/face-tracking-service" &
  SERVICE_PIDS+=($!)
  "${BUILD_DIR}/bin/fridge-service" &
  SERVICE_PIDS+=($!)

  cleanup() {
    if [[ ${#SERVICE_PIDS[@]} -gt 0 ]]; then
      kill "${SERVICE_PIDS[@]}" 2>/dev/null || true
      wait "${SERVICE_PIDS[@]}" 2>/dev/null || true
    fi
  }

  trap cleanup EXIT INT TERM
  "${BUILD_DIR}/bin/FungerGames"
}

case "${1:-}" in
  build)
    build
    ;;
  clean)
    clean
    ;;
  run)
    run_all
    ;;
  *)
    echo "Usage: $0 {build|clean|run}"
    exit 1
    ;;
esac
