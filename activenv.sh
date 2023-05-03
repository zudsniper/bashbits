#!/bin/bash
# activenv.sh
# -----------
# 
# initialize and active the python virtual environment specified as a parameter. Default value is "env". 
# 
# TODO: Check for python installation
#       Add CLI flag to specify necessary python version (--needs-python-version|-V)
#       Add --help|-h and --verbose|-v and --version CLI options
# 
# by @zudsniper

VENV="env"

echo -ne "${A_}${A_BOLD}[ACTIVENV]${A_RESET} Starting...\n";

if [[ $# -gt 0 ]]; then
	echo -ne "${A_LIGHTGRAY}${A_ITALIC}Setting virtualenv name to $1 ${A_RESET}\n";
	VENV="$1"
fi
	
python -m venv "${VENV}"
source "${CWD}${VENV}/bin/activate"

if [[ "$VIRTUAL_ENV" != "" ]]; then 
	INVENV=1
	echo -ne "${A_GREEN}${A_BOLD}Successfully entered venv: ${A_RESET}${VENV}\n"
else
	INVENV=0
	echo -ne "${A_RED}${A_BOLD}Failed to enter a venv: ${A_RESET}${VENV}\n";
fi

