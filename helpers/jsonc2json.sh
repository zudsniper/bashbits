#!/usr/bin/env bash
# jsonc2json.sh — no-deps JSONC -> JSON converter
# Usage:
#   ./jsonc2json.sh input.jsonc output.json
#   ./jsonc2json.sh install [DEST=/usr/local/bin/jsonc2json]
#   ./jsonc2json.sh --help | --version
set -euo pipefail

VERSION="1.1.0"

BOLD="\033[1m"; DIM="\033[2m"; RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"; RESET="\033[0m"
usage() {
  cat <<EOF
${BOLD}jsonc2json.sh${RESET} v${VERSION}
Convert JSONC -> JSON (strips //, /* */ comments, and trailing commas) with Node, no npm deps.

${BOLD}Usage${RESET}
  jsonc2json.sh input.jsonc output.json
  jsonc2json.sh install [DEST]     # installs this script as a CLI (default DEST=/usr/local/bin/jsonc2json)
  jsonc2json.sh --help | --version
EOF
}

find_node() {
  local candidates=("node" "node22" "node20" "node18" "/opt/homebrew/bin/node" "/usr/local/bin/node")
  for c in "${candidates[@]}"; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "$c"; return 0
    fi
  done
  echo "Error: Node.js not found in PATH." >&2
  exit 3
}

install_cli() {
  local dest="${1:-/usr/local/bin/jsonc2json}"
  local dir; dir="$(dirname "$dest")"

  if [ -w "$dir" ] && { [ ! -e "$dest" ] || [ -w "$dest" ]; }; then
    cp "$0" "$dest"
    chmod +x "$dest"
  else
    sudo cp "$0" "$dest"
    sudo chmod +x "$dest"
  fi

  printf "${GREEN}✔${RESET} Installed ${BOLD}%s${RESET}\n" "$dest"
}

convert_once() {
  local input="${1:-}"; local output="${2:-}"
  if [ -z "$input" ] || [ -z "$output" ]; then usage >&2; exit 1; fi

  local NODE; NODE="$(find_node)"
  "$NODE" - "$input" "$output" <<'EOF_NODE'
const fs = require('fs');

function stripJsonc(s){
  let out='', state='normal';
  for (let i=0;i<s.length;i++){
    const ch=s[i];
    if (state==='normal'){
      if (ch==='"'){ out+=ch; state='string'; }
      else if (ch==='/'){
        const n=s[i+1];
        if (n==='/'){ state='line'; i++; }
        else if (n==='*'){ state='block'; i++; }
        else out+=ch;
      } else out+=ch;
    } else if (state==='string'){
      if (ch==='\\'){ out+=ch; i++; out+=s[i]??''; }
      else if (ch==='"'){ out+=ch; state='normal'; }
      else out+=ch;
    } else if (state==='line'){
      if (ch==='\n'||ch==='\r'){ out+=ch; state='normal'; }
    } else if (state==='block'){
      if (ch==='*' && s[i+1]==='/'){ i++; state='normal'; }
    }
  }
  return out;
}

function removeTrailingCommas(s){
  let out='', inStr=false;
  for (let i=0;i<s.length;i++){
    const ch=s[i];
    if (!inStr){
      if (ch==='"'){ inStr=true; out+=ch; }
      else if (ch===','){
        let j=i+1; while (j<s.length && /\s/.test(s[j])) j++;
        if (j<s.length && (s[j]==='}'||s[j]===']')){ /* drop trailing comma */ }
        else out+=ch;
      } else out+=ch;
    } else {
      if (ch==='\\'){ out+=ch; i++; out+=s[i]??''; }
      else if (ch==='"'){ inStr=false; out+=ch; }
      else out+=ch;
    }
  }
  return out;
}

const [, , input, output] = process.argv;
if (!input || !output) {
  console.error('Usage: jsonc2json input.jsonc output.json');
  process.exit(1);
}

const raw = fs.readFileSync(input,'utf8');
const noComments = stripJsonc(raw);
const cleaned = removeTrailingCommas(noComments);

let obj;
try { obj = JSON.parse(cleaned); }
catch (e){
  console.error('Failed to parse after stripping comments/trailing commas:\n' + e.message);
  process.exit(2);
}

fs.writeFileSync(output, JSON.stringify(obj, null, 2));
EOF_NODE
}

main() {
  case "${1:-}" in
    install) install_cli "${2:-/usr/local/bin/jsonc2json}" ;;
    --help|-h) usage ;;
    --version|-v) echo "$VERSION" ;;
    *) convert_once "$@" ;;
  esac
}

main "$@"