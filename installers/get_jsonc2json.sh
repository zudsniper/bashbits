#!/usr/bin/env bash
# jsonc2json_installer.sh — curl-able installer for jsonc2json
# Home: https://github.com/zudsniper/bashbits
set -euo pipefail

# ---------- ANSI ----------
BOLD="\033[1m"; DIM="\033[2m"; RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"; RESET="\033[0m"
check() { printf "${GREEN}✔${RESET} %b\n" "$*"; }
info()  { printf "${BLUE}ℹ${RESET} %b\n" "$*"; }
warn()  { printf "${YELLOW}⚠${RESET} %b\n" "$*"; }
err()   { printf "${RED}✖${RESET} %b\n" "$*"; }

# ---------- Defaults ----------
BIN_DIR="/usr/local/bin"
NAME="jsonc2json"
FORCE=0
YES=0
QUIET=0
NO_SUDO=0
HELPER_URL="${JSONC2JSON_HELPER_URL:-https://raw.githubusercontent.com/zudsniper/bashbits/master/helpers/jsonc2json.sh}"

usage() {
  cat <<EOF
${BOLD}jsonc2json installer${RESET}
Installs the jsonc2json CLI (no npm deps). Requires Node in PATH at runtime.

Options:
  --bin-dir DIR       Install directory (default: /usr/local/bin)
  --name NAME         Installed command name (default: jsonc2json)
  --source-url URL    Override helper script raw URL
  --force             Overwrite existing binary
  --yes               Non-interactive install
  --quiet             Less output
  --no-sudo           Do not use sudo (fail if not writable)
  -h, --help          Show help
EOF
}

# ---------- Parse args ----------
while [ $# -gt 0 ]; do
  case "$1" in
    --bin-dir) BIN_DIR="${2:-}"; shift 2;;
    --name) NAME="${2:-}"; shift 2;;
    --source-url) HELPER_URL="${2:-}"; shift 2;;
    --force) FORCE=1; shift;;
    --yes) YES=1; shift;;
    --quiet) QUIET=1; shift;;
    --no-sudo) NO_SUDO=1; shift;;
    -h|--help) usage; exit 0;;
    *) err "Unknown option: $1"; usage; exit 2;;
  esac
done

DEST="${BIN_DIR%/}/${NAME}"

# ---------- Preflight ----------
[ "$QUIET" -eq 1 ] || info "Installing ${BOLD}${NAME}${RESET} to ${BOLD}${DEST}${RESET}"
[ "$QUIET" -eq 1 ] || info "Fetching helper from: ${DIM}${HELPER_URL}${RESET}"

TMP="$(mktemp -t jsonc2json.XXXXXXXX.sh)"
cleanup(){ rm -f "$TMP" 2>/dev/null || true; }
trap cleanup EXIT

if ! curl -fsSL "$HELPER_URL" -o "$TMP"; then
  err "Failed to download helper script."
  exit 3
fi

# Quick sanity check the payload
if ! grep -q "jsonc2json.sh" "$TMP" && ! grep -q "stripJsonc" "$TMP"; then
  warn "Helper script did not match expected content. Proceeding anyway."
fi

chmod +x "$TMP"

# Confirm overwrite
if [ -e "$DEST" ] && [ "$FORCE" -ne 1 ] && [ "$YES" -ne 1 ]; then
  printf "${YELLOW}⚠${RESET} ${BOLD}%s${RESET} already exists. Overwrite? [y/N] " "$DEST"
  read -r ans
  case "${ans,,}" in
    y|yes) : ;;
    *) info "Aborted."; exit 0;;
  esac
fi

# Ensure bin dir exists
if [ ! -d "$BIN_DIR" ]; then
  if [ "$NO_SUDO" -eq 1 ]; then
    mkdir -p "$BIN_DIR"
  else
    sudo mkdir -p "$BIN_DIR"
  fi
fi

# Install
if [ -w "$BIN_DIR" ]; then
  install -m 0755 "$TMP" "$DEST"
else
  if [ "$NO_SUDO" -eq 1 ]; then
    err "No write permission to ${BIN_DIR} and --no-sudo set."
    exit 4
  fi
  sudo install -m 0755 "$TMP" "$DEST"
fi

[ "$QUIET" -eq 1 ] || check "Installed ${BOLD}${DEST}${RESET}"

# Post hints
if command -v node >/dev/null 2>&1; then
  [ "$QUIET" -eq 1 ] || check "Node detected: $(node -v)"
else
  warn "Node not detected in PATH. The CLI uses Node at runtime."
fi

# Final message
if [ "$QUIET" -ne 1 ]; then
  cat <<EOF
${GREEN}Done!${RESET}

Try it:
  ${BOLD}${DEST} --help${RESET}
  ${BOLD}${DEST} input.jsonc output.json${RESET}

Options (re-run installer):
  ${DIM}--bin-dir, --name, --force, --yes, --quiet, --source-url, --no-sudo${RESET}
EOF
fi