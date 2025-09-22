#!/usr/bin/env bash
# make_admin.sh
# Create/update a UNIX user, install an SSH public key, and enable passwordless sudo.
# Works on Debian/Ubuntu, RHEL/CentOS/Rocky/Alma/Fedora/Amazon Linux, and Alpine.

set -Eeuo pipefail

################################
# Minimal, safe ANSI formatting #
################################
# Only enable colors if stdout is a TTY
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  RED=$'\033[31m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  CYAN=$'\033[36m'
  RESET=$'\033[0m'
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
fi

info()  { printf "%s\n" "${CYAN}[INFO]${RESET}  $*"; }
ok()    { printf "%s\n" "${GREEN}[OK]${RESET}    $*"; }
warn()  { printf "%s\n" "${YELLOW}[WARN]${RESET}  $*"; }
err()   { printf "%s\n" "${RED}[ERROR]${RESET} $*" >&2; }
die()   { err "$*"; exit 1; }

on_error() {
  err "An error occurred on line ${BASH_LINENO[0]}. Aborting."
}
trap on_error ERR

#################
# Default opts  #
#################
ASSUME_YES="false"
PUBKEY_FILE=""
PREFERRED_SHELL="/bin/bash"

###############
# Help text   #
###############
print_help() {
  cat <<'EOF'
make_admin.sh

Create/update a user, install an SSH public key, and enable passwordless sudo.

USAGE:
  make_admin.sh [OPTIONS] USERNAME [PUBKEY|-]

POSITIONAL:
  USERNAME            Login name to create or update.
  PUBKEY              SSH public key string. Use "-" to read from STDIN.
                      If omitted, provide --pubkey-file or pipe via STDIN.

OPTIONS:
  -y, --yes, --non-interactive
                      Assume "yes" to prompts (non-interactive).
  --pubkey-file PATH  Read SSH public key from PATH.
  --shell SHELL       Set login shell (default: /bin/bash).
  -h, --help          Show this help and exit.

INPUT SOURCES (priority):
  1) PUBKEY positional arg (or "-")
  2) --pubkey-file PATH
  3) STDIN (if piped)

EXAMPLES:
  make_admin.sh -y jason "ssh-ed25519 AAAA... jason@host"
  cat ~/.ssh/id_ed25519.pub | make_admin.sh -y jason -
  make_admin.sh --pubkey-file ./jason.pub jason

NOTES:
  • Run as root.
  • Installs key to /home/<user>/.ssh/authorized_keys (0600).
  • Grants passwordless sudo via /etc/sudoers.d/90-<user>-nopasswd (0440), validated by visudo.
  • Idempotent: safe to re-run.
EOF
}

#################
# Parse args    #
#################
ARGS=()
while (( "$#" )); do
  case "${1:-}" in
    -y|--yes|--non-interactive)
      ASSUME_YES="true"; shift ;;
    --pubkey-file)
      [[ "${2:-}" ]] || die "--pubkey-file requires a path"
      PUBKEY_FILE="${2}"; shift 2 ;;
    --shell)
      [[ "${2:-}" ]] || die "--shell requires a path (e.g., /bin/bash)"
      PREFERRED_SHELL="${2}"; shift 2 ;;
    -h|--help)
      print_help; exit 0 ;;
    --) shift; break ;;
    -*)
      die "Unknown option: $1 (use --help)" ;;
    *)
      ARGS+=("$1"); shift ;;
  esac
done
(( "$#" )) && ARGS+=("$@")

USERNAME="${ARGS[0]:-}"
PUBKEY_ARG="${ARGS[1]:-}"

[[ -z "${USERNAME}" ]] && { print_help; die "USERNAME is required."; }
[[ "${EUID}" -ne 0 ]] && die "Run as root (try: sudo bash $0 ...)."

#####################################
# Detect OS and proper sudo group   #
#####################################
SUDO_GROUP="sudo"  # default
OS_FAMILY="unknown"
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  case "${ID_LIKE:-$ID}" in
    *debian*|*ubuntu*) OS_FAMILY="debian"; SUDO_GROUP="sudo" ;;
    *rhel*|*fedora*|*centos*|*almalinux*|*rocky*) OS_FAMILY="rhel"; SUDO_GROUP="wheel" ;;
    *alpine*) OS_FAMILY="alpine"; SUDO_GROUP="wheel" ;;
    *) OS_FAMILY="${ID:-unknown}" ;;
  case_esac_fix:
  esac
else
  warn "/etc/os-release not found; assuming Debian-like."
  OS_FAMILY="debian"; SUDO_GROUP="sudo"
fi
# If the chosen group doesn't exist but the other common one does, switch.
if ! getent group "${SUDO_GROUP}" >/dev/null 2>&1; then
  if getent group wheel >/dev/null 2>&1; then SUDO_GROUP="wheel"
  elif getent group sudo  >/dev/null 2>&1; then SUDO_GROUP="sudo"
  else
    warn "Neither 'sudo' nor 'wheel' exist; creating '${SUDO_GROUP}'."
    groupadd -f "${SUDO_GROUP}"
  fi
fi
info "OS: ${BOLD}${OS_FAMILY}${RESET} | sudo group: ${BOLD}${SUDO_GROUP}${RESET}"

#################################
# Ensure sudo/visudo available  #
#################################
ensure_pkg() {
  local bin="$1" pkg="$2"
  if ! command -v "$bin" >/dev/null 2>&1; then
    warn "Missing '${bin}'. Attempting install..."
    case "${OS_FAMILY}" in
      debian)
        apt-get update -y
        apt-get install -y "${pkg}"
        ;;
      rhel)
        if command -v dnf >/dev/null 2>&1; then dnf install -y "${pkg}"; else yum install -y "${pkg}"; fi
        ;;
      alpine)
        apk add --no-cache "${pkg}"
        ;;
      *)
        die "Unknown OS family '${OS_FAMILY}'. Install '${pkg}' manually and re-run."
        ;;
    esac
  fi
}
ensure_pkg sudo sudo
ensure_pkg visudo sudo   # visudo comes with sudo

#########################################
# Read/validate SSH public key content  #
#########################################
read_stdin_if_piped() {
  if [[ ! -t 0 ]]; then cat -; fi
}

PUBKEY_CONTENT=""
if [[ -n "${PUBKEY_ARG:-}" && "${PUBKEY_ARG}" != "-" ]]; then
  PUBKEY_CONTENT="${PUBKEY_ARG}"
elif [[ "${PUBKEY_ARG:-}" == "-" ]]; then
  PUBKEY_CONTENT="$(read_stdin_if_piped || true)"
fi
if [[ -z "${PUBKEY_CONTENT}" && -n "${PUBKEY_FILE}" ]]; then
  [[ -f "${PUBKEY_FILE}" ]] || die "File not found: ${PUBKEY_FILE}"
  PUBKEY_CONTENT="$(<"${PUBKEY_FILE}")"
fi
if [[ -z "${PUBKEY_CONTENT}" ]]; then
  # Last attempt: if piped but user forgot "-"
  if [[ ! -t 0 ]]; then PUBKEY_CONTENT="$(cat -)"; fi
fi
[[ -z "${PUBKEY_CONTENT}" ]] && { print_help; die "No SSH public key provided (arg, file, or stdin)."; }

# Basic sanity check (allow but warn if unusual)
if ! grep -E -q '^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp(256|384|521)) ' <<<"${PUBKEY_CONTENT}"; then
  warn "SSH key format not recognized; proceeding anyway."
fi

##########################
# Confirmation prompt    #
##########################
if [[ "${ASSUME_YES}" != "true" ]]; then
  printf "\n%s\n" "${BOLD}About to:${RESET}
  - Ensure user: ${BOLD}${USERNAME}${RESET}
  - Set shell:   ${BOLD}${PREFERRED_SHELL}${RESET}
  - Add to:      ${BOLD}${SUDO_GROUP}${RESET}
  - Install key: ${BOLD}/home/${USERNAME}/.ssh/authorized_keys${RESET}
  - Passwordless sudo via: ${BOLD}/etc/sudoers.d/90-${USERNAME}-nopasswd${RESET}"
  read -r -p "Proceed? [y/N]: " reply || true
  case "${reply:-}" in y|Y|yes|YES) ;; *) die "Aborted."; esac
fi

##########################
# Create/update user     #
##########################
create_user_if_needed() {
  if id -u "${USERNAME}" >/dev/null 2>&1; then
    ok "User '${USERNAME}' already exists."
    return
  fi
  info "Creating user '${USERNAME}'..."
  case "${OS_FAMILY}" in
    debian) adduser --disabled-password --gecos "" --shell "${PREFERRED_SHELL}" "${USERNAME}" ;;
    rhel)   useradd -m -s "${PREFERRED_SHELL}" "${USERNAME}" ;;
    alpine) adduser -D -s "${PREFERRED_SHELL}" "${USERNAME}" ;;
    *)      useradd -m -s "${PREFERRED_SHELL}" "${USERNAME}" ;;
  esac
  ok "Created user '${USERNAME}'."
}
create_user_if_needed

# Ensure home and shell
USER_HOME="$(getent passwd "${USERNAME}" | cut -d: -f6)"
[[ -d "${USER_HOME}" ]] || { warn "Home dir missing at ${USER_HOME}; creating."; mkdir -p "${USER_HOME}"; chown "${USERNAME}:${USERNAME}" "${USER_HOME}"; }
# Set shell (warn if not in /etc/shells)
if ! grep -qxF "${PREFERRED_SHELL}" /etc/shells 2>/dev/null; then
  warn "Shell ${PREFERRED_SHELL} not in /etc/shells; chsh may fail."
fi
chsh -s "${PREFERRED_SHELL}" "${USERNAME}" || warn "Could not set shell to ${PREFERRED_SHELL} (may already be set)."

# Ensure sudo/wheel membership
if id -nG "${USERNAME}" | tr ' ' '\n' | grep -qx "${SUDO_GROUP}"; then
  ok "User '${USERNAME}' already in '${SUDO_GROUP}'."
else
  usermod -aG "${SUDO_GROUP}" "${USERNAME}"
  ok "Added '${USERNAME}' to '${SUDO_GROUP}'."
fi

##########################
# SSH authorized_keys    #
##########################
SSH_DIR="${USER_HOME}/.ssh"
AUTH_KEYS="${SSH_DIR}/authorized_keys"
install -d -m 0700 -o "${USERNAME}" -g "${USERNAME}" "${SSH_DIR}"
touch "${AUTH_KEYS}"
chmod 0600 "${AUTH_KEYS}"
chown "${USERNAME}:${USERNAME}" "${AUTH_KEYS}"

if grep -Fqx "${PUBKEY_CONTENT}" "${AUTH_KEYS}" 2>/dev/null; then
  ok "SSH key already present in authorized_keys."
else
  printf "%s\n" "${PUBKEY_CONTENT}" >> "${AUTH_KEYS}"
  ok "Appended SSH key to ${AUTH_KEYS}."
fi

##########################
# Passwordless sudo      #
##########################
SUDOERS_FILE="/etc/sudoers.d/90-${USERNAME}-nopasswd"
TMP_SUDOERS="$(mktemp)"
cat > "${TMP_SUDOERS}" <<EOF
# Managed by make_admin.sh
${USERNAME} ALL=(ALL) NOPASSWD:ALL
Defaults:${USERNAME} !requiretty
EOF

if visudo -c -f "${TMP_SUDOERS}" >/dev/null; then
  install -m 0440 "${TMP_SUDOERS}" "${SUDOERS_FILE}"
  ok "Installed NOPASSWD sudo rule at ${SUDOERS_FILE}."
else
  rm -f "${TMP_SUDOERS}"
  die "visudo validation failed; not installing sudoers file."
fi
rm -f "${TMP_SUDOERS}"

##########################
# Final summary          #
##########################
printf "\n%s\n" "${GREEN}[DONE]${RESET}  ${BOLD}Summary:${RESET}
  User:               ${USERNAME}
  Home:               ${USER_HOME}
  Shell:              ${PREFERRED_SHELL}
  Admin group:        ${SUDO_GROUP}
  Authorized keys:    ${AUTH_KEYS}
  Sudoers (NOPASSWD): ${SUDOERS_FILE}
"