# make_admin.sh

make_admin.sh is a portable Bash helper for quickly creating or updating a Linux user, installing their SSH public key, and granting passwordless sudo.

It’s designed to be safe, idempotent, and curl-friendly for bootstrapping new servers.

⸻

## Features
	•	Creates a user if missing, or updates if it exists
	•	Installs SSH public key (from arg, file, or stdin) into ~/.ssh/authorized_keys
	•	Grants passwordless sudo via /etc/sudoers.d/ (validated by visudo)
	•	Works on Debian/Ubuntu, RHEL/Fedora/CentOS, and Alpine
	•	Colored output for clarity
	•	Non-interactive mode (-y) for automation

⸻

## Usage

### Show help

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/zudsniper/bashbits/master/helpers/make_admin.sh) --help
```

### Create a user with inline SSH key (non-interactive)

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/zudsniper/bashbits/master/helpers/make_admin.sh) -y jason "ssh-ed25519 AAAAC3NzaC1... jason@laptop"
```

### Pipe key via stdin

```sh
cat ~/.ssh/id_ed25519.pub | bash <(curl -fsSL https://raw.githubusercontent.com/zudsniper/bashbits/master/helpers/make_admin.sh) -y jason -
```

### Read key from a file

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/zudsniper/bashbits/master/helpers/make_admin.sh) -y --pubkey-file ~/.ssh/id_ed25519.pub jason
```

⸻

Notes
	•	Must be run as root or via sudo.
	•	Adds user to the correct admin group (sudo on Debian/Ubuntu, wheel on RHEL/Alpine).
	•	Re-running is safe: duplicate keys won’t be added, and sudoers file will be validated.
	•	Default login shell is /bin/bash (override with --shell /bin/zsh).

