#!/bin/bash
# docker_merge.sh v2 by ChatGPT-4
# used to merge 2 or more docker images into a single new image via a multilayered Dockerfile being constructed then built.  
# !! new to v2 -- added new CLI options to avoid inputting origins array if input is simple enough to warrant doing so.
# ----------------------------- #
# Human: @zudsniper 
# i'm afraid

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is required but not installed. Please install Docker and try again."
    exit 1
fi

# Define colors for logs
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# ProgressBar function
function progress_bar {
    local width=40
    local percent=$1
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    printf "${GREEN}["
    for ((i = 0; i < filled; i++)); do printf "#"; done
    for ((i = 0; i < empty; i++)); do printf " "; done
    printf "]${NC} %3d%%\r" $percent
}

function usage {
    echo -e "Usage: $0 [-r] [-f] [-nc] [-ad|-al] -i <image_names> [-o <origins>] -n <output_name>"
    echo -e "\n    HINT - The FIRST image provided in both lists will be the OUTERMOST image, unless -r is used.\n"
    echo "  -r,  --reverse             Reverse the order of provided docker images"
    echo "  -f,  --file-only           Output a Dockerfile instead of exporting the image"
    echo "  -nc, --no-cache            Disable cache when building the image"
    echo "  -ad, --all-dockerhub       Treat all images as Docker Hub images"
    echo "  -al, --all-local           Treat all images as local images"
    echo "  -i,  --images <image_names> Comma-separated list of docker image names"
    echo "  -o,  --origins <origins>    Comma-separated list of origins (0 for local, 1 for Docker Hub, optional with -ad or -al)"
    echo "  -n,  --name <output_name>   Name of the output merged image"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

REVERSE=false
FILE_ONLY=false
NO_CACHE=false
ALL_DOCKERHUB=false
ALL_LOCAL=false
ORIGINS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--reverse)
            REVERSE=true
            shift
            ;;
        -f|--file-only)
            FILE_ONLY=true
            shift
            ;;
        -nc|--no-cache)
            NO_CACHE=true
            shift
            ;;
        -ad|--all-dockerhub)
            ALL_DOCKERHUB=true
            shift
            ;;
        -al|--all-local)
            ALL_LOCAL=true
            shift
            ;;
        -i|--images)
            IMAGES="$2"
            shift 2
            ;;
        -o|--origins)
            ORIGINS="$2"
            shift 2
            ;;
        -n|--name)
            OUTPUT_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$IMAGES" ] || [ -z "$OUTPUT_NAME" ]; then
    usage
fi

if [ "$ALL_DOCKERHUB" = true ] && [ "$ALL_LOCAL" = true ]; then
    echo -e "${RED}Error: You cannot use both --all-dockerhub and --all-local at the same time.${NC}"
    exit 1
fi

IFS=',' read -ra IMAGE_ARRAY <<< "$IMAGES"

if [ -z "$ORIGINS" ]; then
    if [ "$ALL_DOCKERHUB" = true ]; then
        ORIGINS=$(printf '1%.0s' $(seq 1 ${#IMAGE_ARRAY[@]}))
    elif [ "$ALL_LOCAL" = true ]; then
        ORIGINS=$(printf '0%.0s' $(seq 1 ${#IMAGE_ARRAY[@]}))
    else
        echo -e "${RED}Error: You must provide either --all-dockerhub, --all-local, or -o flag with origins.${NC}"
        exit 1
    fi
fi

IFS=',' read -ra ORIGIN_ARRAY <<< "$ORIGINS"

if [ ${#IMAGE_ARRAY[@]} -ne ${#ORIGIN_ARRAY[@]} ]; then
    echo -e "${RED}Error: The length of image_names and origins must be equal.${NC}"
    exit 1
fi

if [ "$REVERSE" = true ]; then
    IMAGE_ARRAY=("${IMAGE_ARRAY[@]}" | tac)
    ORIGIN_ARRAY=("${ORIGIN_ARRAY[@]}" | tac)
fi

DOCKERFILE="Dockerfile.$OUTPUT_NAME"

echo "FROM ${IMAGE_ARRAY[0]}" > $DOCKERFILE
for ((i = 1; i < ${#IMAGE_ARRAY[@]}; i++)); do
    if [ ${ORIGIN_ARRAY[$i]} -eq 1 ]; then
        docker pull "${IMAGE_ARRAY[$i]}"
    fi
    echo "COPY --from=${IMAGE_ARRAY[$i]} / /" >> $DOCKERFILE
    progress=$((100 * i / ${#IMAGE_ARRAY[@]}))
    progress_bar $progress
done
progress_bar 100
echo

BUILD_OPTIONS=""
if [ "$NO_CACHE" = true ]; then
    BUILD_OPTIONS="--no-cache"
fi

if [ "$FILE_ONLY" = true ]; then
    echo -e "${GREEN}Dockerfile generated:${NC} $DOCKERFILE"
else
    docker build $BUILD_OPTIONS -t "$OUTPUT_NAME" -f $DOCKERFILE .
    echo -e "${GREEN}Merged image created:${NC} $OUTPUT_NAME"
fi
