#!/bin/bash
# beautify_dir.sh
# ---------------
# by @zudsniper on github 
# not really, its by chatGPT but i guess i get the credit
# DEPENDENCIES
# - js-beautify: does all the heavy-lifting
#
# TODO
# - add js-unuglifier for variable renaming 
#   https://www.npmjs.com/package/unuglify-js
# ---------------

usage() {
  echo -e "${A_LCYAN}USAGE:${A_RESET} $0 [source_directory] -o [output_directory] [-- js-beautify options] [-h]"
  echo ""
  echo "${A_LCYAN}Recursively beautify JavaScript, CSS, and HTML files in source_directory and copy all files to output_directory.${A_RESET}"
  echo ""
  echo "${A_LCYAN}OPTIONS:${A_RESET}"
  echo "  ${A_YELLOW}-o, --output${A_RESET}  ${A_LIGHTGRAY}Output directory${A_RESET}"
  echo "  ${A_YELLOW}--${A_RESET}            ${A_LIGHTGRAY}Pass arguments directly to js-beautify${A_RESET}"
  echo "  ${A_YELLOW}-h, --help${A_RESET}    ${A_LIGHTGRAY}Show this help message${A_RESET}"
  exit 1
}

# Check if .ansi_colors.sh exists, and if not, download it from Github
if [ ! -f "$HOME/.ansi_colors.sh" ]; then
  echo "${A_LIGHTGREY}Downloading ${A_BOLD}.ansi_colors.sh${A_RESET}${A_LIGHTGRAY}...${A_RESET}"
  curl -sSf "https://gist.githubusercontent.com/zudsniper/e5bbdb7d3384a2b5f76277b52d103e59/raw/.ansi_colors.sh" > "$HOME/.ansi_colors.sh"
fi

# Load ANSI color variables
. "$HOME/.ansi_colors.sh"

# Check if js-beautify is installed
if ! command -v js-beautify &> /dev/null; then
  echo -e "${A_LRED}js-beautify not found.${A_RESET} ${A_YELLOW}Installing...${A_RESET}"
  npm i js-beautify -g
  echo -ne "${A_GREEN}${A_BOLD}Done.${A_RESET}\n"
fi

usage() {
  echo -e "${A_LCYAN}USAGE:${A_RESET} $0 [source_directory] -o [output_directory] [-- js-beautify options] [-h]"
  echo ""
  echo "${A_LCYAN}Recursively beautify JavaScript, CSS, and HTML files in source_directory and copy all files to output_directory.${A_RESET}"
  echo ""
  echo "${A_LCYAN}OPTIONS:${A_RESET}"
  echo "  ${A_YELLOW}-o, --output${A_RESET}  ${A_LIGHTGRAY}Output directory${A_RESET}"
  echo "  ${A_YELLOW}--${A_RESET}            ${A_LIGHTGRAY}Pass arguments directly to js-beautify${A_RESET}"
  echo "  ${A_YELLOW}-h, --help${A_RESET}    ${A_LIGHTGRAY}Show this help message${A_RESET}"
  exit 1
}

# Parse command line arguments
jsbeautify_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUTPUT_DIR=$(echo "$2" | sed 's:/*$::') # Remove trailing slashes
      shift 2;;
    --)
      jsbeautify_args+=("${@:2}")
      break;;
    -h|--help)
      usage;;
    *)
      SOURCE_DIR=$(echo "$1" | sed 's:/*$::') # Remove trailing slashes
      shift;;
  esac
done

# Check if source and output directories were specified
if [ -z "$SOURCE_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  usage
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Recursively copy files and beautify JavaScript, CSS, and HTML files
beautify_files() {
  for file in "$1"/*; do
    if [ -f "$file" ]; then
      if [[ "$file" == *.js || "$file" == *.jsx || "$file" == *.css || "$file" == *.html ]]; then
        echo -e "${A_LGREEN}Beautifying $file...${A_RESET}"
        js-beautify "${jsbeautify_args[@]}" -f "$file" -o "$OUTPUT_DIR/$(basename "$file")"
      else
        echo -e "${A_LIGHTGRAY}Copying $file...${A_RESET}"
        cp "$file" "$OUTPUT_DIR/$(basename "$file")"
      fi
    elif [ -d "$file" ]; then
      beautify_files "$file"
    fi
  done
}

beautify_files "$SOURCE_DIR"
