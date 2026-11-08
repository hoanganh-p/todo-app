#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/prompt-context.sh <mode> [files-to-prompt options...]

Modes:
  full      Toàn bộ source code (backend + frontend + infra)
  backend   Chỉ backend Go
  frontend  Chỉ frontend React
  infra     Chỉ Docker/config files
  crud      Các file CRUD core (nhanh, ít token)
  diff      Các file đang thay đổi (git diff + untracked)

Examples:
  scripts/prompt-context.sh full -o prompt-project.md
  scripts/prompt-context.sh backend --cxml -o prompt-backend.xml
  scripts/prompt-context.sh diff -o prompt-diff.md

Notes:
  - Mặc định thêm -n và --markdown nếu không truyền --cxml.
  - diff mode bao gồm modified, staged, và untracked files.
EOF
}

require_tool() {
  if ! command -v files-to-prompt >/dev/null 2>&1; then
    echo "Missing dependency: files-to-prompt" >&2
    echo "Install: python3 -m pip install files-to-prompt" >&2
    exit 1
  fi
}

has_format_flag() {
  local -a args=("${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}")
  local arg
  for arg in "${args[@]}"; do
    case "$arg" in
      --markdown|-m|--cxml|-c) return 0 ;;
    esac
  done
  return 1
}

run_files_to_prompt() {
  local -a input_paths=("$@")
  local -a paths=()

  for p in "${input_paths[@]}"; do
    if [[ -e "$ROOT_DIR/$p" ]]; then
      paths+=("$p")
    else
      echo "Warning: '$p' không tồn tại, bỏ qua." >&2
    fi
  done

  [[ ${#paths[@]} -eq 0 ]] && { echo "Error: Không có path hợp lệ nào." >&2; exit 1; }

  local -a cmd=(files-to-prompt "${paths[@]}")

  cmd+=(
    --ignore "tmp"
    --ignore "*.log"
    --ignore "node_modules"
    --ignore "build"
    --ignore "dist"
    --ignore "package-lock.json"
    --ignore "go.sum"
    --ignore ".env"
    --ignore "*.test.js"
    --ignore "*.test.go"
    -n
  )

  if ! has_format_flag; then
    cmd+=(--markdown)
  fi

  cmd+=("${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}")

  (cd "$ROOT_DIR" && "${cmd[@]}")
}

collect_diff_files() {
  local -A seen=()
  local -a files=()
  local file

  while IFS= read -r -d '' file; do
    [[ -n "$file" ]] || continue
    [[ -f "$ROOT_DIR/$file" ]] || continue
    if [[ -z "${seen[$file]+x}" ]]; then
      files+=("$file")
      seen["$file"]=1
    fi
  done < <(
    cd "$ROOT_DIR"
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
      git diff --name-only --diff-filter=d -z HEAD --
    else
      git diff --name-only --diff-filter=d -z --
      git diff --cached --name-only --diff-filter=d -z --
    fi
    git ls-files --others --exclude-standard -z --
  )

  if ((${#files[@]} == 0)); then
    echo "Không có file nào thay đổi." >&2
    exit 1
  fi

  printf '%s\0' "${files[@]}"
}

# --- Parse args ---
MODE="${1:-help}"
if [[ "$MODE" == "-h" || "$MODE" == "--help" || "$MODE" == "help" ]]; then
  usage; exit 0
fi
shift || true
EXTRA_ARGS=("$@")

require_tool

case "$MODE" in
  full)
    run_files_to_prompt \
      backend \
      backend/.air.toml \
      backend/.dockerignore \
      frontend \
      frontend/.dockerignore \
      docker-compose.yml \
      docker-compose.prod.yml \
      .env.example
    ;;

  backend)
    run_files_to_prompt \
      backend/main.go \
      backend/database \
      backend/handlers \
      backend/models \
      backend/go.mod \
      backend/Dockerfile \
      backend/Dockerfile.prod \
      backend/.air.toml \
      backend/.dockerignore
    ;;

  frontend)
    run_files_to_prompt \
      frontend/src \
      frontend/public \
      frontend/package.json \
      frontend/Dockerfile \
      frontend/Dockerfile.prod \
      frontend/.dockerignore
    ;;

  infra)
    run_files_to_prompt \
      docker-compose.yml \
      docker-compose.prod.yml \
      backend/Dockerfile \
      backend/Dockerfile.prod \
      backend/.air.toml \
      backend/.dockerignore \
      frontend/Dockerfile \
      frontend/Dockerfile.prod \
      frontend/.dockerignore \
      .env.example
    ;;

  crud)
    run_files_to_prompt \
      backend/main.go \
      backend/database/db.go \
      backend/handlers/task_handler.go \
      backend/models/task.go \
      frontend/src/App.js \
      frontend/src/api.js \
      docker-compose.yml
    ;;

  diff)
    mapfile -d '' -t diff_files < <(collect_diff_files)
    run_files_to_prompt "${diff_files[@]}"
    ;;

  *)
    echo "Unknown mode: $MODE" >&2
    usage >&2
    exit 1
    ;;
esac