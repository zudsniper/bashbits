#!/bin/bash
# v2.0.0
# simple ass print script for pdf files & gdocs links
# ================================
# 
# v2.0.0 
# fixing this dogshit script AGAIN
# - its not matching gdocs links correctly, fixing that
#
# v1.2.0
# troubleshooting & also it handles google docs kinda now (must be publicly accessible) 
#
# v1.1.0
# (should) handle google docs links as argument
# 
# v1.0.0
# script works
#
# ===============================
# SOME INFO
# view print queue
#     lpstat -R
#
# clear print queue
#     lprm -
# 
# DANGER | administate printer or something
#     sudo lpadmin --help
#
# NOTE
# only difference between lp and lpr commands are the fact that lpr will read from stdin if given no filepath input

# helper function to regex detect if something is a gdocs link better than previously
function is_google_drive_link() {
    local link="$1"

    # Regular expression for matching Google Drive, Docs, Sheets, or Slides links
    # This version accounts for extra query parameters and possible variations in the URL
    local regex='(https://drive\.google\.com/(drive/folders/|file/d/|open\?id=)[a-zA-Z0-9_-]+([?&][a-zA-Z0-9_=-]*)?)|(https://docs\.google\.com/(document/d/|spreadsheets/d/|presentation/d/)[a-zA-Z0-9_-]+([?&][a-zA-Z0-9_=-]*)?)'

    if [[ $link =~ $regex ]]; then
        return 0 # True
    else
        return 1 # False
    fi
}
# ------------------------------ # 

PRINTER_NAME="Canon-MF3010"

if [[ "$#" -eq 0 ]]; then
	echo -e "${A_RED}Please provide a PDF document as an argument${A_RESET}"
	exit 1
fi

export PRINT_PDF="$1"

if is_google_drive_link "${PRINT_PDF}"; then
	echo -e "${A_YELLOW}Detected Google Docs URL, downloading with gdown...${A_RESET}"
	echo -e "${A_BOLD}URL${A_RESET}: $1"
	gdown --format pdf -O "print.temp.pdf" "${PRINT_PDF}"
	export PRINT_PDF="print.temp.pdf"
fi	

echo -e "Trying to print ${A_BOLD}${PRINT_PDF}${A_RESET}... \n"

lpr -P "${PRINTER_NAME}" "${PRINT_PDF}"

echo -e "${A_GREEN}${A_BOLD}${PRINT_PDF}${A_RESET}${A_GREEN} print started!${A_RESET}"

